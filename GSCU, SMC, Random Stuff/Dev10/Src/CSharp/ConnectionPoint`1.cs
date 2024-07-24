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
	using System.Runtime.InteropServices;
	using Microsoft.VisualStudio;
	using Microsoft.VisualStudio.OLE.Interop;
	using CONNECTDATA = Microsoft.VisualStudio.OLE.Interop.CONNECTDATA;

	public class ConnectionPoint<TSink> : IConnectionPoint
		where TSink : class
	{
		private readonly Dictionary<uint, TSink> sinks;
		private readonly ConnectionPointContainer container;
		private readonly IEventSource<TSink> source;
		private uint nextCookie;

		public ConnectionPoint(ConnectionPointContainer container, IEventSource<TSink> source)
		{
			if(null == container)
			{
				throw new ArgumentNullException("container");
			}
			if(null == source)
			{
				throw new ArgumentNullException("source");
			}

			this.sinks = new Dictionary<uint, TSink>();
			this.container = container;
			this.source = source;
			this.nextCookie = 1;
		}

		#region IConnectionPoint Members
		public virtual void Advise(object pUnkSink, out uint pdwCookie)
		{
			TSink sink = pUnkSink as TSink;
			if (sink == null)
				Marshal.ThrowExceptionForHR(VSConstants.E_NOINTERFACE);

			sinks.Add(nextCookie, sink);
			pdwCookie = nextCookie;
			source.OnSinkAdded(sink);
			nextCookie += 1;
		}

		public virtual void EnumConnections(out IEnumConnections ppEnum)
		{
			ppEnum = new ConnectionEnumerator(sinks);
		}

		public virtual void GetConnectionInterface(out Guid pIID)
		{
			pIID = typeof(TSink).GUID;
		}

		public virtual void GetConnectionPointContainer(out IConnectionPointContainer ppCPC)
		{
			ppCPC = this.container;
		}

		public virtual void Unadvise(uint dwCookie)
		{
			// This will throw if the cookie is not in the list.
			TSink sink = sinks[dwCookie];
			sinks.Remove(dwCookie);
			source.OnSinkRemoved(sink);
		}
		#endregion

		[ComVisible(true)]
		protected class ConnectionEnumerator : IEnumConnections
		{
			private readonly ReadOnlyCollection<KeyValuePair<uint, TSink>> _connections;
			private int _currentIndex;

			public ConnectionEnumerator(IEnumerable<KeyValuePair<uint, TSink>> connections)
			{
				if (connections == null)
					throw new ArgumentNullException("connections");

				_connections = new List<KeyValuePair<uint, TSink>>(connections).AsReadOnly();
			}

			protected ConnectionEnumerator(ReadOnlyCollection<KeyValuePair<uint, TSink>> connections, int currentIndex)
			{
				if (connections == null)
					throw new ArgumentNullException("connections");

				_connections = connections;
				_currentIndex = currentIndex;
			}

			#region IEnumConnections Members

			public virtual void Clone(out IEnumConnections ppEnum)
			{
				ppEnum = new ConnectionEnumerator(_connections, _currentIndex);
			}

			public virtual int Next(uint cConnections, CONNECTDATA[] rgcd, out uint pcFetched)
			{
				pcFetched = 0;

				if (rgcd == null || rgcd.Length < cConnections)
					return VSConstants.E_INVALIDARG;

				int remaining = _connections.Count - _currentIndex;
				pcFetched = checked((uint)Math.Min(cConnections, remaining));
				for (int i = 0; i < pcFetched; i++)
				{
					rgcd[i].dwCookie = _connections[_currentIndex + i].Key;
					rgcd[i].punk = _connections[_currentIndex + i].Value;
				}

				_currentIndex += (int)pcFetched;
				return pcFetched == cConnections ? VSConstants.S_OK : VSConstants.S_FALSE;
			}

			public virtual int Reset()
			{
				_currentIndex = 0;
				return VSConstants.S_OK;
			}

			public virtual int Skip(uint cConnections)
			{
				int remaining = _connections.Count - _currentIndex;
				if (remaining < cConnections)
				{
					_currentIndex = _connections.Count;
					return VSConstants.S_FALSE;
				}

				_currentIndex += (int)cConnections;
				return VSConstants.S_OK;
			}

			#endregion
		}
	}
}
