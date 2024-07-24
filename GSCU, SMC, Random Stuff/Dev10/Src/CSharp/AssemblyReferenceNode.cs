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
	using System.Collections;
	using System.Collections.Generic;
	using System.Diagnostics;
	using System.IO;
	using System.Reflection;
	using System.Runtime.InteropServices;
	using Microsoft.VisualStudio.Shell;
	using Microsoft.VisualStudio.Shell.Interop;
	using MSBuild = Microsoft.Build.Evaluation;

	[CLSCompliant(false)]
	[ComVisible(true)]
	public class AssemblyReferenceNode : ReferenceNode
	{
		#region fields
		/// <summary>
		/// The name of the assembly this reference represents
		/// </summary>
		private System.Reflection.AssemblyName assemblyName;
		private AssemblyName resolvedAssemblyName;

		private string assemblyPath = String.Empty;

		/// <summary>
		/// Defines the listener that would listen on file changes on the nested project node.
		/// </summary>
		private FileChangeManager fileChangeListener;

		/// <summary>
		/// A flag for specifying if the object was disposed.
		/// </summary>
		private bool isDisposed;
		#endregion

		#region properties
		/// <summary>
		/// The name of the assembly this reference represents.
		/// </summary>
		/// <value></value>
		public System.Reflection.AssemblyName AssemblyName
		{
			get
			{
				return this.assemblyName;
			}
		}

		/// <summary>
		/// Returns the name of the assembly this reference refers to on this specific
		/// machine. It can be different from the AssemblyName property because it can
		/// be more specific.
		/// </summary>
		public System.Reflection.AssemblyName ResolvedAssembly
		{
			get { return resolvedAssemblyName; }
		}

		public override string Url
		{
			get
			{
				return this.AssemblyPath;
			}
		}

		public override string Caption
		{
			get
			{
				return this.assemblyName.Name;
			}
		}

		private Automation.OAAssemblyReference assemblyRef;
		public override object Object
		{
			get
			{
				if(null == assemblyRef)
				{
					assemblyRef = new Automation.OAAssemblyReference(this);
				}
				return assemblyRef;
			}
		}

        public override bool CanCacheCanonicalName
        {
            get
            {
                return !string.IsNullOrEmpty(AssemblyPath);
            }
        }
		#endregion

        protected string AssemblyPath
        {
            get
            {
                //Contract.Ensures(Contract.Result<string>() != null);

                return assemblyPath;
            }

            set
            {
                if (value == null)
                    throw new ArgumentNullException("value");

                if (assemblyPath == value)
                    return;

                assemblyPath = value;
                ProjectManager.ItemIdMap.UpdateCanonicalName(this);
            }
        }

		#region constructors
		/// <summary>
		/// Constructor for the ReferenceNode
		/// </summary>
		public AssemblyReferenceNode(ProjectNode root, ProjectElement element)
			: base(root, element)
		{
			this.GetPathNameFromProjectFile();

			this.InitializeFileChangeEvents();

			string include = this.ItemNode.GetMetadata(ProjectFileConstants.Include);

			this.CreateFromAssemblyName(new System.Reflection.AssemblyName(include));
		}

		/// <summary>
		/// Constructor for the AssemblyReferenceNode
		/// </summary>
		public AssemblyReferenceNode(ProjectNode root, string assemblyPath)
			: base(root)
		{
			if(root == null)
			{
				throw new ArgumentNullException("root");
			}

			if(assemblyPath == null)
			{
				throw new ArgumentNullException("assemblyPath");
			}

			if(string.IsNullOrEmpty(assemblyPath))
			{
				throw new ArgumentException("assemblyPath cannot be null or empty");
			}

			this.InitializeFileChangeEvents();

			// The assemblyPath variable can be an actual path on disk or a generic assembly name.
			if(File.Exists(assemblyPath))
			{
				// The assemblyPath parameter is an actual file on disk; try to load it.
				this.assemblyName = System.Reflection.AssemblyName.GetAssemblyName(assemblyPath);
				this.AssemblyPath = assemblyPath;

				// We register with listening to changes on the path here. The rest of the cases will call into resolving the assembly and registration is done there.
				this.fileChangeListener.ObserveItem(this.assemblyPath);
			}
			else
			{
				// The file does not exist on disk. This can be because the file / path is not
				// correct or because this is not a path, but an assembly name.
				// Try to resolve the reference as an assembly name.
				this.CreateFromAssemblyName(new System.Reflection.AssemblyName(assemblyPath));
			}
		}
		#endregion

		#region methods
		/// <summary>
		/// Closes the node.
		/// </summary>
		/// <returns></returns>
		public override int Close()
		{
			try
			{
				this.Dispose(true);
			}
			finally
			{
				base.Close();
			}

			return VSConstants.S_OK;
		}

		/// <summary>
		/// Links a reference node to the project and hierarchy.
		/// </summary>
		protected override void BindReferenceData()
		{
			Debug.Assert(this.assemblyName != null, "The AssemblyName field has not been initialized");

			// If the item has not been set correctly like in case of a new reference added it now.
			// The constructor for the AssemblyReference node will create a default project item. In that case the Item is null.
			// We need to specify here the correct project element. 
			if(this.ItemNode == null || this.ItemNode.Item == null)
			{
				this.ItemNode = new ProjectElement(this.ProjectManager, this.assemblyName.FullName, ProjectFileConstants.Reference);
			}

			// Set the basic information we know about
			this.ItemNode.SetMetadata(ProjectFileConstants.Name, this.assemblyName.Name);
			if (!string.IsNullOrEmpty(this.AssemblyPath))
			{
				this.ItemNode.SetMetadata(ProjectFileConstants.AssemblyName, Path.GetFileName(this.AssemblyPath));
			}
			else
			{
				this.ItemNode.SetMetadata(ProjectFileConstants.AssemblyName, null);
			}

			this.SetReferenceProperties();
		}

		/// <summary>
		/// Disposes the node
		/// </summary>
		/// <param name="disposing"></param>
		protected override void Dispose(bool disposing)
		{
			if(this.isDisposed)
			{
				return;
			}

			try
			{
				this.UnregisterFromFileChangeService();
			}
			finally
			{
				base.Dispose(disposing);
				this.isDisposed = true;
			}
		}

		protected virtual void CreateFromAssemblyName(AssemblyName name)
		{
			this.assemblyName = name;

			// Use MsBuild to resolve the assembly name 
			this.ResolveAssemblyReference();

			if(String.IsNullOrEmpty(this.AssemblyPath) && (null != this.ItemNode.Item))
			{
				// Try to get the assembly name from the hint path.
				this.GetPathNameFromProjectFile();
				if(this.AssemblyPath == null)
				{
					// Try to get the assembly name from the path
					this.assemblyName = System.Reflection.AssemblyName.GetAssemblyName(this.AssemblyPath);
				}
			}
			if(null == resolvedAssemblyName)
			{
				resolvedAssemblyName = assemblyName;
			}
		}

		/// <summary>
		/// Checks if an assembly is already added. The method parses all references and compares the full assembly names, or the location of the assemblies to decide whether two assemblies are the same.
		/// </summary>
		/// <returns>true if the assembly has already been added.</returns>
		public override bool IsAlreadyAdded(out ReferenceNode existingEquivalentNode)
		{
			ReferenceContainerNode referencesFolder = this.ProjectManager.FindChild(ReferenceContainerNode.ReferencesNodeVirtualName) as ReferenceContainerNode;
			Debug.Assert(referencesFolder != null, "Could not find the References node");
			bool shouldCheckPath = !string.IsNullOrEmpty(this.Url);

			for(HierarchyNode n = referencesFolder.FirstChild; n != null; n = n.NextSibling)
			{
				AssemblyReferenceNode assemblyReferenceNode = n as AssemblyReferenceNode;
				if(null != assemblyReferenceNode)
				{
					// We will check if the full assembly names are the same or if the URL of the assemblies is the same.
					if(String.Equals(assemblyReferenceNode.AssemblyName.FullName, this.assemblyName.FullName, StringComparison.OrdinalIgnoreCase) ||
						(shouldCheckPath && NativeMethods.IsSamePath(assemblyReferenceNode.Url, this.Url)))
					{
						existingEquivalentNode = assemblyReferenceNode;
						return true;
					}
				}
			}

			existingEquivalentNode = null;
			return false;
		}

		/// <summary>
		/// Determines if this is node a valid node for painting the default reference icon.
		/// </summary>
		/// <returns></returns>
		protected override bool CanShowDefaultIcon()
		{
			if(String.IsNullOrEmpty(this.AssemblyPath) || !File.Exists(this.AssemblyPath))
			{
				return false;
			}

			return true;
		}

		protected virtual void GetPathNameFromProjectFile()
		{
			string result = this.ItemNode.GetMetadata(ProjectFileConstants.HintPath);
			if(String.IsNullOrEmpty(result))
			{
				result = this.ItemNode.GetMetadata(ProjectFileConstants.AssemblyName);
				if(String.IsNullOrEmpty(result))
				{
					this.AssemblyPath = String.Empty;
				}
				else if(!result.EndsWith(".dll", StringComparison.OrdinalIgnoreCase))
				{
					result += ".dll";
					this.AssemblyPath = result;
				}
			}
			else
			{
				this.AssemblyPath = this.GetFullPathFromPath(result);
			}
		}

		protected virtual string GetFullPathFromPath(string path)
		{
			if(Path.IsPathRooted(path))
			{
				return path;
			}
			else
			{
				Uri uri = new Uri(this.ProjectManager.BaseUri.Uri, path);

				if(uri != null)
				{
					return Microsoft.VisualStudio.Shell.Url.Unescape(uri.LocalPath, true);
				}
			}

			return String.Empty;
		}

		protected override void ResolveReference()
		{
			this.ResolveAssemblyReference();
		}

		protected virtual void SetHintPathAndPrivateValue()
		{
			// Remove the HintPath, we will re-add it below if it is needed
			if(!String.IsNullOrEmpty(this.AssemblyPath))
			{
				this.ItemNode.SetMetadata(ProjectFileConstants.HintPath, null);
			}

			// Get the list of items which require HintPath
			IEnumerable<MSBuild.ProjectItem> references = this.ProjectManager.BuildProject.GetItems(MSBuildGeneratedItemType.ReferenceCopyLocalPaths);

			// Now loop through the generated References to find the corresponding one
            foreach (MSBuild.ProjectItem reference in references)
			{
				string fileName = Path.GetFileNameWithoutExtension(reference.EvaluatedInclude);
				if(String.Equals(fileName, this.assemblyName.Name, StringComparison.OrdinalIgnoreCase))
				{
					// We found it, now set some properties based on this.
					string hintPath = reference.GetMetadataValue(ProjectFileConstants.HintPath);
					this.SetHintPathAndPrivateValue(hintPath);
					break;
				}
			}
		}

		/// <summary>
		/// Sets the hint path to the provided value. 
		/// It also sets the private value to true if it has not been already provided through the associated project element.
		/// </summary>
		/// <param name="hintPath">The hint path to set.</param>
		protected virtual void SetHintPathAndPrivateValue(string hintPath)
		{
			if (String.IsNullOrEmpty(hintPath))
			{
				return;
			}

			if (Path.IsPathRooted(hintPath))
			{
				hintPath = PackageUtilities.GetPathDistance(this.ProjectManager.BaseUri.Uri, new Uri(hintPath));
			}

			this.ItemNode.SetMetadata(ProjectFileConstants.HintPath, hintPath);

			// Private means local copy; we want to know if it is already set to not override the default
			string privateValue = this.ItemNode != null ? this.ItemNode.GetMetadata(ProjectFileConstants.Private) : null;

			// If this is not already set, we default to true
			if (String.IsNullOrEmpty(privateValue))
			{
				this.ItemNode.SetMetadata(ProjectFileConstants.Private, true.ToString());
			}
		}

		/// <summary>
		/// This function ensures that some properties of the reference are set.
		/// </summary>
		protected virtual void SetReferenceProperties()
		{
			// If there is an assembly path then just set the hint path
			if (!string.IsNullOrEmpty(this.assemblyPath))
			{
				this.SetHintPathAndPrivateValue(this.assemblyPath);
				return;
			}

			// Set a default HintPath for MSBuild to be able to resolve the reference.
			this.ItemNode.SetMetadata(ProjectFileConstants.HintPath, this.AssemblyPath);

			// Resolve assembly references. This is needed to make sure that properties like the full path
			// to the assembly or the hint path are set.
			if(this.ProjectManager.Build(MSBuildTarget.ResolveAssemblyReferences) != MSBuildResult.Successful)
			{
				return;
			}

			// Check if we have to resolve again the path to the assembly.
			this.ResolveReference();

			// Make sure that the hint path if set (if needed).
			this.SetHintPathAndPrivateValue();
		}

		/// <summary>
		/// Does the actual job of resolving an assembly reference. We need a private method that does not violate 
		/// calling virtual method from the constructor.
		/// </summary>
        protected virtual void ResolveAssemblyReference()
        {
            if (this.ProjectManager == null || this.ProjectManager.IsClosed)
            {
                return;
            }

            var group = this.ProjectManager.CurrentConfig.GetItems(ProjectFileConstants.ReferencePath);
            foreach (var item in group)
            {
                string fullPath = this.GetFullPathFromPath(item.EvaluatedInclude);

                System.Reflection.AssemblyName name = System.Reflection.AssemblyName.GetAssemblyName(fullPath);

                // Try with full assembly name and then with weak assembly name.
                if (String.Equals(name.FullName, this.assemblyName.FullName, StringComparison.OrdinalIgnoreCase) || String.Equals(name.Name, this.assemblyName.Name, StringComparison.OrdinalIgnoreCase))
                {
                    if (!NativeMethods.IsSamePath(fullPath, this.AssemblyPath))
                    {
                        // set the full path now.
                        this.AssemblyPath = fullPath;

                        // We have a new item to listen too, since the assembly reference is resolved from a different place.
                        this.fileChangeListener.ObserveItem(this.AssemblyPath);
                    }

                    this.resolvedAssemblyName = name;

                    // No hint path is needed since the assembly path will always be resolved.
                    return;
                }
            }
        }

		/// <summary>
		/// Registers with File change events
		/// </summary>
		protected virtual void InitializeFileChangeEvents()
		{
			this.fileChangeListener = new FileChangeManager(this.ProjectManager.Site);
			this.fileChangeListener.FileChangedOnDisk += this.OnAssemblyReferenceChangedOnDisk;
		}

		/// <summary>
		/// Unregisters this node from file change notifications.
		/// </summary>
		protected virtual void UnregisterFromFileChangeService()
		{
			this.fileChangeListener.FileChangedOnDisk -= this.OnAssemblyReferenceChangedOnDisk;
			this.fileChangeListener.Dispose();
		}

		/// <summary>
		/// Event callback. Called when one of the assembly file is changed.
		/// </summary>
		/// <param name="sender">The FileChangeManager object.</param>
		/// <param name="e">Event arguments containing the file name that was updated.</param>
		protected virtual void OnAssemblyReferenceChangedOnDisk(object sender, FileChangedOnDiskEventArgs e)
		{
			Debug.Assert(e != null, "No event arguments specified for the FileChangedOnDisk event");

			// We only care about file deletes, so check for one before enumerating references.			
			if((e.FileChangeFlag & _VSFILECHANGEFLAGS.VSFILECHG_Del) == 0)
			{
				return;
			}


			if(NativeMethods.IsSamePath(e.FileName, this.AssemblyPath))
			{
				this.OnInvalidateItems(this.Parent);
			}
		}
		#endregion
	}
}
