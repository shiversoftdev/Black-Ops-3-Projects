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
	using System.Runtime.InteropServices;
	using Microsoft.VisualStudio.OLE.Interop;

	[ComVisible(true)]
	public class ConnectionPointContainer : IConnectionPointContainer
	{
		private readonly Dictionary<Guid, IConnectionPoint> connectionPoints;

		public ConnectionPointContainer()
		{
			connectionPoints = new Dictionary<Guid, IConnectionPoint>();
		}

		public virtual void AddEventSource<TSink>(IEventSource<TSink> source)
			where TSink : class
		{
			if(null == source)
			{
				throw new ArgumentNullException("source");
			}
			if(connectionPoints.ContainsKey(typeof(TSink).GUID))
			{
				throw new ArgumentException("EventSource guid already added to the list of connection points", "source");
			}
			connectionPoints.Add(typeof(TSink).GUID, new ConnectionPoint<TSink>(this, source));
		}

		#region IConnectionPointContainer Members
		void IConnectionPointContainer.EnumConnectionPoints(out IEnumConnectionPoints ppEnum)
		{
			ppEnum = new EnumConnectionPoints(connectionPoints.Values);
		}

		void IConnectionPointContainer.FindConnectionPoint(ref Guid riid, out IConnectionPoint ppCP)
		{
			ppCP = connectionPoints[riid];
		}
		#endregion
	}
}
