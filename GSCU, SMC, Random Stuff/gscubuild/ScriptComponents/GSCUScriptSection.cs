using System;
using System.Collections.Generic;
using System.Text;

namespace gscubuild.ScriptComponents
{
    internal abstract class GSCUScriptSection
    {
        public GSCUScriptSection NextSection { get; private set; }
        public GSCUScriptSection PreviousSection { get; private set; }

        public abstract uint Size();

        public abstract ushort Count();

        public abstract byte[] Serialize();

        public abstract void UpdateHeader(ref GSCUScriptHeader Header);

        public uint GetScriptEnd()
        {
            return Size() + (NextSection?.GetScriptEnd() ?? 0u);
        }

        public uint GetBaseAddress()
        {
            if (PreviousSection == null)
                return 0;

            return PreviousSection.GetSectionEnd();
        }

        public uint GetSectionEnd()
        {
            if (PreviousSection == null)
                return Size();

            return Size() + PreviousSection.GetSectionEnd();
        }

        internal void Link(GSCUScriptSection previous, GSCUScriptSection next)
        {
            NextSection = next;
            PreviousSection = previous;
        }

        public virtual void Commit(ref byte[] RawData, ref GSCUScriptHeader Header)
        {
            byte[] LocalData = Serialize();

            byte[] NewBuffer = new byte[LocalData.Length + RawData.Length];

            RawData.CopyTo(NewBuffer, 0);
            LocalData.CopyTo(NewBuffer, RawData.Length);

            RawData = NewBuffer;

            UpdateHeader(ref Header);
            NextSection?.Commit(ref RawData, ref Header);
        }
    }
}
