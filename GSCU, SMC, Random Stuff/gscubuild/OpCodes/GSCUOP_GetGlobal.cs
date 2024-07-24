using gscubuild.ScriptComponents;
using System;
using System.Collections.Generic;
using System.Text;

namespace gscubuild.OpCodes
{
    internal sealed class GSCUOP_GetGlobal : GSCUOpCode
    {
        private GSCUGlobalRef _global;
        private GSCUGlobalRef Global
        {
            get
            {
                return _global;
            }
            set
            {
                _global?.References.Remove(this);
                _global = value;
                _global?.References.Add(this);
            }
        }
        public GSCUOP_GetGlobal(GSCUGlobalRef global)
        {
            Code = ScriptOpCode.GSCUOP_GetGlobalVariable;
            Global = global;
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

        public override uint GetSize()
        {
            return GSCUOP_SIZE + 1 + 1;
        }
    }
}
