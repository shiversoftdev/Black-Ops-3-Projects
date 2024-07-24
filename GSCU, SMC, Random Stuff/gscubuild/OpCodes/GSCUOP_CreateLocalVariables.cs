using System;
using System.Collections.Generic;
using System.Text;

namespace gscubuild.OpCodes
{
    internal sealed class GSCUOP_CreateLocalVariables : GSCUOpCode
    {
        /* The Idea™ :
         * Need a fast lookup method for both the index of the variable AND inserting the variable
         * Dictionary<uint VarHash, byte StackPosition>
         * Add should be o(1) because we can do Stack[hash] = stack.size;
         * A get simply needs to invert its index by doing Stack.Count - Stack[VarHash] - 1
         * Remove, however, will be o(n) because to remove we need to do value = stack[hash]; stack.remove(hash); foreach(hash in stack.keys) if(stack[hash] > value) stack[hash]--;
         * Lookups should be o(1) because hashmap
         * 
         * All GetLocalvariablewhatever(s) should reference this object directly, then when they need to commit, should query for the location of their local variable.
         * Emit will be o(n) of course.
         */

        private Dictionary<uint, byte> Stack;
        private byte NumParams = 0;

        public GSCUOP_CreateLocalVariables()
        {
            Stack = new Dictionary<uint, byte>();
        }

        public void MarkParams()
        {
            NumParams = (byte)Stack.Count;
        }

        public int GetParamCount()
        {
            return NumParams;
        }

        protected override ScriptOpCode Code
        {
            get
            {
                return ScriptOpCode.GSCUOP_CreateLocalVariables;
            }
        }

        protected override byte[] Serialize(ushort EmissionValue)
        {
            byte[] data = new byte[GetSize()];

            base.Serialize(EmissionValue).CopyTo(data, 0);

            data[2] = (byte)(Stack.Count - NumParams);
            data[3] = (byte)NumParams;

            return data;
        }

        public uint GetStackValue(byte index)
        {
            // index = (byte)(Stack.Count + ~(int)index);

            foreach (var key in Stack.Keys)
                if (Stack[key] == index)
                    return key;
            return 0u;
        }

        public uint GetListValue(byte index)
        {
            foreach (var key in Stack.Keys)
                if (Stack[key] == index)
                    return key;
            return 0u;
        }

        public override uint GetCommitDataAddress()
        {
            if (Stack.Count < 1)
                return (CommitAddress + GSCUOP_SIZE);

            return (CommitAddress + GSCUOP_SIZE + 1).AlignValue(0x4);
        }

        /// <summary>
        /// Add a local variable to the stack and return its reference index
        /// </summary>
        /// <param name="VarHash"></param>
        /// <returns></returns>
        public byte AddLocal(uint VarHash)
        {
            //if (Stack.ContainsKey(VarHash))
            //    return (byte)(Stack.Count - Stack[VarHash] - 1);

            //Stack[VarHash] = (byte)Stack.Count;

            //return (byte)(Stack.Count - Stack[VarHash] - 1);
            if (Stack.ContainsKey(VarHash))
                return (byte)(Stack[VarHash]);

            Stack[VarHash] = (byte)Stack.Count;

            return (byte)(Stack[VarHash]);
        }

        /// <summary>
        /// Try to get a local variable's index
        /// </summary>
        /// <param name="VarHash"></param>
        /// <param name="Index"></param>
        /// <returns></returns>
        public bool TryGetLocal(uint VarHash, out byte Index)
        {
            Index = 0;

            bool result = Stack.ContainsKey(VarHash);

            //if (result)
            //    Index = (byte)(Stack.Count - Stack[VarHash] - 1);

            if (result)
                Index = (byte)(Stack[VarHash]);

            return result;
        }

        /// <summary>
        /// Remove a local from the stack
        /// </summary>
        /// <param name="VarHash"></param>
        public void RemoveLocal(uint VarHash)
        {
            if (!Stack.TryGetValue(VarHash, out byte value))
                return;

            foreach (uint key in Stack.Keys)
                if (Stack[key] > value)
                    Stack[key]--;

            Stack.Remove(VarHash);
        }

        public override uint GetSize()
        {
            return 4;
        }
    }
}
