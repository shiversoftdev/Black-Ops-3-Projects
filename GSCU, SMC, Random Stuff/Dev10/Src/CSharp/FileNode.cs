/********************************************************************************************

Copyright (c) Microsoft Corporation 
All rights reserved. 

Microsoft Public License: 

This license governs use of the accompanying software. If you use the software, you 
accept this license. If you do not accept the license, do not use the software. 

1. Definitions 
The terms "reproduce," "reproduction," "derivative works," and "distribution" have the 
same meaning here as under U.S. copyright law. 
A "contribution" is the original software, or any additions or changes to the software. 
A "contributor" is any person that distributes its contribution under this license. 
"Licensed patents" are a contributor's patent claims that read directly on its contribution. 

2. Grant of Rights 
(A) Copyright Grant- Subject to the terms of this license, including the license conditions 
and limitations in section 3, each contributor grants you a non-exclusive, worldwide, 
royalty-free copyright license to reproduce its contribution, prepare derivative works of 
its contribution, and distribute its contribution or any derivative works that you create. 
(B) Patent Grant- Subject to the terms of this license, including the license conditions 
and limitations in section 3, each contributor grants you a non-exclusive, worldwide, 
royalty-free license under its licensed patents to make, have made, use, sell, offer for 
sale, import, and/or otherwise dispose of its contribution in the software or derivative 
works of the contribution in the software. 

3. Conditions and Limitations 
(A) No Trademark License- This license does not grant you rights to use any contributors' 
name, logo, or trademarks. 
(B) If you bring a patent claim against any contributor over patents that you claim are 
infringed by the software, your patent license from such contributor to the software ends 
automatically. 
(C) If you distribute any portion of the software, you must retain all copyright, patent, 
trademark, and attribution notices that are present in the software. 
(D) If you distribute any portion of the software in source code form, you may do so only 
under this license by including a complete copy of this license with your distribution. 
If you distribute any portion of the software in compiled or object code form, you may only 
do so under a license that complies with this license. 
(E) The software is licensed "as-is." You bear the risk of using it. The contributors give 
no express warranties, guarantees or conditions. You may have additional consumer rights 
under your local laws which this license cannot change. To the extent permitted under your 
local laws, the contributors exclude the implied warranties of merchantability, fitness for 
a particular purpose and non-infringement.

********************************************************************************************/

namespace Microsoft.VisualStudio.Project
{
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Diagnostics.CodeAnalysis;
    using System.Globalization;
    using System.IO;
    using System.Linq;
    using System.Runtime.InteropServices;
    using Microsoft.VisualStudio.Shell;
    using Microsoft.VisualStudio.Shell.Interop;
    using OLECMDEXECOPT = Microsoft.VisualStudio.OLE.Interop.OLECMDEXECOPT;
    using OleConstants = Microsoft.VisualStudio.OLE.Interop.Constants;
    using VsCommands = Microsoft.VisualStudio.VSConstants.VSStd97CmdID;
    using VsCommands2K = Microsoft.VisualStudio.VSConstants.VSStd2KCmdID;
    using vsCommandStatus = EnvDTE.vsCommandStatus;

    [CLSCompliant(false)]
    [ComVisible(true)]
    public class FileNode : HierarchyNode, IProjectSourceNode
    {
        #region static fiels
        // Build the dictionary with the mapping between some well known extensions
        // and the index of the icons inside the standard image list.
        protected static Dictionary<string, int> extensionIcons = new Dictionary<string, int>()
            {
                { ".aspx", (int)ImageName.WebForm },
                { ".asax", (int)ImageName.GlobalApplicationClass },
                { ".asmx", (int)ImageName.WebService },
                { ".ascx", (int)ImageName.WebUserControl },
                { ".asp", (int)ImageName.AspPage },
                { ".config", (int)ImageName.WebConfig },
                { ".htm", (int)ImageName.HtmlPage },
                { ".html", (int)ImageName.HtmlPage },
                { ".css", (int)ImageName.StyleSheet },
                { ".xsl", (int)ImageName.StyleSheet },
                { ".vbs", (int)ImageName.ScriptFile },
                { ".js", (int)ImageName.ScriptFile },
                { ".wsf", (int)ImageName.ScriptFile },
                { ".txt", (int)ImageName.TextFile },
                { ".resx", (int)ImageName.Resources },
                { ".rc", (int)ImageName.Resources },
                { ".bmp", (int)ImageName.Bitmap },
                { ".ico", (int)ImageName.Icon },
                { ".gif", (int)ImageName.Image },
                { ".jpg", (int)ImageName.Image },
                { ".png", (int)ImageName.Image },
                { ".map", (int)ImageName.ImageMap },
                { ".wav", (int)ImageName.Audio },
                { ".mid", (int)ImageName.Audio },
                { ".midi", (int)ImageName.Audio },
                { ".avi", (int)ImageName.Video },
                { ".mov", (int)ImageName.Video },
                { ".mpg", (int)ImageName.Video },
                { ".mpeg", (int)ImageName.Video },
                { ".cab", (int)ImageName.Cab },
                { ".jar", (int)ImageName.Jar },
                { ".xslt", (int)ImageName.XsltFile },
                { ".xsd", (int)ImageName.XmlSchema },
                { ".xml", (int)ImageName.XmlFile },
                { ".pfx", (int)ImageName.Pfx },
                { ".snk", (int)ImageName.Snk },
            };
        #endregion

        private bool isNonMemberItem;

        #region overriden Properties
        /// <summary>
        /// overwrites of the generic hierarchyitem.
        /// </summary>
        [System.ComponentModel.BrowsableAttribute(false)]
        public override string Caption
        {
            get
            {
                // Use LinkedIntoProjectAt property if available
                string caption = this.ItemNode.GetMetadata(ProjectFileConstants.LinkedIntoProjectAt);
                if(caption == null || caption.Length == 0)
                {
                    // Otherwise use filename
                    caption = this.ItemNode.GetMetadata(ProjectFileConstants.Include);
                    caption = Path.GetFileName(caption);
                }
                return caption;
            }
        }
        public override int ImageIndex
        {
            get
            {
                if (this.IsNonmemberItem)
                {
                    return (int)ImageName.ExcludedFile;
                }

                // Check if the file is there.
                if(!this.CanShowDefaultIcon())
                {
                    return (int)ImageName.MissingFile;
                }

                //Check for known extensions
                int imageIndex;
                string extension = System.IO.Path.GetExtension(this.FileName);
                if((string.IsNullOrEmpty(extension)) || (!extensionIcons.TryGetValue(extension, out imageIndex)))
                {
                    // Missing or unknown extension; let the base class handle this case.
                    return base.ImageIndex;
                }

                // The file type is known and there is an image for it in the image list.
                return imageIndex;
            }
        }

        public override Guid ItemTypeGuid
        {
            get { return VSConstants.GUID_ItemType_PhysicalFile; }
        }

        public override int MenuCommandId
        {
            get
            {
                if (this.IsNonmemberItem)
                {
                    return VsMenus.IDM_VS_CTXT_XPROJ_MULTIITEM;
                }

                return VsMenus.IDM_VS_CTXT_ITEMNODE;
            }
        }

