/********************************************************************************************

Copyright (c) Microsoft Corporation 
All rights reserved. 

Microsoft Public License: 

This license governs use of the accompanying software. If you use the software, you 
accept this license. If you do not accept the license, do not use the software. 

1. Definitions 
The terms "reproduce," "reproduction," "derivative works," and "distribution" have the 
same meaning here as under U.S. copyright law. 
A "contribution" is the original software, or any additions or changes to the software. 
A "contributor" is any person that distributes its contribution under this license. 
"Licensed patents" are a contributor's patent claims that read directly on its contribution. 

2. Grant of Rights 
(A) Copyright Grant- Subject to the terms of this license, including the license conditions 
and limitations in section 3, each contributor grants you a non-exclusive, worldwide, 
royalty-free copyright license to reproduce its contribution, prepare derivative works of 
its contribution, and distribute its contribution or any derivative works that you create. 
(B) Patent Grant- Subject to the terms of this license, including the license conditions 
and limitations in section 3, each contributor grants you a non-exclusive, worldwide, 
royalty-free license under its licensed patents to make, have made, use, sell, offer for 
sale, import, and/or otherwise dispose of its contribution in the software or derivative 
works of the contribution in the software. 

3. Conditions and Limitations 
(A) No Trademark License- This license does not grant you rights to use any contributors' 
name, logo, or trademarks. 
(B) If you bring a patent claim against any contributor over patents that you claim are 
infringed by the software, your patent license from such contributor to the software ends 
automatically. 
(C) If you distribute any portion of the software, you must retain all copyright, patent, 
trademark, and attribution notices that are present in the software. 
(D) If you distribute any portion of the software in source code form, you may do so only 
under this license by including a complete copy of this license with your distribution. 
If you distribute any portion of the software in compiled or object code form, you may only 
do so under a license that complies with this license. 
(E) The software is licensed "as-is." You bear the risk of using it. The contributors give 
no express warranties, guarantees or conditions. You may have additional consumer rights 
under your local laws which this license cannot change. To the extent permitted under your 
local laws, the contributors exclude the implied warranties of merchantability, fitness for 
a particular purpose and non-infringement.

********************************************************************************************/

namespace Microsoft.VisualStudio.Project
{
    using System;
    using System.Diagnostics;
    using System.Diagnostics.CodeAnalysis;
    using System.Globalization;
    using System.Runtime.InteropServices;
    using Microsoft.VisualStudio.Shell;
    using Microsoft.VisualStudio.Shell.Interop;

    //=============================================================================
    // NOTE: advises on out-of-process build execution to maximize
    // future cross-platform targeting capabilities of the VS tools.

