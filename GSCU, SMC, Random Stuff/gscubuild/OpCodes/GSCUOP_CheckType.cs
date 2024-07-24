using System;
using System.Collections.Generic;
using System.Text;

namespace gscubuild.OpCodes
{
    internal class GSCUOP_CheckType : GSCUOpCode
    {
        private byte CType;
        private bool Negate;
        public GSCUOP_CheckType(byte type, bool negate)
        {
            Code = ScriptOpCode.GSCUOP_CheckType;
            Negate = negate;
            CType = type;
        }

        protected override byte[] Serialize(ushort EmissionValue)
        {
            byte[] data = new byte[GetSize()];

            base.Serialize(EmissionValue).CopyTo(data, 0);

            data[2] = CType;
            data[3] = Negate ? (byte)1 : (byte)0;

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
