using gscubuild.ScriptComponents;
using System;
using System.Collections.Generic;
using System.Text;

namespace gscubuild.OpCodes
{
    internal class GSCUOP_AbstractCall : GSCUOpCode
    {
        private GSCUImport __import__;
        public GSCUImport Import
        {
            get => __import__;
            protected set
            {
                __import__?.References.Remove(this);
                __import__ = value;
                __import__?.References.Add(this);
            }
        }
    }
}
