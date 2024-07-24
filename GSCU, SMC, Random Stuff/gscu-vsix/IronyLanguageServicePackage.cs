using Microsoft.VisualStudio.OLE.Interop;
using Microsoft.VisualStudio.Shell;
using Microsoft.VisualStudio.Shell.Interop;
using Microsoft.Win32;
using shiversoft.gscuLanguageService;
using System;
using System.ComponentModel.Design;
using System.Diagnostics;
using System.Globalization;
using System.Runtime.InteropServices;

namespace shiversoft
{
    [ProvideProjectFactory(typeof(GSCUProjectFactory), "Default GSCU Project", "GSCU Project Files (*.gscuproj);*.gscuproj", "gscuproj", "gscuproj", @"Templates\Projects", LanguageVsTemplate = "GSCU Project", NewProjectRequireNewFolderVsTemplate = true)]
    [ProvideLanguageExtension(typeof(IronyLanguageService), ".gscu")]
    [ProvideLanguageService(typeof(IronyLanguageService), "GSCU", 110, 
        AutoOutlining = true, CodeSense = true, CodeSenseDelay = 100, 
        EnableCommenting = true, EnableFormatSelection = true, EnableLineNumbers = true, 
        MatchBracesAtCaret = true, QuickInfo = true, RequestStockColors = true, 
        ShowCompletion = true, ShowDropDownOptions = true, ShowMatchingBrace = true, DefaultToInsertSpaces = true, MatchBraces = true)]
    [PackageRegistration(UseManagedResourcesOnly = true)]
    [DefaultRegistryRoot("Software\\Microsoft\\VisualStudio\\16.0")]
    [Guid(GuidList.guidIronyLanguageServicePkgString)]
    [ProvideService(typeof(IronyLanguageService), ServiceName = "GSCU Language Service")]
    [ProvideObject(typeof(GSCUProjectSettingsPage))]
    [ProvideObject(typeof(GSCUCompilerSettingsPage))]
    public class Package : IronyPackage
    {
        public Package() => Trace.WriteLine(string.Format((IFormatProvider)CultureInfo.CurrentCulture, "Entering constructor for: {0}", (object)((object)this).ToString()));

        protected override void Initialize()
        {
            // Trace.WriteLine(string.Format((IFormatProvider)CultureInfo.CurrentCulture, "Entering Initialize() of: {0}", (object)((object)this).ToString()));
            base.Initialize();
            this.RegisterProjectFactory(new GSCUProjectFactory(this));
            if (!(this.GetService(typeof(IMenuCommandService)) is OleMenuCommandService service))
                return;
            //MenuCommand command = new MenuCommand(new EventHandler(this.MenuItemCallback), new CommandID(GuidList.guidCodLanguageCmdSet, 256));
            //((MenuCommandService)service).AddCommand(command);
        }
    }
}