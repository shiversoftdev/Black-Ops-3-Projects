using gscubuild.OpCodes;
using gscubuild.ScriptComponents;
using Irony.Parsing;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

// TODO: LNK -> link imports to exports in our script so that we can overload builtins and external calls

// TODO: intellisense: autoexec functions cannot return a value
// TODO: intellisense: undefined cannot be cast to other types
// TODO: fix exception when you k+u a line without a comment indicator
// TODO: intellisense: class sanity (one ctor, one dtor, one indexer, no duplicate variables (fields nor props)
// TODO: intellisense: duplicate namespace/class name
// TODO: intellisense: class function parameter cannot have the same name as a field
// TODO: intellisense: switch continues are not allowed

namespace gscubuild
{
    /// <summary>
    /// Note that this is a one shot use. We dont expect the compiler to get run multiple times in one instance and trying to do so will result in broken things
    /// </summary>
    internal static class GSCUCompiler // next error: 26
    {
        [Flags]
        public enum ScriptExportFlags // SOURCE: GSCObj.h
        {
            None = 0x0,
            Variadic = 0x1,
            AutoExec = 0x2,
            Private = 0x4
        }

        enum GSCUVariableType // from GSCUVARS.h
        {
            GSCUVAR_FREE = 0,
            GSCUVAR_THREAD = 1,
            GSCUVAR_BEGINPARAMS = 2,
            GSCUVAR_PRECODEPOS = 3,
            GSCUVAR_UNDEFINED = 4,
            GSCUVAR_REFVAR = 5,
            GSCUVAR_INTEGER = 6,
            GSCUVAR_STRING = 7,
            GSCUVAR_FLOAT = 8,
            GSCUVAR_STRUCT = 9,
            GSCUVAR_HASH = 10,
            GSCUVAR_VECTOR = 11,
            GSCUVAR_ENDON = 12,
            GSCUVAR_WAITTILL = 13,
            GSCUVAR_FUNCTION = 14,
            GSCUVAR_SEHFRAME = 15,
            GSCUVAR_ITERATOR2 = 16,
            GSCUVAR_COUNT
        };

        enum GSCUCastableVariableType // from GSCUVARS.h
        {
            GSCUCVAR_UNDEFINED = GSCUVariableType.GSCUVAR_UNDEFINED,
            GSCUCVAR_INTEGER = GSCUVariableType.GSCUVAR_INTEGER,
            GSCUCVAR_STRING = GSCUVariableType.GSCUVAR_STRING,
            GSCUCVAR_FLOAT = GSCUVariableType.GSCUVAR_FLOAT,
            GSCUCVAR_HASH = GSCUVariableType.GSCUVAR_HASH,
            GSCUCVAR_VECTOR = GSCUVariableType.GSCUVAR_VECTOR,
            GSCUCVAR_FUNCTION = GSCUVariableType.GSCUVAR_FUNCTION,
            GSCUCVAR_STRUCT = GSCUVariableType.GSCUVAR_COUNT,
            GSCUCVAR_ARRAY = GSCUCVAR_STRUCT + 1
        };

        struct ScriptFunctionMetadata
        {
            public string FunctionName;
            public string FunctionNamespace;
            public uint FunctionNameHash;
            public uint FunctionNamespaceHash;
            public byte NumParams;
            public byte Flags;
            public ParseTreeNode node;
            public bool IsClassFunction;
        }

        struct ScriptClassField
        {
            public string Name;
            public uint NameHash;
            public string Setter; // signature
            public string Getter; // signature
            public ParseTreeNode DefaultValue;
        }

        class ScriptClassMetadata
        {
            public string Classname;
            public uint ClassnameHash;
            public string Ctor; // signature
            public string Dtor; // signature
            public Dictionary<string, ScriptClassField> Fields;
            public List<string> Methods;
            // public ParseTreeNode Indexer;
            public ParseTreeNode node;
        }

        private static Parser SyntaxParser;
        private static shiversoft.Grammar GSCUGrammar;
        private static GSCUScriptObject Script;
        private static Dictionary<string, GSCUScriptObject> CompiledScripts;
        private static Stack<uint> NamespaceStack;
        private static Dictionary<string, ScriptFunctionMetadata> ScriptMetadata;
        private static Dictionary<string, ScriptClassMetadata> ScriptClasses;
        private static readonly Stack<QOperand> ScriptOperands;
        private static string CurrentFile;

        static GSCUCompiler()
        {
            GSCUGrammar = new shiversoft.Grammar();
            SyntaxParser = new Parser(GSCUGrammar);
            CompiledScripts = new Dictionary<string, GSCUScriptObject>();
            NamespaceStack = new Stack<uint>();
            ScriptMetadata = new Dictionary<string, ScriptFunctionMetadata>();
            ScriptOperands = new Stack<QOperand>();
            ScriptClasses = new Dictionary<string, ScriptClassMetadata>();
        }

        internal static int CompileSingle(string file, string outpath)
        {
            NamespaceStack.Clear();
            ScriptMetadata.Clear();
            ScriptOperands.Clear();
            ScriptClasses.Clear();

            if (!File.Exists(file))
            {
                return Error(file, 0, 0, 1, "file doesnt exist");
            }

            string sourceText;

            try
            {
                sourceText = File.ReadAllText(file);
            }
            catch
            {
                return Error(file, 0, 0, 2, "failed to read file");
            }

            var tree = SyntaxParser.Parse(sourceText);

            if(tree.HasErrors())
            {
                return Error(file, tree.ParserMessages[0].Location.Line, tree.ParserMessages[0].Location.Column, 3, $"{tree.ParserMessages[0].Message}");
            }

            Script = new GSCUScriptObject();
            Script.Header.Fields.name = Script.HashCanon64(file.Replace(".gscu", ""));
            CurrentFile = file;

            return CompileTree(tree, file, outpath);
        }

