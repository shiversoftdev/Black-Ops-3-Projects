using gscubuild.ScriptComponents;
using System;
using System.Collections.Generic;
using System.Text;

namespace gscubuild.OpCodes
{
    public sealed class GSCUOP_GetString : GSCUOpCode
    {
        private GSCUStringTableEntry __ref__;
        public GSCUStringTableEntry ReferencedString
        {
            get => __ref__;
            private set
            {
                __ref__?.References.Remove(this);
                __ref__ = value;
                __ref__?.References.Add(this);
            }
        }

        public GSCUOP_GetString(ScriptOpCode op_info, GSCUStringTableEntry refstring) : base(op_info)
        {
            ReferencedString = refstring;
        }

        protected override byte[] Serialize(ushort EmissionValue)
        {
            byte[] data = new byte[GetSize()];

            base.Serialize(EmissionValue).CopyTo(data, 0);

            for (int i = 2; i < data.Length; i += 2)
            {
                BitConverter.GetBytes((short)rand.Next((int)ScriptOpCode.GSCUOP_COUNT)).CopyTo(data, i); // fill padding with random garbage opcodes
            }

            new byte[] { 0xFF, 0xFF, 0xFF, 0xFF }.CopyTo(data, GetCommitDataAddress() - CommitAddress);

            return data;
        }

        public override uint GetCommitDataAddress()
        {
            return (CommitAddress + GSCUOP_SIZE).AlignValue(0x4);
        }

        public override uint GetSize()
        {
            return 4 + GetCommitDataAddress() - CommitAddress;
        }
    }
}
