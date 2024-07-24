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

namespace Microsoft.VisualStudio.Project.Automation
{
	using System;
	using System.Runtime.InteropServices;
	using prjReferenceType = VSLangProj.prjReferenceType;
	using Reference = VSLangProj.Reference;
	using Reference2 = VSLangProj2.Reference2;
	using Reference3 = VSLangProj80.Reference3;
	using References = VSLangProj.References;

	/// <summary>
	/// Represents the automation equivalent of ReferenceNode
	/// </summary>
	/// <typeparam name="TReferenceNode"></typeparam>
	[ComVisible(true)]
	public abstract class OAReferenceBase<TReferenceNode> : Reference, Reference2, Reference3
		where TReferenceNode : ReferenceNode
	{
		private readonly TReferenceNode _referenceNode;

		protected OAReferenceBase(TReferenceNode referenceNode)
		{
			if (referenceNode == null)
				throw new ArgumentNullException("referenceNode");

			this._referenceNode = referenceNode;
		}

		protected TReferenceNode BaseReferenceNode
		{
			get
			{
				//Contract.Ensures(Contract.Result<TReferenceNode>() != null);
				return _referenceNode;
			}
		}

		#region Reference Members

		public virtual References Collection
		{
			get
			{
				return BaseReferenceNode.Parent.Object as References;
			}
		}

		public virtual EnvDTE.Project ContainingProject
		{
			get
			{
				return BaseReferenceNode.ProjectManager.GetAutomationObject() as EnvDTE.Project;
			}
		}

		public virtual bool CopyLocal
		{
			get
			{
				throw new NotSupportedException();
			}

			set
			{
				throw new NotSupportedException();
			}
		}

		public virtual string Culture
		{
			get
			{
				throw new NotSupportedException();
			}
		}

		public virtual EnvDTE.DTE DTE
		{
			get
			{
				return BaseReferenceNode.ProjectManager.Site.GetService(typeof(EnvDTE.DTE)) as EnvDTE.DTE;
			}
		}

		public virtual string Description
		{
			get
			{
				return this.Name;
			}
		}

		public virtual string ExtenderCATID
		{
			get
			{
				throw new NotSupportedException();
			}
		}

		public virtual object ExtenderNames
		{
			get
			{
				throw new NotSupportedException();
			}
		}

		public virtual string Identity
		{
			get
			{
				throw new NotSupportedException();
			}
		}

		public virtual int MajorVersion
		{
			get
			{
				return 0;
			}
		}

		public virtual int MinorVersion
		{
			get
			{
				return 0;
			}
		}

		public virtual int BuildNumber
		{
			get
			{
				return 0;
			}
		}

		public virtual int RevisionNumber
		{
			get
			{
				return 0;
			}
		}

		public virtual string Version
		{
			get
			{
				return new Version(MajorVersion, MinorVersion, BuildNumber, RevisionNumber).ToString();
			}
		}

		public virtual string Name
		{
			get
			{
				throw new NotSupportedException();
			}
		}

		public virtual string Path
		{
			get
			{
				return BaseReferenceNode.Url;
			}
		}

		public virtual string PublicKeyToken
		{
			get
			{
				throw new NotSupportedException();
			}
		}

		public virtual EnvDTE.Project SourceProject
		{
			get
			{
				return null;
			}
		}

		public virtual bool StrongName
		{
			get
			{
				return false;
			}
		}

		public virtual prjReferenceType Type
		{
			get
			{
				throw new NotSupportedException();
			}
		}

		public virtual object get_Extender(string ExtenderName)
		{
			throw new NotImplementedException();
		}

		public virtual void Remove()
		{
			BaseReferenceNode.Remove(false);
		}

		#endregion

		#region Reference2 Members

		/// <summary>
		/// Gets the version of the runtime the reference was built against.
		/// </summary>
		public virtual string RuntimeVersion
		{
			get
			{
				throw new NotSupportedException();
			}
		}

		#endregion

		#region Reference3 Members

		/// <summary>
		/// Gets or sets the aliased names for the specified reference. This property applies to Visual C# only.
		/// </summary>
		public virtual string Aliases
		{
			get
			{
				throw new NotSupportedException();
			}

			set
			{
				throw new NotSupportedException();
			}
		}

		/// <summary>
		/// Gets whether the reference is automatically referenced by the compiler.
		/// </summary>
		public virtual bool AutoReferenced
		{
			get
			{
				throw new NotSupportedException();
			}
		}

		/// <summary>
		/// Gets or sets whether the COM reference is isolated, that is, not registered with Windows.
		/// </summary>
		public virtual bool Isolated
		{
			get
			{
				throw new NotSupportedException();
			}

			set
			{
				throw new NotSupportedException();
			}
		}

		/// <summary>
		/// Gets the type of reference: assembly, COM, or native.
		/// </summary>
		public virtual uint RefType
		{
			get
			{
				throw new NotSupportedException();
			}
		}

		/// <summary>
		/// Gets whether the current reference was resolved.
		/// </summary>
		public virtual bool Resolved
		{
			get
			{
				throw new NotSupportedException();
			}
		}

		/// <summary>
		/// Gets or sets whether only a specific version of the reference is used.
		/// </summary>
		public virtual bool SpecificVersion
		{
			get
			{
				throw new NotSupportedException();
			}

			set
			{
				throw new NotSupportedException();
			}
		}

		/// <summary>
		/// Sets or Gets the assembly subtype.
		/// </summary>
		public virtual string SubType
		{
			get
			{
				throw new NotSupportedException();
			}

			set
			{
				throw new NotSupportedException();
			}
		}

		#endregion
	}
}
