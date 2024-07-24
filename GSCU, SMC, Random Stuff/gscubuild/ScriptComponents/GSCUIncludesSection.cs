using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace gscubuild.ScriptComponents
{
    internal sealed class GSCUIncludesSection : GSCUScriptSection
    {
        /// <summary>
        /// Internal list of includes
        /// </summary>
        public HashSet<ulong> Includes = new HashSet<ulong>();

        public GSCUScriptObject Script { get; private set; }
        private GSCUIncludesSection(GSCUScriptObject script) { Script = script; } //We dont want initializations of this class without our deserialization procedures

        public static GSCUIncludesSection New(GSCUScriptObject script)
        {
            GSCUIncludesSection section = new GSCUIncludesSection(script);
            section.Includes = new HashSet<ulong>();
            return section;
        }

        /// <summary>
        /// Add an include to this script
        /// </summary>
        /// <param name="Include"></param>
        public void Add(ulong Include)
        {
            Includes.Add(Include);
        }

        /// <summary>
        /// Remove an include from this script
        /// </summary>
        /// <param name="Include"></param>
        public void Remove(ulong Include)
        {
            Includes.Remove(Include);
        }

        /// <summary>
        /// Number of includes in this section
        /// </summary>
        /// <returns></returns>
        public override ushort Count()
        {
            return (ushort)Includes.Count;
        }

        /// <summary>
        /// Returns the section size. For includes, this consists of the string and the reference for each include.
        /// </summary>
        /// <returns></returns>
        public override uint Size()
        {
            uint count = 0;

            foreach (ulong s in Includes)
                count += 8;

            uint Base = GetBaseAddress();

            count = (Base + count).AlignValue(0x10) - Base;

            return count;
        }

        public override byte[] Serialize()
        {
            byte[] data = new byte[Size()];

            BinaryWriter writer = new BinaryWriter(new MemoryStream(data));

            foreach (ulong s in Includes)
            {
                writer.Write(s);
            }

            writer.Dispose();

            return data;
        }

        public override void UpdateHeader(ref GSCUScriptHeader Header)
        {
            Header.Fields.num_includes = Count();
            Header.Fields.includes = GetBaseAddress();
        }
    }
}