        /// <summary>
        /// Specifies if a Node is under source control.
        /// </summary>
        /// <value>Specifies if a Node is under source control.</value>
        [SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "Scc")]
        public override bool ExcludeNodeFromScc
        {
            get
            {
                // Non member items do not participate in SCC.
                if (this.IsNonmemberItem)
                {
                    return true;
                }

                return base.ExcludeNodeFromScc;
            }

            set
            {
                base.ExcludeNodeFromScc = value;
            }
        }

        public override string Url
        {
            get
            {
                string path = this.ItemNode.GetMetadata(ProjectFileConstants.Include);
                if(String.IsNullOrEmpty(path))
                {
                    return String.Empty;
                }

                Url url;
                if(Path.IsPathRooted(path))
                {
                    // Use absolute path
                    url = new Microsoft.VisualStudio.Shell.Url(path);
                }
                else
                {
                    // Path is relative, so make it relative to project path
                    url = new Url(this.ProjectManager.BaseUri, path);
                }

                return url.AbsoluteUrl;
            }
        }

        public override bool CanCacheCanonicalName
        {
            get
            {
                return this.ProjectManager.CanCacheCanonicalName
                    && !string.IsNullOrEmpty(ItemNode.GetMetadata(ProjectFileConstants.Include));
            }
        }
        #endregion

        #region ctor
        /// <summary>
        /// Constructor for the FileNode
        /// </summary>
        /// <param name="root">Root of the hierarchy</param>
        /// <param name="element">Associated project element</param>
        public FileNode(ProjectNode root, ProjectElement element)
            : base(root, element)
        {
            if(this.ProjectManager.NodeHasDesigner(this.ItemNode.GetMetadata(ProjectFileConstants.Include)))
            {
                this.HasDesigner = true;
            }

            this.isNonMemberItem = ItemNode.IsVirtual;
        }
        #endregion

        // =========================================================================================
        // IProjectSourceNode Properties
        // =========================================================================================

        /// <summary>
        /// Flag that indicates if this node is not a member of the project.
        /// </summary>
        /// <value>true if the item is not a member of the project build, false otherwise.</value>
        public bool IsNonmemberItem
        {
            get
            {
                return this.isNonMemberItem;
            }

            set
            {
                if (this.isNonMemberItem == value)
                    return;

                this.isNonMemberItem = value;
                // Reset exclude from scc
                this.ExcludeNodeFromScc = this.ExcludeNodeFromScc;
            }
        }

        #region overridden methods
        protected override NodeProperties CreatePropertiesObject()
        {
            return new FileNodeProperties(this);
        }

        public override object GetIconHandle(bool open)
        {
            int index = this.ImageIndex;
            if(NoImage == index)
            {
                // There is no image for this file; let the base class handle this case.
                return base.GetIconHandle(open);
            }
            // Return the handle for the image.
            return this.ProjectManager.ImageHandler.GetIconHandle(index);
        }

        /// <summary>
        /// Get an instance of the automation object for a FileNode
        /// </summary>
        /// <returns>An instance of the Automation.OAFileNode if succeeded</returns>
        public override object GetAutomationObject()
        {
            if(this.ProjectManager == null || this.ProjectManager.IsClosed)
            {
                return null;
            }

            return new Automation.OAFileItem(this.ProjectManager.GetAutomationObject() as Automation.OAProject, this);
        }

        /// <summary>
        /// Renames a file node.
        /// </summary>
        /// <param name="label">The new name.</param>
        /// <returns>An errorcode for failure or S_OK.</returns>
        /// <exception cref="InvalidOperationException">if the file cannot be validated</exception>
        /// <devremark> 
        /// We are going to throw instaed of showing messageboxes, since this method is called from various places where a dialog box does not make sense.
        /// For example the FileNodeProperties are also calling this method. That should not show directly a messagebox.
        /// Also the automation methods are also calling SetEditLabel
        /// </devremark>

        public override int SetEditLabel(string label)
        {
            // IMPORTANT NOTE: This code will be called when a parent folder is renamed. As such, it is
            //                 expected that we can be called with a label which is the same as the current
            //                 label and this should not be considered a NO-OP.

            if(this.ProjectManager == null || this.ProjectManager.IsClosed)
            {
                return VSConstants.E_FAIL;
            }

            // Validate the filename. 
            if(String.IsNullOrEmpty(label))
            {
                throw new InvalidOperationException(SR.GetString(SR.ErrorInvalidFileName, CultureInfo.CurrentUICulture));
            }
            else if(label.Length > NativeMethods.MAX_PATH)
            {
                throw new InvalidOperationException(String.Format(CultureInfo.CurrentCulture, SR.GetString(SR.PathTooLong, CultureInfo.CurrentUICulture), label));
            }
            else if(Utilities.IsFileNameInvalid(label))
            {
                throw new InvalidOperationException(SR.GetString(SR.ErrorInvalidFileName, CultureInfo.CurrentUICulture));
            }

            for(HierarchyNode n = this.Parent.FirstChild; n != null; n = n.NextSibling)
            {
                if(n != this && String.Equals(n.Caption, label, StringComparison.OrdinalIgnoreCase))
                {
                    //A file or folder with the name '{0}' already exists on disk at this location. Please choose another name.
                    //If this file or folder does not appear in the Solution Explorer, then it is not currently part of your project. To view files which exist on disk, but are not in the project, select Show All Files from the Project menu.
                    throw new InvalidOperationException(String.Format(CultureInfo.CurrentCulture, SR.GetString(SR.FileOrFolderAlreadyExists, CultureInfo.CurrentUICulture), label));
                }
            }

            string fileName = Path.GetFileNameWithoutExtension(label);

            // If there is no filename or it starts with a leading dot issue an error message and quit.
            if(String.IsNullOrEmpty(fileName) || fileName[0] == '.')
            {
                throw new InvalidOperationException(SR.GetString(SR.FileNameCannotContainALeadingPeriod, CultureInfo.CurrentUICulture));
            }

            // Verify that the file extension is unchanged
            string strRelPath = Path.GetFileName(this.ItemNode.GetMetadata(ProjectFileConstants.Include));
            if(!String.Equals(Path.GetExtension(strRelPath), Path.GetExtension(label), StringComparison.OrdinalIgnoreCase))
            {
                // Prompt to confirm that they really want to change the extension of the file
                string message = SR.GetString(SR.ConfirmExtensionChange, CultureInfo.CurrentUICulture, new string[] { label });
                IVsUIShell shell = this.ProjectManager.Site.GetService(typeof(SVsUIShell)) as IVsUIShell;

                Debug.Assert(shell != null, "Could not get the ui shell from the project");
                if(shell == null)
                {
                    return VSConstants.E_FAIL;
                }

                if(!VsShellUtilities.PromptYesNo(message, null, OLEMSGICON.OLEMSGICON_INFO, shell))
                {
                    // The user cancelled the confirmation for changing the extension.
                    // Return S_OK in order not to show any extra dialog box
                    return VSConstants.S_OK;
                }
            }


            // Build the relative path by looking at folder names above us as one scenarios
            // where we get called is when a folder above us gets renamed (in which case our path is invalid)
            HierarchyNode parent = this.Parent;
            while(parent != null && (parent is FolderNode))
            {
                strRelPath = Path.Combine(parent.Caption, strRelPath);
                parent = parent.Parent;
            }

            return SetEditLabel(label, strRelPath);
        }