    [CLSCompliant(false)]
    [ComVisible(true)]
    [SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "Buildable")]
    public class BuildableProjectConfig : IVsBuildableProjectCfg
    {
        #region fields
        private readonly ProjectConfig config;
        private readonly EventSinkCollection callbacks = new EventSinkCollection();
        #endregion

        #region constructors
        public BuildableProjectConfig(ProjectConfig config)
        {
            this.config = config;
        }
        #endregion

        #region IVsBuildableProjectCfg methods

        public virtual int AdviseBuildStatusCallback(IVsBuildStatusCallback callback, out uint cookie)
        {
            CciTracing.TraceCall();

            cookie = callbacks.Add(callback);
            return VSConstants.S_OK;
        }

        public virtual int get_ProjectCfg(out IVsProjectCfg p)
        {
            CciTracing.TraceCall();

            p = config;
            return VSConstants.S_OK;
        }

        public virtual int QueryStartBuild(uint options, int[] supported, int[] ready)
        {
            CciTracing.TraceCall();
            if(supported != null && supported.Length > 0)
                supported[0] = 1;
            if(ready != null && ready.Length > 0)
                ready[0] = (this.config.ProjectManager.BuildInProgress) ? 0 : 1;
            return VSConstants.S_OK;
        }

        public virtual int QueryStartClean(uint options, int[] supported, int[] ready)
        {
            CciTracing.TraceCall();
            config.PrepareBuild(false);
            if(supported != null && supported.Length > 0)
                supported[0] = 1;
            if(ready != null && ready.Length > 0)
                ready[0] = (this.config.ProjectManager.BuildInProgress) ? 0 : 1;
            return VSConstants.S_OK;
        }

        public virtual int QueryStartUpToDateCheck(uint options, int[] supported, int[] ready)
        {
            CciTracing.TraceCall();
            config.PrepareBuild(false);
            if(supported != null && supported.Length > 0)
                supported[0] = 0; // TODO:
            if(ready != null && ready.Length > 0)
                ready[0] = (this.config.ProjectManager.BuildInProgress) ? 0 : 1;
            return VSConstants.S_OK;
        }

        public virtual int QueryStatus(out int done)
        {
            CciTracing.TraceCall();

            done = (this.config.ProjectManager.BuildInProgress) ? 0 : 1;
            return VSConstants.S_OK;
        }

        public virtual int StartBuild(IVsOutputWindowPane pane, uint options)
        {
            CciTracing.TraceCall();
            config.PrepareBuild(false);

            // Current version of MSBuild wish to be called in an STA
            uint flags = VSConstants.VS_BUILDABLEPROJECTCFGOPTS_REBUILD;

            // If we are not asked for a rebuild, then we build the default target (by passing null)
            this.Build(options, pane, ((options & flags) != 0) ? MSBuildTarget.Rebuild : null);

            return VSConstants.S_OK;
        }

        public virtual int StartClean(IVsOutputWindowPane pane, uint options)
        {
            CciTracing.TraceCall();
            config.PrepareBuild(true);
            // Current version of MSBuild wish to be called in an STA
            this.Build(options, pane, MSBuildTarget.Clean);
            return VSConstants.S_OK;
        }

        public virtual int StartUpToDateCheck(IVsOutputWindowPane pane, uint options)
        {
            CciTracing.TraceCall();

            return VSConstants.E_NOTIMPL;
        }

        public virtual int Stop(int fsync)
        {
            CciTracing.TraceCall();

            return VSConstants.S_OK;
        }

        public virtual int UnadviseBuildStatusCallback(uint cookie)
        {
            CciTracing.TraceCall();


            callbacks.RemoveAt(cookie);
            return VSConstants.S_OK;
        }

        public virtual int Wait(uint ms, int fTickWhenMessageQNotEmpty)
        {
            CciTracing.TraceCall();

            return VSConstants.E_NOTIMPL;
        }
        #endregion

        #region helpers

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1031:DoNotCatchGeneralExceptionTypes")]
        protected virtual bool NotifyBuildBegin()
        {
            int shouldContinue = 1;
            foreach (IVsBuildStatusCallback cb in callbacks)
            {
                try
                {
                    ErrorHandler.ThrowOnFailure(cb.BuildBegin(ref shouldContinue));
                    if (shouldContinue == 0)
                    {
                        return false;
                    }
                }
                catch (Exception e)
                {
                    // If those who ask for status have bugs in their code it should not prevent the build/notification from happening
                    Debug.Fail(String.Format(CultureInfo.CurrentCulture, SR.GetString(SR.BuildEventError, CultureInfo.CurrentUICulture), e.Message));
                }
            }

            return true;
        }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1031:DoNotCatchGeneralExceptionTypes")]
        protected virtual void NotifyBuildEnd(MSBuildResult result, string buildTarget)
        {
            int success = ((result == MSBuildResult.Successful) ? 1 : 0);

            foreach (IVsBuildStatusCallback cb in callbacks)
            {
                try
                {
                    ErrorHandler.ThrowOnFailure(cb.BuildEnd(success));
                }
                catch (Exception e)
                {
                    // If those who ask for status have bugs in their code it should not prevent the build/notification from happening
                    Debug.Fail(String.Format(CultureInfo.CurrentCulture, SR.GetString(SR.BuildEventError, CultureInfo.CurrentUICulture), e.Message));
                }
                finally
                {
                    // We want to refresh the references if we are building with the Build or Rebuild target or if the project was opened for browsing only.
                    bool shouldRepaintReferences = (buildTarget == null || buildTarget == MSBuildTarget.Build || buildTarget == MSBuildTarget.Rebuild);

                    // Now repaint references if that is needed. 
                    // We hardly rely here on the fact the ResolveAssemblyReferences target has been run as part of the build.
                    // One scenario to think at is when an assembly reference is renamed on disk thus becoming unresolvable, 
                    // but MSBuild can actually resolve it.
                    // Another one if the project was opened only for browsing and now the user chooses to build or rebuild.
                    if (shouldRepaintReferences && (result == MSBuildResult.Successful))
                    {
                        this.RefreshReferences();
                    }
                }
            }
        }

        protected virtual void Build(uint options, IVsOutputWindowPane output, string target)
        {
            if (!this.NotifyBuildBegin())
            {
                return;
            }

            try
            {
                config.ProjectManager.BuildAsync(options, this.config.ConfigName, this.config.Platform, output, target, (result, buildTarget) => this.NotifyBuildEnd(result, buildTarget));
            }
            catch(Exception e)
            {
                Trace.WriteLine("Exception : " + e.Message);
                ErrorHandler.ThrowOnFailure(output.OutputStringThreadSafe("Unhandled Exception:" + e.Message + "\n"));
                this.NotifyBuildEnd(MSBuildResult.Failed, target);
                throw;
            }
            finally
            {              
                ErrorHandler.ThrowOnFailure(output.FlushToTaskList());               
            }
        }

        /// <summary>
        /// Refreshes references and redraws them correctly.
        /// </summary>
        protected virtual void RefreshReferences()
        {
            // Refresh the reference container node for assemblies that could be resolved.
            IReferenceContainer referenceContainer = this.config.ProjectManager.GetReferenceContainer();
            if (referenceContainer == null)
                return;

            foreach(ReferenceNode referenceNode in referenceContainer.EnumReferences())
            {
                referenceNode.RefreshReference();
            }
        }
        #endregion
    }
}
