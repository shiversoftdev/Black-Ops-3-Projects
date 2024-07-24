using gscubuild.ScriptComponents;
using System;
using System.Collections.Generic;
using System.Text;

namespace gscubuild.OpCodes
{
    internal sealed class GSCUOP_GetFuncPtr : GSCUOP_AbstractCall
    {
        internal GSCUOP_GetFuncPtr(GSCUImport import, ScriptOpCode code)
        {
            Code = code;
            Import = import;
        }

        protected override byte[] Serialize(ushort EmissionValue)
        {
            byte[] data = new byte[GetSize()];

            base.Serialize(EmissionValue).CopyTo(data, 0);

            for (int i = 2; i < data.Length; i += 2)
            {
                BitConverter.GetBytes((short)rand.Next((int)ScriptOpCode.GSCUOP_COUNT)).CopyTo(data, i); // fill padding with random garbage opcodes
            }

            return data;
        }

        public override uint GetCommitDataAddress()
        {
            return CommitAddress + GSCUOP_SIZE;
        }

        //OP_CODE 0x2
        //QWORD ALIGN
        //Function
        //0 (x4)
        public override uint GetSize()
        {
            return (GetCommitDataAddress()).AlignValue(0x8) + 8 - CommitAddress;
        }
    }
}