        public override string GetMKDocument()
        {
            Debug.Assert(this.Url != null, "No url sepcified for this node");

            return this.Url;
        }

        /// <summary>
        /// Delete the item corresponding to the specified path from storage.
        /// </summary>
        /// <param name="path"></param>
        public override void DeleteFromStorage(string path)
        {
            if(File.Exists(path))
            {
                File.SetAttributes(path, FileAttributes.Normal); // make sure it's not readonly.
                File.Delete(path);
            }
        }

        /// <summary>
        /// Rename the underlying document based on the change the user just made to the edit label.
        /// </summary>
        public override int SetEditLabel(string label, string relativePath)
        {
            int returnValue = VSConstants.S_OK;
            uint oldId = this.Id;
            string strSavePath = Path.GetDirectoryName(relativePath);

            if(!Path.IsPathRooted(relativePath))
            {
                strSavePath = Path.Combine(Path.GetDirectoryName(this.ProjectManager.BaseUri.Uri.LocalPath), strSavePath);
            }

            string newName = Path.Combine(strSavePath, label);

            if(NativeMethods.IsSamePath(newName, this.Url))
            {
                // If this is really a no-op, then nothing to do
                if(String.Equals(newName, this.Url, StringComparison.Ordinal))
                    return VSConstants.S_FALSE;
            }
            else
            {
                // If the renamed file already exists then quit (unless it is the result of the parent having done the move).
                if(IsFileOnDisk(newName)
                    && (IsFileOnDisk(this.Url)
                    || !String.Equals(Path.GetFileName(newName), Path.GetFileName(this.Url), StringComparison.Ordinal)))
                {
                    throw new InvalidOperationException(String.Format(CultureInfo.CurrentCulture, SR.GetString(SR.FileCannotBeRenamedToAnExistingFile, CultureInfo.CurrentUICulture), label));
                }
                else if(newName.Length > NativeMethods.MAX_PATH)
                {
                    throw new InvalidOperationException(String.Format(CultureInfo.CurrentCulture, SR.GetString(SR.PathTooLong, CultureInfo.CurrentUICulture), label));
                }

            }

            string oldName = this.Url;
            // must update the caption prior to calling RenameDocument, since it may
            // cause queries of that property (such as from open editors).
            string oldrelPath = this.ItemNode.GetMetadata(ProjectFileConstants.Include);

            try
            {
                if(!RenameDocument(oldName, newName))
                {
                    this.ItemNode.Rename(oldrelPath);
                    this.ItemNode.RefreshProperties();
                    ProjectManager.ItemIdMap.UpdateCanonicalName(this);
                }

                if(this is DependentFileNode)
                {
                    OnInvalidateItems(this.Parent);
                }

            }
            catch(Exception e)
            {
                // Just re-throw the exception so we don't get duplicate message boxes.
                Trace.WriteLine("Exception : " + e.Message);
                this.RecoverFromRenameFailure(newName, oldrelPath);
                returnValue = Marshal.GetHRForException(e);
                throw;
            }
            // Return S_FALSE if the hierarchy item id has changed.  This forces VS to flush the stale
            // hierarchy item id.
            if(returnValue == (int)VSConstants.S_OK || returnValue == (int)VSConstants.S_FALSE || returnValue == VSConstants.OLE_E_PROMPTSAVECANCELLED)
            {
                return (oldId == this.Id) ? VSConstants.S_OK : (int)VSConstants.S_FALSE;
            }

            return returnValue;
        }

        /// <summary>
        /// Returns a specific Document manager to handle files
        /// </summary>
        /// <returns>Document manager object</returns>
        public override DocumentManager GetDocumentManager()
        {
            return new FileDocumentManager(this);
        }

        /// <summary>
        /// Called by the drag&amp;drop implementation to ask the node
        /// which is being dragged/droped over which nodes should
        /// process the operation.
        /// This allows for dragging to a node that cannot contain
        /// items to let its parent accept the drop, while a reference
        /// node delegate to the project and a folder/project node to itself.
        /// </summary>
        /// <returns></returns>
        public override HierarchyNode GetDragTargetHandlerNode()
        {
            Debug.Assert(this.ProjectManager != null, " The project manager is null for the filenode");
            HierarchyNode handlerNode = this;
            while(handlerNode != null && !(handlerNode is ProjectNode || handlerNode is FolderNode))
                handlerNode = handlerNode.Parent;
            if(handlerNode == null)
                handlerNode = this.ProjectManager;
            return handlerNode;
        }

        protected override int ExecCommandOnNode(Guid cmdGroup, uint cmd, OLECMDEXECOPT nCmdexecopt, IntPtr pvaIn, IntPtr pvaOut)
        {
            if(this.ProjectManager == null || this.ProjectManager.IsClosed)
            {
                return (int)OleConstants.OLECMDERR_E_NOTSUPPORTED;
            }

            // Exec on special filenode commands
            if(cmdGroup == VsMenus.guidStandardCommandSet97)
            {
                IVsWindowFrame windowFrame = null;

                switch((VsCommands)cmd)
                {
                    case VsCommands.ViewCode:
                        return ((FileDocumentManager)this.GetDocumentManager()).Open(false, false, VSConstants.LOGVIEWID_Code, out windowFrame, WindowFrameShowAction.Show);

                    case VsCommands.ViewForm:
                        return ((FileDocumentManager)this.GetDocumentManager()).Open(false, false, VSConstants.LOGVIEWID_Designer, out windowFrame, WindowFrameShowAction.Show);

                    case VsCommands.Open:
                        return ((FileDocumentManager)this.GetDocumentManager()).Open(false, false, WindowFrameShowAction.Show);

                    case VsCommands.OpenWith:
                        return ((FileDocumentManager)this.GetDocumentManager()).Open(false, true, VSConstants.LOGVIEWID_UserChooseView, out windowFrame, WindowFrameShowAction.Show);
                }
            }

            // Exec on special filenode commands
            if(cmdGroup == VsMenus.guidStandardCommandSet2K)
            {
                switch((VsCommands2K)cmd)
                {
                    case VsCommands2K.INCLUDEINPROJECT:
                        return ((IProjectSourceNode)this).IncludeInProject();

                    case VsCommands2K.EXCLUDEFROMPROJECT:
                        return ((IProjectSourceNode)this).ExcludeFromProject();

                    case VsCommands2K.RUNCUSTOMTOOL:
                        {
                            try
                            {
                                this.RunGenerator();
                                return VSConstants.S_OK;
                            }
                            catch(Exception e)
                            {
                                Trace.WriteLine("Running Custom Tool failed : " + e.Message);
                                throw;
                            }
                        }
                }
            }

            return base.ExecCommandOnNode(cmdGroup, cmd, nCmdexecopt, pvaIn, pvaOut);
        }


