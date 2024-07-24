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
	using System.Collections;
	using System.Collections.Generic;
	using System.Diagnostics.CodeAnalysis;
	using System.Runtime.InteropServices;
	using Microsoft.VisualStudio.Shell.Interop;
	using VSLangProj;
	using ErrorHandler = Microsoft.VisualStudio.ErrorHandler;

	/// <summary>
	/// Represents the automation object for the equivalent ReferenceContainerNode object
	/// </summary>
	[SuppressMessage("Microsoft.Naming", "CA1710:IdentifiersShouldHaveCorrectSuffix")]
	[ComVisible(true)]
	public class OAReferences : ConnectionPointContainer,
								IEventSource<_dispReferencesEvents>,
								References,
								ReferencesEvents
	{
		private readonly ReferenceContainerNode _container;

		public OAReferences(ReferenceContainerNode containerNode)
		{
			_container = containerNode;
			AddEventSource<_dispReferencesEvents>(this as IEventSource<_dispReferencesEvents>);
			_container.ChildAdded += new EventHandler<HierarchyNodeEventArgs>(OnReferenceAdded);
			_container.ChildRemoved += new EventHandler<HierarchyNodeEventArgs>(OnReferenceRemoved);
		}

		#region Private Members
		protected virtual Reference AddFromSelectorData(VSCOMPONENTSELECTORDATA selector, string wrapperTool = null)
		{
			ReferenceNode refNode = _container.AddReferenceFromSelectorData(selector, wrapperTool);
			if(null == refNode)
			{
				return null;
			}

			return refNode.Object as Reference;
		}

		protected virtual Reference FindByName(string stringIndex)
		{
			foreach(Reference refNode in this)
			{
				if(string.Equals(refNode.Name, stringIndex, StringComparison.Ordinal))
				{
					return refNode;
				}
			}
			return null;
		}
		#endregion

		#region References Members

		public virtual Reference Add(string bstrPath)
		{
			if(string.IsNullOrEmpty(bstrPath))
			{
				return null;
			}
			VSCOMPONENTSELECTORDATA selector = new VSCOMPONENTSELECTORDATA();
			selector.type = VSCOMPONENTTYPE.VSCOMPONENTTYPE_File;
			selector.bstrFile = bstrPath;

			return AddFromSelectorData(selector);
		}

		public virtual Reference AddActiveX(string bstrTypeLibGuid, int lMajorVer, int lMinorVer, int lLocaleId, string bstrWrapperTool)
		{
			VSCOMPONENTSELECTORDATA selector = new VSCOMPONENTSELECTORDATA();
			selector.type = VSCOMPONENTTYPE.VSCOMPONENTTYPE_Com2;
			selector.guidTypeLibrary = new Guid(bstrTypeLibGuid);
			selector.lcidTypeLibrary = (uint)lLocaleId;
			selector.wTypeLibraryMajorVersion = (ushort)lMajorVer;
			selector.wTypeLibraryMinorVersion = (ushort)lMinorVer;

			return AddFromSelectorData(selector, bstrWrapperTool);
		}

		public virtual Reference AddProject(EnvDTE.Project project)
		{
			if(null == project)
			{
				return null;
			}
			// Get the soulution.
			IVsSolution solution = _container.ProjectManager.Site.GetService(typeof(SVsSolution)) as IVsSolution;
			if(null == solution)
			{
				return null;
			}

			// Get the hierarchy for this project.
			IVsHierarchy projectHierarchy;
			ErrorHandler.ThrowOnFailure(solution.GetProjectOfUniqueName(project.UniqueName, out projectHierarchy));

			// Create the selector data.
			VSCOMPONENTSELECTORDATA selector = new VSCOMPONENTSELECTORDATA();
			selector.type = VSCOMPONENTTYPE.VSCOMPONENTTYPE_Project;

			// Get the project reference string.
			ErrorHandler.ThrowOnFailure(solution.GetProjrefOfProject(projectHierarchy, out selector.bstrProjRef));

			selector.bstrTitle = project.Name;
			selector.bstrFile = System.IO.Path.GetDirectoryName(project.FullName);

			return AddFromSelectorData(selector);
		}

		public EnvDTE.Project ContainingProject
		{
			get
			{
				return _container.ProjectManager.GetAutomationObject() as EnvDTE.Project;
			}
		}

		public int Count
		{
			get
			{
				return _container.EnumReferences().Count;
			}
		}

		public EnvDTE.DTE DTE
		{
			get
			{
				return _container.ProjectManager.Site.GetService(typeof(EnvDTE.DTE)) as EnvDTE.DTE;
			}
		}

		public virtual Reference Find(string bstrIdentity)
		{
			if(string.IsNullOrEmpty(bstrIdentity))
			{
				return null;
			}
			foreach(Reference refNode in this)
			{
				if(null != refNode)
				{
					if(string.Equals(bstrIdentity, refNode.Identity, StringComparison.Ordinal))
					{
						return refNode;
					}
				}
			}
			return null;
		}

		public virtual IEnumerator GetEnumerator()
		{
			List<Reference> references = new List<Reference>();
			IEnumerator baseEnum = _container.EnumReferences().GetEnumerator();
			if(null == baseEnum)
			{
				return references.GetEnumerator();
			}
			while(baseEnum.MoveNext())
			{
				ReferenceNode refNode = baseEnum.Current as ReferenceNode;
				if(null == refNode)
				{
					continue;
				}
				Reference reference = refNode.Object as Reference;
				if(null != reference)
				{
					references.Add(reference);
				}
			}
			return references.GetEnumerator();
		}

		public virtual Reference Item(object index)
		{
			string stringIndex = index as string;
			if(null != stringIndex)
			{
				return FindByName(stringIndex);
			}
			// Note that this cast will throw if the index is not convertible to int.
			int intIndex = (int)index;
			IList<ReferenceNode> refs = _container.EnumReferences();
			if(null == refs)
			{
				throw new ArgumentOutOfRangeException("index");
			}
			if((intIndex <= 0) || (intIndex > refs.Count))
			{
				throw new ArgumentOutOfRangeException("index");
			}
			// Let the implementation of IList<> throw in case of index not correct.
			return refs[intIndex - 1].Object as Reference;
		}

		public object Parent
		{
			get
			{
				return _container.Parent.Object;
			}
		}

		#endregion

		#region _dispReferencesEvents_Event Members
		public event _dispReferencesEvents_ReferenceAddedEventHandler ReferenceAdded;
		public event _dispReferencesEvents_ReferenceChangedEventHandler ReferenceChanged;
		public event _dispReferencesEvents_ReferenceRemovedEventHandler ReferenceRemoved;
		#endregion

		#region Callbacks for the HierarchyNode events
		protected virtual void OnReferenceAdded(object sender, HierarchyNodeEventArgs args)
		{
			// Validate the parameters.
			if((_container != sender as ReferenceContainerNode) ||
				(null == args) || (null == args.Child))
			{
				return;
			}

			// Check if there is any sink for this event.
			if(null == ReferenceAdded)
			{
				return;
			}

			// Check that the removed item implements the Reference interface.
			Reference reference = args.Child.Object as Reference;
			if(null != reference)
			{
				ReferenceAdded(reference);
			}
		}

        protected virtual void OnReferenceChanged(object sender, HierarchyNodeEventArgs args)
        {
            // Validate the parameters.
            if ((_container != sender as ReferenceContainerNode) ||
                (null == args) || (null == args.Child))
            {
                return;
            }

            // Check if there is any sink for this event.
            if (null == ReferenceChanged)
            {
                return;
            }

            // Check that the removed item implements the Reference interface.
            Reference reference = args.Child.Object as Reference;
            if (null != reference)
            {
                ReferenceChanged(reference);
            }
        }
        
        protected virtual void OnReferenceRemoved(object sender, HierarchyNodeEventArgs args)
		{
			// Validate the parameters.
			if((_container != sender as ReferenceContainerNode) ||
				(null == args) || (null == args.Child))
			{
				return;
			}

			// Check if there is any sink for this event.
			if(null == ReferenceRemoved)
			{
				return;
			}

			// Check that the removed item implements the Reference interface.
			Reference reference = args.Child.Object as Reference;
			if(null != reference)
			{
				ReferenceRemoved(reference);
			}
		}
		#endregion

		#region IEventSource<_dispReferencesEvents> Members
		void IEventSource<_dispReferencesEvents>.OnSinkAdded(_dispReferencesEvents sink)
		{
			ReferenceAdded += new _dispReferencesEvents_ReferenceAddedEventHandler(sink.ReferenceAdded);
			ReferenceChanged += new _dispReferencesEvents_ReferenceChangedEventHandler(sink.ReferenceChanged);
			ReferenceRemoved += new _dispReferencesEvents_ReferenceRemovedEventHandler(sink.ReferenceRemoved);
		}

		void IEventSource<_dispReferencesEvents>.OnSinkRemoved(_dispReferencesEvents sink)
		{
			ReferenceAdded -= new _dispReferencesEvents_ReferenceAddedEventHandler(sink.ReferenceAdded);
			ReferenceChanged -= new _dispReferencesEvents_ReferenceChangedEventHandler(sink.ReferenceChanged);
			ReferenceRemoved -= new _dispReferencesEvents_ReferenceRemovedEventHandler(sink.ReferenceRemoved);
		}
		#endregion
	}
}
