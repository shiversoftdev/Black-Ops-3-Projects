using System;
using System.Collections.Generic;
using System.Text;

namespace gscubuild.OpCodes
{
    internal sealed class GSCUOP_Switch : GSCUOpCode
    {
        /// <summary>
        /// The opcode this switch should end at
        /// </summary>
        public GSCUOpCode EndSwitch;
        private Dictionary<uint, GSCUOpCode> Cases;
        public GSCUOpCode DefaultCase;

        internal GSCUOP_Switch()
        {
            Code = ScriptOpCode.GSCUOP_Switch;
            Cases = new Dictionary<uint, GSCUOpCode>();
            DefaultCase = null;
            EndSwitch = null;
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

        internal bool AddCase(uint val, GSCUOpCode after)
        {
            if(Cases.ContainsKey(val))
            {
                return false;
            }
            Cases[val] = after;
            return true;
        }

        internal void CommitCases(ref byte[] data)
        {
            if (EndSwitch is null)
                throw new NotImplementedException("A switch was recorded, but the opcode to jump past for the end was never set...");

            uint JumpTo = EndSwitch.CommitAddress + EndSwitch.GetSize();
            uint JumpFrom = CommitAddress + GetSize();

            var start = GetCommitDataAddress();

            ((short)Cases.Count).ToByteArray().CopyTo(data, start + 0); // number of cases
            ((short)(DefaultCase is null ? (JumpTo - JumpFrom) : ((DefaultCase.CommitAddress + DefaultCase.GetSize()) - JumpFrom))).ToByteArray().CopyTo(data, start + 2); // default case or end switch

            start = (start + 2 + 2).AlignValue(0x4);

            foreach(var Case in Cases)
            {
                ((short)((Case.Value.CommitAddress + Case.Value.GetSize()) - JumpFrom)).ToByteArray().CopyTo(data, start);
                Case.Key.ToByteArray().CopyTo(data, start + 4);
                start += 8;
            }
        }

        public override uint GetCommitDataAddress()
        {
            return CommitAddress + GSCUOP_SIZE;
        }

        public override uint GetSize()
        {
            return (uint)((GSCUOP_SIZE + 2 + 2).AlignValue(0x4) + Cases.Count * 8);
        }
    }
}
