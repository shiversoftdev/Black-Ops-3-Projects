using gscubuild.OpCodes;
using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

namespace gscubuild.ScriptComponents
{
    public delegate void JumpCommitter(ref byte[] data);

    internal sealed class GSCUExportsSection : GSCUScriptSection
    {
        internal Dictionary<uint, GSCUScriptExport> ScriptExports;
        private GSCUScriptExport FirstExport;
        public GSCUScriptObject Script { get; private set; }
        private GSCUExportsSection(GSCUScriptObject script)
        {
            Script = script;
            ScriptExports = new Dictionary<uint, GSCUScriptExport>();
        } //prevent public initializer

        internal static GSCUExportsSection New(GSCUScriptObject script)
        {
            GSCUExportsSection exports = new GSCUExportsSection(script);
            exports.ScriptExports = new Dictionary<uint, GSCUScriptExport>();
            return exports;
        }

        public GSCUScriptExport CreateLocal(GSCUScriptObject script)
        {
            return GSCUScriptExport.NewLocal(script);
        }

        public override ushort Count()
        {
            return (ushort)ScriptExports.Count;
        }

        public IEnumerable<GSCUScriptExport> AllExports()
        {
            foreach (var export in ScriptExports.Values)
                yield return export;
        }

        /// <summary>
        /// Serialization was overriden in this class because it makes no sense to serialize the bytecode section when not commiting
        /// </summary>
        /// <returns></returns>
        public override byte[] Serialize()
        {
            throw new InvalidOperationException("Cannot serialize the exports section!");
        }

        public override void Commit(ref byte[] RawData, ref GSCUScriptHeader Header)
        {
            uint BaseOffset = (uint)RawData.Length;
            uint BaseOffsetCached = BaseOffset;

            byte[] NewBuffer = new byte[RawData.Length + HeaderSize()];

            RawData.CopyTo(NewBuffer, 0);
            RawData = NewBuffer;

            var currentExport = FirstExport;
            while(currentExport != null)
            {
                currentExport.Commit(ref RawData, ref BaseOffset);
                currentExport = currentExport.NextExport;
            }

            //We have to copy again because we need to enforce our section alignment rules
            byte[] FinalBuffer = new byte[(uint)(RawData.Length).AlignValue(0x10)];
            RawData.CopyTo(FinalBuffer, 0);

            RawData = FinalBuffer;

            CommitSize = (uint)(RawData.Length - BaseOffsetCached);

            UpdateHeader(ref Header);
            NextSection?.Commit(ref RawData, ref Header);
        }

        private uint CommitSize;
        public override uint Size()
        {
            return CommitSize;
        }

        private uint HeaderSize()
        {
            return Count() * (uint)Marshal.SizeOf(typeof(GSCExport));
        }

        public override void UpdateHeader(ref GSCUScriptHeader Header)
        {
            Header.Fields.num_exports = Count();
            Header.Fields.exports = GetBaseAddress();
        }

        /// <summary>
        /// Add a function object to this script
        /// </summary>
        /// <param name="FunctionID">Hashed function ID for export</param>
        /// <param name="NamespaceID">Hashed namespace ID for export</param>
        /// <param name="NumParams">Number of parameters for this function</param>
        /// <returns>A new script export object. If the function already exists, a reference to the existing object.</returns>
        public GSCUScriptExport Add(uint FunctionID, uint NamespaceID, byte NumParams)
        {
            if (ScriptExports.ContainsKey(FunctionID))
                return ScriptExports[FunctionID];

            GSCUScriptExport Previous = FirstExport?.Last();
            GSCUScriptExport export = GSCUScriptExport.New(Previous, FunctionID, NamespaceID, NumParams, Script);

            if (FirstExport == null)
                FirstExport = export;

            ScriptExports[FunctionID] = export;

            return export;
        }

        /// <summary>
        /// Remove a function object from this script
        /// </summary>
        /// <param name="FunctionID">Hashed ID of the function to remove</param>
        /// <returns></returns>
        public GSCUScriptExport Remove(uint FunctionID)
        {
            if (!ScriptExports.ContainsKey(FunctionID))
                return null;

            GSCUScriptExport export = ScriptExports[FunctionID];

            ScriptExports.Remove(FunctionID);

            if (export == FirstExport)
            {
                FirstExport = export.NextExport;
            }

            export.Delete();

            return export;
        }

