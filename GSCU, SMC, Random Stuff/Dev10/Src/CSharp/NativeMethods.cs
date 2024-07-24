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
	using System.Diagnostics;
    using System.Runtime.InteropServices;
	using Microsoft.VisualStudio.OLE.Interop;

    internal static class NativeMethods
	{
		public const int
		WM_KEYFIRST = 0x0100,
		WM_KEYLAST = 0x0108,
		WM_MOUSEFIRST = 0x0200,
		WM_MOUSELAST = 0x020A;

		/// <devdoc>
		/// Please use this "approved" method to compare file names.
		/// </devdoc>
		public static bool IsSamePath(string file1, string file2)
		{
			if(file1 == null || file1.Length == 0)
			{
				return (file2 == null || file2.Length == 0);
			}

			Uri uri1 = null;
			Uri uri2 = null;

			try
			{
				if(!Uri.TryCreate(file1, UriKind.Absolute, out uri1) || !Uri.TryCreate(file2, UriKind.Absolute, out uri2))
				{
					return false;
				}

				if(uri1 != null && uri1.IsFile && uri2 != null && uri2.IsFile)
				{
					return String.Equals(uri1.LocalPath, uri2.LocalPath, StringComparison.OrdinalIgnoreCase);
				}

				return file1 == file2;
			}
			catch(UriFormatException e)
			{
				Trace.WriteLine("Exception " + e.Message);
			}

			return false;
		}

		public const ushort CF_HDROP = 15; // winuser.h
		public const uint MK_CONTROL = 0x0008; //winuser.h
		public const uint MK_SHIFT = 0x0004;
		public const int MAX_PATH = 260; // windef.h	

		public const int ILD_NORMAL = 0x0000,
			ILD_TRANSPARENT = 0x0001,
			ILD_MASK = 0x0010,
			ILD_ROP = 0x0040;

		/// <summary>
		/// Changes the parent window of the specified child window.
		/// </summary>
		/// <param name="hWnd">Handle to the child window.</param>
		/// <param name="hWndParent">Handle to the new parent window. If this parameter is NULL, the desktop window becomes the new parent window.</param>
		/// <returns>A handle to the previous parent window indicates success. NULL indicates failure.</returns>
		[DllImport(ExternDll.User32)]
		public static extern IntPtr SetParent(IntPtr hWnd, IntPtr hWndParent);

		[DllImport(ExternDll.User32)]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool DestroyIcon(IntPtr handle);

		[DllImport("user32.dll", EntryPoint = "IsDialogMessageA", SetLastError = true, CharSet = CharSet.Ansi, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool IsDialogMessageA(IntPtr hDlg, ref MSG msg);

		/// <summary>
		/// Indicates whether the file type is binary or not
		/// </summary>
		/// <param name="lpApplicationName">Full path to the file to check</param>
		/// <param name="lpBinaryType">If file isbianry the bitness of the app is indicated by lpBinaryType value.</param>
		/// <returns>True if the file is binary false otherwise</returns>
		[DllImport(ExternDll.Kernel32)]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool GetBinaryType([MarshalAs(UnmanagedType.LPWStr)]string lpApplicationName, out uint lpBinaryType);

	}
}

