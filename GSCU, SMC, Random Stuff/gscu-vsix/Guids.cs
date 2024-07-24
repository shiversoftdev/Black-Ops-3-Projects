using System;

namespace shiversoft
{
    static class GuidList
    {
        public const string guidIronyLanguageServiceString = "74ae1442-9da6-474b-8f26-3e9c3083b199";
        public const string guidIronyLanguageServicePkgString = "aa6c69ab-9220-4da9-97f6-89c0edfbfdb2";
        public const string guidIronyLanguageServiceCmdSetString = "9c74ad00-9531-45a2-8e28-809edcc7e50c";
        public const string guidGSCUProjectFactoryString = "1C4A8C14-E10D-4F52-93FD-9EFE2289E9D7";
        public const string guidGSCUTemplatePkgString = "E1C8D1DB-EFF2-413E-84DA-B44A47BD2726";

        public static readonly Guid guidGSCUProjectFactory = new Guid(guidGSCUProjectFactoryString);
        public static readonly Guid guidIronyLanguageServiceCmdSet = new Guid(guidIronyLanguageServiceCmdSetString);
    };
}