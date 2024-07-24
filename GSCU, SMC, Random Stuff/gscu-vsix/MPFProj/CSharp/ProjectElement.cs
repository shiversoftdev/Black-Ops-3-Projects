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
	using System.Globalization;
	using System.IO;
	using System.Runtime.InteropServices;
	using Microsoft.Build.Evaluation;
	using MSBuild = Microsoft.Build.Evaluation;

    /// <summary>
    /// This class represent a project item (usualy a file) and allow getting and
    /// setting attribute on it.
    /// This class allow us to keep the internal details of our items hidden from
    /// our derived classes.
    /// While the class itself is public so it can be manipulated by derived classes,
    /// its internal constructors make sure it can only be created from within the assembly.
    /// </summary>
    public sealed class ProjectElement
    {
        private readonly ProjectNode itemProject;
        private MSBuild.ProjectItem item;
        private bool deleted;
        private bool isVirtual;
        private Dictionary<string, string> virtualProperties;

        #region properties
        public string ItemName
        {
            get
            {
                if (HasItemBeenDeleted)
                    throw new InvalidOperationException("The item has been deleted.");

                if (IsVirtual)
                {
                    return String.Empty;
                }
                else
                {
                    return this.Item.ItemType;
                }
            }

            set
            {
                if (value == null)
                    throw new ArgumentNullException("value");
                if (string.IsNullOrEmpty("value"))
                    throw new ArgumentException("value cannot be null or empty");
                if (IsVirtual)
                    throw new InvalidOperationException("The item is virtual.");
                if (HasItemBeenDeleted)
                    throw new InvalidOperationException("The item has been deleted.");

                // Check out the project file.
                if (!this.ProjectManager.QueryEditProjectFile(false))
                {
                    throw Marshal.GetExceptionForHR(VSConstants.OLE_E_PROMPTSAVECANCELLED);
                }

                this.Item.ItemType = value;
            }
        }

        public MSBuild.ProjectItem Item
        {
            get
            {
                if (HasItemBeenDeleted)
                    throw new InvalidOperationException("The item has been deleted.");

                return this.item;
            }
        }

        public bool IsVirtual
        {
            get
            {
                return this.isVirtual;
            }
        }

        public ProjectNode ProjectManager
        {
            get
            {
                //Contract.Ensures(Contract.Result<ProjectNode>() != null);
                return itemProject;
            }
        } 

        /// <summary>
        /// Has the item been deleted
        /// </summary>
        public bool HasItemBeenDeleted
        {
            get
            {
                return (this.deleted || (!IsVirtual && this.item == null));
            }
        }
        #endregion

        #region ctors
        /// <summary>
        /// Constructor to create a new MSBuild.ProjectItem and add it to the project
        /// Only have internal constructors as the only one who should be creating
        /// such object is the project itself (see Project.CreateFileNode()).
        /// </summary>
        public ProjectElement(ProjectNode project, string itemPath, string itemType)
        {
            if(project == null)
            {
                throw new ArgumentNullException("project");
            }

            if(String.IsNullOrEmpty(itemPath))
            {
                throw new ArgumentException(SR.GetString(SR.ParameterCannotBeNullOrEmpty, CultureInfo.CurrentUICulture), "itemPath");
            }


            if(String.IsNullOrEmpty(itemType))
            {
                throw new ArgumentException(SR.GetString(SR.ParameterCannotBeNullOrEmpty, CultureInfo.CurrentUICulture), "itemType");
            }

            this.itemProject = project;

            // create and add the item to the project

            this.item = project.BuildProject.AddItem(itemType, Microsoft.Build.Evaluation.ProjectCollection.Escape(itemPath))[0];
            if (project.BuildProject.IsDirty)
                this.ProjectManager.SetProjectFileDirty(true);

            this.RefreshProperties();
        }

        /// <summary>
        /// Constructor to Wrap an existing MSBuild.ProjectItem
        /// Only have internal constructors as the only one who should be creating
        /// such object is the project itself (see Project.CreateFileNode()).
        /// </summary>
        /// <param name="project">Project that owns this item</param>
        /// <param name="existingItem">an MSBuild.ProjectItem; can be null if virtualFolder is true</param>
        /// <param name="virtualFolder">Is this item virtual (such as reference folder)</param>
        public ProjectElement(ProjectNode project, MSBuild.ProjectItem existingItem, bool virtualFolder)
        {
            if(project == null)
                throw new ArgumentNullException("project");
            if(!virtualFolder && existingItem == null)
                throw new ArgumentNullException("existingItem");

            // Keep a reference to project and item
            this.itemProject = project;
            this.item = existingItem;
            this.isVirtual = virtualFolder;

            if(this.isVirtual)
                this.virtualProperties = new Dictionary<string, string>();
        }
        #endregion

        #region public methods
        /// <summary>
        /// Calling this method remove this item from the project file.
        /// Once the item is delete, you should not longer be using it.
        /// Note that the item should be removed from the hierarchy prior to this call.
        /// </summary>
        public void RemoveFromProjectFile()
        {
            if(!deleted && Item != null)
            {
                ProjectManager.BuildProject.RemoveItem(Item);
                deleted = true;
            }

            item = null;
        }

        /// <summary>
        /// Set an attribute on the project element
        /// </summary>
        /// <param name="attributeName">Name of the attribute to set</param>
        /// <param name="attributeValue">Value to give to the attribute.  Use <c>null</c> to delete the metadata definition.</param>
        public void SetMetadata(string attributeName, string attributeValue)
        {
            if (attributeName == null)
                throw new ArgumentNullException("attributeName");
            if (string.IsNullOrEmpty(attributeName))
                throw new ArgumentException("attributeName cannot be null or empty");
            if (string.Equals(attributeName, ProjectFileConstants.Include, StringComparison.OrdinalIgnoreCase))
                throw new ArgumentException("Use Rename to set the Include attribute.");
            if (HasItemBeenDeleted)
                throw new InvalidOperationException("The item has been deleted.");

            if(this.IsVirtual)
            {
                /* For virtual node, use our virtual property collection
                 * Remove followed by Add ensures that the key in the dictionary has the same case as attributeName
                 */
                virtualProperties.Remove(attributeName);
                virtualProperties.Add(attributeName, attributeValue);
                return;
            }

            // Check out the project file.
            if(!this.ProjectManager.QueryEditProjectFile(false))
            {
                throw Marshal.GetExceptionForHR(VSConstants.OLE_E_PROMPTSAVECANCELLED);
            }

            // Build Action is the type, not a property, so intercept
            if(String.Equals(attributeName, ProjectFileConstants.BuildAction, StringComparison.OrdinalIgnoreCase))
            {
                Item.ItemType = attributeValue;
                return;
            }

            if(attributeValue == null)
                Item.RemoveMetadata(attributeName);
            else
                Item.SetMetadataValue(attributeName, attributeValue);

            ProjectManager.SetProjectFileDirty(true);
        }

        public string GetEvaluatedMetadata(string attributeName)
        {
            if (attributeName == null)
                throw new ArgumentNullException("attributeName");
            if (string.IsNullOrEmpty(attributeName))
                throw new ArgumentException("attributeName cannot be null or empty");
            if (HasItemBeenDeleted)
                throw new InvalidOperationException("The item has been deleted.");

            if(this.IsVirtual)
            {
                // For virtual items, use our virtual property collection
                string attributeValue;
                if (!virtualProperties.TryGetValue(attributeName, out attributeValue))
                    return string.Empty;

                return ProjectCollection.Unescape(attributeValue);
            }

            // cannot ask MSBuild for Include, so intercept it and return the corresponding property
            if(String.Equals(attributeName, ProjectFileConstants.Include, StringComparison.OrdinalIgnoreCase))
            {
                return Item.EvaluatedInclude;
            }

            // Build Action is the type, not a property, so intercept this one as well
            if(String.Equals(attributeName, ProjectFileConstants.BuildAction, StringComparison.OrdinalIgnoreCase))
            {
                return Item.ItemType;
            }

            return Item.GetMetadataValue(attributeName);
        }

        /// <summary>
        /// Get the value of an attribute on a project element
        /// </summary>
        /// <param name="attributeName">Name of the attribute to get the value for</param>
        /// <returns>Value of the attribute</returns>
        public string GetMetadata(string attributeName)
        {
            if (attributeName == null)
                throw new ArgumentNullException("attributeName");
            if (string.IsNullOrEmpty(attributeName))
                throw new ArgumentException("attributeName cannot be null or empty");
            if (HasItemBeenDeleted)
                throw new InvalidOperationException("The item has been deleted.");

            if(this.IsVirtual)
            {
                // For virtual items, use our virtual property collection
                if(!virtualProperties.ContainsKey(attributeName))
                    return String.Empty;

                return ProjectCollection.Unescape(virtualProperties[attributeName]);
            }

            // cannot ask MSBuild for Include, so intercept it and return the corresponding property
            if(String.Equals(attributeName, ProjectFileConstants.Include, StringComparison.OrdinalIgnoreCase))
                return Item.EvaluatedInclude;

            // Build Action is the type, not a property, so intercept this one as well
            if(String.Equals(attributeName, ProjectFileConstants.BuildAction, StringComparison.OrdinalIgnoreCase))
                return Item.ItemType;

            return Item.GetMetadataValue(attributeName);
        }

        /// <summary>
        /// Gets the attribute and throws the handed exception if the exception if the attribute is empty or null.
        /// </summary>
        /// <param name="attributeName">The name of the attribute to get.</param>
        /// <param name="exception">The exception to be thrown if not found or empty.</param>
        /// <returns>The attribute if found</returns>
        /// <remarks>The method will throw an Exception and neglect the passed in exception if the attribute is deleted</remarks>
        public string GetMetadataAndThrow(string attributeName, Exception exception)
        {
            if (attributeName == null)
                throw new ArgumentNullException("attributeName");
            if (string.IsNullOrEmpty(attributeName))
                throw new ArgumentException("attributeName cannot be null or empty");
            if (HasItemBeenDeleted)
                throw new InvalidOperationException("The item has been deleted.");

            Debug.Assert(!String.IsNullOrEmpty(attributeName), "Cannot retrieve an attribute for a null or empty attribute name");
            string attribute = GetMetadata(attributeName);

            if(String.IsNullOrEmpty(attributeName) && exception != null)
            {
                if(String.IsNullOrEmpty(exception.Message))
                {
                    Debug.Assert(!String.IsNullOrEmpty(this.ProjectManager.BaseUri.AbsoluteUrl), "Cannot retrieve an attribute for a project that does not have a name");
                    string message = String.Format(CultureInfo.CurrentCulture, SR.GetString(SR.AttributeLoad, CultureInfo.CurrentUICulture), attributeName, this.ProjectManager.BaseUri.AbsoluteUrl);
                    throw new InvalidOperationException(message, exception);
                }

                throw exception;
            }

            return attribute;
        }


        public void Rename(string newPath)
        {
            if (newPath == null)
                throw new ArgumentNullException("newPath");
            if (string.IsNullOrEmpty(newPath))
                throw new ArgumentException("newPath cannot be null or empty");
            if (HasItemBeenDeleted)
                throw new InvalidOperationException("The item has been deleted.");

            string escapedPath = Microsoft.Build.Evaluation.ProjectCollection.Escape(newPath);
            if(this.IsVirtual)
            {
                virtualProperties[ProjectFileConstants.Include] = escapedPath;
                return;
            }

            Item.Rename(escapedPath);
            this.RefreshProperties();
        }


        /// <summary>
        /// Reevaluate all properties for the current item
        /// This should be call if you believe the property for this item
        /// may have changed since it was created/refreshed, or global properties
        /// this items depends on have changed.
        /// Be aware that there is a perf cost in calling this function.
        /// </summary>
        public void RefreshProperties()
        {
            if (HasItemBeenDeleted)
                throw new InvalidOperationException("The item has been deleted.");

            if(this.IsVirtual)
                return;

            ProjectManager.BuildProject.ReevaluateIfNecessary();

            IEnumerable<ProjectItem> items = ProjectManager.BuildProject.GetItems(Item.ItemType);
            foreach (ProjectItem projectItem in items)
            {
                if(projectItem!= null && projectItem.EvaluatedInclude.Equals(Item.EvaluatedInclude))
                {
                    item = projectItem;
                    return;
                }
            }
        }

        /// <summary>
        /// Return an absolute path for the passed in element.
        /// If the element is already an absolute path, it is returned.
        /// Otherwise, it is unrelativized using the project directory
        /// as the base.
        /// Note that any ".." in the paths will be resolved.
        /// 
        /// For non-file system based project, it may make sense to override.
        /// </summary>
        /// <returns>FullPath</returns>
        public string GetFullPathForElement()
        {
            if (HasItemBeenDeleted)
                throw new InvalidOperationException("The item has been deleted.");

            string path = this.GetMetadata(ProjectFileConstants.Include);
            if(!Path.IsPathRooted(path))
                path = Path.Combine(this.ProjectManager.ProjectFolder, path);

            // If any part of the path used relative paths, resolve this now
            path = Path.GetFullPath(path);
            return path;
        }

        #endregion

        #region overridden from System.Object
        public static bool operator ==(ProjectElement element1, ProjectElement element2)
        {
            // Do they reference the same element?
            if(Object.ReferenceEquals(element1, element2))
                return true;

            // Verify that they are not null (cast to object first to avoid stack overflow)
            if (object.ReferenceEquals(element1, null) || object.ReferenceEquals(element2, null))
            {
                return false;
            }

            Debug.Assert(!element1.IsVirtual || !element2.IsVirtual, "Cannot compare virtual nodes");

            // Cannot compare vitual items.
            if(element1.IsVirtual || element2.IsVirtual)
            {
                return false;
            }

            // Do they reference the same project?
            if(!element1.ProjectManager.Equals(element2.ProjectManager))
                return false;

            // Do they have the same include?
            string include1 = element1.GetMetadata(ProjectFileConstants.Include);
            string include2 = element2.GetMetadata(ProjectFileConstants.Include);

            // Virtual folders should not be handled here.
            return String.Equals(include1, include2, StringComparison.CurrentCultureIgnoreCase);
        }


        public static bool operator !=(ProjectElement element1, ProjectElement element2)
        {
            return !(element1 == element2);
        }


        public override bool Equals(object obj)
        {
            ProjectElement element2 = obj as ProjectElement;
            if(element2 == null)
                return false;

            return this == element2;
        }


        public override int GetHashCode()
        {
            return base.GetHashCode();
        }
        #endregion



    }
}
