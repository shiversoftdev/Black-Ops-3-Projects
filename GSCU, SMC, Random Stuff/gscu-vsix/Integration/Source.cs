/***************************************************************************

Copyright (c) Microsoft Corporation. All rights reserved.
This code is licensed under the Visual Studio SDK license terms.
THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.

***************************************************************************/

using Microsoft.VisualStudio.Package;
using Microsoft.VisualStudio.TextManager.Interop;
using System;
using System.Collections.Generic;
using System.Text;

namespace shiversoft
{
    public class Source : Microsoft.VisualStudio.Package.Source
    {
        public Source(LanguageService service, IVsTextLines textLines, Colorizer colorizer)
            : base(service, textLines, colorizer)
        {
        }

        private object parseResult;
        public object ParseResult
        {
            get { return parseResult; }
            set { parseResult = value; }
        }

        private IList<TextSpan[]> braces;
        public IList<TextSpan[]> Braces
        {
            get { return braces; }
            set { braces = value; }
        }

        public TokenInfo[] GetLineInfo(int line) => this.GetColorizer().GetLineInfo(this.GetTextLines(), line, this.ColorState);
    }
}