        protected override int QueryStatusOnNode(Guid cmdGroup, uint cmd, IntPtr pCmdText, ref vsCommandStatus result)
        {
            if(cmdGroup == VsMenus.guidStandardCommandSet97)
            {
                switch((VsCommands)cmd)
                {
                    case VsCommands.Copy:
                    case VsCommands.Paste:
                    case VsCommands.Cut:
                    case VsCommands.Rename:
                        string linkPath = this.ItemNode.GetMetadata(ProjectFileConstants.Link);
                        if (string.IsNullOrEmpty(linkPath))
                        {
                            result |= vsCommandStatus.vsCommandStatusSupported | vsCommandStatus.vsCommandStatusEnabled;
                            return VSConstants.S_OK;
                        }
                        else
                        {
                            // disable these commands on linked items
                            result = vsCommandStatus.vsCommandStatusUnsupported;
                            return VSConstants.S_OK;
                        }

                    case VsCommands.ViewCode:
                        if (this.IsNonmemberItem)
                            result = vsCommandStatus.vsCommandStatusUnsupported;
                        else
                            result |= vsCommandStatus.vsCommandStatusSupported | vsCommandStatus.vsCommandStatusEnabled;

                        return VSConstants.S_OK;

                    //case VsCommands.Delete: goto case VsCommands.OpenWith;
                    case VsCommands.Open:
                    case VsCommands.OpenWith:
                        result |= vsCommandStatus.vsCommandStatusSupported | vsCommandStatus.vsCommandStatusEnabled;
                        return VSConstants.S_OK;
                }
            }
            else if(cmdGroup == VsMenus.guidStandardCommandSet2K)
            {
                if ((VsCommands2K)cmd == VsCommands2K.INCLUDEINPROJECT)
                {
                    // if it is a non member item node, the we support "Include In Project" command
                    if (IsNonmemberItem)
                    {
                        result |= vsCommandStatus.vsCommandStatusSupported | vsCommandStatus.vsCommandStatusEnabled;
                        return VSConstants.S_OK;
                    }
                }
                else if((VsCommands2K)cmd == VsCommands2K.EXCLUDEFROMPROJECT)
                {
                    // if it is a non member item node, then we don't support "Exclude From Project" command
                    if (IsNonmemberItem)
                    {
                        result = vsCommandStatus.vsCommandStatusUnsupported;
                        return VSConstants.S_OK;
                    }

                    string linkPath = this.ItemNode.GetMetadata(ProjectFileConstants.Link);
                    if (string.IsNullOrEmpty(linkPath))
                    {
                        result |= vsCommandStatus.vsCommandStatusSupported | vsCommandStatus.vsCommandStatusEnabled;
                        return VSConstants.S_OK;
                    }
                    else
                    {
                        result = vsCommandStatus.vsCommandStatusUnsupported;
                        return VSConstants.S_OK;
                    }
                }
                if((VsCommands2K)cmd == VsCommands2K.RUNCUSTOMTOOL)
                {
                    if(string.IsNullOrEmpty(this.ItemNode.GetMetadata(ProjectFileConstants.DependentUpon)))
                    {
                        IEnumerable<string> extenderNames = this.NodeProperties.ExtenderNames() as IEnumerable<string>;
                        if (extenderNames != null && extenderNames.Contains(SingleFileGeneratorNodeExtenderProvider.Name)
                            && this.NodeProperties.Extender(SingleFileGeneratorNodeExtenderProvider.Name) != null)
                        {
                            result |= vsCommandStatus.vsCommandStatusSupported | vsCommandStatus.vsCommandStatusEnabled;
                            return VSConstants.S_OK;
                        }
                    }
                }
            }
            else
            {
                return (int)OleConstants.OLECMDERR_E_UNKNOWNGROUP;
            }
            return base.QueryStatusOnNode(cmdGroup, cmd, pCmdText, ref result);
        }


        protected override void DoDefaultAction()
        {
            CciTracing.TraceCall();
            FileDocumentManager manager = this.GetDocumentManager() as FileDocumentManager;
            Debug.Assert(manager != null, "Could not get the FileDocumentManager");
            manager.Open(false, false, WindowFrameShowAction.Show);
        }

        /// <summary>
        /// Performs a SaveAs operation of an open document. Called from SaveItem after the running document table has been updated with the new doc data.
        /// </summary>
        /// <param name="docData">A pointer to the document in the rdt</param>
        /// <param name="newFilePath">The new file path to the document</param>
        /// <returns></returns>
        protected override int AfterSaveItemAs(IntPtr docData, string newFilePath)
        {
            if(String.IsNullOrEmpty(newFilePath))
            {
                throw new ArgumentException(SR.GetString(SR.ParameterCannotBeNullOrEmpty, CultureInfo.CurrentUICulture), "newFilePath");
            }

            int returnCode = VSConstants.S_OK;
            newFilePath = newFilePath.Trim();

            //Identify if Path or FileName are the same for old and new file
            string newDirectoryName = Path.GetDirectoryName(newFilePath);
            Uri newDirectoryUri = new Uri(newDirectoryName);
            string newCanonicalDirectoryName = newDirectoryUri.LocalPath;
            newCanonicalDirectoryName = newCanonicalDirectoryName.TrimEnd(Path.DirectorySeparatorChar);
            string oldCanonicalDirectoryName = new Uri(Path.GetDirectoryName(this.GetMKDocument())).LocalPath;
            oldCanonicalDirectoryName = oldCanonicalDirectoryName.TrimEnd(Path.DirectorySeparatorChar);
            string errorMessage = String.Empty;
            bool isSamePath = NativeMethods.IsSamePath(newCanonicalDirectoryName, oldCanonicalDirectoryName);
            bool isSameFile = NativeMethods.IsSamePath(newFilePath, this.Url);

			string linkPath = null;
            string projectCannonicalDirecoryName = new Uri(this.ProjectManager.ProjectFolder).LocalPath;
            projectCannonicalDirecoryName = projectCannonicalDirecoryName.TrimEnd(Path.DirectorySeparatorChar);
            if(!isSamePath && newCanonicalDirectoryName.IndexOf(projectCannonicalDirecoryName, StringComparison.OrdinalIgnoreCase) == -1)
            {
                // Link the new file into the same location in the project hierarchy it was before.
                string oldRelPath = this.ItemNode.GetMetadata(ProjectFileConstants.Link);
                if (String.IsNullOrEmpty(oldRelPath))
                {
                    oldRelPath = this.ItemNode.GetMetadata(ProjectFileConstants.Include);
                }

                newDirectoryName = Path.GetDirectoryName(oldRelPath);
                linkPath = Path.Combine(newDirectoryName, Path.GetFileName(newFilePath));
            }

            //Get target container
            HierarchyNode targetContainer = null;
            if(isSamePath)
            {
                targetContainer = this.Parent;
            }
            else if(NativeMethods.IsSamePath(newCanonicalDirectoryName, projectCannonicalDirecoryName))
            {
                //the projectnode is the target container
                targetContainer = this.ProjectManager;
            }
            else
            {
                //search for the target container among existing child nodes
                targetContainer = this.ProjectManager.FindChild(newDirectoryName);
                if(targetContainer != null && (targetContainer is FileNode))
                {
                    // We already have a file node with this name in the hierarchy.
                    errorMessage = String.Format(CultureInfo.CurrentCulture, SR.GetString(SR.FileAlreadyExistsAndCannotBeRenamed, CultureInfo.CurrentUICulture), Path.GetFileNameWithoutExtension(newFilePath));
                    throw new InvalidOperationException(errorMessage);
                }
            }

            if(targetContainer == null)
            {
                // Add a chain of subdirectories to the project.
                string relativeUri = PackageUtilities.GetPathDistance(this.ProjectManager.BaseUri.Uri, newDirectoryUri);
                Debug.Assert(!String.IsNullOrEmpty(relativeUri) && relativeUri != newDirectoryUri.LocalPath, "Could not make pat distance of " + this.ProjectManager.BaseUri.Uri.LocalPath + " and " + newDirectoryUri);
                targetContainer = this.ProjectManager.CreateFolderNodes(relativeUri);
            }
            Debug.Assert(targetContainer != null, "We should have found a target node by now");

            //Suspend file changes while we rename the document
            string oldrelPath = this.ItemNode.GetMetadata(ProjectFileConstants.Include);
            string oldName = Path.Combine(this.ProjectManager.ProjectFolder, oldrelPath);
            SuspendFileChanges sfc = new SuspendFileChanges(this.ProjectManager.Site, oldName);
            sfc.Suspend();

            try
            {
                // Rename the node.	
                DocumentManager.UpdateCaption(this.ProjectManager.Site, Path.GetFileName(newFilePath), docData);
                // Check if the file name was actually changed.
                // In same cases (e.g. if the item is a file and the user has changed its encoding) this function
                // is called even if there is no real rename.
                if(!isSameFile || (this.Parent.Id != targetContainer.Id))
                {
                    // The path of the file is changed or its parent is changed; in both cases we have
                    // to rename the item.
                    this.RenameFileNode(oldName, newFilePath, linkPath, targetContainer);
                    this.ItemNode.SetMetadata(ProjectFileConstants.Link, linkPath);
                    OnInvalidateItems(this.Parent);
                }
            }
            catch(Exception e)
            {
                Trace.WriteLine("Exception : " + e.Message);
                this.RecoverFromRenameFailure(newFilePath, oldrelPath);
                throw;
            }
            finally
            {
                sfc.Resume();
            }

            return returnCode;
        }

