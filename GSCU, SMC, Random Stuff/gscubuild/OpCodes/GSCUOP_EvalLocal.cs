using System;
using System.Collections.Generic;
using System.Text;

namespace gscubuild.OpCodes
{
    internal sealed class GSCUOP_EvalLocal : GSCUOpCode
    {
        private GSCUOP_CreateLocalVariables LocalVariables;
        private uint Hash;
        private bool ShouldPushFirst = false;

        public GSCUOP_EvalLocal(GSCUOP_CreateLocalVariables cache, uint hash, ScriptOpCode Op, bool shouldPushFirst = false)
        {
            if (!cache.TryGetLocal(hash, out byte index))
                throw new ArgumentException("Tried to access an undefined variable.");

            LocalVariables = cache;
            Hash = hash;
            Code = Op;
            ShouldPushFirst = shouldPushFirst;
        }

        protected override byte[] Serialize(ushort EmissionValue)
        {
            byte[] data = new byte[GetSize()];

            base.Serialize(EmissionValue).CopyTo(data, 0);

            if (!LocalVariables.TryGetLocal(Hash, out byte Index))
                throw new ArgumentException("A local variable that was referenced inside the export was removed from the variables cache without purging references to it");

            data[GetCommitDataAddress() - CommitAddress] = Index;
            data[GetCommitDataAddress() - CommitAddress + 1] = ShouldPushFirst ? (byte)1 : (byte)0;

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

        public override string ToString()
        {
            return "var_" + Hash.ToString("X");
        }
    }
}
