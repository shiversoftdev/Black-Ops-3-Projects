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

	[System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "STATDATA")]
	public class EnumSTATDATA : IEnumSTATDATA
	{
		private readonly IEnumerable _i;

		private readonly IEnumerator _e;

		public EnumSTATDATA(IEnumerable data)
		{
			if (data == null)
				throw new ArgumentNullException("data");

			this._i = data;
			this._e = data.GetEnumerator();
		}

		void IEnumSTATDATA.Clone(out IEnumSTATDATA clone)
		{
			clone = new EnumSTATDATA(_i);
		}

		int IEnumSTATDATA.Next(uint celt, STATDATA[] d, out uint fetched)
		{
			uint rc = 0;
			//uint size = (fetched != null) ? fetched[0] : 0;
			for(uint i = 0; i < celt; i++)
			{
				if(_e.MoveNext())
				{
					STATDATA sdata = (STATDATA)_e.Current;

					rc++;
					if(d != null && d.Length > i)
					{
						d[i] = sdata;
					}
				}
			}

			fetched = rc;
			return 0;
		}

		int IEnumSTATDATA.Reset()
		{
			_e.Reset();
			return 0;
		}

		int IEnumSTATDATA.Skip(uint celt)
		{
			for(uint i = 0; i < celt; i++)
			{
				_e.MoveNext();
			}

			return 0;
		}
	}
}
