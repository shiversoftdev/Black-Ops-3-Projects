using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static gsc2c.PrimeParseResult;

namespace gsc2c
{
    internal enum PrimeParseResult
    {
        PPR_SUCCESS = 0,
        PPR_FAILURE_UNIMPLEMENTED,
        PPR_FAILURE_TOOSMALL,
        PPR_FAILURE_UNSUPPORTED,
        PPR_FAILURE_INVALID_HEADER_OFFSET
    }

    internal enum VM_VERSION
    {
        VM_1C
    }

    internal class PrimeObj
    {
        private delegate PrimeParseResult ParseStageByVMDelegate(byte[] obj, BinaryReader reader, PrimeObj prime);
        private static Dictionary<VM_VERSION, ParseStageByVMDelegate> HeaderParsers;
        public readonly static PrimeObj None;

        public string ParserMessage { get; private set; }
        public Dictionary<uint, PrimeExport> Exports;
        public Dictionary<uint, PrimeImport> Imports;

        internal VM_VERSION VM { get; private set; }
        internal long[] Includes { get; private set; }

        private PrimeObj()
        {
            ParserMessage = "OK";
            Includes = new long[0];
            Exports = new Dictionary<uint, PrimeExport>();
            Imports = new Dictionary<uint, PrimeImport>();
        }

        static PrimeObj()
        {
            None = new PrimeObj();
            HeaderParsers = new Dictionary<VM_VERSION, ParseStageByVMDelegate>()
            {
                { VM_VERSION.VM_1C, Parse1CHeader }
            };
        }

        internal static PrimeParseResult Parse(byte[] obj, out PrimeObj primeOut)
        {
            primeOut = new PrimeObj();

            if(obj is null || obj.Length < 8)
            {
                primeOut.ParserMessage = "Invalid buffer";
                return PPR_FAILURE_TOOSMALL;
            }

            BinaryReader reader = new BinaryReader(new MemoryStream(obj));
            var revision = reader.ReadInt64();

            switch (revision)
            {
                case 0x1C000A0D43534780:
                    primeOut.VM = VM_VERSION.VM_1C;
                    break;
                default:
                    primeOut.ParserMessage = $"Unimplemented VM revision {(revision >> (14 * 8)):X}";
                    return PPR_FAILURE_UNSUPPORTED;
            }

            if(!HeaderParsers.TryGetValue(primeOut.VM, out var parseHeader))
            {
                primeOut.ParserMessage = $"Unimplimented header parser for VM revision {primeOut.VM.ToString()}";
                return PPR_FAILURE_UNIMPLEMENTED;
            }

            return parseHeader(obj, reader, primeOut);
        }

        private static PrimeParseResult Parse1CHeader(byte[] obj, BinaryReader reader, PrimeObj prime)
        {
            reader.BaseStream.Position = 0xC;
            var includeOffset = reader.ReadUInt32();

            if(includeOffset >= reader.BaseStream.Length)
            {
                prime.ParserMessage = "Invalid includes table offset";
                return PPR_FAILURE_INVALID_HEADER_OFFSET;
            }

            reader.BaseStream.Position = 0x44;
            var numIncludes = reader.Read();

            if(numIncludes > 0)
            {
                reader.BaseStream.Position = includeOffset;
                prime.Includes = new long[numIncludes];
                for(int i = 0; i < numIncludes; i++)
                {
                    if (includeOffset + (i * 4) >= reader.BaseStream.Length)
                    {
                        prime.ParserMessage = "Invalid includes table entry; unexpected end of file";
                        return PPR_FAILURE_INVALID_HEADER_OFFSET;
                    }

                    reader.BaseStream.Position = includeOffset + (i * 4);
                    var offset = reader.ReadUInt32();

                    if(offset >= obj.Length)
                    {
                        prime.ParserMessage = "Invalid includes table entry; unexpected offset entry";
                        return PPR_FAILURE_INVALID_HEADER_OFFSET;
                    }

                    try
                    {
                        prime.Includes[i] = (long)Hash64(obj.String((int)offset).Bytes());
                    }
                    catch
                    {
                        prime.ParserMessage = "Invalid includes table entry; failed to read an include string";
                        return PPR_FAILURE_INVALID_HEADER_OFFSET;
                    }
                }
            }

            // TODO: imports



            // TODO: exports

            // need to parse export struct (including flags!)
            // parse bytecode

            // TODO: anims
            // TODO: strings


            return PPR_SUCCESS;
        }

        internal static ulong Hash64(byte[] bytes, ulong fnv64Offset = 14695981039346656037, ulong fnv64Prime = 0x100000001b3)
        {
            ulong hash = fnv64Offset;

            for (var i = 0; i < bytes.Length; i++)
            {
                if (bytes[i] == 0)
                {
                    break;
                }
                hash = hash ^ bytes[i];
                hash *= fnv64Prime;
            }

            return 0x7FFFFFFFFFFFFFFF & hash;
        }
    }
}