        /// <summary>
        /// Determines if this is node a valid node for painting the default file icon.
        /// </summary>
        /// <returns></returns>
        protected override bool CanShowDefaultIcon()
        {
            string moniker = this.GetMKDocument();

            if(String.IsNullOrEmpty(moniker) || !File.Exists(moniker))
            {
                return false;
            }

            return true;
        }

        #endregion

        #region virtual methods
        public virtual string FileName
        {
            get
            {
                return this.Caption;
            }
            set
            {
                this.SetEditLabel(value);
            }
        }

        /// <summary>
        /// Determine if this item is represented physical on disk and shows a messagebox in case that the file is not present and a UI is to be presented.
        /// </summary>
        /// <param name="showMessage">true if user should be presented for UI in case the file is not present</param>
        /// <returns>true if file is on disk</returns>
        public virtual bool IsFileOnDisk(bool showMessage)
        {
            bool fileExist = IsFileOnDisk(this.Url);

            if(!fileExist && showMessage && !Utilities.IsInAutomationFunction(this.ProjectManager.Site))
            {
                string message = String.Format(CultureInfo.CurrentCulture, SR.GetString(SR.ItemDoesNotExistInProjectDirectory, CultureInfo.CurrentUICulture), this.Caption);
                string title = string.Empty;
                OLEMSGICON icon = OLEMSGICON.OLEMSGICON_CRITICAL;
                OLEMSGBUTTON buttons = OLEMSGBUTTON.OLEMSGBUTTON_OK;
                OLEMSGDEFBUTTON defaultButton = OLEMSGDEFBUTTON.OLEMSGDEFBUTTON_FIRST;
                VsShellUtilities.ShowMessageBox(this.ProjectManager.Site, title, message, icon, buttons, defaultButton);
            }

            return fileExist;
        }

        /// <summary>
        /// Determine if the file represented by "path" exist in storage.
        /// Override this method if your files are not persisted on disk.
        /// </summary>
        /// <param name="path">Url representing the file</param>
        /// <returns>True if the file exist</returns>
        public virtual bool IsFileOnDisk(string path)
        {
            return File.Exists(path);
        }