        static int CompileTree(ParseTree tree, string file, string outpath)
        {
            var functionTree = new Dictionary<string, ParseTreeNode>();
            foreach(var rootDirective in tree.Root.ChildNodes)
            {
                switch(rootDirective.Term.Name)
                {
                    case shiversoft.Grammar.Constants.USINGFILE:
                        Script.Includes.Add(Script.HashCanon64(rootDirective.ChildNodes[1].Token.ValueString.Replace("<", "").Replace(">", "")));
                        break;

                    case shiversoft.Grammar.Constants.IMPORTAPI:
                        Script.Includes.Add(Script.HashCanon32(rootDirective.ChildNodes[1].Token.ValueString.Replace("<", "").Replace(">", "")) | 0x8000000000000000);
                        break;

                    case shiversoft.Grammar.Constants.NAMESPACE:

                        string currentNs = rootDirective.ChildNodes[1].Token.ValueString.ToLower();
                        uint ns_value = Script.HashCanon32(currentNs);

                        foreach(var directive in rootDirective.ChildNodes[2].ChildNodes)
                        {
                            CollectFunction(directive, currentNs, ns_value, file);
                        }

                        break;

                    case shiversoft.Grammar.Constants.CLASS:

                        string className = rootDirective.ChildNodes[1].FindTokenAndGetText().ToLower();

                        if(ScriptClasses.ContainsKey(className))
                        {
                            Error(file, rootDirective.Span.Location.Line, rootDirective.Span.Location.Column, 21, $"class '{className}' has already been declared in this script.");
                            break;
                        }

                        ScriptClasses[className] = new ScriptClassMetadata();
                        ScriptClasses[className].Classname = className;
                        ScriptClasses[className].ClassnameHash = Script.HashCanon32(className);
                        ScriptClasses[className].Fields = new Dictionary<string, ScriptClassField>();
                        ScriptClasses[className].Methods = new List<string>();
                        ScriptClasses[className].node = rootDirective;

                        foreach(var classDirective in rootDirective.ChildNodes[2].ChildNodes)
                        {
                            switch(classDirective.Term.Name)
                            {
                                case shiversoft.Grammar.Constants.CTOR:
                                    {
                                        if(ScriptClasses[className].Ctor != null)
                                        {
                                            Error(file, classDirective.Span.Location.Line, classDirective.Span.Location.Column, 5, $"function redefinition '{className}::constructor'");
                                            continue;
                                        }

                                        ScriptClasses[className].Ctor = $"{className}::.ctor";

                                        if (ScriptMetadata.ContainsKey(ScriptClasses[className].Ctor))
                                        {
                                            Error(file, classDirective.Span.Location.Line, classDirective.Span.Location.Column, 5, $"function redefinition '{className}::constructor'");
                                            continue;
                                        }

                                        byte flgs = 0;
                                        bool abort = false;
                                        for (int i = 0; i < classDirective.ChildNodes[1].ChildNodes.Count; i++)
                                        {
                                            var paramNode = classDirective.ChildNodes[1].ChildNodes[i].ChildNodes[0];

                                            if (paramNode.Term.Name == shiversoft.Grammar.Constants.IDENTIFIER)
                                            {
                                                continue;
                                            }

                                            if ((paramNode.Token?.ValueString ?? "") == "...")
                                            {
                                                if (i + 1 != classDirective.ChildNodes[1].ChildNodes.Count)
                                                {
                                                    Error(file, paramNode.Span.Location.Line, paramNode.Span.Location.Column, 8, $"variadic arguments list must be at the end of the function parameters list");
                                                    abort = true;
                                                    break;
                                                }

                                                flgs |= (byte)ScriptExportFlags.Variadic;
                                                break;
                                            }
                                        }

                                        if (abort)
                                        {
                                            continue;
                                        }

                                        ScriptMetadata[ScriptClasses[className].Ctor] = new ScriptFunctionMetadata()
                                        {
                                            FunctionName = ".ctor",
                                            FunctionNamespace = className,
                                            FunctionNameHash = Script.HashCanon32(".ctor"),
                                            FunctionNamespaceHash = Script.HashCanon32(className),
                                            NumParams = (byte)classDirective.ChildNodes[1].ChildNodes.Count,
                                            Flags = flgs,
                                            node = classDirective,
                                            IsClassFunction = true
                                        };
                                    }
                                    break;

                                case shiversoft.Grammar.Constants.DTOR:
                                    {
                                        if (ScriptClasses[className].Dtor != null)
                                        {
                                            Error(file, classDirective.Span.Location.Line, classDirective.Span.Location.Column, 5, $"function '{className}::destructor' can only be declared once");
                                            continue;
                                        }

                                        ScriptClasses[className].Dtor = $"{className}::.dtor";

                                        if (ScriptMetadata.ContainsKey(ScriptClasses[className].Dtor))
                                        {
                                            Error(file, classDirective.Span.Location.Line, classDirective.Span.Location.Column, 5, $"function '{className}::destructor' can only be declared once");
                                            continue;
                                        }

                                        if(classDirective.ChildNodes[classDirective.ChildNodes.FindIndex(e => e.Term.Name == shiversoft.Grammar.Constants.FUNCTIONPARAMETERS)].ChildNodes.Count > 0)
                                        {
                                            Error(file, classDirective.Span.Location.Line, classDirective.Span.Location.Column, 23, $"class destructors should not have any parameters");
                                            continue;
                                        }

                                        ScriptMetadata[ScriptClasses[className].Dtor] = new ScriptFunctionMetadata()
                                        {
                                            FunctionName = ".dtor",
                                            FunctionNamespace = className,
                                            FunctionNameHash = Script.HashCanon32(".dtor"),
                                            FunctionNamespaceHash = Script.HashCanon32(className),
                                            NumParams = (byte)classDirective.ChildNodes[1].ChildNodes.Count,
                                            Flags = 0,
                                            node = classDirective,
                                            IsClassFunction = true
                                        };
                                    }
                                    break;

                                case shiversoft.Grammar.Constants.CLASSFIELD:
                                    {
                                        // note: fields do not have a setter or getter. we reuse the term for props only in the struct.
                                        string fieldname = classDirective.ChildNodes[1].FindTokenAndGetText().ToLower();

                                        if(ScriptClasses[className].Fields.ContainsKey(fieldname))
                                        {
                                            Error(file, classDirective.Span.Location.Line, classDirective.Span.Location.Column, 22, $"class field/property '{className}::{fieldname}' can only be declared once");
                                            continue;
                                        }

                                        ScriptClasses[className].Fields[fieldname] = new ScriptClassField()
                                        {
                                            Name = fieldname,
                                            NameHash = Script.HashCanon32(fieldname),
                                            DefaultValue = classDirective.ChildNodes.Count > 3 ? classDirective.ChildNodes[3] : null
                                        };
                                    }
                                    break;

                                case shiversoft.Grammar.Constants.CLASSPROP:
                                    {
                                        string fieldname = classDirective.ChildNodes[1].FindTokenAndGetText().ToLower();
                                        if (ScriptClasses[className].Fields.ContainsKey(fieldname))
                                        {
                                            Error(file, classDirective.Span.Location.Line, classDirective.Span.Location.Column, 22, $"class field/property '{className}::{fieldname}' can only be declared once");
                                            continue;
                                        }

                                        ParseTreeNode getter, setter;
                                        string getstr = $"{className}::{fieldname}.get";
                                        string setstr = $"{className}::{fieldname}.set";
                                        if (classDirective.ChildNodes[2].Term.Name == shiversoft.Grammar.Constants.GETDEC)
                                        {
                                            getter = classDirective.ChildNodes[2];
                                            setter = classDirective.ChildNodes[3];
                                        }
                                        else
                                        {
                                            getter = classDirective.ChildNodes[3];
                                            setter = classDirective.ChildNodes[2];
                                        }

                                        ScriptMetadata[getstr] = new ScriptFunctionMetadata()
                                        {
                                            FunctionName = $"{fieldname}.get",
                                            FunctionNamespace = className,
                                            FunctionNameHash = Script.HashCanon32($"{fieldname}.get"),
                                            FunctionNamespaceHash = Script.HashCanon32(className),
                                            NumParams = 0,
                                            Flags = 0,
                                            node = getter,
                                            IsClassFunction = true
                                        };

                                        ScriptMetadata[setstr] = new ScriptFunctionMetadata()
                                        {
                                            FunctionName = $"{fieldname}.set",
                                            FunctionNamespace = className,
                                            FunctionNameHash = Script.HashCanon32($"{fieldname}.set"),
                                            FunctionNamespaceHash = Script.HashCanon32(className),
                                            NumParams = 1,
                                            Flags = 0,
                                            node = setter,
                                            IsClassFunction = true
                                        };

                                        ScriptClasses[className].Fields[fieldname] = new ScriptClassField()
                                        {
                                            Name = fieldname,
                                            NameHash = Script.HashCanon32(fieldname),
                                            DefaultValue = null,
                                            Getter = getstr,
                                            Setter = setstr
                                        };
                                    }
                                    break;

                                case shiversoft.Grammar.Constants.FUNCTION:
                                    {
                                        int res = CollectFunction(classDirective, className, ScriptClasses[className].ClassnameHash, file, true);
                                        if(res != 0)
                                        {
                                            continue;
                                        }
                                        var sig = $"{className}::{classDirective.ChildNodes[2].Token.ValueString.ToLower()}";
                                        var meta = ScriptMetadata[sig];
                                        if((meta.Flags & (int)ScriptExportFlags.AutoExec) > 0)
                                        {
                                            Warning(file, classDirective.Span.Location.Line, classDirective.Span.Location.Column, 24, $"class functions cannot contain the 'autoexec' qualifier");
                                            meta.Flags = (byte)(meta.Flags & ~(int)ScriptExportFlags.AutoExec); // clear it
                                        }
                                        ScriptClasses[className].Methods.Add(sig);
                                    }
                                    break;

                                default:
                                    throw new NotImplementedException();
                            }
                        }

                        string static_auto_ctor_name = $"{className}::.static.ctor";
                        var static_auto_ctor = Script.Exports.Add(Script.HashCanon32(static_auto_ctor_name), Script.HashCanon32(className), 0);
                        static_auto_ctor.Fields.flags = (int)ScriptExportFlags.Private | (int)ScriptExportFlags.AutoExec;
                        static_auto_ctor.FriendlyName = $"{className}::<static class initializer>";

                        string ctor_auto_name = $"{className}::.ctor_auto";
                        var ctor_auto_hash = Script.HashCanon32(".ctor_auto");
                        var ctor_auto = Script.Exports.Add(ctor_auto_hash, Script.HashCanon32(className), ScriptClasses[className].Ctor != null ? ScriptMetadata[ScriptClasses[className].Ctor].NumParams : (byte)0);
                        ctor_auto.Fields.flags = ScriptMetadata[ScriptClasses[className].Ctor].Flags; // to catch variadic
                        ctor_auto.FriendlyName = $"{className}::<class constructor>";

                        string dtor_auto_name = $"{className}::.dtor_auto";
                        var dtor_auto_hash = Script.HashCanon32(".dtor_auto");
                        var dtor_auto = Script.Exports.Add(dtor_auto_hash, Script.HashCanon32(className), 0);
                        dtor_auto.Fields.flags = (int)ScriptExportFlags.Private;
                        dtor_auto.FriendlyName = $"{className}::<class destructor>";

                        if (ScriptClasses[className].Ctor != null)
                        {
                            static_auto_ctor.AddFunctionPtr(Script.Imports.AddImport(ScriptMetadata[ScriptClasses[className].Ctor].FunctionNameHash, ScriptMetadata[ScriptClasses[className].Ctor].FunctionNamespaceHash, 0, (byte)GSCUImportFlags.GSCUIF_REF));
                        }
                        else
                        {
                            static_auto_ctor.AddOp(ScriptOpCode.GSCUOP_AddUndefined);
                        }

                        if (ScriptClasses[className].Dtor != null)
                        {
                            static_auto_ctor.AddFunctionPtr(Script.Imports.AddImport(ScriptMetadata[ScriptClasses[className].Dtor].FunctionNameHash, ScriptMetadata[ScriptClasses[className].Dtor].FunctionNamespaceHash, 0, (byte)GSCUImportFlags.GSCUIF_REF));
                        }
                        else
                        {
                            static_auto_ctor.AddOp(ScriptOpCode.GSCUOP_AddUndefined);
                        }

                        static_auto_ctor.AddClassRegistration(ScriptClasses[className].ClassnameHash);

                        static_auto_ctor.AddFunctionPtr(Script.Imports.AddImport(ctor_auto_hash, ScriptClasses[className].ClassnameHash, 0, (byte)GSCUImportFlags.GSCUIF_REF));
                        static_auto_ctor.AddGetNumber(ctor_auto_hash);
                        static_auto_ctor.AddClassCall(ScriptClasses[className].ClassnameHash, ScriptOpCode.GSCUOP_SetClassMethod);

                        static_auto_ctor.AddFunctionPtr(Script.Imports.AddImport(dtor_auto_hash, ScriptClasses[className].ClassnameHash, 0, (byte)GSCUImportFlags.GSCUIF_REF));
                        static_auto_ctor.AddGetNumber(dtor_auto_hash);
                        static_auto_ctor.AddClassCall(ScriptClasses[className].ClassnameHash, ScriptOpCode.GSCUOP_SetClassMethod);

                        foreach (var method in ScriptClasses[className].Methods)
                        {
                            static_auto_ctor.AddFunctionPtr(Script.Imports.AddImport(ScriptMetadata[method].FunctionNameHash, ScriptMetadata[method].FunctionNamespaceHash, 0, (byte)GSCUImportFlags.GSCUIF_REF));
                            static_auto_ctor.AddGetNumber(ScriptMetadata[method].FunctionNameHash);
                            static_auto_ctor.AddClassCall(ScriptClasses[className].ClassnameHash, ScriptOpCode.GSCUOP_SetClassMethod);
                        }

                        foreach(var fieldProp in ScriptClasses[className].Fields)
                        {
                            if(fieldProp.Value.Getter is null)
                            {
                                continue;
                            }

                            static_auto_ctor.AddGetHash(ScriptClasses[className].ClassnameHash);
                            static_auto_ctor.AddGetHash(fieldProp.Value.NameHash);
                            static_auto_ctor.AddFunctionPtr(Script.Imports.AddImport(ScriptMetadata[fieldProp.Value.Getter].FunctionNameHash, ScriptMetadata[fieldProp.Value.Getter].FunctionNamespaceHash, 0, (byte)GSCUImportFlags.GSCUIF_REF));
                            static_auto_ctor.AddOp(ScriptOpCode.GSCUOP_SetClassPropGetter);

                            static_auto_ctor.AddGetHash(ScriptClasses[className].ClassnameHash);
                            static_auto_ctor.AddGetHash(fieldProp.Value.NameHash);
                            static_auto_ctor.AddFunctionPtr(Script.Imports.AddImport(ScriptMetadata[fieldProp.Value.Setter].FunctionNameHash, ScriptMetadata[fieldProp.Value.Setter].FunctionNamespaceHash, 0, (byte)GSCUImportFlags.GSCUIF_REF));
                            static_auto_ctor.AddOp(ScriptOpCode.GSCUOP_SetClassPropSetter);
                        }

                        static_auto_ctor.AddOp(ScriptOpCode.GSCUOP_End);

                        foreach (var fieldProp in ScriptClasses[className].Fields)
                        {
                            if(fieldProp.Value.DefaultValue is null)
                            {
                                continue;
                            }

                            ctor_auto.AddOp(ScriptOpCode.GSCUOP_GetSelf);

                            ScriptOperands.Clear();
                            Push(ctor_auto, fieldProp.Value.DefaultValue, 0);
                            IterateStack();

                            ctor_auto.AddSetFieldVar(fieldProp.Value.NameHash);
                        }

                        if(ScriptClasses[className].Ctor != null)
                        {
                            ctor_auto.AddOp(ScriptOpCode.GSCUOP_PreScriptCall);
                            ctor_auto.AddOp(ScriptOpCode.GSCUOP_DuplicateParameters);
                            ctor_auto.AddOp(ScriptOpCode.GSCUOP_GetSelf);
                            ctor_auto.AddClassCall(ScriptMetadata[ScriptClasses[className].Ctor].FunctionNameHash, ScriptOpCode.GSCUOP_CallClassMethod);
                            ctor_auto.AddOp(ScriptOpCode.GSCUOP_DecTop);
                        }

                        ctor_auto.AddOp(ScriptOpCode.GSCUOP_GetSelf);
                        ctor_auto.AddOp(ScriptOpCode.GSCUOP_Return);

                        if(ScriptClasses[className].Dtor != null)
                        {
                            dtor_auto.AddOp(ScriptOpCode.GSCUOP_PreScriptCall);
                            dtor_auto.AddOp(ScriptOpCode.GSCUOP_GetSelf);
                            dtor_auto.AddClassCall(ScriptMetadata[ScriptClasses[className].Dtor].FunctionNameHash, ScriptOpCode.GSCUOP_CallClassMethod);
                            dtor_auto.AddOp(ScriptOpCode.GSCUOP_DecTop);
                        }

                        dtor_auto.AddOp(ScriptOpCode.GSCUOP_GetSelf);
                        dtor_auto.AddOp(ScriptOpCode.GSCUOP_Return);

                        break;

                    default:
                        throw new NotImplementedException();
                }
            }

            foreach(var fn in ScriptMetadata.Values)
            {
                EmitExport(fn);
            }

            CompiledScripts[file] = Script;

            try
            {
                File.WriteAllBytes(outpath, CompiledScripts[file].Serialize());
            }
            catch
            {
                return Error(file, 0, 0, 4, "Failed to serialize script object");
            }

            return 0;
        }

