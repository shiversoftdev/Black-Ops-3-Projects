using gscubuild.OpCodes;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace gscubuild.ScriptComponents
{
    internal sealed class GSCUStringTableSection : GSCUScriptSection
    {
        public GSCUScriptObject Script { get; private set; }
        private GSCUStringTableSection(GSCUScriptObject script) { Script = script; } //Prevent public initializers

        public static GSCUStringTableSection New(GSCUScriptObject script)
        {
            GSCUStringTableSection section = new GSCUStringTableSection(script);
            section.LoadedOffsetPairs = new Dictionary<uint, GSCUStringTableEntry>();
            section.TableEntries = new Dictionary<string, GSCUStringTableEntry>();
            return section;
        }

        /// <summary>
        /// This table is a store of the loaded offsets to the referenced string table entries. Its a reversed link that allows new OP_GetString codes to resolve their expected reference.
        /// </summary>
        private Dictionary<uint, GSCUStringTableEntry> LoadedOffsetPairs;

        private Dictionary<string, GSCUStringTableEntry> TableEntries;

        public override ushort Count()
        {
            return (ushort)TableEntries.Keys.Count;
        }

        public override void Commit(ref byte[] RawData, ref GSCUScriptHeader Header)
        {
            byte[] LocalData = _serialize(RawData);

            byte[] NewBuffer = new byte[(LocalData.Length + RawData.Length).AlignValue(0x10)];

            RawData.CopyTo(NewBuffer, 0);
            LocalData.CopyTo(NewBuffer, RawData.Length);

            RawData = NewBuffer;

            UpdateHeader(ref Header);
            NextSection?.Commit(ref RawData, ref Header);
        }

        private byte[] _serialize(byte[] rawData)
        {
            byte[] bytes = new byte[Size()];
            BinaryWriter writer = new BinaryWriter(new MemoryStream(bytes));
            BinaryWriter rawWriter = new BinaryWriter(new MemoryStream(rawData));

            foreach (string s in TableEntries.Keys)
            {
                var strPos = writer.BaseStream.Position + rawData.Length;
                writer.WriteNullTerminatedString(TableEntries[s].Value);
                foreach (var reference in TableEntries[s].References)
                {
                    rawWriter.BaseStream.Position = reference.GetCommitDataAddress();
                    rawWriter.Write((int)(strPos - (4 + rawWriter.BaseStream.Position)));
                }
            }

            rawWriter.Dispose();
            writer.Dispose();

            return bytes;
        }

        public override byte[] Serialize()
        {
            return null;
        }

        public override uint Size()
        {
            uint count = 0;
            foreach (string s in TableEntries.Keys)
            {
                count += (uint)s.Length + 1; //null terminated 
            }

            uint Base = GetBaseAddress();
            count = (Base + count).AlignValue(0x10) - Base;
            return count;
        }

        /// <summary>
        /// Retrieve a loaded entry from the string table when loading the bytecode section
        /// </summary>
        /// <param name="OpCodeAddy"></param>
        /// <returns></returns>
        public GSCUStringTableEntry GetLoadedEntry(uint OpCodeAddy)
        {
            if (LoadedOffsetPairs.ContainsKey(OpCodeAddy))
                return LoadedOffsetPairs[OpCodeAddy];

            throw new ArgumentException("Couldn't resolve the string table entry for an opcode because the address requested was not expected.");
        }

        public override void UpdateHeader(ref GSCUScriptHeader Header)
        {
            return;
        }

        /// <summary>
        /// Add a string to the string table
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        public GSCUStringTableEntry AddString(string value)
        {
            if (TableEntries.ContainsKey(value))
                return TableEntries[value];

            GSCUStringTableEntry entry = new GSCUStringTableEntry();

            entry.Value = value;
            TableEntries[value] = entry;

            return entry;
        }

        /// <summary>
        /// Try to get a string from the string table
        /// </summary>
        /// <param name="value"></param>
        /// <param name="entry"></param>
        /// <returns></returns>
        public bool TryGetString(string value, out GSCUStringTableEntry entry)
        {
            return TableEntries.TryGetValue(value, out entry);
        }
    }

    public sealed class GSCUStringTableEntry
    {
        internal GSCUStringTableEntry() { }
        public HashSet<GSCUOP_GetString> References = new HashSet<GSCUOP_GetString>();
        public string Value;
    }
}
