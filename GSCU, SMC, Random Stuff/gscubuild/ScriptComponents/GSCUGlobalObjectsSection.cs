using gscubuild.OpCodes;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace gscubuild.ScriptComponents
{
    internal class GSCUGlobalObjectsSection : GSCUScriptSection
    {
        private Dictionary<uint, GSCUGlobalRef> ObjectTable = new Dictionary<uint, GSCUGlobalRef>();
        public GSCUScriptObject Script { get; private set; }
        private GSCUGlobalObjectsSection(GSCUScriptObject script)
        {
            Script = script;
        } //Prevent public initializers

        internal static GSCUGlobalObjectsSection New(GSCUScriptObject script)
        {
            return new GSCUGlobalObjectsSection(script);
        }

        public override ushort Count()
        {
            return (ushort)ObjectTable.Count;
        }

        public override byte[] Serialize()
        {
            byte[] data = new byte[Size()];
            BinaryWriter writer = new BinaryWriter(new MemoryStream(data));
            foreach (var entry in ObjectTable)
            {
                writer.Write(entry.Key);
                writer.Write(entry.Value.References.Count);
                foreach (var val in entry.Value.References) writer.Write(val.GetCommitDataAddress());
            }
            writer.Close();
            return data;
        }

        public override uint Size()
        {
            int count = 0;
            foreach (var entry in ObjectTable) count += 8 + (entry.Value.References.Count * 4);
            return (uint)count;
        }

        public override void UpdateHeader(ref GSCUScriptHeader Header)
        {
            Header.Fields.num_globals = Count();
            Header.Fields.globals = GetBaseAddress();
        }

        public GSCUGlobalRef AddGlobal(uint value)
        {
            if (!ObjectTable.ContainsKey(value)) ObjectTable[value] = new GSCUGlobalRef();
            return ObjectTable[value];
        }
    }
    internal class GSCUGlobalRef
    {
        internal HashSet<GSCUOP_GetGlobal> References = new HashSet<GSCUOP_GetGlobal>();
    }
}
