using Microsoft.VisualStudio.Project;
using Microsoft.VisualStudio.Utilities;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace shiversoft.gscuLanguageService
{
    internal enum Setting
    {
        OutputFileName,
        GSCUPath,
        CompilerOutput
    }

    [ComVisible(true)]
    public class GSCUProjectSettingsPage : SettingsPage
    {
        private string outputFileName;

        public GSCUProjectSettingsPage(ProjectNode projectManager) : base(projectManager)
        {
            this.Name = "General";
        }

        public GSCUProjectSettingsPage() : base(null) { this.Name = "General"; }

        protected override void BindProperties()
        {
            this.outputFileName = this.ProjectManager.GetProjectProperty(Setting.OutputFileName.ToString(), Microsoft.VisualStudio.Shell.Interop._PersistStorageType.PST_PROJECT_FILE, true);
        }

        protected override int ApplyChanges()
        {
            if (string.IsNullOrEmpty(this.OutputFileName))
            {
                throw new ArgumentException("The name of the output file cannot be empty");
            }

            this.ProjectManager.SetProjectProperty(Setting.OutputFileName.ToString(), Microsoft.VisualStudio.Shell.Interop._PersistStorageType.PST_PROJECT_FILE, this.OutputFileName);
            this.IsDirty = false;

            return Microsoft.VisualStudio.VSConstants.S_OK;
        }

        [System.ComponentModel.DisplayName("Output File Name")]
        public string OutputFileName
        {
            get
            {
                return this.outputFileName;
            }
            set
            {
                this.outputFileName = value;
                this.IsDirty = true;
            }
        }
    }

    [ComVisible(true)]
    public class GSCUCompilerSettingsPage : SettingsPage
    {
        private string compilerPath;

        public GSCUCompilerSettingsPage(ProjectNode projectManager) : base(projectManager)
        {
            this.Name = "Compiler";
        }

        public GSCUCompilerSettingsPage() : base(null) { this.Name = "Compiler"; }

        protected override void BindProperties()
        {
            this.compilerPath = this.ProjectManager.GetProjectProperty(Setting.GSCUPath.ToString(), Microsoft.VisualStudio.Shell.Interop._PersistStorageType.PST_PROJECT_FILE, false);
        }

        protected override int ApplyChanges()
        {
            if (string.IsNullOrEmpty(this.compilerPath))
            {
                throw new ArgumentException("Path to the compiler cannot be empty.");
            }

            this.ProjectManager.SetProjectProperty(Setting.GSCUPath.ToString(), Microsoft.VisualStudio.Shell.Interop._PersistStorageType.PST_PROJECT_FILE, this.compilerPath);

            this.IsDirty = false;
            return Microsoft.VisualStudio.VSConstants.S_OK;
        }

        [System.ComponentModel.DisplayName("GSCU Installation Path")]
        [Description("Path to your GSCU installation")]
        public string CompilerPath
        {
            get
            {
                return this.compilerPath;
            }
            set
            {
                this.compilerPath = value;
                this.IsDirty = true;
            }
        }
    }
}
