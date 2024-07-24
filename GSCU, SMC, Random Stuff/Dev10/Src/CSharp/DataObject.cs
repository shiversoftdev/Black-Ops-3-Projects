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
	using Microsoft.VisualStudio.OLE.Interop;
	using Microsoft.VisualStudio.Shell;

	/// <summary>
	/// Unfortunately System.Windows.Forms.IDataObject and
	/// Microsoft.VisualStudio.OLE.Interop.IDataObject are different...
	/// </summary>
	public sealed class DataObject : IDataObject
	{
		#region fields
		public const int DATA_S_SAMEFORMATETC = 0x00040130;
		private readonly EventSinkCollection map;
		private readonly ArrayList entries;
		#endregion

		public DataObject()
		{
			this.map = new EventSinkCollection();
			this.entries = new ArrayList();
		}

		public void SetData(FORMATETC format, SafeGlobalAllocHandle data)
		{
			this.entries.Add(new DataCacheEntry(format, data, DATADIR.DATADIR_SET));
		}

		#region IDataObject methods
		int IDataObject.DAdvise(FORMATETC[] e, uint adv, IAdviseSink sink, out uint cookie)
		{
			if (e == null)
			{
				throw new ArgumentNullException("e");
			}

			STATDATA sdata = new STATDATA();

			sdata.ADVF = adv;
			sdata.FORMATETC = e[0];
			sdata.pAdvSink = sink;
			cookie = this.map.Add(sdata);
			sdata.dwConnection = cookie;
			return 0;
		}

		void IDataObject.DUnadvise(uint cookie)
		{
			this.map.RemoveAt(cookie);
		}

		int IDataObject.EnumDAdvise(out IEnumSTATDATA e)
		{
			e = new EnumSTATDATA((IEnumerable)this.map);
			return 0; //??
		}

		int IDataObject.EnumFormatEtc(uint direction, out IEnumFORMATETC penum)
		{
			penum = new EnumFORMATETC((DATADIR)direction, (IEnumerable)this.entries);
			return 0;
		}

		int IDataObject.GetCanonicalFormatEtc(FORMATETC[] format, FORMATETC[] fmt)
		{
			throw new System.Runtime.InteropServices.COMException("", DATA_S_SAMEFORMATETC);
		}

		[System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Reliability", "CA2001:AvoidCallingProblematicMethods", MessageId = "System.Runtime.InteropServices.SafeHandle.DangerousGetHandle")]
		void IDataObject.GetData(FORMATETC[] fmt, STGMEDIUM[] m)
		{
			STGMEDIUM retMedium = new STGMEDIUM();

			if(fmt == null || fmt.Length < 1)
				return;

			SafeGlobalAllocHandle copy = null;
			foreach(DataCacheEntry e in this.entries)
			{
				if(e.Format.cfFormat == fmt[0].cfFormat /*|| fmt[0].cfFormat == InternalNativeMethods.CF_HDROP*/)
				{
					retMedium.tymed = e.Format.tymed;

					// Caller must delete the memory.
					copy = DragDropHelper.CopyHGlobal(e.Data);
					retMedium.unionmember = copy.DangerousGetHandle();
					break;
				}
			}

			if (m != null && m.Length > 0)
			{
				m[0] = retMedium;
				if (copy != null)
					copy.SetHandleAsInvalid();
			}
		}

		void IDataObject.GetDataHere(FORMATETC[] fmt, STGMEDIUM[] m)
		{
		}

		int IDataObject.QueryGetData(FORMATETC[] fmt)
		{
			if(fmt == null || fmt.Length < 1)
				return VSConstants.S_FALSE;

			foreach(DataCacheEntry e in this.entries)
			{
				if(e.Format.cfFormat == fmt[0].cfFormat /*|| fmt[0].cfFormat == InternalNativeMethods.CF_HDROP*/)
					return VSConstants.S_OK;
			}

			return VSConstants.S_FALSE;
		}

		void IDataObject.SetData(FORMATETC[] fmt, STGMEDIUM[] m, int fRelease)
		{
		}
		#endregion
	}
}
