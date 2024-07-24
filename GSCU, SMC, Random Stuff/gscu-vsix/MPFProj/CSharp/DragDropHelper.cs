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
	using System.Collections.ObjectModel;
	using System.Diagnostics;
	using System.Runtime.InteropServices;
	using System.Security.Permissions;
	using Microsoft.VisualStudio.OLE.Interop;

	[SecurityPermissionAttribute(SecurityAction.Demand, Flags = SecurityPermissionFlag.UnmanagedCode)]
	public static class DragDropHelper
	{
		[System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "VSREFPROJECTITEMS")]
		[System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1707:IdentifiersShouldNotContainUnderscores")]
		public static readonly ushort CF_VSREFPROJECTITEMS = checked((ushort)UnsafeNativeMethods.RegisterClipboardFormat("CF_VSREFPROJECTITEMS"));
		[System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "VSSTGPROJECTITEMS")]
		[System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1707:IdentifiersShouldNotContainUnderscores")]
		public static readonly ushort CF_VSSTGPROJECTITEMS = checked((ushort)UnsafeNativeMethods.RegisterClipboardFormat("CF_VSSTGPROJECTITEMS"));
		[System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "VSPROJECTCLIPDESCRIPTOR")]
		[System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1707:IdentifiersShouldNotContainUnderscores")]
		public static readonly ushort CF_VSPROJECTCLIPDESCRIPTOR = checked((ushort)UnsafeNativeMethods.RegisterClipboardFormat("CF_PROJECTCLIPBOARDDESCRIPTOR"));

		public static FORMATETC CreateFormatEtc(ushort format)
		{
			FORMATETC fmt = new FORMATETC();
			fmt.cfFormat = format;
			fmt.ptd = IntPtr.Zero;
			fmt.dwAspect = (uint)DVASPECT.DVASPECT_CONTENT;
			fmt.lindex = -1;
			fmt.tymed = (uint)TYMED.TYMED_HGLOBAL;
			return fmt;
		}

		[System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "fmtetc")]
		public static int QueryGetData(Microsoft.VisualStudio.OLE.Interop.IDataObject dataObject, ref FORMATETC fmtetc)
		{
			if (dataObject == null)
				throw new ArgumentNullException("dataObject");

			int returnValue = VSConstants.E_FAIL;
			FORMATETC[] af = new FORMATETC[1];
			af[0] = fmtetc;
			try
			{
				int result = ErrorHandler.ThrowOnFailure(dataObject.QueryGetData(af));
				if(result == VSConstants.S_OK)
				{
					fmtetc = af[0];
					returnValue = VSConstants.S_OK;
				}
			}
			catch(COMException e)
			{
				Trace.WriteLine("COMException : " + e.Message);
				returnValue = e.ErrorCode;
			}

			return returnValue;
		}

		[System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "fmtetc")]
		public static STGMEDIUM GetData(Microsoft.VisualStudio.OLE.Interop.IDataObject dataObject, ref FORMATETC fmtetc)
		{
			if (dataObject == null)
				throw new ArgumentNullException("dataObject");

			FORMATETC[] af = new FORMATETC[1];
			af[0] = fmtetc;
			STGMEDIUM[] sm = new STGMEDIUM[1];
			dataObject.GetData(af, sm);
			fmtetc = af[0];
			return sm[0];
		}

		/// <summary>
		/// Retrives data from a VS format.
		/// </summary>
		public static ReadOnlyCollection<string> GetDroppedFiles(ushort format, Microsoft.VisualStudio.OLE.Interop.IDataObject dataObject, out DropDataType ddt)
		{
			ddt = DropDataType.None;
			List<string> droppedFiles = new List<string>();

			// try HDROP
			FORMATETC fmtetc = CreateFormatEtc(format);

			if(QueryGetData(dataObject, ref fmtetc) == VSConstants.S_OK)
			{
				STGMEDIUM stgmedium = DragDropHelper.GetData(dataObject, ref fmtetc);
				if(stgmedium.tymed == (uint)TYMED.TYMED_HGLOBAL)
				{
					// We are releasing the cloned hglobal here.
					IntPtr dropInfoHandle = stgmedium.unionmember;
					if(dropInfoHandle != IntPtr.Zero)
					{
						ddt = DropDataType.Shell;
						try
						{
							uint numFiles = UnsafeNativeMethods.DragQueryFile(dropInfoHandle, 0xFFFFFFFF, null, 0);

							// We are a directory based project thus a projref string is placed on the clipboard.
							// We assign the maximum length of a projref string.
							// The format of a projref is : <Proj Guid>|<project rel path>|<file path>
							uint lenght = (uint)Guid.Empty.ToString().Length + 2 * NativeMethods.MAX_PATH + 2;
							char[] moniker = new char[lenght + 1];
							for(uint fileIndex = 0; fileIndex < numFiles; fileIndex++)
							{
								uint queryFileLength = UnsafeNativeMethods.DragQueryFile(dropInfoHandle, fileIndex, moniker, lenght);
								string filename = new String(moniker, 0, (int)queryFileLength);
								droppedFiles.Add(filename);
							}
						}
						finally
						{
							Marshal.FreeHGlobal(dropInfoHandle);
						}
					}
				}
			}

			return droppedFiles.AsReadOnly();
		}

		public static string GetSourceProjectPath(Microsoft.VisualStudio.OLE.Interop.IDataObject dataObject)
		{
			string projectPath = null;
			FORMATETC fmtetc = CreateFormatEtc(CF_VSPROJECTCLIPDESCRIPTOR);

			if(QueryGetData(dataObject, ref fmtetc) == VSConstants.S_OK)
			{
				STGMEDIUM stgmedium = DragDropHelper.GetData(dataObject, ref fmtetc);
				if(stgmedium.tymed == (uint)TYMED.TYMED_HGLOBAL && stgmedium.unionmember != IntPtr.Zero)
				{
					// We are releasing the cloned hglobal here.
					using (SafeGlobalAllocHandle dropInfoHandle = new SafeGlobalAllocHandle(stgmedium.unionmember, true))
					{
						projectPath = GetData(dropInfoHandle);
					}
				}
			}

			return projectPath;
		}

		/// <summary>
		/// Returns the data packed after the DROPFILES structure.
		/// </summary>
		/// <param name="dropHandle"></param>
		/// <returns></returns>
		public static string GetData(SafeGlobalAllocHandle dropHandle)
		{
			IntPtr data = UnsafeNativeMethods.GlobalLock(dropHandle);
			try
			{
				_DROPFILES df = (_DROPFILES)Marshal.PtrToStructure(data, typeof(_DROPFILES));
				if(df.fWide)
				{
					IntPtr pdata = new IntPtr((long)data + df.pFiles);
					return Marshal.PtrToStringUni(pdata);
				}
			}
			finally
			{
				if(data != null)
				{
					UnsafeNativeMethods.GlobalUnlock(dropHandle);
				}
			}

			return null;
		}

		public static SafeGlobalAllocHandle CopyHGlobal(SafeGlobalAllocHandle data)
		{
			IntPtr src = UnsafeNativeMethods.GlobalLock(data);
			UIntPtr size = UnsafeNativeMethods.GlobalSize(data);
			SafeGlobalAllocHandle ptr = UnsafeNativeMethods.GlobalAlloc(0, size);
			IntPtr buffer = UnsafeNativeMethods.GlobalLock(ptr);

			try
			{
				UnsafeNativeMethods.MoveMemory(buffer, src, size);
			}
			finally
			{
				if(buffer != IntPtr.Zero)
				{
					UnsafeNativeMethods.GlobalUnlock(ptr);
				}

				if(src != IntPtr.Zero)
				{
					UnsafeNativeMethods.GlobalUnlock(data);
				}
			}

			return ptr;
		}

		[System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "s")]
		public static void CopyStringToHGlobal(string s, IntPtr data, int bufferSize)
		{
			if (s == null)
				throw new ArgumentNullException("s");
			if (data == null)
				throw new ArgumentNullException("data");
			if (bufferSize < 0)
				throw new ArgumentOutOfRangeException("bufferSize");

			byte[] stringData = System.Text.Encoding.Unicode.GetBytes(s);
			if (bufferSize < stringData.Length + 2)
				throw new ArgumentException("The encoded string does not fit in the buffer.");

			Marshal.Copy(stringData, 0, data, stringData.Length);
			Marshal.WriteInt16(data, stringData.Length, 0);
		}
	}
}