        /// <summary>
        /// Renames the file in the hierarchy by removing old node and adding a new node in the hierarchy.
        /// </summary>
        /// <param name="oldFileName">The old file name.</param>
        /// <param name="newFileName">The new file name</param>
        /// <param name="newParent">The new parent of the item.</param>
        /// <returns>The newly added FileNode.</returns>
        /// <remarks>While a new node will be used to represent the item, the underlying MSBuild item will be the same and as a result file properties saved in the project file will not be lost.</remarks>
        protected virtual FileNode RenameFileNode(string oldFileName, string newFileName, string linkPath, HierarchyNode newParent)
        {
            if (oldFileName == null)
                throw new ArgumentNullException("oldFileName");
            if (newFileName == null)
                throw new ArgumentNullException("newFileName");
            if (newParent == null)
                throw new ArgumentNullException("newParent");
            if (string.IsNullOrEmpty(oldFileName))
                throw new ArgumentException("oldFileName cannot be null or empty");
            if (string.IsNullOrEmpty(newFileName))
                throw new ArgumentException("newFileName cannot be null or empty");

            if(string.Equals(oldFileName, newFileName, StringComparison.Ordinal))
            {
                // We do not want to rename the same file
                return null;
            }

            this.OnItemDeleted();
            this.Parent.RemoveChild(this);

            // Since this node has been removed all of its state is zombied at this point
            // Do not call virtual methods after this point since the object is in a deleted state.

            string[] file = new string[1];
            file[0] = newFileName;
            VSADDRESULT[] result = new VSADDRESULT[1];
            Guid emptyGuid = Guid.Empty;
            VSADDITEMOPERATION op = (String.IsNullOrEmpty(linkPath) ? VSADDITEMOPERATION.VSADDITEMOP_OPENFILE : VSADDITEMOPERATION.VSADDITEMOP_LINKTOFILE);
            ErrorHandler.ThrowOnFailure(this.ProjectManager.AddItemWithSpecific(newParent.Id, op, null, 0, file, IntPtr.Zero, 0, ref emptyGuid, null, ref emptyGuid, result));
            FileNode childAdded = this.ProjectManager.FindChild(newFileName) as FileNode;
            Debug.Assert(childAdded != null, "Could not find the renamed item in the hierarchy");

            /* No need to update the ID of this node. If ID is referenced by the caller after the
             * node is removed from the hierarchy, it will throw an InvalidOperationException.
             */
            //this.ID = childAdded.ID;

            // Remove the item created by the add item. We need to do this otherwise we will have two items.
            // Please be aware that we have not removed the ItemNode associated to the removed file node from the hierrachy.
            // What we want to achieve here is to reuse the existing build item. 
            // We want to link to the newly created node to the existing item node and addd the new include.

            bool wasIndependentNode = !this.ItemNode.Item.UnevaluatedInclude.Contains("*");
            bool isIndependentNode = !childAdded.ItemNode.Item.UnevaluatedInclude.Contains("*");

            if (wasIndependentNode && isIndependentNode)
            {
                //temporarily keep properties from new itemnode since we are going to overwrite it
                string newInclude = childAdded.ItemNode.Item.EvaluatedInclude;
                string dependentOf = childAdded.ItemNode.GetMetadata(ProjectFileConstants.DependentUpon);

                childAdded.ItemNode.RemoveFromProjectFile();

                // Assign existing msbuild item to the new childnode
                childAdded.ItemNode = this.ItemNode;
                childAdded.ItemNode.Item.ItemType = this.ItemNode.ItemName;
                childAdded.ItemNode.Item.Xml.Include = newInclude;
                if (!string.IsNullOrEmpty(dependentOf))
                    childAdded.ItemNode.SetMetadata(ProjectFileConstants.DependentUpon, dependentOf);
                if (!string.IsNullOrEmpty(linkPath))
                    childAdded.ItemNode.SetMetadata(ProjectFileConstants.Link, linkPath);
                childAdded.ItemNode.RefreshProperties();
            }
            else if (wasIndependentNode)
            {
                this.ItemNode.RemoveFromProjectFile();
            }

            //Update the new document in the RDT.
            DocumentManager.RenameDocument(this.ProjectManager.Site, oldFileName, newFileName, childAdded.Id);

            //Select the new node in the hierarchy
            IVsUIHierarchyWindow uiWindow = UIHierarchyUtilities.GetUIHierarchyWindow(this.ProjectManager.Site, SolutionExplorer);
			// This happens in the context of renaming a file.
			// Since we are already in solution explorer, it is extremely unlikely that we get a null return.
			// If we do, the consequences are minimal: the parent node will be selected instead of the
			// renamed node.
			if (uiWindow != null)
			{
				ErrorHandler.ThrowOnFailure(uiWindow.ExpandItem(this.ProjectManager.InteropSafeIVsUIHierarchy, this.Id, EXPANDFLAGS.EXPF_SelectItem));
			}

            //Update FirstChild
            foreach (var child in this.Children)
            {
                LinkedListNode<HierarchyNode> linkedNode = childAdded.Children.AddLast(child);
                childAdded.SetParent(childAdded, linkedNode);
            }

            //Update ChildNodes
            RenameChildNodes(childAdded);

            return childAdded;
        }

        /// <summary>
        /// Rename all childnodes
        /// </summary>
        /// <param name="parentNode">The newly added Parent node.</param>
        protected virtual void RenameChildNodes(FileNode parentNode)
        {
            foreach(HierarchyNode child in Children)
            {
                FileNode childNode = child as FileNode;
                if(null == childNode)
                {
                    continue;
                }
                string newfilename;
                if(childNode.HasParentNodeNameRelation)
                {
                    string relationalName = childNode.Parent.GetRelationalName();
                    string extension = childNode.GetRelationNameExtension();
                    newfilename = relationalName + extension;
                    newfilename = Path.Combine(Path.GetDirectoryName(childNode.Parent.GetMKDocument()), newfilename);
                }
                else
                {
                    newfilename = Path.Combine(Path.GetDirectoryName(childNode.Parent.GetMKDocument()), childNode.Caption);
                }

                childNode.RenameDocument(childNode.GetMKDocument(), newfilename);

                //We must update the DependsUpon property since the rename operation will not do it if the childNode is not renamed
                //which happens if the is no name relation between the parent and the child
                string dependentOf = childNode.ItemNode.GetMetadata(ProjectFileConstants.DependentUpon);
                if(!string.IsNullOrEmpty(dependentOf))
                {
                    childNode.ItemNode.SetMetadata(ProjectFileConstants.DependentUpon, childNode.Parent.ItemNode.GetMetadata(ProjectFileConstants.Include));
                }
            }
        }


        /// <summary>
        /// Tries recovering from a rename failure.
        /// </summary>
        /// <param name="fileThatFailed"> The file that failed to be renamed.</param>
        /// <param name="originalFileName">The original filenamee</param>
        protected virtual void RecoverFromRenameFailure(string fileThatFailed, string originalFileName)
        {
            if(this.ItemNode != null && !String.IsNullOrEmpty(originalFileName))
            {
                this.ItemNode.Rename(originalFileName);
                ProjectManager.ItemIdMap.UpdateCanonicalName(this);
            }
        }

        protected override bool CanDeleteItem(__VSDELETEITEMOPERATION deleteOperation)
        {
            string linkPath = this.ItemNode.GetMetadata(ProjectFileConstants.Link);
            __VSDELETEITEMOPERATION supportedOp = String.IsNullOrEmpty(linkPath) ?
                __VSDELETEITEMOPERATION.DELITEMOP_DeleteFromStorage : __VSDELETEITEMOPERATION.DELITEMOP_RemoveFromProject;

            if (deleteOperation == supportedOp)
            {
                return this.ProjectManager.CanProjectDeleteItems;
            }

            return false;
        }

        /// <summary>
        /// This should be overriden for node that are not saved on disk
        /// </summary>
        /// <param name="oldName">Previous name in storage</param>
        /// <param name="newName">New name in storage</param>
        protected virtual void RenameInStorage(string oldName, string newName)
        {
            File.Move(oldName, newName);
        }

        /// <summary>
        /// factory method for creating single file generators.
        /// </summary>
        /// <returns></returns>
        public virtual ISingleFileGenerator CreateSingleFileGenerator()
        {
            return new SingleFileGenerator(this.ProjectManager);
        }

