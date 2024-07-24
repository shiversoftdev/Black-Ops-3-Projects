using Irony.Parsing;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace shiversoft.gscuLanguageService
{
    internal class GscuIdentifierTerminal : IdentifierTerminal
    {
        private char FilenameSeparator = '\\';
        private bool IsFilename;

        public GscuIdentifierTerminal(string name, bool filename)
          : base(name)
        {
            IsFilename = filename;
            if(IsFilename)
            {
                AllFirstChars = "<";
            }
            else
            {
                AllFirstChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_";
            }
            AllChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890_";
            if (!IsFilename)
                return;
            AllChars += FilenameSeparator + ">";
            ++Priority;
        }

        private bool HasFilenameSeparator(string ValueString) => ValueString.IndexOf('>') == (ValueString.Length - 1);

        protected override Token QuickParse(ParsingContext context, ISourceStream source)
        {
            Token token = base.QuickParse(context, source);
            if (token != null && IsFilename && !HasFilenameSeparator(token.ValueString))
                token = (Token)null;
            return token;
        }

        protected override bool ReadBody(
          ISourceStream source,
          CompoundTokenDetails details)
        {
            bool flag = base.ReadBody(source, details);
            if (!flag || !IsFilename || HasFilenameSeparator(details.Body))
                return flag;
            details.Body = null;
            return false;
        }
    }
}
