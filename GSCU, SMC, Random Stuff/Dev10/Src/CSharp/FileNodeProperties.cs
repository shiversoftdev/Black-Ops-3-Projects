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
	using System.ComponentModel;
	using System.Globalization;
	using System.IO;
	using System.Linq;
	using System.Runtime.InteropServices;
	using prjBuildAction = VSLangProj.prjBuildAction;

	[CLSCompliant(false), ComVisible(true)]
	public class FileNodeProperties : NodeProperties
	{
		#region properties
		[SRCategoryAttribute(SR.Advanced)]
		[LocDisplayName(SR.BuildAction)]
		[SRDescriptionAttribute(SR.BuildActionDescription)]
		[DefaultValue(prjBuildAction.prjBuildActionNone)]
		public virtual prjBuildAction BuildAction
		{
			get
			{
				string value = this.Node.ItemNode.ItemName;
				if(value == null || value.Length == 0)
				{
					return prjBuildAction.prjBuildActionNone;
				}

				KeyValuePair<string, prjBuildAction> pair = Node.ProjectManager.AvailableFileBuildActions.FirstOrDefault(i => string.Equals(i.Key, value, StringComparison.OrdinalIgnoreCase));
				return pair.Value;
			}

			set
			{
				KeyValuePair<string, prjBuildAction> pair = Node.ProjectManager.AvailableFileBuildActions.FirstOrDefault(i => i.Value == value);
				if (!string.IsNullOrEmpty(pair.Key))
					this.Node.ItemNode.ItemName = pair.Key;
				else
					this.Node.ItemNode.ItemName = value.ToString();
			}
		}

		[SRCategoryAttribute(SR.Misc)]
		[LocDisplayName(SR.FileName)]
		[SRDescriptionAttribute(SR.FileNameDescription)]
		public virtual string FileName
		{
			get
			{
				return this.Node.Caption;
			}
			set
			{
				this.Node.SetEditLabel(value);
			}
		}

        [SRCategory(SR.Advanced)]
        [LocDisplayName(SR.CopyToOutputDirectory)]
        [SRDescription(SR.CopyToOutputDirectoryDescription)]
        [DefaultValue(CopyToOutputDirectoryBehavior.DoNotCopy)]
        public virtual CopyToOutputDirectoryBehavior CopyToOutputDirectory
        {
            get
            {
                if (this.Node.ItemNode.IsVirtual)
                    return CopyToOutputDirectoryBehavior.DoNotCopy;

                string metadata = this.Node.ItemNode.GetMetadata(ProjectFileConstants.CopyToOutputDirectory);
                if (string.IsNullOrEmpty(metadata))
                    return CopyToOutputDirectoryBehavior.DoNotCopy;

                return (CopyToOutputDirectoryBehavior)Enum.Parse(typeof(CopyToOutputDirectoryBehavior), metadata);
            }

            set
            {
                if (Node.ItemNode.IsVirtual && value != CopyToOutputDirectoryBehavior.DoNotCopy)
                {
                    Node.ItemNode = Node.ProjectManager.AddFileToMSBuild(Node.VirtualNodeName, ProjectFileConstants.Content, null);
                }

                if (this.Node.ItemNode.Item != null)
                {
                    this.Node.ItemNode.SetMetadata(ProjectFileConstants.CopyToOutputDirectory, value.ToString());
                }
            }
        }

		[SRCategoryAttribute(SR.Misc)]
		[LocDisplayName(SR.FullPath)]
		[SRDescriptionAttribute(SR.FullPathDescription)]
		public virtual string FullPath
		{
			get
			{
				return this.Node.Url;
			}
		}

		#region non-browsable properties - used for automation only
		[Browsable(false)]
		public virtual string Extension
		{
			get
			{
				return Path.GetExtension(this.Node.Caption);
			}
		}
		#endregion

		#endregion

		#region ctors
		public FileNodeProperties(FileNode node)
			: base(node)
		{
		}
		#endregion

		#region overridden methods
		public override string GetClassName()
		{
			return SR.GetString(SR.FileProperties, CultureInfo.CurrentUICulture);
		}
		#endregion
	}
}
