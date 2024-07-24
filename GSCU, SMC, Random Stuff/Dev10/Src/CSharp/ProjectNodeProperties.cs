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
	using System.ComponentModel;
	using System.Globalization;
	using System.IO;
	using System.Runtime.InteropServices;
	using Microsoft.VisualStudio.Shell;
	using Microsoft.VisualStudio.Shell.Interop;
	using IOleServiceProvider = Microsoft.VisualStudio.OLE.Interop.IServiceProvider;

	[CLSCompliant(false), ComVisible(true)]
	public class ProjectNodeProperties : NodeProperties
	{
		#region properties
		[SRCategoryAttribute(SR.Misc)]
		[LocDisplayName(SR.ProjectFolder)]
		[SRDescriptionAttribute(SR.ProjectFolderDescription)]
		[AutomationBrowsable(false)]
		public string ProjectFolder
		{
			get
			{
				return this.Node.ProjectManager.ProjectFolder;
			}
		}

		[SRCategoryAttribute(SR.Misc)]
		[LocDisplayName(SR.ProjectFile)]
		[SRDescriptionAttribute(SR.ProjectFileDescription)]
		[AutomationBrowsable(false)]
		public string ProjectFile
		{
			get
			{
				return this.Node.ProjectManager.ProjectFile;
			}
			set
			{
				this.Node.ProjectManager.ProjectFile = value;
			}
		}

		#region non-browsable properties - used for automation only
		[Browsable(false)]
		public string FileName
		{
			get
			{
				return this.Node.ProjectManager.ProjectFile;
			}
			set
			{
				this.Node.ProjectManager.ProjectFile = value;
			}
		}


		[Browsable(false)]
		public string FullPath
		{
			get
			{
				string fullPath = this.Node.ProjectManager.ProjectFolder;
				if(!fullPath.EndsWith(Path.DirectorySeparatorChar.ToString(), StringComparison.Ordinal))
				{
					return fullPath + Path.DirectorySeparatorChar;
				}
				else
				{
					return fullPath;
				}
			}
		}
		#endregion

		#endregion

		#region ctors
		public ProjectNodeProperties(ProjectNode node)
			: base(node)
		{
		}
		#endregion

		#region overridden methods
		public override string GetClassName()
		{
			return SR.GetString(SR.ProjectProperties, CultureInfo.CurrentUICulture);
		}

		/// <summary>
		/// ICustomTypeDescriptor.GetEditor
		/// To enable the "Property Pages" button on the properties browser
		/// the browse object (project properties) need to be unmanaged
		/// or it needs to provide an editor of type ComponentEditor.
		/// </summary>
		/// <param name="editorBaseType">Type of the editor</param>
		/// <returns>Editor</returns>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Reliability", "CA2000:Dispose objects before losing scope", 
            Justification="The service provider is used by the PropertiesEditorLauncher")]
        public override object GetEditor(Type editorBaseType)
		{
			// Override the scenario where we are asked for a ComponentEditor
			// as this is how the Properties Browser calls us
			if(editorBaseType == typeof(ComponentEditor))
			{
				IOleServiceProvider sp;
				ErrorHandler.ThrowOnFailure(this.Node.GetSite(out sp));
				return new PropertiesEditorLauncher(new ServiceProvider(sp));
			}

			return base.GetEditor(editorBaseType);
		}

		public override int GetCfgProvider(out IVsCfgProvider p)
		{
			if(this.Node != null && this.Node.ProjectManager != null)
			{
				return this.Node.ProjectManager.GetCfgProvider(out p);
			}

			return base.GetCfgProvider(out p);
		}
		#endregion
	}
}