        static int CollectFunction(ParseTreeNode directive, string currentNs, uint ns_value, string file, bool isClassFunction = false)
        {
            string currentFn = directive.ChildNodes[2].Token.ValueString.ToLower();
            string fnSig = $"{currentNs}::{currentFn}";

            if (ScriptMetadata.ContainsKey(fnSig))
            {
                return Error(file, directive.Span.Location.Line, directive.Span.Location.Column, 5, $"function '{fnSig}' was defined more than once");
            }

            if (directive.ChildNodes[3].ChildNodes.Count >= 255)
            {
                return Error(file, directive.Span.Location.Line, directive.Span.Location.Column, 6, $"function has too many parameters '{directive.ChildNodes[3].ChildNodes.Count}' (cannot exceed 255 parameters)");
            }

            byte flgs = 0;

            foreach (var flagNode in directive.ChildNodes[1].ChildNodes)
            {
                switch (flagNode.Term.Name)
                {
                    case shiversoft.Grammar.Constants.PRIVATE:
                        if ((flgs & (byte)ScriptExportFlags.Private) > 0)
                        {
                            Warning(file, flagNode.Span.Location.Line, flagNode.Span.Location.Column, 7, "redeclaration of private attribute");
                            continue;
                        }
                        flgs |= (byte)ScriptExportFlags.Private;
                        break;
                    case shiversoft.Grammar.Constants.AUTOEXEC:
                        if ((flgs & (byte)ScriptExportFlags.AutoExec) > 0)
                        {
                            Warning(file, flagNode.Span.Location.Line, flagNode.Span.Location.Column, 7, "redeclaration of autoexec attribute");
                            continue;
                        }
                        flgs |= (byte)ScriptExportFlags.AutoExec;
                        break;
                }
            }

            for (int i = 0; i < directive.ChildNodes[3].ChildNodes.Count; i++)
            {
                var paramNode = directive.ChildNodes[3].ChildNodes[i].ChildNodes[0];

                if (paramNode.Term.Name == shiversoft.Grammar.Constants.IDENTIFIER)
                {
                    continue;
                }

                if ((paramNode.Token?.ValueString ?? "") == "...")
                {
                    if (i + 1 != directive.ChildNodes[3].ChildNodes.Count)
                    {
                        return Error(file, paramNode.Span.Location.Line, paramNode.Span.Location.Column, 8, $"variadic arguments list must be at the end of the function parameters list");
                    }

                    flgs |= (byte)ScriptExportFlags.Variadic;
                    break;
                }
            }

            ScriptMetadata[fnSig] = new ScriptFunctionMetadata()
            {
                FunctionName = currentFn,
                FunctionNamespace = currentNs,
                FunctionNameHash = Script.HashCanon32(currentFn),
                FunctionNamespaceHash = ns_value,
                NumParams = (byte)directive.ChildNodes[3].ChildNodes.Count,
                Flags = flgs,
                node = directive,
                IsClassFunction = isClassFunction
            };

            return 0;
        }

        static void EmitExport(ScriptFunctionMetadata func)
        {
            var parameters = func.node.ChildNodes[func.node.ChildNodes.FindIndex(e => e.Term.Name == shiversoft.Grammar.Constants.FUNCTIONPARAMETERS)].ChildNodes;

            var CurrentFunction = Script.Exports.Add(func.FunctionNameHash, func.FunctionNamespaceHash, func.NumParams);
            CurrentFunction.Fields.flags = func.Flags;
            CurrentFunction.FriendlyName = $"{func.FunctionNamespace}::{func.FunctionName}";
            CurrentFunction.IsClassExport = func.IsClassFunction;

            if(func.IsClassFunction)
            {
                CurrentFunction.ClassName = func.FunctionNamespace;
            }

            bool hasVararg = false;
            foreach (var paramNode in parameters)
            {
                var strval = paramNode.FindTokenAndGetText();
                if(strval == shiversoft.Grammar.Constants.VADECLARATION)
                {
                    strval = shiversoft.Grammar.Constants.VARARG;
                    hasVararg = true;
                }
                AddLocal(CurrentFunction, strval);
            }

            CurrentFunction.Locals.MarkParams();

            if(hasVararg)
            {
                var vaIndex = CurrentFunction.Locals.GetParamCount() - 1;
                CurrentFunction.AddVarargs(Script.HashCanon32(shiversoft.Grammar.Constants.VARARG));
            }

            var block = func.node.ChildNodes[func.node.ChildNodes.Count - 1];

            ScriptOperands.Clear();
            EmitOptionalParameters(CurrentFunction, parameters);
            ScriptOperands.Clear();

            Push(CurrentFunction, block, 0);
            IterateStack();

            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_End);
        }

        private static void EmitOptionalParameters(GSCUScriptExport CurrentFunction, ParseTreeNodeList Params)
        {
            foreach (var node in Params)
            {
                if (node.ChildNodes[0].Term.Name != shiversoft.Grammar.Constants.SETLOCALVARIABLE)
                {
                    continue;
                }

                var optional = node.ChildNodes[0];
                string pname = optional.ChildNodes[0].FindTokenAndGetText();

                if (optional.ChildNodes[1].FindTokenAndGetText() != "=")
                {
                    Error(CurrentFile, optional.ChildNodes[1].Span.Location.Line, optional.ChildNodes[1].Span.Location.Column, 20, "cannot apply complex assignment operators to parameter initializers");
                }

                AddEvalLocal(CurrentFunction, pname, optional);
                CurrentFunction.AddOp(ScriptOpCode.GSCUOP_IsDefined);

                var __jmp = CurrentFunction.AddJump(ScriptOpCode.GSCUOP_JumpOnTrue);

                Push(CurrentFunction, optional.ChildNodes[2], 0);

                IterateStack();

                AddSetLocal(CurrentFunction, pname, optional);
                __jmp.After = CurrentFunction.Locals.GetEndOfChain();
            }
        }

        private static void Push(QOperand op)
        {
            ScriptOperands.Push(op);
        }

        private static void Push(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            ScriptOperands.Push(new QOperand(CurrentFunction, node, Context));
        }

        private static void PushObject(object o)
        {
            ScriptOperands.Push(new QOperand(null, o, 0));
        }

