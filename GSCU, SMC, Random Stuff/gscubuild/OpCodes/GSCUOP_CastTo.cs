using System;
using System.Collections.Generic;
using System.Text;

namespace gscubuild.OpCodes
{
    internal class GSCUOP_CastTo : GSCUOpCode
    {
        private byte CType;
        public GSCUOP_CastTo(byte type)
        {
            Code = ScriptOpCode.GSCUOP_CastTo;
            CType = type;
        }

        protected override byte[] Serialize(ushort EmissionValue)
        {
            byte[] data = new byte[GetSize()];

            base.Serialize(EmissionValue).CopyTo(data, 0);

            data[2] = CType;

            return data;
        }

        public override uint GetCommitDataAddress()
        {
            return (CommitAddress + GSCUOP_SIZE);
        }

        public override uint GetSize()
        {
            return 4;
        }
    }
}
