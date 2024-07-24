using System;
using System.Collections.Generic;
using System.Text;

using gscubuild.ScriptComponents;

namespace gscubuild
{
    // TODO: REMEMBER TO LINK NEW SECTIONS
    internal sealed class GSCUScriptObject
    {
        /// <summary>
        /// Script header for this object
        /// </summary>
        public GSCUScriptHeader Header => __header__;
        private GSCUScriptHeader __header__;

        /// <summary>
        /// Script includes
        /// </summary>
        public GSCUIncludesSection Includes => __includes__;
        private GSCUIncludesSection __includes__;

        /// <summary>
        /// Script function export table
        /// </summary>
        public GSCUExportsSection Exports => __exports__;
        private GSCUExportsSection __exports__;

        /// <summary>
        /// Script function import table
        /// </summary>
        public GSCUImportsSection Imports => __imports__;
        private GSCUImportsSection __imports__;

        /// <summary>
        /// Script function global objects table
        /// </summary>
        public GSCUGlobalObjectsSection Globals => __globals__;
        private GSCUGlobalObjectsSection __globals__;

        /// <summary>
        /// Normal String Table
        /// </summary>
        public GSCUStringTableSection Strings => __strings__;
        private GSCUStringTableSection __strings__;


        internal GSCUScriptObject()
        {
            __header__ = GSCUScriptHeader.New(this);
            __includes__ = GSCUIncludesSection.New(this);
            __exports__ = GSCUExportsSection.New(this);
            __imports__ = GSCUImportsSection.New(this);
            __globals__ = GSCUGlobalObjectsSection.New(this);
            __strings__ = GSCUStringTableSection.New(this);
            Link();
        }

        public byte[] Serialize()
        {
            byte[] DataBuffer = new byte[0];
            Header.Commit(ref DataBuffer, ref __header__);
            Header.CommitHeader(ref DataBuffer);
            return DataBuffer;
        }

        private void Link()
        {
            Header.Link(null, Includes);
            Includes.Link(Header, Exports);
            Exports.Link(Includes, Imports);
            Imports.Link(Exports, Globals);
            Globals.Link(Imports, Strings);
            Strings.Link(Globals, null); // strings have to come after exports now
        }

        /// <summary>
        /// Cast a script object to a byte array, emitting its raw data.
        /// </summary>
        /// <param name="obj"></param>
        public static explicit operator byte[](GSCUScriptObject obj)
        {
            return obj.Serialize();
        }

        /// <summary>
        /// Calculate a script hash for a string input.
        /// </summary>
        /// <param name="input"></param>
        /// <returns></returns>
        public uint HashCanon32(string input)
        {
            if (input == null)
            {
                return 0;
            }

            input = input.ToLower();
            return (uint)Unk0Hash(input);
        }

        /// <summary>
        /// Calculate a script hash for a string input.
        /// </summary>
        /// <param name="input"></param>
        /// <returns></returns>
        public static uint HashCanon32S(string input)
        {
            if (input == null)
            {
                return 0;
            }

            input = input.ToLower();
            return (uint)Unk0Hash(input);
        }

        public ulong HashCanon64(string input)
        {
            if(input == null)
            {
                return 0;
            }

            input = input.ToLower();
            return 0x7FFFFFFFFFFFFFFF & HashFNV1a(Encoding.ASCII.GetBytes(input));
        }

        public static ulong HashCanon64S(string input)
        {
            if (input == null)
            {
                return 0;
            }

            input = input.ToLower();
            return 0x7FFFFFFFFFFFFFFF & HashFNV1a(Encoding.ASCII.GetBytes(input));
        }

        private static ulong Unk0Hash(string input)
        {
            uint hash = 0x4B9ACE2F;
            input = input.ToLower();

            foreach (char c in input)
                hash = ((c + hash) ^ ((c + hash) << 10)) + (((c + hash) ^ ((c + hash) << 10)) >> 6);

            return 0x8001 * ((9 * hash) ^ ((9 * hash) >> 11));
        }

        private static ulong HashFNV1a(byte[] bytes, ulong fnv64Offset = 14695981039346656037, ulong fnv64Prime = 0x100000001b3)
        {
            ulong hash = fnv64Offset;

            for (var i = 0; i < bytes.Length; i++)
            {
                hash = hash ^ bytes[i];
                hash *= fnv64Prime;
            }

            return hash;
        }
    }
}