        private static void IterateStack()
        {
            while (ScriptOperands.Count > 0)
            {
                var CurrentOp = ScriptOperands.Pop();

                if (!CurrentOp.IsParseNode)
                {
                    continue; //Stack misalignment
                }

                var node = CurrentOp.ObjectNode;
                var CurrentFunction = CurrentOp.CurrentFunction;
                var Context = CurrentOp.Context;

                if (CurrentOp.GetOperands != null)
                {
                    if (!CurrentOp.GetOperands.MoveNext())
                    {
                        continue;
                    }

                    Push(CurrentOp);
                    Push(CurrentOp.GetOperands.Current);
                    continue;
                }

                switch (node.Term.Name)
                {
                    case shiversoft.Grammar.Constants.JUMPSTATEMENT:
                        int offset = 1;
                        if (node.ChildNodes.Count > 1)
                        {
                            offset = (int)node.ChildNodes[1].Token.Value;
                        }

                        offset = Math.Max(1, offset);
                        offset--;

                        if (node.ChildNodes[0].Term.Name == "continue")
                        {
                            CurrentFunction.PushLCF(true, offset);
                        }
                        else
                        {
                            CurrentFunction.PushLCF(false, offset);
                        }
                        break;

                    case shiversoft.Grammar.Constants.NEWARRAY:
                        CurrentFunction.AddOp(ScriptOpCode.GSCUOP_AddArray);
                        break;

                    case shiversoft.Grammar.Constants.NEWSTRUCT:
                        CurrentFunction.AddOp(ScriptOpCode.GSCUOP_AddStruct);
                        break;

                    case shiversoft.Grammar.Constants.DEBUGBREAK:
                        CurrentFunction.AddOp(ScriptOpCode.GSCUOP_Breakpoint);
                        break;

                    //case "shortHandArray":
                    //    throw new NotImplementedException("An array shorthand was passed in an invalid context to the node handler.");

                    case shiversoft.Grammar.Constants.IFSTATEMENT:
                        int count = node.ChildNodes.Count;
                        CurrentOp.SetOperands = EmitConditionalJump(CurrentFunction, node.ChildNodes[1], node.ChildNodes[2], count == 5 ? node.ChildNodes[4] : null);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.WHILESTATEMENT:
                        CurrentOp.SetOperands = EmitWhile(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.FORSTATEMENT:
                        CurrentOp.SetOperands = EmitForLoop(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.SWITCHSTATEMENT:
                        CurrentOp.SetOperands = EmitSwitchStatement(CurrentFunction, node);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.SIMPLECALL:
                        CurrentOp.SetOperands = EmitSimpleCall(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.CALL:
                        CurrentOp.SetOperands = EmitCall(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.CLASSCALL:
                        CurrentOp.SetOperands = EmitClassCall(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.NOTIFY:
                        CurrentOp.SetOperands = EmitNotify(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.ENDON:
                        CurrentOp.SetOperands = EmitEndon(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.WAITTILLSTATEMENT:
                        CurrentOp.SetOperands = EmitWaittill(CurrentFunction, node.ChildNodes[0], Context, true);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.WAITTILL:
                        CurrentOp.SetOperands = EmitWaittill(CurrentFunction, node, Context, false);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.WAITFRAME:
                        CurrentOp.SetOperands = EmitWaitOfType(CurrentFunction, node, Context, ScriptOpCode.GSCUOP_Waitframe);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.WAIT:
                        CurrentOp.SetOperands = EmitWaitOfType(CurrentFunction, node, Context, ScriptOpCode.GSCUOP_Wait);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.RETURN:
                        CurrentOp.SetOperands = EmitReturn(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.ISDEFINED:
                        CurrentOp.SetOperands = EmitIsdefined(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.DIRECTACCESS:
                        CurrentOp.SetOperands = EmitEvalFieldVariable(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.ARRAYACCESS:
                        CurrentOp.SetOperands = EmitEvalArrayField(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.SETARRAYFIELD:
                        CurrentOp.SetOperands = EmitSetArrayField(CurrentFunction, node, Context, false);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.STACKDECLARATION:
                        switch(node.ChildNodes[0].Term.Name)
                        {
                            case shiversoft.Grammar.Constants.SETARRAYFIELD:
                                CurrentOp.SetOperands = EmitSetArrayField(CurrentFunction, node.ChildNodes[0], Context, true);
                                break;

                            case shiversoft.Grammar.Constants.SETFIELDVARIABLE:
                                CurrentOp.SetOperands = EmitSetFieldVariable(CurrentFunction, node.ChildNodes[0], Context, true);
                                break;

                            case shiversoft.Grammar.Constants.SETLOCALVARIABLE:
                                CurrentOp.SetOperands = EmitSetLocalVariable(CurrentFunction, node.ChildNodes[0], Context, true);
                                break;
                        }
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.FOREACHSTATEMENT:
                        CurrentOp.SetOperands = EmitForeach(CurrentFunction, node);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.PEMDAS:
                        CurrentOp.SetOperands = EmitMathExpr(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.RELATIONALEXPRESSION:
                        CurrentOp.SetOperands = EmitRelationalExpr(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.EQUALITYEXPRESSION:
                        CurrentOp.SetOperands = EmitEqualityExpr(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.BOOLEANOREXPRESSION:
                        CurrentOp.SetOperands = EmitBoolLogic(CurrentFunction, node, false);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.BOOLEANANDEXPRESSION:
                        CurrentOp.SetOperands = EmitBoolLogic(CurrentFunction, node, true);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.BOOLNOT:
                        CurrentOp.SetOperands = EmitBoolNot(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.BITNOT:
                        CurrentOp.SetOperands = EmitBitNot(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.INCDECLOCAL:
                        CurrentOp.SetOperands = EmitIncDecLocal(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.INCDECFIELD:
                        CurrentOp.SetOperands = EmitIncDecField(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.SIZE:
                        CurrentOp.SetOperands = EmitSizeof(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.TERNARY:
                        CurrentOp.SetOperands = EmitConditionalJump(CurrentFunction, node.ChildNodes[0], node.ChildNodes[1], node.ChildNodes[2]);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.IDENTIFIER:
                        string LocalToLower = node.Token.ValueString.ToLower();
                        AddEvalLocal(CurrentFunction, LocalToLower, node);
                        break;

                    case shiversoft.Grammar.Constants.VARARG:
                        AddEvalLocal(CurrentFunction, shiversoft.Grammar.Constants.VARARG, node);
                        break;

                    case shiversoft.Grammar.Constants.UNPACKTOSTACK:
                        CurrentOp.SetOperands = EmitStackUnpack(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.UNPACKSTATEMENT:
                        CurrentOp.SetOperands = EmitUnpack(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.HASHEDSTRING:
                        CurrentFunction.AddGetHash(Script.HashCanon64(node.ChildNodes[0].Token.ValueString));
                        break;

                    case shiversoft.Grammar.Constants.HASHEDVARIABLE:
                        CurrentFunction.AddGetHash(Script.HashCanon32(node.ChildNodes[0].FindTokenAndGetText()));
                        break;

                    case shiversoft.Grammar.Constants.STRINGLITERAL:
                        AddGetString(CurrentFunction, node.Token.ValueString);
                        break;

                    case shiversoft.Grammar.Constants.NUMBERLITERAL:
                        CurrentFunction.AddGetNumber(node.Token.Value);
                        break;

                    case shiversoft.Grammar.Constants.GETFUNCTION:
                        EmitFunctionPtr(CurrentFunction, node);
                        break;

                    case shiversoft.Grammar.Constants.VEC:
                        CurrentOp.SetOperands = EmitVector(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.SETFIELDVARIABLE:
                        CurrentOp.SetOperands = EmitSetFieldVariable(CurrentFunction, node, Context, false);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.SETLOCALVARIABLE:
                        CurrentOp.SetOperands = EmitSetLocalVariable(CurrentFunction, node, Context, false);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.FALSE:
                        CurrentFunction.AddGetNumber(0);
                        break;

                    case shiversoft.Grammar.Constants.TRUE:
                        CurrentFunction.AddGetNumber(1);
                        break;

                    case shiversoft.Grammar.Constants.UNDEFINED:
                        CurrentFunction.AddOp(ScriptOpCode.GSCUOP_AddUndefined);
                        break;

                    case shiversoft.Grammar.Constants.SELF:
                        CurrentFunction.AddOp(ScriptOpCode.GSCUOP_GetSelf);
                        break;

                    // TODO: need to redo this so that we can properly handle globals at compile time
                    // we can infer that anything that doesnt match a local name is going to be a global reference, and if still not found we throw an error. need to modify locals behavior for this.
                    // globals.level? then do a macro to do #define level globals.level? this fixes our issue with accesing stuff from other games since API can write overloads for accessors and stuff maybe?
                    case shiversoft.Grammar.Constants.GLOBALS:
                        CurrentFunction.AddGlobal(Script.Globals.AddGlobal(Script.HashCanon32(shiversoft.Grammar.Constants.GLOBALS)));
                        break;

                    case shiversoft.Grammar.Constants.VTIME:
                        CurrentFunction.AddOp(ScriptOpCode.GSCUOP_VMTime);
                        break;

                    case shiversoft.Grammar.Constants.INCDECSTATEMENT:
                        CurrentOp.SetOperands = EmitIncDecStatement(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.CHECKTYPE:
                        CurrentOp.SetOperands = EmitCheckType(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.CASTTO:
                        CurrentOp.SetOperands = EmitCastTo(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.TRYSTATEMENT:
                        CurrentOp.SetOperands = EmitTryCatch(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.FREESTRUCT:
                        CurrentOp.SetOperands = EmitFreeObject(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.SHORTHANDARRAY:
                        CurrentOp.SetOperands = EmitShorthandArray(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.SHORTHANDSTRUCT:
                        CurrentOp.SetOperands = EmitShorthandStruct(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.SPAWNCLASS:
                        CurrentOp.SetOperands = EmitSpawnClass(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.LOCALFUNCTION:
                        CurrentOp.SetOperands = EmitLocalFunction(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.THROWEXCEPTION:
                        CurrentOp.SetOperands = EmitThrowStatement(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    case shiversoft.Grammar.Constants.SETCLASSPROP:
                        CurrentOp.SetOperands = EmitSetClassProp(CurrentFunction, node, Context);
                        Push(CurrentOp);
                        break;

                    default:
                        foreach (var child in node.ChildNodes.AsEnumerable().Reverse())
                            Push(CurrentFunction, child, Context);
                        break;
                }
            }
        }

        private static IEnumerable<QOperand> EmitSetClassProp(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            throw new NotImplementedException();
        }

        private static IEnumerable<QOperand> EmitThrowStatement(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            yield return new QOperand(CurrentFunction, node.ChildNodes[3], 0); // obj
            yield return new QOperand(CurrentFunction, node.ChildNodes[2], 0); // msg
            yield return new QOperand(CurrentFunction, node.ChildNodes[1], 0); // code
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_Throw);
        }

        private static IEnumerable<QOperand> EmitLocalFunction(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            int capturesIndex = node.ChildNodes.FindIndex(e => e.Term.Name == shiversoft.Grammar.Constants.FUNCTIONCAPTURES);
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_AddArray);

            var localFn = Script.Exports.CreateLocal(Script);

            #region Compile Local Function
            var paramsNodes = node.ChildNodes[node.ChildNodes.Count - 2].ChildNodes;

            bool hasVararg = false;
            foreach (var paramNode in paramsNodes)
            {
                var strval = paramNode.FindTokenAndGetText();
                if (strval == shiversoft.Grammar.Constants.VADECLARATION)
                {
                    strval = shiversoft.Grammar.Constants.VARARG;
                    hasVararg = true;
                }
                AddLocal(localFn, strval);
            }

            localFn.Locals.MarkParams();

            if (hasVararg)
            {
                var vaIndex = localFn.Locals.GetParamCount() - 1;
                localFn.AddVarargs(Script.HashCanon32(shiversoft.Grammar.Constants.VARARG));
            }

            if (capturesIndex != -1)
            {
                var capList = node.ChildNodes[capturesIndex].ChildNodes[1].ChildNodes;
                int count = 0;
                foreach (var cap in capList)
                {
                    var text = cap.FindTokenAndGetText();
                    uint hValue = Script.HashCanon32(text);
                    if (localFn.Locals.TryGetLocal(hValue, out _))
                    {
                        Error(CurrentFile, cap.Span.Location.Line, cap.Span.Location.Column, 25, $"cannot capture variable '{text}' because the variable is already being used as a parameter");
                        continue;
                    }
                    CurrentFunction.AddGetNumber(count++);
                    AddEvalLocal(CurrentFunction, text, cap);
                    CurrentFunction.AddOp(ScriptOpCode.GSCUOP_AddFieldOnStack);
                    localFn.Locals.AddLocal(hValue);
                }
            }

            var block = node.ChildNodes[node.ChildNodes.Count - 1];

            Stack<QOperand> cached = new Stack<QOperand>();
            while (ScriptOperands.Count > 0)
            {
                cached.Push(ScriptOperands.Pop());
            }

            ScriptOperands.Clear();
            EmitOptionalParameters(localFn, paramsNodes);
            ScriptOperands.Clear();

            Push(localFn, block, 0);
            IterateStack();

            ScriptOperands.Clear();

            while (cached.Count > 0)
            {
                ScriptOperands.Push(cached.Pop());
            }

            localFn.AddOp(ScriptOpCode.GSCUOP_End);
            #endregion

            var jumpPast = CurrentFunction.AddJump(ScriptOpCode.GSCUOP_AddAnonymousFunction);
            CurrentFunction.ConcatFunction(localFn);
            jumpPast.After = CurrentFunction.Locals.GetEndOfChain();

            yield break;
        }

        private static IEnumerable<QOperand> EmitUnpack(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            yield return new QOperand(CurrentFunction, node.ChildNodes[2], 0); // unpack value

            var unpackList = node.ChildNodes[0].ChildNodes;
            CurrentFunction.AddUnpack(unpackList.Count);

            foreach(var entry in unpackList)
            {
                switch(entry.Term.Name)
                {
                    // assign local
                    case shiversoft.Grammar.Constants.IDENTIFIER:
                        {
                            string lname = entry.Token.ValueString.ToLower();
                            // TODO: class local
                            CurrentFunction.Locals.AddLocal(Script.HashCanon32(lname));
                            AddSetLocal(CurrentFunction, lname, entry);
                        }
                        break;

                    // field assignment
                    case shiversoft.Grammar.Constants.DIRECTACCESS:
                        {
                            var direct_access = entry;
                            var dest_field = direct_access.ChildNodes[1];
                            var dest_obj = direct_access.ChildNodes[0];

                            yield return new QOperand(CurrentFunction, dest_obj, 0); // parent

                            CurrentFunction.AddStackCopy(1);
                            AddSetFieldVar(CurrentFunction, dest_field.Token.ValueString, Context);
                            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_DecTop);
                        }
                        break;

                    // array assignment
                    case shiversoft.Grammar.Constants.ARRAYACCESS:
                        {
                            yield return new QOperand(CurrentFunction, entry.ChildNodes[0], 0); // owner
                            yield return new QOperand(CurrentFunction, entry.ChildNodes[1], 0); // field

                            CurrentFunction.AddStackCopy(2);
                            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_SetFieldOnStack);
                            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_DecTop);
                        }
                        break;
                }
            }

            yield break;
        }

        private static IEnumerable<QOperand> EmitStackUnpack(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            yield return new QOperand(CurrentFunction, node.ChildNodes[1], 0); // expr
            CurrentFunction.AddUnpack(-1);
        }

        private static void EnterLoop(GSCUScriptExport CurrentFunction)
        {
            CurrentFunction.IncLCFContext();
        }

        private static void ExitLoop(GSCUScriptExport CurrentFunction, GSCUOpCode Header, GSCUOpCode Footer)
        {
            while (CurrentFunction.TryPopLCF(out GSCUOP_Jump __lcf))
            {
                __lcf.After = __lcf.RefHead ? Header : Footer;
            }
            CurrentFunction.DecLCFContext();
        }

        private static IEnumerable<QOperand> EmitWhile(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            EnterLoop(CurrentFunction);
            var __backref = CurrentFunction.Locals.GetEndOfChain();

            yield return new QOperand(CurrentFunction, node.ChildNodes[1], 0); // expr

            var __while_jmp = CurrentFunction.AddJump(ScriptOpCode.GSCUOP_JumpOnFalse);

            yield return new QOperand(CurrentFunction, node.ChildNodes[2], 0);

            var __while_jmp_back = CurrentFunction.AddJump(ScriptOpCode.GSCUOP_Jump);
            __while_jmp.After = __while_jmp_back;
            __while_jmp_back.After = __backref;

            ExitLoop(CurrentFunction, __backref, __while_jmp_back);
        }

        private static IEnumerable<QOperand> EmitForLoop(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            EnterLoop(CurrentFunction);
            ParseTreeNode Header = node.ChildNodes[1];
            var InitializationNode = Header.ChildNodes[0];
            int BoolExprIndex = Header.ChildNodes.FindIndex(e => e.Term.Name == shiversoft.Grammar.Constants.BOOLEANEXPRESSION);
            var ContinueNode = Header.ChildNodes[Header.ChildNodes.Count - 1];

            yield return new QOperand(CurrentFunction, InitializationNode, 0); // init

            var __header = CurrentFunction.Locals.GetEndOfChain();
            GSCUOP_Jump __jmp = null;
            if (BoolExprIndex != -1)
            {
                yield return new QOperand(CurrentFunction, Header.ChildNodes[BoolExprIndex], 0); // bool condition
                __jmp = CurrentFunction.AddJump(ScriptOpCode.GSCUOP_JumpOnFalse);
            }

            yield return new QOperand(CurrentFunction, node.ChildNodes[2], 0); // body

            var __ctheader = CurrentFunction.Locals.GetEndOfChain();

           foreach(var child in ContinueNode.ChildNodes)
            {
                switch(child.Term.Name)
                {
                    case shiversoft.Grammar.Constants.CLASSCALL:
                    case shiversoft.Grammar.Constants.INCDECLOCAL:
                    case shiversoft.Grammar.Constants.INCDECARRAY:
                    case shiversoft.Grammar.Constants.INCDECFIELD:
                    case shiversoft.Grammar.Constants.CALL:
                    case shiversoft.Grammar.Constants.WAITTILL:
                        yield return new QOperand(CurrentFunction, child, 0);
                        CurrentFunction.AddOp(ScriptOpCode.GSCUOP_DecTop);
                        break;

                    default:
                        yield return new QOperand(CurrentFunction, child, 0);
                        break;
                }
            }

            var __bottomjump = CurrentFunction.AddJump(ScriptOpCode.GSCUOP_Jump);
            __bottomjump.After = __header;

            if (__jmp != null)
            {
                __jmp.After = __bottomjump;
            }

            ExitLoop(CurrentFunction, __ctheader, __bottomjump);
        }

        private static IEnumerable<QOperand> EmitSwitchStatement(GSCUScriptExport CurrentFunction, ParseTreeNode node)
        {
            /*
                OP_Switch <ushort num cases> <ushort defaultCaseJmp> case[numcases]

                case: [ushort jumpTo] [ushort pad] [uint caseHash]

                switch = CurrentFunction.AddSwitch();
                EnterLoop
                foreach(case)
                switch.AddCase(hash, Locals.EndOfChain());
                compileCode
                AddBreak
                
                ExitLoop

             */

            // compile the value to switch on
            EnterLoop(CurrentFunction);

            var head = CurrentFunction.Locals.GetEndOfChain();

            yield return new QOperand(CurrentFunction, node.ChildNodes[1], 0);

            var _switch = CurrentFunction.AddSwitch();

            List<GSCUOP_Jump> jumps = new List<GSCUOP_Jump>();
            
            foreach(var casenode in node.ChildNodes[2].ChildNodes)
            {
                var caseheader = casenode.ChildNodes[0];

                if(caseheader.ChildNodes[0].Term.Name == shiversoft.Grammar.Constants.DEFAULT)
                {
                    if(_switch.DefaultCase is null)
                    {
                        _switch.DefaultCase = CurrentFunction.Locals.GetEndOfChain();
                    }
                    else
                    {
                        Error(CurrentFile, caseheader.ChildNodes[0].Span.Location.Line, caseheader.ChildNodes[0].Span.Location.Column, 17, "cannot have more than one default case for a switch statement");
                        continue;
                    }
                }

                if (caseheader.ChildNodes.Count > 1)
                {
                    var valnode = caseheader.ChildNodes[1];

                    string tval = valnode.FindTokenAndGetText();
                    uint hVal = 0;

                    switch (valnode.Term.Name)
                    {
                        case shiversoft.Grammar.Constants.TRUE:
                            hVal = 1;
                            break;
                        case shiversoft.Grammar.Constants.FALSE:
                            hVal = 0;
                            break;
                        case shiversoft.Grammar.Constants.STRINGLITERAL:
                            hVal = Script.HashCanon32(valnode.Token.ValueString);
                            break;
                        case shiversoft.Grammar.Constants.NUMBERLITERAL:
                            hVal = (uint)(int)valnode.Token.Value;
                            break;
                    }

                    if (!_switch.AddCase(hVal, CurrentFunction.Locals.GetEndOfChain()))
                    {
                        Error(CurrentFile, valnode.Span.Location.Line, valnode.Span.Location.Column, 18, $"duplicate switch case '{tval}'");
                        continue;
                    }
                }

                if (casenode.ChildNodes.Count > 1)
                {
                    yield return new QOperand(CurrentFunction, casenode.ChildNodes[1], 0);
                }

                var jmp = CurrentFunction.AddJump(ScriptOpCode.GSCUOP_Jump);
                jumps.Add(jmp);
            }

            var endswitch = CurrentFunction.Locals.GetEndOfChain();
            _switch.EndSwitch = endswitch;

            foreach(var jmp in jumps)
            {
                jmp.After = endswitch;
            }

            ExitLoop(CurrentFunction, head, endswitch);
        }

        private static IEnumerable<QOperand> EmitConditionalJump(GSCUScriptExport CurrentFunction, ParseTreeNode BoolExpr, ParseTreeNode BlockContent, ParseTreeNode SecondBlock = null)
        {
            yield return new QOperand(CurrentFunction, BoolExpr, 0); // expr

            var __if_jmp = CurrentFunction.AddJump(ScriptOpCode.GSCUOP_JumpOnFalse);
            yield return new QOperand(CurrentFunction, BlockContent, 0);
            if (SecondBlock != null)
            {
                var __else_jmp = CurrentFunction.AddJump(ScriptOpCode.GSCUOP_Jump);
                __if_jmp.After = CurrentFunction.Locals.GetEndOfChain();

                yield return new QOperand(CurrentFunction, SecondBlock, 0);
                __else_jmp.After = CurrentFunction.Locals.GetEndOfChain();
            }
            else
            {
                __if_jmp.After = CurrentFunction.Locals.GetEndOfChain();
            }
        }

        private static IEnumerable<QOperand> EmitNotify(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            bool hasData = false;
            switch(node.ChildNodes[2].ChildNodes.Count)
            {
                case 0:
                    Error(CurrentFile, node.Span.Location.Line, node.Span.Location.Column, 10, "too few parameters for notify. usage: object notify([message], <data>);");
                    yield break;
                case 1:
                    break;
                case 2:
                    hasData = true;
                    break;
                default:
                    Error(CurrentFile, node.Span.Location.Line, node.Span.Location.Column, 11, "too many parameters for notify. usage: object notify([message], <data>);");
                    yield break;

            }

            if(hasData)
            {
                yield return new QOperand(CurrentFunction, node.ChildNodes[2].ChildNodes[1], 0); // struct data (if present)

            }

            yield return new QOperand(CurrentFunction, node.ChildNodes[2].ChildNodes[0], 0); // message
            yield return new QOperand(CurrentFunction, node.ChildNodes[0], 0); // caller

            CurrentFunction.AddNotify(hasData);
        }

        private static IEnumerable<QOperand> EmitSimpleCall(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            yield return new QOperand(CurrentFunction, node.ChildNodes[0], 0);
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_DecTop);
        }

        private static IEnumerable<QOperand> EmitIncDecStatement(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            yield return new QOperand(CurrentFunction, node.ChildNodes[0], 0);
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_DecTop);
        }

        private static IEnumerable<QOperand> EmitCheckType(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            yield return new QOperand(CurrentFunction, node.ChildNodes[0], 0);
            int index = 2;
            bool negate = false;
            byte type = (byte)GSCUCastableVariableType.GSCUCVAR_UNDEFINED;

            if(node.ChildNodes[2].FindTokenAndGetText() == shiversoft.Grammar.Constants.NOT)
            {
                index++;
                negate = true;
            }

            string tok = node.ChildNodes[index].FindTokenAndGetText();

            switch(tok)
            {
                case shiversoft.Grammar.Constants.DEFINED:
                    type = (byte)GSCUCastableVariableType.GSCUCVAR_UNDEFINED;
                    negate = !negate;
                    break;

                case shiversoft.Grammar.Constants.UNDEFINED:
                    type = (byte)GSCUCastableVariableType.GSCUCVAR_UNDEFINED;
                    break;

                case shiversoft.Grammar.Constants.INT:
                    type = (byte)GSCUCastableVariableType.GSCUCVAR_INTEGER;
                    break;

                case shiversoft.Grammar.Constants.STRING:
                    type = (byte)GSCUCastableVariableType.GSCUCVAR_STRING;
                    break;

                case shiversoft.Grammar.Constants.HASH:
                    type = (byte)GSCUCastableVariableType.GSCUCVAR_HASH;
                    break;

                case shiversoft.Grammar.Constants.FLOAT:
                    type = (byte)GSCUCastableVariableType.GSCUCVAR_FLOAT;
                    break;

                case shiversoft.Grammar.Constants.VECTOR:
                    type = (byte)GSCUCastableVariableType.GSCUCVAR_VECTOR;
                    break;

                case shiversoft.Grammar.Constants.STRUCT:
                    type = (byte)GSCUCastableVariableType.GSCUCVAR_STRUCT;
                    break;

                case shiversoft.Grammar.Constants.ARRAY:
                    type = (byte)GSCUCastableVariableType.GSCUCVAR_ARRAY;
                    break;

                case shiversoft.Grammar.Constants.FUNCTION:
                    type = (byte)GSCUCastableVariableType.GSCUCVAR_FUNCTION;
                    break;
            }

            CurrentFunction.AddCheckType(type, negate);
        }

        private static IEnumerable<QOperand> EmitCastTo(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            yield return new QOperand(CurrentFunction, node.ChildNodes[0], 0);
            byte type = (byte)GSCUCastableVariableType.GSCUCVAR_UNDEFINED;
            string tok = node.ChildNodes[2].FindTokenAndGetText();

            switch(tok)
            {
                case shiversoft.Grammar.Constants.INT:
                    type = (byte)GSCUCastableVariableType.GSCUCVAR_INTEGER;
                    break;

                case shiversoft.Grammar.Constants.STRING:
                    type = (byte)GSCUCastableVariableType.GSCUCVAR_STRING;
                    break;

                case shiversoft.Grammar.Constants.HASH:
                    type = (byte)GSCUCastableVariableType.GSCUCVAR_HASH;
                    break;

                case shiversoft.Grammar.Constants.FLOAT:
                    type = (byte)GSCUCastableVariableType.GSCUCVAR_FLOAT;
                    break;

                case shiversoft.Grammar.Constants.VECTOR:
                    type = (byte)GSCUCastableVariableType.GSCUCVAR_VECTOR;
                    break;

                case shiversoft.Grammar.Constants.STRUCT:
                    type = (byte)GSCUCastableVariableType.GSCUCVAR_STRUCT;
                    break;

                case shiversoft.Grammar.Constants.ARRAY:
                    type = (byte)GSCUCastableVariableType.GSCUCVAR_ARRAY;
                    break;

                case shiversoft.Grammar.Constants.FUNCTION:
                    Error(CurrentFile, node.Span.Location.Line, node.Span.Location.Column, 16, "Cannot cast variable to a function");
                    break;
            }

            CurrentFunction.AddCastTo(type);
        }

        private static IEnumerable<QOperand> EmitTryCatch(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            var beginSafeContext = CurrentFunction.AddJump(ScriptOpCode.GSCUOP_EnterSafeContext);

            CurrentFunction.IncSafeContext();
            yield return new QOperand(CurrentFunction, node.ChildNodes[1], 0); // tryblock
            CurrentFunction.DecSafeContext();
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_ExitSafeContext);

            var beginHandler = CurrentFunction.AddJump(ScriptOpCode.GSCUOP_Jump);
            
            beginSafeContext.After = CurrentFunction.Locals.GetEndOfChain();

            string pname = node.ChildNodes[3].FindTokenAndGetText();
            AddLocal(CurrentFunction, pname);
            AddSetLocal(CurrentFunction, pname, node.ChildNodes[3]); // error struct destination
            yield return new QOperand(CurrentFunction, node.ChildNodes[4], 0); // handler block
            
            beginHandler.After = CurrentFunction.Locals.GetEndOfChain();
        }

        private static IEnumerable<QOperand> EmitFreeObject(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_PreScriptCall);
            yield return new QOperand(CurrentFunction, node.ChildNodes[1], 0); // caller
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_DeconstructObject);
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_FreeObject);
        }

        private static IEnumerable<QOperand> EmitShorthandArray(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            var assignments = node.ChildNodes[0].ChildNodes;

            // add an empty array
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_AddArray);

            // add all the fields
            int count = 0;
            foreach(var fieldNode in assignments)
            {
                // stack: 
                // value
                // field

                CurrentFunction.AddGetNumber(count);
                yield return new QOperand(CurrentFunction, fieldNode.ChildNodes[0], 0); // value
                CurrentFunction.AddOp(ScriptOpCode.GSCUOP_AddFieldOnStack);
                count++;
            }
        }

        private static IEnumerable<QOperand> EmitShorthandStruct(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            var assignments = node.ChildNodes[0].ChildNodes;

            // add an empty struct
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_AddStruct);

            // add all the fields
            foreach (var fieldNode in assignments)
            {
                if(fieldNode.ChildNodes[1].FindTokenAndGetText() != "=")
                {
                    Error(CurrentFile, fieldNode.ChildNodes[1].Span.Location.Line, fieldNode.ChildNodes[1].Span.Location.Column, 19, "cannot apply complex assignments to struct initializers");
                }
                yield return new QOperand(CurrentFunction, fieldNode.ChildNodes[2], 0); // value
                CurrentFunction.AddMakeFieldVar(Script.HashCanon32(fieldNode.ChildNodes[0].FindTokenAndGetText()));
            }
        }

        private static IEnumerable<QOperand> EmitSpawnClass(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            ParseTreeNodeList parameters = node.ChildNodes[node.ChildNodes.Count - 1].ChildNodes;
            string classname = node.ChildNodes[node.ChildNodes.Count - 2].FindTokenAndGetText().ToLower();
            uint classname_hash = Script.HashCanon32(classname);

            // prepare
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_PreScriptCall);

            parameters.Reverse();
            foreach (ParseTreeNode parameter in parameters)
            {
                yield return new QOperand(CurrentFunction, parameter, 0);
            }

            CurrentFunction.AddClassCall(classname_hash, ScriptOpCode.GSCUOP_SpawnClassObject);
        }

        private static IEnumerable<QOperand> EmitForeach(GSCUScriptExport CurrentFunction, ParseTreeNode node)
        {
            /*
                GSCU foreach pattern: 
                    cArray = array; // compile array accessor, setlocalvariable(autogen)
                    cKey = FirstField(cArray); // getlocal(autogen) firstfield setlocal(autogen)
                    userValue = GetFieldValue(cKey); // getlocal(autogen) fieldvalue setlocal(userValue)
                    compiler-if(userKey) userKey = GetFieldKey(cKey); // note that this will *always* be a type hash so devs need to be told this (why??!)
                    while(cKey is defined)
                    {
                        // user code
                        
                        // continue here
                        cKey = NextField(cKey);
                        userValue = GetFieldValue(cKey); // getlocal(autogen) fieldvalue setlocal(userValue)
                        compiler-if(userKey) userKey = GetFieldKey(cKey); // note that this will *always* be a type hash so devs need to be told this
                    }
                    // break here
             */

            string key = Guid.NewGuid().ToString();
            string arr = Guid.NewGuid().ToString();
            string userValue = node.ChildNodes[1].ChildNodes[node.ChildNodes[1].ChildNodes.Count - 1].FindTokenAndGetText();
            string userKey = null;

            if(node.ChildNodes[1].ChildNodes.Count > 1)
            {
                userKey = node.ChildNodes[1].ChildNodes[0].FindTokenAndGetText();
            }

            CurrentFunction.Locals.AddLocal(Script.HashCanon32(key));
            CurrentFunction.Locals.AddLocal(Script.HashCanon32(arr));
            CurrentFunction.Locals.AddLocal(Script.HashCanon32(userValue));

            if(userKey != null)
            {
                CurrentFunction.Locals.AddLocal(Script.HashCanon32(userKey));
            }

            // compile array value
            yield return new QOperand(CurrentFunction, node.ChildNodes[3], 0);

            // assign it to the array local generated for this loop (eq: cArray = array);
            AddSetLocal(CurrentFunction, arr, null);

            // eval the local array
            AddEvalLocal(CurrentFunction, arr, null);

            // get the first field (or undefined if it doesnt exist)
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_FirstField);

            // set the local field tracker (eq: cKey = FirstField(cArray));
            AddSetLocal(CurrentFunction, key, null);

            EnterLoop(CurrentFunction);
            var __header = CurrentFunction.Locals.GetEndOfChain();

            // eval the field tracker
            AddEvalLocal(CurrentFunction, key, null);

            // eval the field's value (or undefined if the input field tracker is undefined)
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_GetFieldValue);

            // store the result in userValue (eq: userValue = GetFieldValue(cKey));
            AddSetLocal(CurrentFunction, userValue, null);

            if (userKey != null)
            {
                // eval the field tracker
                AddEvalLocal(CurrentFunction, key, null);

                // eval the field's key (or undefined if the input field tracker is undefined)
                CurrentFunction.AddOp(ScriptOpCode.GSCUOP_GetFieldKey);

                // set the userKey (eq: userKey = GetFieldKey(cKey));
                AddSetLocal(CurrentFunction, userKey, null);
            }

            // eval cKey
            AddEvalLocal(CurrentFunction, key, null);

            // check if cKey is defined
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_IsDefined);

            // if not, skip the loop code (break) (eq: while(isdefined(cKey)));
            var __jmp = CurrentFunction.AddJump(ScriptOpCode.GSCUOP_JumpOnFalse);

            // user code
            yield return new QOperand(CurrentFunction, node.ChildNodes[4], 0);

            var __foreach_header = CurrentFunction.Locals.GetEndOfChain();

            // eval the field tracker
            AddEvalLocal(CurrentFunction, key, null);

            // get next field or undefined
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_NextField);

            // set the local field tracker (eq: cKey = NextField(cKey));
            AddSetLocal(CurrentFunction, key, null);

            //Exit the loop
            var __footer = CurrentFunction.AddJump(ScriptOpCode.GSCUOP_Jump);
            __footer.After = __header;
            __jmp.After = __footer;
            ExitLoop(CurrentFunction, __foreach_header, __footer);
        }

        private static IEnumerable<QOperand> EmitWaittill(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context, bool emitDecTop)
        {
            // push events, then push parent

            if(node.ChildNodes[2].ChildNodes.Count < 1)
            {
                Error(CurrentFile, node.Span.Location.Line, node.Span.Location.Column, 12, "too few parameters for waittill. usage: result = object waittill(event1, event2, ...);");
                yield break;
            }

            if(node.ChildNodes[2].ChildNodes.Count > 128)
            {
                Error(CurrentFile, node.Span.Location.Line, node.Span.Location.Column, 13, "too many parameters for waittill. usage: result = object waittill(event1, event2, ...);");
                yield break;
            }

            foreach (var p in node.ChildNodes[2].ChildNodes)
            {
                yield return new QOperand(CurrentFunction, p, 0); // event
            }

            yield return new QOperand(CurrentFunction, node.ChildNodes[0], 0); // caller

            CurrentFunction.AddWaittill(node.ChildNodes[2].ChildNodes.Count); // number of events

            if(emitDecTop)
            {
                CurrentFunction.AddOp(ScriptOpCode.GSCUOP_DecTop);
            }
        }

        private static IEnumerable<QOperand> EmitEndon(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            if(node.ChildNodes[2].ChildNodes.Count < 1)
            {
                Error(CurrentFile, node.Span.Location.Line, node.Span.Location.Column, 12, "too few parameters for endon. usage: object endon(event1, event2, ...);");
                yield break;
            }

            if (node.ChildNodes[2].ChildNodes.Count > 32)
            {
                Error(CurrentFile, node.Span.Location.Line, node.Span.Location.Column, 13, "too many parameters for endon. max number is 32. usage: object endon(event1, event2, ...);");
                yield break;
            }

            foreach (var p in node.ChildNodes[2].ChildNodes)
            {
                yield return new QOperand(CurrentFunction, p, 0); // event
            }

            yield return new QOperand(CurrentFunction, node.ChildNodes[0], 0); // caller

            CurrentFunction.AddEndon(node.ChildNodes[2].ChildNodes.Count);
        }

        private static IEnumerable<QOperand> EmitWaitOfType(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context, ScriptOpCode code)
        {
            yield return new QOperand(CurrentFunction, node.ChildNodes[1], 0);
            CurrentFunction.AddOp(code);
        }

        private static IEnumerable<QOperand> EmitEvalFieldVariable(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            // owner
            yield return new QOperand(CurrentFunction, node.ChildNodes[0], 0);
            AddFieldVariable(CurrentFunction, node.ChildNodes[1].FindTokenAndGetText(), Context);
        }

        private static IEnumerable<QOperand> EmitEvalArrayField(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            // stack:
            // field
            // owner
            yield return new QOperand(CurrentFunction, node.ChildNodes[0], 0); // owner
            yield return new QOperand(CurrentFunction, node.ChildNodes[1], 0); // field
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_EvalFieldOnStack);
        }

        private static IEnumerable<QOperand> EmitSetArrayField(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context, bool pushResult)
        {
            // stack:
            // value
            // field
            // owner
            var @operator = node.ChildNodes[1].FindToken().ValueString;

            yield return new QOperand(CurrentFunction, node.ChildNodes[0].ChildNodes[0], 0); // owner
            yield return new QOperand(CurrentFunction, node.ChildNodes[0].ChildNodes[1], 0); // field

            if (@operator != "=")
            {
                yield return new QOperand(CurrentFunction, node.ChildNodes[0].ChildNodes[0], 0); // owner
                yield return new QOperand(CurrentFunction, node.ChildNodes[0].ChildNodes[1], 0); // field
                CurrentFunction.AddOp(ScriptOpCode.GSCUOP_EvalFieldOnStack);
            }

            yield return new QOperand(CurrentFunction, node.ChildNodes[2], 0); // val

            if (@operator != "=")
            {
                CurrentFunction.AddOperator(@operator.Replace("=", ""));
            }

            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_SetFieldOnStack);

            if(pushResult)
            {
                yield return new QOperand(CurrentFunction, node.ChildNodes[0].ChildNodes[0], 0); // owner
                yield return new QOperand(CurrentFunction, node.ChildNodes[0].ChildNodes[1], 0); // field
                CurrentFunction.AddOp(ScriptOpCode.GSCUOP_EvalFieldOnStack);
            }
        }

        private static void AddFieldVariable(GSCUScriptExport CurrentFunction, string FVIdentifier, uint Context)
        {
            CurrentFunction.AddFieldVariable(Script.HashCanon32(FVIdentifier));
        }

        private static void AddSetFieldVar(GSCUScriptExport CurrentFunction, string FVIdentifier, uint Context)
        {
            CurrentFunction.AddSetFieldVar(Script.HashCanon32(FVIdentifier));
        }

        private static IEnumerable<QOperand> EmitReturn(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            if (node.ChildNodes.Count > 1)
            {
                if((CurrentFunction.Fields.flags & (byte)ScriptExportFlags.AutoExec) > 0)
                {
                    Warning(CurrentFile, node.Span.Location.Line, node.Span.Location.Column, 15, "autoexec functions cannot return values");
                    CurrentFunction.AddOp(ScriptOpCode.GSCUOP_End);
                    yield break;
                }
                yield return new QOperand(CurrentFunction, node.ChildNodes[1], 0);
                CurrentFunction.AddOp(ScriptOpCode.GSCUOP_Return);
            }
            else
            {
                CurrentFunction.AddOp(ScriptOpCode.GSCUOP_End);
            }
        }

        private static IEnumerable<QOperand> EmitIsdefined(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            yield return new QOperand(CurrentFunction, node.ChildNodes[1], 0);
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_IsDefined);
        }

        private static IEnumerable<QOperand> EmitSizeof(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            yield return new QOperand(CurrentFunction, node.ChildNodes[0], 0);
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_SizeOf);
        }

        private static IEnumerable<QOperand> EmitBoolLogic(GSCUScriptExport CurrentFunction, ParseTreeNode node, bool isAnd)
        {
            yield return new QOperand(CurrentFunction, node.ChildNodes[0], 0);
            dynamic target = isAnd ? ScriptOpCode.GSCUOP_JumpOnFalseExpr : ScriptOpCode.GSCUOP_JumpOnTrueExpr;
            dynamic __jmp = CurrentFunction.AddJump(target);
            yield return new QOperand(CurrentFunction, node.ChildNodes[2], 0);
            __jmp.After = CurrentFunction.Locals.GetEndOfChain();
        }

        
        private static IEnumerable<QOperand> EmitMathExpr(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            yield return new QOperand(CurrentFunction, node.ChildNodes[0], 0);
            yield return new QOperand(CurrentFunction, node.ChildNodes[2], 0);
            CurrentFunction.AddOperator(node.ChildNodes[1].FindTokenAndGetText());
        }

        private static IEnumerable<QOperand> EmitRelationalExpr(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            yield return new QOperand(CurrentFunction, node.ChildNodes[0], 0);
            yield return new QOperand(CurrentFunction, node.ChildNodes[2], 0);
            CurrentFunction.AddOperator(node.ChildNodes[1].FindTokenAndGetText());
        }

        private static IEnumerable<QOperand> EmitEqualityExpr(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            yield return new QOperand(CurrentFunction, node.ChildNodes[0], 0);
            yield return new QOperand(CurrentFunction, node.ChildNodes[2], 0);
            CurrentFunction.AddOperator(node.ChildNodes[1].FindTokenAndGetText());
        }

        private static IEnumerable<QOperand> EmitBoolNot(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            yield return new QOperand(CurrentFunction, node.ChildNodes[1], 0);
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_BoolNot);
        }

        private static IEnumerable<QOperand> EmitBitNot(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            yield return new QOperand(CurrentFunction, node.ChildNodes[0], 0);
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_BitNegate);
        }

        private static IEnumerable<QOperand> EmitIncDecLocal(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            bool shouldPushFirst = false;
            ParseTreeNode idNode = node.ChildNodes[1];
            ParseTreeNode opNode = node.ChildNodes[0];
            if (node.ChildNodes[0].Term.Name == shiversoft.Grammar.Constants.IDENTIFIER)
            {
                shouldPushFirst = true;
                idNode = node.ChildNodes[0];
                opNode = node.ChildNodes[1];
            }

            string op = opNode.FindTokenAndGetText();
            string pname = idNode.FindTokenAndGetText().ToLower();

            if (CurrentFunction.IsClassExport && ScriptClasses[CurrentFunction.ClassName].Fields.ContainsKey(pname))
            {
                // TODO: class local
                throw new NotImplementedException("Inc/Dec class locals isnt implemented");
            }

            try
            {
                CurrentFunction.AddIncDecLocal(pname, Script.HashCanon32(pname), op == "++", shouldPushFirst);
            }
            catch (Exception e)
            {
                Error(CurrentFile, node.Span.Location.Line, node.Span.Location.Column, 14, e.Message);
                CurrentFunction.AddOp(ScriptOpCode.GSCUOP_DecTop); // prevent stack from exploding if they run this code anyways (which they shouldnt)
            }

            yield break;
        }

        private static IEnumerable<QOperand> EmitIncDecField(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            bool shouldPushFirst = false;
            ParseTreeNode idNode = node.ChildNodes[1];
            ParseTreeNode opNode = node.ChildNodes[0];
            if (node.ChildNodes[0].Token is null)
            {
                shouldPushFirst = true;
                idNode = node.ChildNodes[0];
                opNode = node.ChildNodes[1];
            }

            string op = opNode.FindTokenAndGetText();
            bool isInc = op == "++";

            // TODO

            yield break;
        }

        private static IEnumerable<QOperand> EmitSetFieldVariable(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context, bool pushResult)
        {
            // stack:
            // value
            // owner

            var direct_access = node.ChildNodes[0];
            var dest_field = direct_access.ChildNodes[1];
            var dest_obj = direct_access.ChildNodes[0];
            var @operator = node.ChildNodes[1].FindToken().ValueString;

            yield return new QOperand(CurrentFunction, dest_obj, 0); // parent

            if (@operator != "=")
            {
                yield return new QOperand(CurrentFunction, dest_obj, 0); // parent
                AddFieldVariable(CurrentFunction, dest_field.Token.ValueString, Context);
            }

            yield return new QOperand(CurrentFunction, node.ChildNodes[2], 0); // value

            if (@operator != "=")
            {
                CurrentFunction.AddOperator(@operator.Replace("=", ""));
            }

            AddSetFieldVar(CurrentFunction, dest_field.Token.ValueString, Context);            

            if(pushResult)
            {
                yield return new QOperand(CurrentFunction, dest_obj, 0); // parent
                AddFieldVariable(CurrentFunction, dest_field.Token.ValueString, Context);
            }
        }

        private static IEnumerable<QOperand> EmitSetLocalVariable(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context, bool pushResult)
        {
            // TODO: class local
            var dest = node.ChildNodes[0];
            string lname = dest.Token.ValueString.ToLower();
            var @operator = node.ChildNodes[1].FindToken().ValueString;

            if (@operator != "=")
            {
                AddEvalLocal(CurrentFunction, lname, node);
            }

            yield return new QOperand(CurrentFunction, node.ChildNodes[2], 0); // value

            if (@operator != "=")
            {
                CurrentFunction.AddOperator(@operator.Replace("=", ""));
            }

            CurrentFunction.Locals.AddLocal(Script.HashCanon32(lname));
            AddSetLocal(CurrentFunction, lname, node);

            if(pushResult)
            {
                AddEvalLocal(CurrentFunction, lname, node);
            }
        }

        private static void AddEvalLocal(GSCUScriptExport CurrentFunction, string pname, ParseTreeNode node)
        {
            // TODO: class local
            try
            {
                CurrentFunction.AddEvalLocal(pname, Script.HashCanon32(pname));
            }
            catch(Exception e)
            {
                Error(CurrentFile, node.Span.Location.Line, node.Span.Location.Column, 8, e.Message);
                CurrentFunction.AddOp(ScriptOpCode.GSCUOP_AddUndefined); // not fatal for get accessors
            }
        }

        private static void AddSetLocal(GSCUScriptExport CurrentFunction, string pname, ParseTreeNode node)
        {
            try
            {
                CurrentFunction.AddSetLocal(pname, Script.HashCanon32(pname));
            }
            catch (Exception e)
            {
                Error(CurrentFile, node.Span.Location.Line, node.Span.Location.Column, 9, e.Message);
                CurrentFunction.AddOp(ScriptOpCode.GSCUOP_DecTop); // prevent stack from exploding if they run this code anyways (which they shouldnt)
            }
        }

        private static IEnumerable<QOperand> EmitVector(GSCUScriptExport CurrentFunction, ParseTreeNode node, uint Context)
        {
            if (node.ChildNodes.Count > 3)
            {
                yield return new QOperand(CurrentFunction, node.ChildNodes[3], 0);
            }

            if (node.ChildNodes.Count > 2)
            {
                yield return new QOperand(CurrentFunction, node.ChildNodes[2], 0);
            }

            yield return new QOperand(CurrentFunction, node.ChildNodes[1], 0);
            yield return new QOperand(CurrentFunction, node.ChildNodes[0], 0);
            CurrentFunction.AddOp((ScriptOpCode)((int)ScriptOpCode.GSCUOP_MakeVec2 + (node.ChildNodes.Count - 2)));
        }

        private static void AddGetString(GSCUScriptExport CurrentFunction, string Value)
        {
            CurrentFunction.AddGetString(Script.Strings.AddString(Value));
        }

        private static void EmitFunctionPtr(GSCUScriptExport CurrentFunction, ParseTreeNode node)
        {
            if (node.ChildNodes.Count > 1)
            {
                var ns = node.ChildNodes[1].FindToken().ValueString;
                var fn = node.ChildNodes[2].FindToken().ValueString;
                CurrentFunction.AddFunctionPtr(Script.Imports.AddImport(Script.HashCanon32(fn), Script.HashCanon32(ns), 0, (byte)GSCUImportFlags.GSCUIF_REF));
            }
            else
            {
                var fn = node.ChildNodes[1].FindToken().ValueString;
                CurrentFunction.AddFunctionPtr(Script.Imports.AddImport(Script.HashCanon32(fn), 0, 0, (byte)GSCUImportFlags.GSCUIF_REF));
            }
        }

        private static void AddLocal(GSCUScriptExport CurrentFunction, string LocalName)
        {
            CurrentFunction.Locals.AddLocal(Script.HashCanon32(LocalName));
        }

        private static IEnumerable<QOperand> EmitClassCall(GSCUScriptExport CurrentFunction, ParseTreeNode callNode, uint Context)
        {
            ParseTreeNode caller = callNode.ChildNodes[callNode.ChildNodes.Count - 3];
            ParseTreeNodeList parameters = callNode.ChildNodes[callNode.ChildNodes.Count - 1].ChildNodes;
            string function_name = callNode.ChildNodes[callNode.ChildNodes.Count - 2].FindTokenAndGetText().ToLower();
            uint fn_hash = Script.HashCanon32(function_name);
            bool is_threaded = callNode.ChildNodes[0].Term.Name == shiversoft.Grammar.Constants.THREAD;

            // prepare
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_PreScriptCall);

            parameters.Reverse();
            foreach (ParseTreeNode parameter in parameters)
            {
                yield return new QOperand(CurrentFunction, parameter, 0);
            }

            yield return new QOperand(CurrentFunction, caller, 0);
            CurrentFunction.AddClassCall(fn_hash, is_threaded ? ScriptOpCode.GSCUOP_CallClassMethodThreaded : ScriptOpCode.GSCUOP_CallClassMethod);
        }

        private static IEnumerable<QOperand> EmitCall(GSCUScriptExport CurrentFunction, ParseTreeNode callNode, uint Context)
        {
            ParseTreeNode CallFrame = callNode.ChildNodes[callNode.ChildNodes.Count - 1];
            ParseTreeNode BaseCall = CallFrame.ChildNodes[0];
            ParseTreeNode CallPrefix = callNode.ChildNodes.Count > 1 ? callNode.ChildNodes[0] : null;
            ParseTreeNode Caller = null;

            string function_name = BaseCall.ChildNodes[BaseCall.ChildNodes.Count - 2].FindTokenAndGetText().ToLower();
            string NS_String = null;
            uint fhash = Script.HashCanon32(function_name);
            if (BaseCall.ChildNodes.Count == 3)
            {
                NS_String = BaseCall.ChildNodes[0].FindTokenAndGetText();
            }

            ParseTreeNode CallParameters = BaseCall.ChildNodes[BaseCall.ChildNodes.Count - 1];
            ParseTreeNodeList parameters = CallParameters.ChildNodes;

            bool is_threaded = false;
            bool is_pointer = false;

            //Our context should update if we have a prefix
            if (CallPrefix != null)
            {
                if (CallPrefix.Term.Name != shiversoft.Grammar.Constants.THREAD)
                {
                    Caller = CallPrefix.ChildNodes[0];

                    if (CallPrefix.ChildNodes[CallPrefix.ChildNodes.Count - 1].Term.Name == shiversoft.Grammar.Constants.THREAD)
                    {
                        is_threaded = true;
                    }
                }
                else
                {
                    is_threaded = true;
                }
            }

            //Update the context if we are using a call pointer term
            if (CallFrame.ChildNodes[0].Term.Name == shiversoft.Grammar.Constants.BASECALLPOINTER)
            {
                is_pointer = true;
            }

            // prepare
            CurrentFunction.AddOp(ScriptOpCode.GSCUOP_PreScriptCall);

            parameters.Reverse();
            foreach (ParseTreeNode parameter in parameters)
            {
                yield return new QOperand(CurrentFunction, parameter, 0);
            }

            if (Caller != null)
            {
                yield return new QOperand(CurrentFunction, Caller, 0);
            }

            if (is_pointer)
            {
                yield return new QOperand(CurrentFunction, CallFrame.ChildNodes[0].ChildNodes[0], 0);
                if(is_threaded)
                {
                    if(Caller is null)
                    {
                        CurrentFunction.AddOp(ScriptOpCode.GSCUOP_ThreadCallPointer);
                    }
                    else
                    {
                        CurrentFunction.AddOp(ScriptOpCode.GSCUOP_ThreadMethodCallPointer);
                    }
                }
                else
                {
                    if (Caller is null)
                    {
                        CurrentFunction.AddOp(ScriptOpCode.GSCUOP_CallPointer);
                    }
                    else
                    {
                        CurrentFunction.AddOp(ScriptOpCode.GSCUOP_MethodCallPointer);
                    }
                }
                yield break;
            }
            
            byte Flags = 0;
            uint hashed_ns = NS_String != null ? Script.HashCanon32(NS_String) : 0; 

            if(Caller != null)
            {
                Flags |= (byte)GSCUImportFlags.GSCUIF_METHOD;
            }

            if (is_threaded)
            {
                Flags |= (byte)GSCUImportFlags.GSCUIF_THREADED;
            }

            CurrentFunction.AddCall(Script.Imports.AddImport(fhash, hashed_ns, (byte)parameters.Count, Flags));
        }

        static int Error(string file, int line, int column, int code, string msg)
        {
            Console.Error.WriteLine($"{file}({line + 1},{column}) : error GSCUB{code}: {msg}");
            return code;
        }

        static int Warning(string file, int line, int column, int code, string msg)
        {
            Console.Error.WriteLine($"{file}({line + 1},{column}) : warning GSCUB{code}: {msg}");
            return code;
        }

        private class QOperand
        {
            public readonly bool IsParseNode;
            public object ObjectValue { private set; get; }
            public ParseTreeNode ObjectNode
            {
                get
                {
                    return ObjectValue as ParseTreeNode;
                }
            }

            private IEnumerable<QOperand> __operandsList;
            public IEnumerable<QOperand> SetOperands
            {
                set
                {
                    __operandsList = value;
                    GetOperands = __operandsList.GetEnumerator();
                }
            }

            public IEnumerator<QOperand> GetOperands { get; private set; }

            public readonly GSCUScriptExport CurrentFunction;
            public readonly uint Context;

            public QOperand(GSCUScriptExport export, object Value, uint context)
            {
                if (Value is ParseTreeNode)
                    IsParseNode = true;

                ObjectValue = Value;
                CurrentFunction = export;
                Context = context;
            }

            public QOperand Replace(int index)
            {
                ObjectValue = ObjectNode.ChildNodes[index];

                return this;
            }
        }
    }
}
