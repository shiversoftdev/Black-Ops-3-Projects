using System;
using System.Collections.Generic;
using System.Text;

namespace gscubuild.OpCodes
{
    public sealed class GSCUOP_Notify : GSCUOpCode
    {
        bool HasData;
        public GSCUOP_Notify(bool hasData) : base(ScriptOpCode.GSCUOP_Notify)
        {
            HasData = hasData;
        }

        protected override byte[] Serialize(ushort EmissionValue)
        {
            byte[] data = new byte[GetSize()];

            base.Serialize(EmissionValue).CopyTo(data, 0);

            data[2] = HasData ? (byte)1 : (byte)0;

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
