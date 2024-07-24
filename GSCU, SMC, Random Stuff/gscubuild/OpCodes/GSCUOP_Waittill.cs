using System;
using System.Collections.Generic;
using System.Text;

namespace gscubuild.OpCodes
{
    public sealed class GSCUOP_Waittill : GSCUOpCode
    {
        int NumWaittillParams;
        public GSCUOP_Waittill(int numWaittillParams) : base(ScriptOpCode.GSCUOP_Waittill)
        {
            NumWaittillParams = numWaittillParams;
        }

        protected override byte[] Serialize(ushort EmissionValue)
        {
            byte[] data = new byte[GetSize()];

            base.Serialize(EmissionValue).CopyTo(data, 0);

            data[2] = (byte)NumWaittillParams;

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
