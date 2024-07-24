using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

namespace gscubuild.ScriptComponents
{
    internal class GSCUScriptHeader : GSCUScriptSection
    {
        private const int GSCU_BRANCH_DEBUG = 1;
        private const int GSCU_BRANCH_RELEASE = 0;

        private const int MAGIC = 0x55435347;
#if DEBUG
        private const int GSCU_BRANCH = GSCU_BRANCH_DEBUG;
#else
        private const int GSCU_BRANCH = GSCU_BRANCH_RELEASE;
#endif
        private const int GSCU_MAJOR = 0;
        private const int GSCU_MINOR = 0;
        private const int GSCU_PATCH = 0;

        [StructLayout(LayoutKind.Sequential)]
        public struct GSCVersion
        {
            public byte branch;
            public byte major;
            public byte minor;
            public byte patch;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct GSCObjHeader
        {
            public int magic;
	        public GSCVersion version;
            public uint includes;
            public uint num_includes;

            public uint exports;
            public uint num_exports;
            public uint imports;
            public uint num_imports;

            public uint encryption_const;
            public uint src_checksum;
            public uint globals;
            public uint num_globals;

            public ulong name;
            public uint size;
            public uint flags;
        };

        public GSCUScriptObject Script { get; private set; }
        private GSCUScriptHeader(GSCUScriptObject script) { Script = script; } //We dont want initialization outside of our internal method

        public GSCObjHeader Fields;

        public override ushort Count()
        {
            return 1;
        }

        public override byte[] Serialize()
        {
            byte[] header = new byte[Size()];
            CommitHeader(ref header);
            return header;
        }

        public void CommitHeader(ref byte[] raw)
        {
            BinaryWriter writer = new BinaryWriter(new MemoryStream(raw));

            // populate const data
            Fields.magic = MAGIC;
            Fields.version.branch = GSCU_BRANCH;
            Fields.version.major = GSCU_MAJOR;
            Fields.version.minor = GSCU_MINOR;
            Fields.version.patch = GSCU_PATCH;
            Fields.size = (uint)raw.Length;

            writer.Write(Fields.ToByteArray(), 0, (int)Size());
            writer.Dispose();
        }

        public override uint Size()
        {
            return (uint)Marshal.SizeOf(typeof(GSCObjHeader));
        }

        public override void UpdateHeader(ref GSCUScriptHeader Header) { }

        public static GSCUScriptHeader New(GSCUScriptObject script)
        {
            GSCUScriptHeader header = new GSCUScriptHeader(script);
            return header;
        }
    }
}
