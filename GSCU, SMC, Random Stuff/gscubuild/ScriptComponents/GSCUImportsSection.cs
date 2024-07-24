using gscubuild.OpCodes;
using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

namespace gscubuild.ScriptComponents
{
    internal sealed class GSCUImportsSection : GSCUScriptSection
    {
        public GSCUScriptObject Script { get; private set; }
        private GSCUImportsSection(GSCUScriptObject script)
        {
            Script = script;
            Imports = new Dictionary<ulong, GSCUImport>();
            LoadedOffsetPairs = new Dictionary<uint, GSCUImport>();
        } //Prevent public initializers

        internal static GSCUImportsSection New(GSCUScriptObject script)
        {
            GSCUImportsSection imports = new GSCUImportsSection(script);
            imports.Imports = new Dictionary<ulong, GSCUImport>();
            imports.LoadedOffsetPairs = new Dictionary<uint, GSCUImport>();
            return imports;
        }

        public Dictionary<ulong, GSCUImport> Imports;
        public Dictionary<uint, GSCUImport> LoadedOffsetPairs;

        public override ushort Count()
        {
            return (ushort)Imports.Count;
        }

        public IEnumerable<GSCUImport> AllImports()
        {
            foreach (var import in Imports.Values)
                yield return import;
        }

        public override byte[] Serialize()
        {
            byte[] data = new byte[Size()];

            BinaryWriter writer = new BinaryWriter(new MemoryStream(data));

            foreach (ulong key in Imports.Keys)
            {
                var import = Imports[key];

                import.Fields.num_references = (ushort)import.References.Count;
                writer.Write(import.Fields.ToByteArray(), 0, Marshal.SizeOf(typeof(GSCImport)));

                foreach (var reference in import.References)
                {
                    writer.Write(reference.CommitAddress);
                }
            }

            writer.Dispose();

            return data;
        }

        public override uint Size()
        {
            uint count = 0;

            foreach (ulong key in Imports.Keys)
            {
                count += (uint)Marshal.SizeOf(typeof(GSCImport)) + (uint)(Imports[key].References.Count * 4);
            }

            uint Base = GetBaseAddress();

            count = (Base + count).AlignValue(0x10) - Base;

            return count;
        }

        public GSCUImport AddImport(uint function, uint ns, byte paramcount, byte Flags)
        {
            if (Imports.TryGetValue(GetUnique(function, ns, paramcount, Flags), out var value))
                return value;

            GSCUImport import = new GSCUImport();
            import.Fields.name = function;
            import.Fields.space = ns;
            import.Fields.param_count = paramcount;
            import.Fields.flags = Flags;

            Imports[GetUnique(function, ns, paramcount, Flags)] = import;

            return import;
        }

        public GSCUImport GetImport(uint function, uint ns, byte numparams, byte Flags)
        {
            if (Imports.TryGetValue(GetUnique(function, ns, numparams, Flags), out var value))
                return value;
            return null;
        }

        public static ulong GetUnique(uint function, uint ns, byte paramcount, byte Flags)
        {
            //very, very small collision chance. may be impossible but i haven't checked all loaded gsc namespaces.
            return (ulong)((Flags << 8) | paramcount) ^ ((ulong)function << 32 | ns);
        }

        public static ulong GetUnique(GSCUImport import)
        {
            return GetUnique(import.Fields.name, import.Fields.space, import.Fields.param_count, import.Fields.flags);
        }

        public override void UpdateHeader(ref GSCUScriptHeader Header)
        {
            Header.Fields.num_imports = Count();
            Header.Fields.imports = GetBaseAddress();
        }

        /// <summary>
        /// Get the number of imports in this imports section
        /// </summary>
        /// <returns></returns>
        public int GetNumImports()
        {
            return Imports.Count;
        }
    }

    internal struct GSCImport
    {
        // 32 bit hashed name of this import
        public uint name;

	    // 32 bit hashed namespace of this import
	    public uint space;

	    // number of params for this import
	    public byte param_count;

        // flags for this import
        public byte flags;

	    // number of references to this import
	    public ushort num_references;
    };

    internal sealed class GSCUImport
    {
        public GSCImport Fields;

        public HashSet<GSCUOP_AbstractCall> References = new HashSet<GSCUOP_AbstractCall>();
    }

    [Flags]
    internal enum GSCUImportFlags
    {
        // import is a threaded opcode
        GSCUIF_THREADED = 1,

        // import is a reference opcode (getfunction or getapifunction)
        GSCUIF_REF = 2,

        // import has a caller
        GSCUIF_METHOD = 4
    }
}
