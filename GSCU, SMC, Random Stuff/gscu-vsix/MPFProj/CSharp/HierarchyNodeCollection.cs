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
    using System.Linq;
    using IEnumerable = System.Collections.IEnumerable;
    using IEnumerator = System.Collections.IEnumerator;
    using Interlocked = System.Threading.Interlocked;
    using LockRecursionPolicy = System.Threading.LockRecursionPolicy;
    using ReaderWriterLockSlim = System.Threading.ReaderWriterLockSlim;

    public class HierarchyNodeCollection : IEnumerable<KeyValuePair<uint, HierarchyNode>>, IDisposable
    {
        private readonly ProjectNode _projectManager;
        private readonly IEqualityComparer<string> _canonicalNameComparer;
        private readonly ReaderWriterLockSlim _syncObject = new ReaderWriterLockSlim(LockRecursionPolicy.SupportsRecursion);
        private readonly Dictionary<uint, HierarchyNode> _nodes = new Dictionary<uint, HierarchyNode>();
        private readonly Dictionary<HierarchyNode, uint> _itemIds = new Dictionary<HierarchyNode, uint>(ObjectReferenceEqualityComparer<HierarchyNode>.Default);

        private readonly HashSet<HierarchyNode> _nonCacheableCanonicalNameNodes = new HashSet<HierarchyNode>(ObjectReferenceEqualityComparer<HierarchyNode>.Default);
        private readonly Dictionary<HierarchyNode, string> _nodeToCanonicalNameMap = new Dictionary<HierarchyNode, string>(ObjectReferenceEqualityComparer<HierarchyNode>.Default);
        // TODO: create a dictionary for the common case of only having a single value for a particular canonical name
        private readonly Dictionary<string, List<HierarchyNode>> _canonicalNameToNodesMap;

        private int _nextNode;

        public HierarchyNodeCollection(ProjectNode projectManager, IEqualityComparer<string> canonicalNameComparer)
        {
            if (projectManager == null)
                throw new ArgumentNullException("projectManager");

            _projectManager = projectManager;
            _canonicalNameComparer = canonicalNameComparer ?? EqualityComparer<string>.Default;
            _canonicalNameToNodesMap = new Dictionary<string, List<HierarchyNode>>(_canonicalNameComparer);
        }

        public ProjectNode ProjectManager
        {
            get
            {
                //Contract.Ensures(Contract.Result<ProjectNode>() != null);

                return _projectManager;
            }
        }

        public int Count
        {
            get
            {
                //Contract.Ensures(Contract.Result<int>() >= 0);

                return _nodes.Count;
            }
        }

        public HierarchyNode this[uint itemId]
        {
            get
            {
                _syncObject.EnterReadLock();
                try
                {
                    HierarchyNode node;
                    if (!_nodes.TryGetValue(itemId, out node))
                        return null;

                    return node;
                }
                finally
                {
                    _syncObject.ExitReadLock();
                }
            }
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (disposing)
            {
                _syncObject.Dispose();
            }
        }

        public virtual uint Add(HierarchyNode node)
        {
            if (node == null)
                throw new ArgumentNullException("node");

            _syncObject.EnterWriteLock();
            try
            {
                uint itemId = (uint)Interlocked.Increment(ref _nextNode);
                _itemIds.Add(node, itemId);
                _nodes.Add(itemId, node);
                // always add the node as non-cacheable since the canonical name may not be initialized when this method is called.
                _nonCacheableCanonicalNameNodes.Add(node);
                return itemId;
            }
            finally
            {
                _syncObject.ExitWriteLock();
            }
        }

        public virtual void Remove(HierarchyNode node)
        {
            if (node == null)
                throw new ArgumentNullException("node");

            _syncObject.EnterWriteLock();
            try
            {
                uint itemId;
                if (!_itemIds.TryGetValue(node, out itemId))
                    return;

                _itemIds.Remove(node);
                _nodes.Remove(itemId);

                // remove any existing copy of this name
                if (!_nonCacheableCanonicalNameNodes.Remove(node))
                {
                    string previousName;
                    if (_nodeToCanonicalNameMap.TryGetValue(node, out previousName))
                    {
                        List<HierarchyNode> previousList;
                        if (_canonicalNameToNodesMap.TryGetValue(previousName, out previousList))
                        {
                            previousList.Remove(node);
                            if (previousList.Count == 0)
                                _canonicalNameToNodesMap.Remove(previousName);
                        }

                        _nodeToCanonicalNameMap.Remove(node);
                    }
                }
            }
            finally
            {
                _syncObject.ExitWriteLock();
            }
        }

        public virtual ReadOnlyCollection<HierarchyNode> GetNodesByName(string canonicalName)
        {
            List<HierarchyNode> nodes = new List<HierarchyNode>();

            _syncObject.EnterReadLock();
            try
            {
                List<HierarchyNode> cachedNodes;
                if (_canonicalNameToNodesMap.TryGetValue(canonicalName, out cachedNodes))
                    nodes.AddRange(cachedNodes);

                nodes.AddRange(_nonCacheableCanonicalNameNodes.Where(i => _canonicalNameComparer.Equals(canonicalName, i.CanonicalName)));
            }
            finally
            {
                _syncObject.ExitReadLock();
            }

            return nodes.AsReadOnly();
        }

        public virtual void UpdateAllCanonicalNames()
        {
            KeyValuePair<HierarchyNode, string>[] itemsToCheck = _nodeToCanonicalNameMap.ToArray();
            foreach (var item in itemsToCheck)
            {
                if (!item.Key.CanCacheCanonicalName || !_canonicalNameComparer.Equals(item.Value, item.Key.CanonicalName))
                    UpdateCanonicalName(item.Key);
            }
        }

        public virtual void UpdateCanonicalName(HierarchyNode node)
        {
            if (node == null)
                throw new ArgumentNullException("node");

            if (!node.CanCacheCanonicalName)
            {
                _syncObject.EnterWriteLock();
                try
                {
                    if (_nonCacheableCanonicalNameNodes.Add(node))
                    {
                        string previousName;
                        if (_nodeToCanonicalNameMap.TryGetValue(node, out previousName))
                        {
                            List<HierarchyNode> previousList;
                            if (_canonicalNameToNodesMap.TryGetValue(previousName, out previousList))
                            {
                                previousList.Remove(node);
                                if (previousList.Count == 0)
                                    _canonicalNameToNodesMap.Remove(previousName);
                            }

                            _nodeToCanonicalNameMap.Remove(node);
                        }
                    }
                }
                finally
                {
                    _syncObject.ExitWriteLock();
                }

                return;
            }
            else
            {
                string canonicalName = node.CanonicalName;

                _syncObject.EnterWriteLock();
                try
                {
                    // remove any existing copy of this name
                    if (!_nonCacheableCanonicalNameNodes.Remove(node))
                    {
                        string previousName;
                        if (_nodeToCanonicalNameMap.TryGetValue(node, out previousName))
                        {
                            List<HierarchyNode> previousList;
                            if (_canonicalNameToNodesMap.TryGetValue(previousName, out previousList))
                            {
                                previousList.Remove(node);
                                if (previousList.Count == 0)
                                    _canonicalNameToNodesMap.Remove(previousName);
                            }

                            _nodeToCanonicalNameMap.Remove(node);
                        }
                    }

                    _nodeToCanonicalNameMap.Add(node, canonicalName);
                    List<HierarchyNode> currentList;
                    if (!_canonicalNameToNodesMap.TryGetValue(canonicalName, out currentList))
                    {
                        currentList = new List<HierarchyNode>();
                        _canonicalNameToNodesMap.Add(canonicalName, currentList);
                    }

                    currentList.Add(node);
                }
                finally
                {
                    _syncObject.ExitWriteLock();
                }

                return;
            }
        }

        public virtual IEnumerator<KeyValuePair<uint, HierarchyNode>> GetEnumerator()
        {
            _syncObject.EnterReadLock();
            try
            {
                return new Dictionary<uint, HierarchyNode>(_nodes).GetEnumerator();
            }
            finally
            {
                _syncObject.ExitReadLock();
            }
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return GetEnumerator();
        }
    }
}
