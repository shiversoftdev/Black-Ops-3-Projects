using System;
using System.Collections.Generic;
using System.Text;

namespace gscubuild.OpCodes
{
    public sealed class GSCUOP_SetFieldVariable : GSCUOpCode
    {
        public uint VariableHash { get; private set; }
        public GSCUOP_SetFieldVariable(uint variable_hash, ScriptOpCode code = ScriptOpCode.GSCUOP_SetVariableField)
        {
            Code = code;
            VariableHash = variable_hash;
        }

        protected override byte[] Serialize(ushort EmissionValue)
        {
            byte[] data = new byte[GetSize()];

            base.Serialize(EmissionValue).CopyTo(data, 0);

            for (int i = 2; i < data.Length; i += 2)
            {
                BitConverter.GetBytes((short)rand.Next((int)ScriptOpCode.GSCUOP_COUNT)).CopyTo(data, i); // fill padding with random garbage opcodes
            }

            BitConverter.GetBytes(VariableHash).CopyTo(data, GetCommitDataAddress() - CommitAddress);

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
