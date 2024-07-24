using System;
using System.Collections.Generic;
using System.Text;

namespace gscubuild.OpCodes
{
    public sealed class GSCUOP_Endon : GSCUOpCode
    {
        int NumEndonParams;
        public GSCUOP_Endon(int numEndonParams) : base(ScriptOpCode.GSCUOP_Endon)
        {
            NumEndonParams = numEndonParams;
        }

        protected override byte[] Serialize(ushort EmissionValue)
        {
            byte[] data = new byte[GetSize()];

            base.Serialize(EmissionValue).CopyTo(data, 0);

            data[2] = (byte)NumEndonParams;

            return data;
        }

        public override uint GetCommitDataAddress()
        {
            return (CommitAddress + GSCUOP_SIZE);
        }

        public override uint GetSize()
        {
            return 2 + GetCommitDataAddress() - CommitAddress;
        }
    }
}