        /// <summary>
        /// Get a function object from this script
        /// </summary>
        /// <param name="FunctionID">Hashed ID of the function to retrieve</param>
        /// <returns></returns>
        public GSCUScriptExport Get(uint FunctionID)
        {
            if (ScriptExports.TryGetValue(FunctionID, out GSCUScriptExport result))
                return result;

            return null;
        }
    }

    [StructLayout(LayoutKind.Sequential)]
    struct GSCExport
    {
        // pointer to the bytecode for this export
        public uint bytecode;

	    // size of the bytecode for this export
	    public uint size;

	    // 32 bit hashed name of this export
	    public uint name;

	    // 32 bit namespace of this export
	    public uint space;

	    // flags of this export
	    public byte flags;

	    // minimum number of parameters used for this function
	    public byte min_params;

	    // maxmimum number of parameters used for this function
	    public byte max_params;

	    // alignment space reserved for future use
	    public byte reserved;
    }

    internal sealed class GSCUScriptExport
    {
        public GSCExport Fields;
        public GSCUScriptObject Script { get; private set; }
        private GSCUScriptExport(GSCUScriptObject script) { Script = script; } //prevent public initializers

        internal static GSCUScriptExport New(GSCUScriptExport Previous, uint fid, uint ns, byte pcount, GSCUScriptObject script)
        {
            GSCUScriptExport Export = new GSCUScriptExport(script);
            if (Previous != null)
            {
                Export.LastExport = Previous;
                Previous.NextExport = Export;
            }
            Export.Fields.name = fid;
            Export.Fields.space = ns;
            Export.Fields.min_params = 0;
            Export.Fields.max_params = pcount;
            Export.Fields.flags = 0;
            Export.Locals = new GSCUOP_CreateLocalVariables();
            Export.OpCodes.Add(Export.Locals);
            Export.FriendlyName = "func_" + fid.ToString("X");
            return Export;
        }

        internal static GSCUScriptExport NewLocal(GSCUScriptObject script)
        {
            GSCUScriptExport Export = new GSCUScriptExport(script);
            Export.Fields.name = 0;
            Export.Fields.space = 0;
            Export.Fields.min_params = 0;
            Export.Fields.max_params = 255;
            Export.Fields.flags = 0;
            Export.Locals = new GSCUOP_CreateLocalVariables();
            Export.OpCodes.Add(Export.Locals);
            Export.FriendlyName = "";
            return Export;
        }

        public GSCUScriptExport LastExport { get; private set; }
        public GSCUScriptExport NextExport { get; private set; }

        /// <summary>
        /// The friendly name of this function, for use in compilation reporting.
        /// </summary>
        public string FriendlyName;

        /// <summary>
        /// Set to true if the function is a class local export (used for fields and props)
        /// </summary>
        public bool IsClassExport;

        /// <summary>
        /// Only populated if the export is a class export
        /// </summary>
        public string ClassName;

        /// <summary>
        /// This is used when we want to perform quick removes/adds from the table
        /// </summary>
        private readonly HashSet<GSCUOpCode> OpCodes = new HashSet<GSCUOpCode>();

        /// <summary>
        /// This is used when we want to walk the opcodes through a linkedlist. Should always be either OP_CheckClearParams or OP_SafeCreateLocalVariables
        /// </summary>
        public GSCUOP_CreateLocalVariables Locals { get; private set; }

        public void Commit(ref byte[] data, ref uint NextExportPtr)
        {
            // OptimizeExport();
            List<byte> OpCodeData = new List<byte>();

            int ByteCodeAddress = data.Length.AlignValue(0x10);

            uint baseaddress = (uint)ByteCodeAddress;

            GSCUOpCode currOp = Locals;

            while (currOp != null)
            {
                currOp?.Commit(ref OpCodeData, ref baseaddress);
                currOp = currOp.NextOpCode;
            }

            byte[] NewBuffer = new byte[ByteCodeAddress + OpCodeData.Count];

            data.CopyTo(NewBuffer, 0);
            OpCodeData.CopyTo(NewBuffer, ByteCodeAddress);

            data = NewBuffer;

            CommitJumps?.Invoke(ref data);

            BinaryWriter writer = new BinaryWriter(new MemoryStream(data));
            writer.BaseStream.Position = NextExportPtr;
            Fields.bytecode = (uint)ByteCodeAddress;
            Fields.size = (uint)OpCodeData.Count;
            writer.Write(Fields.ToByteArray(), 0, Marshal.SizeOf(typeof(GSCExport)));
            writer.Dispose();

            NextExportPtr += (uint)Marshal.SizeOf(typeof(GSCExport));
        }

