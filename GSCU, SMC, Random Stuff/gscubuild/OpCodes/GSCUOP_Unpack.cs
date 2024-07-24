using gscubuild.ScriptComponents;
using System;
using System.Collections.Generic;
using System.Text;

namespace gscubuild.OpCodes
{
    internal sealed class GSCUOP_Unpack : GSCUOpCode
    {
        private byte Count;
        private bool Exact;
        public GSCUOP_Unpack(byte count, bool exact)
        {
            Code = ScriptOpCode.GSCUOP_Unpack;
            Count = count;
            Exact = exact;
        }

        protected override byte[] Serialize(ushort EmissionValue)
        {
            byte[] data = new byte[GetSize()];
            base.Serialize(EmissionValue).CopyTo(data, 0);
            data[2] = Count;
            data[3] = Exact ? (byte)1 : (byte)0;
            return data;
        }

        public override uint GetCommitDataAddress()
        {
            return CommitAddress + GSCUOP_SIZE;
        }

        public override uint GetSize()
        {
            return GSCUOP_SIZE + 1 + 1;
        }
    }
}
