using System;
using System.Collections.Generic;
using System.Text;

namespace gscubuild.OpCodes
{
    public class GSCUOpCode
    {
		protected static Random rand = new Random();
		public const int GSCUOP_SIZE = 2;
        public GSCUOpCode LastOpCode { get; private set; }
        public GSCUOpCode NextOpCode { get; private set; }

        public uint CommitAddress { get; internal set; }

        public ushort LoadedValue { get; set; }

        protected virtual ScriptOpCode Code { get; set; }

        public ScriptOpCode GetOpCode()
        {
            return Code;
        }

        public GSCUOpCode(ScriptOpCode op_info)
        {
            Code = op_info;
        }

        protected GSCUOpCode() { } //allows derived opcodes to not have to call base

        public virtual void Link(GSCUOpCode lastOp, GSCUOpCode nextOp)
        {
            LastOpCode = lastOp;
            NextOpCode = nextOp;
        }

        public GSCUOpCode GetEndOfChain()
        {
            if (NextOpCode == null)
                return this;

            var next = NextOpCode;

            while (next.NextOpCode != null)
                next = next.NextOpCode;

            return next;
        }

		public virtual void Append(GSCUOpCode NextOp)
        {
            if (NextOp == null)
                return;
            NextOpCode = NextOp;
            NextOp.LastOpCode = this;
        }

        public virtual void Insert(GSCUOpCode Target)
        {
            if (Target == null)
                return;

            NextOpCode = Target.NextOpCode;

            Target.NextOpCode = this;
        }

        public virtual void Unlink()
        {
            if (LastOpCode != null)
                LastOpCode.NextOpCode = NextOpCode;
            if (NextOpCode != null)
                NextOpCode.LastOpCode = LastOpCode;
        }

        protected virtual byte[] Serialize(ushort EmissionValue) //protected because we dont want outside classes calling serialize... Only needs to be protected for overrides.
        {
            return BitConverter.GetBytes(EmissionValue);
        }

        public void Commit(ref List<byte> data, ref uint BaseAddress)
        {
            CommitAddress = BaseAddress;

            data.AddRange(Serialize((ushort)Code));

            BaseAddress += GetSize();
        }

        public virtual uint GetSize()
        {
            return GSCUOP_SIZE; //All base opcodes are only 2 bytes
        }

        public virtual uint GetCommitDataAddress()
        {
            return CommitAddress + GSCUOP_SIZE; //Base opcodes have no data
        }
    }

	public enum ScriptOpCode // DEPENDENT
	{
		GSCUOP_NOP,
		GSCUOP_CreateLocalVariables,
		GSCUOP_End,
		GSCUOP_PreScriptCall,
		GSCUOP_GetByte,
		GSCUOP_GetZero,
		GSCUOP_GetOne,
		GSCUOP_GetInteger,
		GSCUOP_GetFloat,
		GSCUOP_GetString,
		GSCUOP_CallBuiltin,
		GSCUOP_Return,
		GSCUOP_DecTop,
		GSCUOP_CallScriptFunction,
		GSCUOP_Wait,
		GSCUOP_GetSelf,
		GSCUOP_ThreadCallBuiltin,
		GSCUOP_ThreadCallScript,
		GSCUOP_MethodCallBuiltin,
		GSCUOP_MethodCallScript,
		GSCUOP_EvalLocalVariableCached,
		GSCUOP_AddStruct,
		GSCUOP_SetLocalVariable,
		GSCUOP_SetVariableField,
		GSCUOP_EvalVariableField,
		GSCUOP_AddArray,
		GSCUOP_AddUndefined,
		GSCUOP_EvalFieldOnStack,
		GSCUOP_GetHash,
		GSCUOP_MakeVec2,
		GSCUOP_MakeVec3,
		GSCUOP_MakeVec4,
		GSCUOP_SetFieldOnStack,
		GSCUOP_ThreadMethodCallScript,
		GSCUOP_ThreadMethodCallBuiltin,
		GSCUOP_Endon,
		GSCUOP_Notify,
		GSCUOP_Waittill,
		GSCUOP_Waitframe,
		GSCUOP_GetAPIFunction,
		GSCUOP_GetScriptFunction,
		GSCUOP_CallPointer,
		GSCUOP_MethodCallPointer,
		GSCUOP_ThreadCallPointer,
		GSCUOP_ThreadMethodCallPointer,
		GSCUOP_BoolNot,
		GSCUOP_Jump,
		GSCUOP_JumpOnFalse,
		GSCUOP_JumpOnTrue,
		GSCUOP_JumpOnFalseExpr,
		GSCUOP_JumpOnTrueExpr,
		GSCUOP_Plus,
		GSCUOP_Minus,
		GSCUOP_Multiply,
		GSCUOP_Divide,
		GSCUOP_Modulo,
		GSCUOP_BitShiftLeft,
		GSCUOP_BitShiftRight,
		GSCUOP_BitAnd,
		GSCUOP_BitOr,
		GSCUOP_BitXor,
		GSCUOP_BitNegate,
		GSCUOP_Equals,
		GSCUOP_NotEquals,
		GSCUOP_SuperEquals,
		GSCUOP_SuperNotEquals,
		GSCUOP_GreaterThan,
		GSCUOP_LessThanEqualTo,
		GSCUOP_LessThan,
		GSCUOP_GreaterThanEqualTo,
		GSCUOP_SizeOf,
		GSCUOP_VMTime,
		GSCUOP_IncField,
		GSCUOP_DecField,
		GSCUOP_IncLocal,
		GSCUOP_DecLocal,


		GSCUOP_IsDefined,
		GSCUOP_GetGlobalVariable,
		GSCUOP_FirstField,
		GSCUOP_NextField,
		GSCUOP_GetFieldValue,
		GSCUOP_GetFieldKey,
		GSCUOP_EnterSafeContext,
		GSCUOP_ExitSafeContext,
		GSCUOP_CheckType,
		GSCUOP_CastTo,
		GSCUOP_DeconstructObject,
		GSCUOP_FreeObject,
		GSCUOP_Switch,
		GSCUOP_AddFieldOnStack,
		GSCUOP_AddField,
		GSCUOP_Breakpoint,
		GSCUOP_RegisterClass,
		GSCUOP_SetClassMethod,
		GSCUOP_GetClassMethod,
		GSCUOP_CallClassMethod,
		GSCUOP_CallClassMethodThreaded,
		GSCUOP_SpawnClassObject,
		GSCUOP_DuplicateParameters,
		GSCUOP_PopulateVararg,
		GSCUOP_Unpack,
		GSCUOP_StackCopy,
		GSCUOP_AddAnonymousFunction,
		GSCUOP_Throw,
		GSCUOP_SetClassPropSetter,
		GSCUOP_SetClassPropGetter,
		GSCUOP_GetClassPropSetter,
		GSCUOP_GetClassPropGetter,
		GSCUOP_COUNT
	}
}
