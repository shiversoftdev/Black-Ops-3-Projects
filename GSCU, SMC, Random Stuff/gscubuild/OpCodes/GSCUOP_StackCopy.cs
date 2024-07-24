using gscubuild.ScriptComponents;
using System;
using System.Collections.Generic;
using System.Text;

namespace gscubuild.OpCodes
{
    internal sealed class GSCUOP_StackCopy : GSCUOpCode
    {
        private byte Index;
        public GSCUOP_StackCopy(byte index)
        {
            Code = ScriptOpCode.GSCUOP_StackCopy;
            Index = index;
        }

        protected override byte[] Serialize(ushort EmissionValue)
        {
            byte[] data = new byte[GetSize()];
            base.Serialize(EmissionValue).CopyTo(data, 0);
            data[2] = Index;
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
