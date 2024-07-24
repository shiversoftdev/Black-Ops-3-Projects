using Microsoft.VisualStudio.Project;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using IOleServiceProvider = Microsoft.VisualStudio.OLE.Interop.IServiceProvider;

namespace shiversoft.gscuLanguageService
{
    [Guid(GuidList.guidGSCUProjectFactoryString)]
    public sealed class GSCUProjectFactory : ProjectFactory
    {
        Package pkg;
        public GSCUProjectFactory(Package p) : base(p)
        {
            pkg = p;
        }

        protected override ProjectNode CreateProject()
        {
            GSCUProjectNode project = new GSCUProjectNode(this.pkg);

            project.SetSite((IOleServiceProvider)((IServiceProvider)this.pkg).GetService(typeof(IOleServiceProvider)));
            return project;
        }
    }
}