        public void LinkBack(GSCUScriptExport Previous)
        {
            if (Previous != null)
                Previous.NextExport = this;
            LastExport = Previous;
        }

        public GSCUScriptExport Last()
        {
            var currentExport = NextExport;

            while(currentExport != null)
            {
                if(currentExport.NextExport is null)
                {
                    return currentExport;
                }
                currentExport = currentExport.NextExport;
            }
            return this;
        }

        internal void Delete()
        {
            if (LastExport != null)
                LastExport.NextExport = NextExport;

            if (NextExport != null)
                NextExport.LastExport = LastExport;
        }

        /// <summary>
        /// Emit an operation to this instance
        /// </summary>
        /// <param name="OpData"></param>
        /// <param name="arguments"></param>
        public GSCUOpCode AddOp(ScriptOpCode OpCode)
        {
            //During development, this should stay a massive switch so the notimplementedexception is triggered
            switch (OpCode)
            {
                case ScriptOpCode.GSCUOP_SetClassPropSetter:
                case ScriptOpCode.GSCUOP_SetClassPropGetter:
                case ScriptOpCode.GSCUOP_Throw:
                case ScriptOpCode.GSCUOP_ExitSafeContext:
                case ScriptOpCode.GSCUOP_DeconstructObject:
                case ScriptOpCode.GSCUOP_DuplicateParameters:
                case ScriptOpCode.GSCUOP_BitNegate:
                case ScriptOpCode.GSCUOP_Breakpoint:
                case ScriptOpCode.GSCUOP_AddFieldOnStack:
                case ScriptOpCode.GSCUOP_AddField:
                case ScriptOpCode.GSCUOP_NOP:
                case ScriptOpCode.GSCUOP_NextField:
                case ScriptOpCode.GSCUOP_GetFieldValue:
                case ScriptOpCode.GSCUOP_GetFieldKey:
                case ScriptOpCode.GSCUOP_FirstField:
                case ScriptOpCode.GSCUOP_FreeObject:
                case ScriptOpCode.GSCUOP_ThreadCallPointer:
                case ScriptOpCode.GSCUOP_CallPointer:
                case ScriptOpCode.GSCUOP_ThreadMethodCallPointer:
                case ScriptOpCode.GSCUOP_MethodCallPointer:
                case ScriptOpCode.GSCUOP_PreScriptCall:
                case ScriptOpCode.GSCUOP_DecTop:
                case ScriptOpCode.GSCUOP_Equals:
                case ScriptOpCode.GSCUOP_NotEquals:
                case ScriptOpCode.GSCUOP_SuperEquals:
                case ScriptOpCode.GSCUOP_SuperNotEquals:
                case ScriptOpCode.GSCUOP_GreaterThan:
                case ScriptOpCode.GSCUOP_GreaterThanEqualTo:
                case ScriptOpCode.GSCUOP_LessThan:
                case ScriptOpCode.GSCUOP_LessThanEqualTo:
                case ScriptOpCode.GSCUOP_BitShiftLeft:
                case ScriptOpCode.GSCUOP_BitShiftRight:
                case ScriptOpCode.GSCUOP_BoolNot:
                case ScriptOpCode.GSCUOP_SetFieldOnStack:
                case ScriptOpCode.GSCUOP_EvalFieldOnStack:
                case ScriptOpCode.GSCUOP_VMTime:
                case ScriptOpCode.GSCUOP_IsDefined:
                case ScriptOpCode.GSCUOP_Wait:
                case ScriptOpCode.GSCUOP_Waitframe:
                case ScriptOpCode.GSCUOP_AddStruct:
                case ScriptOpCode.GSCUOP_GetSelf:
                case ScriptOpCode.GSCUOP_Plus:
                case ScriptOpCode.GSCUOP_Minus:
                case ScriptOpCode.GSCUOP_Multiply:
                case ScriptOpCode.GSCUOP_BitOr:
                case ScriptOpCode.GSCUOP_Divide:
                case ScriptOpCode.GSCUOP_Modulo:
                case ScriptOpCode.GSCUOP_BitAnd:
                case ScriptOpCode.GSCUOP_BitXor:
                case ScriptOpCode.GSCUOP_AddUndefined:
                case ScriptOpCode.GSCUOP_MakeVec2:
                case ScriptOpCode.GSCUOP_MakeVec3:
                case ScriptOpCode.GSCUOP_MakeVec4:
                case ScriptOpCode.GSCUOP_SizeOf:
                case ScriptOpCode.GSCUOP_AddArray:
                    return __addop_internal(new GSCUOpCode(OpCode));

                case ScriptOpCode.GSCUOP_Return:
                case ScriptOpCode.GSCUOP_End:
                    if(SafeContext > 0)
                    {
                        AddOp(ScriptOpCode.GSCUOP_ExitSafeContext);
                    }
                    return __addop_internal(new GSCUOpCode(OpCode));

                default:
                    throw new NotImplementedException($"AddOp tried to add operation '{OpCode.ToString()}', but this operation is not handled!");
            }
        }

