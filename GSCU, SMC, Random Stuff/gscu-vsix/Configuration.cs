using Microsoft.VisualStudio.Package;
using Microsoft.VisualStudio.TextManager.Interop;
using System;
using System.Collections.Generic;

namespace shiversoft
{
    public static partial class Configuration
    {
        public const string Name = "gscu";
        public const string FormatList = "gscu File (*.gscu)\n*.gscu";
        public static readonly Irony.Parsing.TokenColor FilenameColor;

        // TODO https://docs.microsoft.com/en-us/visualstudio/extensibility/internals/syntax-colorizing-in-a-legacy-language-service?view=vs-2022
        // https://docs.microsoft.com/en-us/dotnet/api/microsoft.visualstudio.textmanager.interop.ivshicoloritem?view=visualstudiosdk-2022
        static Configuration()
        {
            // default colors - currently, these need to be declared
            CreateColor("Keyword", COLORINDEX.CI_BLUE, COLORINDEX.CI_USERTEXT_BK);
            CreateColor("Comment", COLORINDEX.CI_DARKGREEN, COLORINDEX.CI_USERTEXT_BK);
            CreateColor("Identifier", COLORINDEX.CI_SYSPLAINTEXT_FG, COLORINDEX.CI_USERTEXT_BK);
            CreateColor("String", COLORINDEX.CI_MAROON, COLORINDEX.CI_USERTEXT_BK);
            CreateColor("Number", COLORINDEX.CI_RED, COLORINDEX.CI_USERTEXT_BK);
            CreateColor("Text", COLORINDEX.CI_SYSPLAINTEXT_FG, COLORINDEX.CI_USERTEXT_BK);
            FilenameColor = (Irony.Parsing.TokenColor)CreateColor("Filename", COLORINDEX.CI_MAROON, COLORINDEX.CI_USERTEXT_BK);
        }
    }
}