using System;
using System.Collections.Generic;
using System.Text;

namespace gscubuild.OpCodes
{
    public sealed class GSCUOP_GetHash : GSCUOpCode
    {
        ulong Hash;
        public GSCUOP_GetHash(ulong hash) : base(ScriptOpCode.GSCUOP_GetHash)
        {
            Hash = hash;
        }

        protected override byte[] Serialize(ushort EmissionValue)
        {
            byte[] data = new byte[GetSize()];

            base.Serialize(EmissionValue).CopyTo(data, 0);

            for (int i = 2; i < data.Length; i += 2)
            {
                BitConverter.GetBytes((short)rand.Next((int)ScriptOpCode.GSCUOP_COUNT)).CopyTo(data, i); // fill padding with random garbage opcodes
            }

            BitConverter.GetBytes(Hash).CopyTo(data, GetCommitDataAddress() - CommitAddress);

            return data;
        }

        public override uint GetCommitDataAddress()
        {
            return (CommitAddress + GSCUOP_SIZE).AlignValue(sizeof(ulong));
        }

        public override uint GetSize()
        {
            return 8 + GetCommitDataAddress() - CommitAddress;
        }
    }
}