        private GSCUOpCode __addop_internal(GSCUOpCode code, GSCUOpCode target = null)
        {
            OpCodes.Add(code);

            if (target == null)
                target = Locals.GetEndOfChain();

            target?.Append(code);
            return code;
        }

        /// <summary>
        /// Add any of the opcodes that get a numeric value
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        public GSCUOpCode AddGetNumber(object value)
        {
            return __addop_internal(new GSCUOP_GetNumericValue(value));
        }

        /// <summary>
        /// Add a getstring reference
        /// </summary>
        /// <param name="str"></param>
        /// <returns></returns>
        public GSCUOpCode AddGetString(GSCUStringTableEntry str)
        {
            return __addop_internal(new GSCUOP_GetString(ScriptOpCode.GSCUOP_GetString, str));
        }

        /// <summary>
        /// Add gethash to the current function
        /// </summary>
        /// <param name="Hash"></param>
        /// <returns></returns>
        public GSCUOpCode AddGetHash(ulong Hash)
        {
            return __addop_internal(new GSCUOP_GetHash(Hash));
        }

        /// <summary>
        /// Try to emit a local variable. Will throw an ArgumentException if the local cant be resolved
        /// </summary>
        /// <param name="Identifier">Lowercase version of the identifier. If not, we will run into ref issues</param>
        /// <param name="_ref"></param>
        /// <returns></returns>
        public GSCUOpCode AddEvalLocal(string identifier, uint hashformat)
        {
            GSCUOpCode code = null;

            try
            {
                code = new GSCUOP_EvalLocal(Locals, hashformat, ScriptOpCode.GSCUOP_EvalLocalVariableCached);
            }
            catch (ArgumentException)
            {
                throw new ArgumentException($"Tried to access variable '{identifier}' in function '{FriendlyName}' before it was defined");
            }
            return __addop_internal(code);
        }

        /// <summary>
        /// Try to emit a local variable. Will throw an ArgumentException if the local cant be resolved
        /// </summary>
        /// <param name="Identifier">Lowercase version of the identifier. If not, we will run into ref issues</param>
        /// <param name="_ref"></param>
        /// <returns></returns>
        public GSCUOpCode AddSetLocal(string identifier, uint hashformat)
        {
            GSCUOpCode code = null;

            try
            {
                code = new GSCUOP_EvalLocal(Locals, hashformat, ScriptOpCode.GSCUOP_SetLocalVariable);
            }
            catch (ArgumentException)
            {
                throw new ArgumentException($"Tried to access variable '{identifier}' in function '{FriendlyName}' before it was defined");
            }
            return __addop_internal(code);
        }

        public GSCUOpCode AddIncDecLocal(string identifier, uint hashformat, bool isInc, bool shouldPushFirst)
        {
            GSCUOpCode code = null;

            try
            {
                code = new GSCUOP_EvalLocal(Locals, hashformat, isInc ? ScriptOpCode.GSCUOP_IncLocal : ScriptOpCode.GSCUOP_DecLocal, shouldPushFirst);
            }
            catch (ArgumentException)
            {
                throw new ArgumentException($"Tried to access variable '{identifier}' in function '{FriendlyName}' before it was defined");
            }

            return __addop_internal(code);
        }

