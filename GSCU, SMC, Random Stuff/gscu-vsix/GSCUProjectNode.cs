using Microsoft.VisualStudio.Project;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace shiversoft.gscuLanguageService
{
    public sealed class GSCUProjectNode : ProjectNode
    {
        private Package package;

        public GSCUProjectNode(Package package) : base(package)
        {
            this.package = package;
        }

        public override Guid ProjectGuid => GuidList.guidGSCUProjectFactory;

        public override string ProjectType
        {
            get { return "GSCUProjectType"; }
        }

        /// <summary>
        /// Overriding to provide project general property page
        /// </summary>
        /// <returns>Page GUID</returns>
        protected override Guid[] GetConfigurationIndependentPropertyPages()
        {
            Guid[] result = new Guid[2];
            result[0] = typeof(GSCUProjectSettingsPage).GUID;
            result[1] = typeof(GSCUCompilerSettingsPage).GUID;

            return result;
        }

        protected override ConfigProvider CreateConfigProvider()
        {
            return new GSCUProjectConfigProvider(this);
        }

        // protected override ReferenceContainerNode CreateReferenceContainerNode() TODO

        public override void AddFileFromTemplate(
            string source, string target)
        {
            this.FileTemplateProcessor.UntokenFile(source, target);
            this.FileTemplateProcessor.Reset();
        }
    }

    public class GSCUProjectConfigProvider : ConfigProvider
    {
        public GSCUProjectConfigProvider(ProjectNode manager) :
            base(manager)
        { }

        protected override ProjectConfig CreateProjectConfiguration(string configName, string platform)
        {
            return new GSCUProjectConfiguration(ProjectManager, configName, platform);
        }
    }

    public class GSCUProjectConfiguration : ProjectConfig
    {
        public GSCUProjectConfiguration(ProjectNode project, string configuration, string platform) :
            base(project, configuration, platform)
        { }

        public override int DebugLaunch(uint grfLaunch)
        {
            string runner = $"C:\\gscu\\bin\\x86rt\\gscutest.exe"; // TODO: un-hardcode this
            string outPath = Path.Combine(ProjectManager.ProjectFolder, ProjectManager.OutputBaseRelativePath, ConfigName);
            List<string> inputFiles = new List<string>();

            foreach(var file in Directory.GetFiles(outPath, "*.gscuc", SearchOption.AllDirectories))
            {
                inputFiles.Add($"\"{file}\"");
            }
            
            //if ((grfLaunch & 0x04) != 0)
            //{
            //    args = GetConfigurationProperty(Setting.EmulatorRunArguments.ToString(), resetCache: true);
            //}
            //else
            //{
            //    args = GetConfigurationProperty(Setting.EmulatorDebugArguments.ToString(), resetCache: true);
            //}

            Process.Start(runner, string.Join(" ", inputFiles));
            return Microsoft.VisualStudio.VSConstants.S_OK;
        }

        public override int QueryDebugLaunch(uint flags, out int fCanLaunch)
        {
            fCanLaunch = 1;

            return Microsoft.VisualStudio.VSConstants.S_OK;
        }
    }
}
