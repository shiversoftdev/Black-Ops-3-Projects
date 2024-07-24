using System;
using System.Collections.Generic;
using System.Text;

namespace gscubuild.OpCodes
{
    internal sealed class GSCUOP_Jump : GSCUOpCode
    {
        /// <summary>
        /// The opcode this jump should jump past
        /// </summary>
        public GSCUOpCode After;

        /// <summary>
        /// Should this jump use the loop head as a ref, or the loop end as a ref.
        /// </summary>
        public bool RefHead { get; internal set; }

        internal GSCUOP_Jump(ScriptOpCode code)
        {
            switch (code)
            {
                case ScriptOpCode.GSCUOP_Jump:
                case ScriptOpCode.GSCUOP_JumpOnFalse:
                case ScriptOpCode.GSCUOP_JumpOnFalseExpr:
                case ScriptOpCode.GSCUOP_JumpOnTrue:
                case ScriptOpCode.GSCUOP_JumpOnTrueExpr:
                case ScriptOpCode.GSCUOP_EnterSafeContext:
                case ScriptOpCode.GSCUOP_AddAnonymousFunction:
                    break;

                default:
                    throw new ArgumentException("Cannot initialize a jump object with a non-jump related operation");
            }
            Code = code;
        }

        protected override byte[] Serialize(ushort EmissionValue)
        {
            byte[] data = new byte[GetSize()];

            base.Serialize(EmissionValue).CopyTo(data, 0);

            // This is just for identification of mis-written jumps in the output binary (if there are any)
            data[2] = 0xFF;
            data[3] = 0xFF;

            return data;
        }

        internal void CommitJump(ref byte[] data)
        {
            if (After == null)
                throw new NotImplementedException("A jump was recorded, but the opcode to jump to was never set...");

            uint JumpTo = After.CommitAddress + After.GetSize();
            uint JumpFrom = CommitAddress + GetSize();

            BitConverter.GetBytes((short)(JumpTo - JumpFrom)).CopyTo(data, GetCommitDataAddress());
        }

        public override uint GetCommitDataAddress()
        {
            return CommitAddress + GSCUOP_SIZE;
        }

        public override uint GetSize()
        {
            return GSCUOP_SIZE + 2;
        }
    }
}