        /// <summary>
        /// This method should be overridden to provide the list of special files and associated flags for source control.
        /// </summary>
        /// <param name="sccFile">One of the file associated to the node.</param>
        /// <param name="files">The list of files to be placed under source control.</param>
        /// <param name="flags">The flags that are associated to the files.</param>
        [SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "Scc")]
        public override void GetSccSpecialFiles(string sccFile, IList<string> files, IList<tagVsSccFilesFlags> flags)
        {
            if (files == null)
                throw new ArgumentNullException("files");

            if(this.ExcludeNodeFromScc)
            {
                return;
            }

            foreach(HierarchyNode node in this.Children)
            {
                files.Add(node.GetMKDocument());
            }
        }

        /// <summary>
        /// Sets the node property.
        /// </summary>
        /// <param name="propid">Property id.</param>
        /// <param name="value">Property value.</param>
        /// <returns>Returns success or failure code.</returns>
        public override int SetProperty(int propid, object value)
        {
            int result;
            __VSHPROPID id = (__VSHPROPID)propid;
            switch (id)
            {
            case __VSHPROPID.VSHPROPID_IsNonMemberItem:
                if (value == null)
                {
                    throw new ArgumentNullException("value");
                }

                bool boolValue;
                CciTracing.TraceCall(this.Id + "," + id.ToString());
                if (Boolean.TryParse(value.ToString(), out boolValue))
                {
                    this.IsNonmemberItem = boolValue;
                }
                else
                {
                    Trace.WriteLine("Could not parse the IsNonMemberItem property value.");
                }

                result = VSConstants.S_OK;
                break;

            default:
                result = base.SetProperty(propid, value);
                break;
            }

            return result;
        }

        /// <summary>
        /// Gets the node property.
        /// </summary>
        /// <param name="propId">Property id.</param>
        /// <returns>The property value.</returns>
        public override object GetProperty(int propId)
        {
            __VSHPROPID id = (__VSHPROPID)propId;
            switch (id)
            {
            case __VSHPROPID.VSHPROPID_IsNonMemberItem:
                return this.IsNonmemberItem;
            }

            return base.GetProperty(propId);
        }

        /// <summary>
        /// Provides the node name for inline editing of caption. 
        /// Overriden to diable this fuctionality for non member fodler node.
        /// </summary>
        /// <returns>Caption of the file node if the node is a member item, null otherwise.</returns>
        public override string GetEditLabel()
        {
            if (this.IsNonmemberItem)
            {
                return null;
            }

            return base.GetEditLabel();
        }
        #endregion

        #region IProjectSourceNode members
        /// <summary>
        /// Exclude the item from the project system.
        /// </summary>
        /// <returns>Returns success or failure code.</returns>
        [SuppressMessage("Microsoft.Design", "CA1033:InterfaceMethodsShouldBeCallableByChildTypes")]
        int IProjectSourceNode.ExcludeFromProject()
        {
            if (this.ProjectManager == null || this.ProjectManager.IsClosed)
            {
                return (int)OleConstants.OLECMDERR_E_NOTSUPPORTED;
            }
            else if (this.IsNonmemberItem)
            {
                return VSConstants.S_OK; // do nothing, just ignore it.
            }

            // Ask Document tracker listeners if we can remove the item.
            { // just to limit the scope.
                string documentToRemove = this.GetMKDocument();
                string[] filesToBeDeleted = new string[1] { documentToRemove };
                VSQUERYREMOVEFILEFLAGS[] queryRemoveFlags = this.GetQueryRemoveFileFlags(filesToBeDeleted);
                if (!this.ProjectManager.Tracker.CanRemoveItems(filesToBeDeleted, queryRemoveFlags))
                {
                    return (int)OleConstants.OLECMDERR_E_CANCELED;
                }

                // Close the document if it has a manager.
                DocumentManager manager = this.GetDocumentManager();
                if (manager != null)
                {
                    if (manager.Close(__FRAMECLOSE.FRAMECLOSE_PromptSave) == VSConstants.E_ABORT)
                    {
                        // User cancelled operation in message box.
                        return VSConstants.OLE_E_PROMPTSAVECANCELLED;
                    }
                }

                // Check out the project file.
                if (!this.ProjectManager.QueryEditProjectFile(false))
                {
                    throw Marshal.GetExceptionForHR(VSConstants.OLE_E_PROMPTSAVECANCELLED);
                }
            }

            // close the document window if open.
            this.CloseDocumentWindow(this);

            ProjectNode projectNode = this.ProjectManager as ProjectNode;

            if (projectNode != null && projectNode.ShowAllFilesEnabled && File.Exists(this.Url))
            {
                string url = this.Url; // need to store before removing the node.
                this.ItemNode.RemoveFromProjectFile();
                this.ProjectManager.Tracker.OnItemRemoved(url, VSREMOVEFILEFLAGS.VSREMOVEFILEFLAGS_NoFlags);
                this.SetProperty((int)__VSHPROPID.VSHPROPID_IsNonMemberItem, true); // Set it as non member item
                this.ItemNode = new ProjectElement(this.ProjectManager, null, true); // now we have to set a new ItemNode to indicate that this is virtual node.
                this.ItemNode.Rename(url);
                this.ItemNode.SetMetadata(ProjectFileConstants.Name, url);

                ////this.ProjectManager.OnItemAdded(this.Parent, this);
                this.Redraw(UIHierarchyElements.Icon); // We have to redraw the icon of the node as it is now not a member of the project and should be drawn using a different icon.
                this.Redraw(UIHierarchyElements.SccState); // update the SCC state icon.
            }
            else if (this.Parent != null) // the project node has no parentNode
            {
                // Remove from the Hierarchy
                this.OnItemDeleted();
                this.Parent.RemoveChild(this);
                this.ItemNode.RemoveFromProjectFile();
            }

            //this.ResetProperties();

            // refresh property browser...
            ProjectNode.RefreshPropertyBrowser();

            return VSConstants.S_OK;
        }

        /// <summary>
        /// Include the item into the project system.
        /// </summary>
        /// <returns>Returns success or failure code.</returns>
        [SuppressMessage("Microsoft.Design", "CA1033:InterfaceMethodsShouldBeCallableByChildTypes")]
        int IProjectSourceNode.IncludeInProject()
        {
            if (ProjectManager == null || ProjectManager.IsClosed)
            {
                return (int)OleConstants.OLECMDERR_E_NOTSUPPORTED;
            }
            else if (!this.IsNonmemberItem)
            {
                return VSConstants.S_OK; // do nothing, just ignore it.
            }

            // Check out the project file.
            if (!ProjectManager.QueryEditProjectFile(false))
            {
                throw Marshal.GetExceptionForHR(VSConstants.OLE_E_PROMPTSAVECANCELLED);
            }

            // make sure that all parent folders are included in the project
            ProjectNode.EnsureParentFolderIncluded(this);

            // now add this node to the project.
            this.SetProperty((int)__VSHPROPID.VSHPROPID_IsNonMemberItem, false);
            this.ItemNode = ProjectManager.AddFileToMSBuild(this.Url);
            this.ProjectManager.Tracker.OnItemAdded(this.Url, VSADDFILEFLAGS.VSADDFILEFLAGS_NoFlags);

            // notify others
            ////projectNode.OnItemAdded(this.Parent, this);
            this.Redraw(UIHierarchyElements.Icon); // We have to redraw the icon of the node as it is now a member of the project and should be drawn using a different icon.
            this.Redraw(UIHierarchyElements.SccState); // update the SCC state icon.

            //this.ResetProperties();

            // refresh property browser...
            ProjectNode.RefreshPropertyBrowser();

            return VSConstants.S_OK;
        }

        /// <summary>
        /// Include the item into the project system recursively.
        /// </summary>
        /// <param name="recursive">Flag that indicates if the inclusion should be recursive or not.</param>
        /// <returns>Returns success or failure code.</returns>
        [SuppressMessage("Microsoft.Design", "CA1033:InterfaceMethodsShouldBeCallableByChildTypes")]
        int IProjectSourceNode.IncludeInProject(bool recursive)
        {
            // recursive doesn't make any sense in case of a file item. so just include this item.
            return ((IProjectSourceNode)this).IncludeInProject();
        }
        #endregion

        #region Helper methods
        /// <summary>
        /// Get's called to rename the eventually running document this hierarchyitem points to
        /// </summary>
        /// returns FALSE if the doc can not be renamed
        public virtual bool RenameDocument(string oldName, string newName)
        {
            IVsRunningDocumentTable pRDT = this.GetService(typeof(IVsRunningDocumentTable)) as IVsRunningDocumentTable;
            if(pRDT == null) return false;
            IntPtr docData = IntPtr.Zero;
            IVsHierarchy pIVsHierarchy;
            uint itemId;
            uint uiVsDocCookie;

            SuspendFileChanges sfc = new SuspendFileChanges(this.ProjectManager.Site, oldName);
            sfc.Suspend();

            try
            {
                // Suspend ms build since during a rename operation no msbuild re-evaluation should be performed until we have finished.
                // Scenario that could fail if we do not suspend.
                // We have a project system relying on MPF that triggers a Compile target build (re-evaluates itself) whenever the project changes. (example: a file is added, property changed.)
                // 1. User renames a file in  the above project sytem relying on MPF
                // 2. Our rename funstionality implemented in this method removes and readds the file and as a post step copies all msbuild entries from the removed file to the added file.
                // 3. The project system mentioned will trigger an msbuild re-evaluate with the new item, because it was listening to OnItemAdded. 
                //    The problem is that the item at the "add" time is only partly added to the project, since the msbuild part has not yet been copied over as mentioned in part 2 of the last step of the rename process.
                //    The result is that the project re-evaluates itself wrongly.
                VSRENAMEFILEFLAGS renameflag = VSRENAMEFILEFLAGS.VSRENAMEFILEFLAGS_NoFlags;
                try
                {
                    this.ProjectManager.SuspendMSBuild();
                    ErrorHandler.ThrowOnFailure(pRDT.FindAndLockDocument((uint)_VSRDTFLAGS.RDT_NoLock, oldName, out pIVsHierarchy, out itemId, out docData, out uiVsDocCookie));

                    if(pIVsHierarchy != null && !Utilities.IsSameComObject(pIVsHierarchy, this.ProjectManager.InteropSafeIVsHierarchy))
                    {
                        // Don't rename it if it wasn't opened by us.
                        return false;
                    }

                    // ask other potentially running packages
                    if(!this.ProjectManager.Tracker.CanRenameItem(oldName, newName, renameflag))
                    {
                        return false;
                    }
                    // Allow the user to "fix" the project by renaming the item in the hierarchy
                    // to the real name of the file on disk.
                    if(IsFileOnDisk(oldName) || !IsFileOnDisk(newName))
                    {
                        RenameInStorage(oldName, newName);
                    }

                    string newFileName = Path.GetFileName(newName);
                    DocumentManager.UpdateCaption(this.ProjectManager.Site, newFileName, docData);
                    bool caseOnlyChange = NativeMethods.IsSamePath(oldName, newName);
                    if(!caseOnlyChange)
                    {
                        // Check out the project file if necessary.
                        if(!this.ProjectManager.QueryEditProjectFile(false))
                        {
                            throw Marshal.GetExceptionForHR(VSConstants.OLE_E_PROMPTSAVECANCELLED);
                        }

                        this.RenameFileNode(oldName, newName);
                    }
                    else
                    {
                        this.RenameCaseOnlyChange(newFileName);
                    }
                }
                finally
                {
                    this.ProjectManager.ResumeMSBuild(this.ProjectManager.ReevaluateProjectFileTargetName);
                }

                this.ProjectManager.Tracker.OnItemRenamed(oldName, newName, renameflag);
            }
            finally
            {
                sfc.Resume();
                if(docData != IntPtr.Zero)
                {
                    Marshal.Release(docData);
                }
            }

            return true;
        }

        protected virtual FileNode RenameFileNode(string oldFileName, string newFileName)
        {
            return this.RenameFileNode(oldFileName, newFileName, null, this.Parent);
        }

        /// <summary>
        /// Renames the file node for a case only change.
        /// </summary>
        /// <param name="newFileName">The new file name.</param>
        protected virtual void RenameCaseOnlyChange(string newFileName)
        {
            //Update the include for this item.
            string include = this.ItemNode.Item.EvaluatedInclude;
            if(String.Equals(include, newFileName, StringComparison.OrdinalIgnoreCase))
            {
                this.ItemNode.Item.Xml.Include = newFileName;
            }
            else
            {
                string includeDir = Path.GetDirectoryName(include);
                this.ItemNode.Item.Xml.Include = Path.Combine(includeDir, newFileName);
            }

            this.ItemNode.RefreshProperties();

            this.Redraw(UIHierarchyElements.Caption);
            this.RenameChildNodes(this);

            // Refresh the property browser.
            IVsUIShell shell = this.ProjectManager.Site.GetService(typeof(SVsUIShell)) as IVsUIShell;
            Debug.Assert(shell != null, "Could not get the ui shell from the project");
            if(shell == null)
            {
                throw new InvalidOperationException();
            }

            ErrorHandler.ThrowOnFailure(shell.RefreshPropertyBrowser(0));

            //Select the new node in the hierarchy
            IVsUIHierarchyWindow uiWindow = UIHierarchyUtilities.GetUIHierarchyWindow(this.ProjectManager.Site, SolutionExplorer);
            // This happens in the context of renaming a file by case only (Table.sql -> table.sql)
            // Since we are already in solution explorer, it is extremely unlikely that we get a null return.
			if (uiWindow != null)
			{
				ErrorHandler.ThrowOnFailure(uiWindow.ExpandItem(this.ProjectManager.InteropSafeIVsUIHierarchy, this.Id, EXPANDFLAGS.EXPF_SelectItem));
			}
        }

        #endregion

        #region SingleFileGenerator Support methods
        /// <summary>
        /// Event handler for the Custom tool property changes
        /// </summary>
        /// <param name="sender">FileNode sending it</param>
        /// <param name="e">Node event args</param>
        public virtual void OnCustomToolChanged(object sender, HierarchyNodeEventArgs e)
        {
            this.RunGenerator();
        }

        /// <summary>
        /// Event handler for the Custom tool namespce property changes
        /// </summary>
        /// <param name="sender">FileNode sending it</param>
        /// <param name="e">Node event args</param>
        public virtual void OnCustomToolNameSpaceChanged(object sender, HierarchyNodeEventArgs e)
        {
            this.RunGenerator();
        }

        #endregion

        #region helpers
        /// <summary>
        /// Runs a generator.
        /// </summary>
        public virtual void RunGenerator()
        {
            ISingleFileGenerator generator = this.CreateSingleFileGenerator();
            if(generator != null)
            {
                generator.RunGenerator(this.Url);
            }
        }

        #endregion
    }
}
