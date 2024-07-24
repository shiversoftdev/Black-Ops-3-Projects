using System;
using System.Collections.Generic;
using System.Text;

namespace gscubuild.OpCodes
{
    public sealed class GSCUOP_GetNumericValue : GSCUOpCode
    {
        protected override ScriptOpCode Code
        {
            get; set;
        }

        private object __value__;
        public object Value
        {
            get
            {
                return __value__;
            }
            set
            {
                Code = GetTypeOfValue(value);

                if (Code == ScriptOpCode.GSCUOP_COUNT)
                    throw new ArgumentException("A non-numeric argument was passed to a numeric opcode!");

                __value__ = value;
            }
        }
        public GSCUOP_GetNumericValue(object value)
        {
            Value = value;
        }

        protected override byte[] Serialize(ushort EmissionValue)
        {
            byte[] data = new byte[GetSize()];

            base.Serialize(EmissionValue).CopyTo(data, 0);

            if (Code == ScriptOpCode.GSCUOP_GetZero || Code == ScriptOpCode.GSCUOP_GetOne)
            {
                return data;
            }

            uint DataAddress = GetCommitDataAddress() - CommitAddress;

            switch (Code)
            {
                case ScriptOpCode.GSCUOP_GetInteger:
                    for (int i = 2; i < data.Length; i += 2)
                    {
                        BitConverter.GetBytes((short)rand.Next((int)ScriptOpCode.GSCUOP_COUNT)).CopyTo(data, i); // fill padding with random garbage opcodes
                    }
                    try { BitConverter.GetBytes(int.Parse(Value.ToString())).CopyTo(data, DataAddress); }
                    catch { BitConverter.GetBytes(uint.Parse(Value.ToString().Replace("-", ""))).CopyTo(data, DataAddress); }
                    break;
                case ScriptOpCode.GSCUOP_GetFloat:
                    for (int i = 2; i < data.Length; i += 2)
                    {
                        BitConverter.GetBytes((short)rand.Next((int)ScriptOpCode.GSCUOP_COUNT)).CopyTo(data, i); // fill padding with random garbage opcodes
                    }
                    BitConverter.GetBytes(float.Parse(Value.ToString())).CopyTo(data, DataAddress);
                    break;
                default:
                    BitConverter.GetBytes(byte.Parse(Value.ToString())).CopyTo(data, DataAddress);
                    break;
            }

            return data;
        }

        public override uint GetCommitDataAddress()
        {
            var size = GetValueSize();

            if(size < 1)
            {
                return (CommitAddress + GSCUOP_SIZE);
            }

            return (CommitAddress + GSCUOP_SIZE).AlignValue(size);
        }

        public override uint GetSize()
        {
            return (GetCommitDataAddress() - CommitAddress) + GetValueSize();
        }

        public byte GetValueSize()
        {
            switch(Code)
            {
                case ScriptOpCode.GSCUOP_GetFloat: return 4;
                case ScriptOpCode.GSCUOP_GetByte: return 2;
                case ScriptOpCode.GSCUOP_GetInteger: return 4;
            }
            return 0;
        }

        private static ScriptOpCode GetTypeOfValue(object value)
        {
            if (value is double || value is float)
                return ScriptOpCode.GSCUOP_GetFloat;

            long unknown;

            try { unknown = long.Parse(value.ToString()); }
            catch (Exception e) { Console.WriteLine(e.ToString()); return ScriptOpCode.GSCUOP_COUNT; }

            if (unknown == 0)
            {
                return ScriptOpCode.GSCUOP_GetZero;
            }

            if(unknown == 1)
            {
                return ScriptOpCode.GSCUOP_GetOne;
            }

            if (unknown <= 255 && unknown >= 0)
            {
                return ScriptOpCode.GSCUOP_GetByte;
            }

            return ScriptOpCode.GSCUOP_GetInteger;
        }

        public override string ToString()
        {
            return Value.ToString();
        }
    }
}