        public GSCUOpCode AddOperator(string op)
        {
            switch(op)
            {
                case "+":
                    return AddOp(ScriptOpCode.GSCUOP_Plus);
                case "-":
                    return AddOp(ScriptOpCode.GSCUOP_Minus);
                case "*":
                    return AddOp(ScriptOpCode.GSCUOP_Multiply);
                case "/":
                    return AddOp(ScriptOpCode.GSCUOP_Divide);
                case "%":
                    return AddOp(ScriptOpCode.GSCUOP_Modulo);
                case "&":
                    return AddOp(ScriptOpCode.GSCUOP_BitAnd);
                case "|":
                    return AddOp(ScriptOpCode.GSCUOP_BitOr);
                case "^":
                    return AddOp(ScriptOpCode.GSCUOP_BitXor);
                case "<<":
                    return AddOp(ScriptOpCode.GSCUOP_BitShiftLeft);
                case ">>":
                    return AddOp(ScriptOpCode.GSCUOP_BitShiftRight);
                case ">":
                    return AddOp(ScriptOpCode.GSCUOP_GreaterThan);
                case ">=":
                    return AddOp(ScriptOpCode.GSCUOP_GreaterThanEqualTo);
                case "<":
                    return AddOp(ScriptOpCode.GSCUOP_LessThan);
                case "<=":
                    return AddOp(ScriptOpCode.GSCUOP_LessThanEqualTo);
                case "==":
                    return AddOp(ScriptOpCode.GSCUOP_Equals);
                case "!=":
                    return AddOp(ScriptOpCode.GSCUOP_NotEquals);
                case "===":
                    return AddOp(ScriptOpCode.GSCUOP_SuperEquals);
                case "!==":
                    return AddOp(ScriptOpCode.GSCUOP_SuperNotEquals);
                default:
                    throw new NotImplementedException($"operator '{op}' hasnt been implemented");
            }
        }

        /// <summary>
        /// Add a field variable ref to the current function
        /// </summary>
        /// <param name="FunctionHash"></param>
        /// <param name="Context"></param>
        /// <returns></returns>
        public GSCUOpCode AddFieldVariable(uint FunctionHash)
        {
            return __addop_internal(new GSCUOP_EvalFieldVariable(FunctionHash));
        }

        /// <summary>
        /// Add a set variable field to the current function
        /// </summary>
        /// <param name="FunctionHash"></param>
        /// <param name="Context"></param>
        /// <returns></returns>
        public GSCUOpCode AddSetFieldVar(uint FunctionHash)
        {
            return __addop_internal(new GSCUOP_SetFieldVariable(FunctionHash));
        }

        /// <summary>
        /// Add a variable field to the current function
        /// </summary>
        /// <param name="FunctionHash"></param>
        /// <param name="Context"></param>
        /// <returns></returns>
        public GSCUOpCode AddMakeFieldVar(uint FunctionHash)
        {
            return __addop_internal(new GSCUOP_SetFieldVariable(FunctionHash, ScriptOpCode.GSCUOP_AddField));
        }

        /// <summary>
        /// Add a reference to an imported function
        /// </summary>
        /// <param name="import"></param>
        /// <returns></returns>
        public GSCUOpCode AddFunctionPtr(GSCUImport import)
        {
            return __addop_internal(new GSCUOP_GetFuncPtr(import, ScriptOpCode.GSCUOP_GetScriptFunction));
        }

        /// <summary>
        /// Add a notification event to the vm
        /// </summary>
        /// <param name="hasData"></param>
        /// <returns></returns>
        public GSCUOpCode AddNotify(bool hasData)
        {
            return __addop_internal(new GSCUOP_Notify(hasData));
        }

        /// <summary>
        /// Add an endon condition to the vm
        /// </summary>
        /// <param name="hasData"></param>
        /// <returns></returns>
        public GSCUOpCode AddEndon(int numEvents)
        {
            return __addop_internal(new GSCUOP_Endon(numEvents));
        }

        /// <summary>
        /// Add a waittill condition to the vm
        /// </summary>
        /// <param name="hasData"></param>
        /// <returns></returns>
        public GSCUOpCode AddWaittill(int numEvents)
        {
            return __addop_internal(new GSCUOP_Waittill(numEvents));
        }

        /// <summary>
        /// Handler for jumps to commit after the export size finalizes
        /// </summary>
        private JumpCommitter CommitJumps = (ref byte[] d) => { };

        /// <summary>
        /// Add a jump to this function.
        /// </summary>
        /// <param name="OpType"></param>
        /// <returns></returns>
        public GSCUOP_Jump AddJump(ScriptOpCode OpType)
        {
            GSCUOP_Jump jmp = new GSCUOP_Jump(OpType);

            CommitJumps += jmp.CommitJump; //bind the event

            return (GSCUOP_Jump)__addop_internal(jmp);
        }

        /// <summary>
        /// Add a switch opcode to this function
        /// </summary>
        /// <returns></returns>
        public GSCUOP_Switch AddSwitch()
        {
            GSCUOP_Switch swtch = new GSCUOP_Switch();

            CommitJumps += swtch.CommitCases;

            return (GSCUOP_Switch)__addop_internal(swtch);
        }

        internal GSCUOpCode AddGlobal(GSCUGlobalRef gSCUGlobalRef)
        {
            return __addop_internal(new GSCUOP_GetGlobal(gSCUGlobalRef));
        }

        /// <summary>
        /// Stack of LCF for this function
        /// </summary>
        private readonly Dictionary<int, List<GSCUOP_Jump>> LCFStack = new Dictionary<int, List<GSCUOP_Jump>>();

        /// <summary>
        /// Context for the lcf stack
        /// </summary>
        private int LCFContext;

        /// <summary>
        /// Keeps track of safe context depth for try-catch statements
        /// </summary>
        private int SafeContext;

        /// <summary>
        /// Push loop control flow (continue, break)
        /// </summary>
        /// <param name="RefHead">Should we refer to the head of the loop, or the end.</param>
        /// <returns></returns>
        internal GSCUOP_Jump PushLCF(bool RefHead, int offset = 0)
        {
            GSCUOP_Jump jmp = AddJump(ScriptOpCode.GSCUOP_Jump);
            jmp.RefHead = RefHead;
            int RealContext = LCFContext - offset;

            if (!LCFStack.ContainsKey(RealContext))
                LCFStack[RealContext] = new List<GSCUOP_Jump>();

            LCFStack[RealContext].Insert(0, jmp);

            return jmp;
        }

        /// <summary>
        /// Pop a loop control flow from the stack
        /// </summary>
        /// <param name="jmp"></param>
        /// <returns></returns>
        internal bool TryPopLCF(out GSCUOP_Jump jmp)
        {
            jmp = null;

            if (!LCFStack.ContainsKey(LCFContext) || LCFStack[LCFContext] == null)
                return false;

            if (LCFStack[LCFContext].Count < 1)
                return false;

            jmp = LCFStack[LCFContext][0];
            LCFStack[LCFContext].RemoveAt(0);

            return true;
        }

        /// <summary>
        /// Increment the LCF context
        /// </summary>
        internal void IncLCFContext()
        {
            LCFContext++;
        }

        /// <summary>
        /// Decrement the LCF context
        /// </summary>
        internal void DecLCFContext()
        {
            LCFContext--;
        }

        internal void IncSafeContext()
        {
            SafeContext++;
        }

        internal void DecSafeContext()
        {
            SafeContext--;
        }

        /// <summary>
        /// Add a call based on a reference or namespace
        /// </summary>
        /// <param name="import"></param>
        /// <param name="context"></param>
        /// <returns></returns>
        public GSCUOpCode AddCall(GSCUImport import)
        {
            return __addop_internal(new GSCUOP_Call(import));
        }

        public GSCUOpCode AddCheckType(byte type, bool negate)
        {
            return __addop_internal(new GSCUOP_CheckType(type, negate));
        }

        public GSCUOpCode AddCastTo(byte type)
        {
            return __addop_internal(new GSCUOP_CastTo(type));
        }

        public GSCUOpCode AddClassRegistration(uint classnameHash)
        {
            return __addop_internal(new GSCUOP_RegisterClass(classnameHash));
        }

        public GSCUOpCode AddClassCall(uint param_hash, ScriptOpCode code)
        {
            return __addop_internal(new GSCUOP_ClassProp(param_hash, code));
        }

        public GSCUOpCode AddVarargs(uint va_hash)
        {
            return __addop_internal(new GSCUOP_EvalLocal(Locals, va_hash, ScriptOpCode.GSCUOP_PopulateVararg, false));
        }

        public GSCUOpCode AddUnpack(int pushLimit)
        {
            return __addop_internal(new GSCUOP_Unpack((byte)pushLimit, pushLimit < 0));
        }

        public GSCUOpCode AddStackCopy(byte offset)
        {
            return __addop_internal(new GSCUOP_StackCopy(offset));
        }

        public void ConcatFunction(GSCUScriptExport child)
        {
            CommitJumps += child.CommitJumps;
            var current = Locals.GetEndOfChain();
            foreach (var code in child.GetOpcodes())
            {
                OpCodes.Add(code);
                current.Append(code);
                current = code;
            }
        }

        public GSCUOpCode[] GetOpcodes()
        {
            GSCUOpCode currOp = Locals;
            List<GSCUOpCode> codes = new List<GSCUOpCode>();
            while (currOp != null)
            {
                codes.Add(currOp);
                currOp = currOp.NextOpCode;
            }
            return codes.ToArray();
        }
    }
}
