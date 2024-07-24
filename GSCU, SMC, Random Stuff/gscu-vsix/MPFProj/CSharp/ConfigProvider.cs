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

/* This file provides a base functionality for IVsCfgProvider2.
   Instead of using the IVsProjectCfgEventsHelper object we have our own little sink and call our own helper methods
   similar to the interface. But there is no real benefit in inheriting from the interface in the first place. 
   Using the helper object seems to be:  
    a) undocumented
    b) not really wise in the managed world
*/
namespace Microsoft.VisualStudio.Project
{
	using System;
	using System.Collections;
	using System.Collections.Generic;
	using System.Collections.ObjectModel;
	using System.Diagnostics;
	using System.Diagnostics.CodeAnalysis;
	using System.Globalization;
	using System.IO;
	using System.Linq;
	using System.Runtime.InteropServices;
	using Microsoft.Build.Construction;
	using Microsoft.VisualStudio.Shell;
	using Microsoft.VisualStudio.Shell.Interop;
	using MSBuild = Microsoft.Build.Evaluation;
	using MSBuildConstruction = Microsoft.Build.Construction;

    [CLSCompliant(false)]
    [ComVisible(true)]
    public class ConfigProvider : IVsCfgProvider2, IVsProjectCfgProvider, IVsExtensibleObject
    {
        #region fields
        public const string AnyCpuPlatform = "Any CPU";
        public const string X86Platform = "x86";

        private readonly ProjectNode _project;
        private readonly EventSinkCollection cfgEventSinks = new EventSinkCollection();
        private List<KeyValuePair<KeyValuePair<string, string>, string>> newCfgProps = new List<KeyValuePair<KeyValuePair<string, string>, string>>();
        private readonly Dictionary<string, ProjectConfig> configurationsList = new Dictionary<string, ProjectConfig>();
        #endregion

        #region Properties
        /// <summary>
        /// The associated project.
        /// </summary>
        protected ProjectNode ProjectManager
        {
            get
            {
                return this._project;
            }
        }
        /// <summary>
        /// If the project system wants to add custom properties to the property group then 
        /// they provide us with this data.
        /// Returns/sets the [(&lt;propName, propCondition&gt;) &lt;propValue&gt;] collection
        /// </summary>
        public virtual ReadOnlyCollection<KeyValuePair<KeyValuePair<string, string>, string>> NewConfigProperties
        {
            get
            {
                return newCfgProps.AsReadOnly();
            }
        }

        #endregion

        #region constructors
        public ConfigProvider(ProjectNode manager)
        {
            if (manager == null)
                throw new ArgumentNullException("manager");

            this._project = manager;
        }
        #endregion

        #region methods

        public virtual string GetConfigurationCondition(string configurationName)
        {
            //Contract.Ensures(Contract.Result<string>() != null);

            const string configString = " '$(Configuration)' == '{0}' ";
            return string.Format(CultureInfo.InvariantCulture, configString, configurationName);
        }

        public virtual string GetPlatformCondition(string platformName)
        {
            //Contract.Ensures(Contract.Result<string>() != null);

            const string platformString = " '$(Platform)' == '{0}' ";
            return string.Format(CultureInfo.InvariantCulture, platformString, GetPlatformPropertyFromPlatformName(platformName));
        }

        public virtual string GetConfigurationPlatformCondition(string configurationName, string platformName)
        {
            //Contract.Ensures(Contract.Result<string>() != null);

            const string configPlatformString = " '$(Configuration)|$(Platform)' == '{0}|{1}' ";
            return string.Format(CultureInfo.InvariantCulture, configPlatformString, configurationName, GetPlatformPropertyFromPlatformName(platformName));
        }

        /// <summary>
        /// Creates new Project Configuration objects based on the configuration name.
        /// </summary>
        /// <param name="configName">The name of the configuration</param>
        /// <returns>An instance of a ProjectConfig object.</returns>
        protected virtual ProjectConfig GetProjectConfiguration(string configName, string platform)
        {
            if (configName == null)
                throw new ArgumentNullException("configName");
            if (platform == null)
                throw new ArgumentNullException("platform");

            string key = string.Format("{0}|{1}", configName, platform);

            // if we already created it, return the cached one
            ProjectConfig requestedConfiguration;
            if (configurationsList.TryGetValue(key, out requestedConfiguration))
                return requestedConfiguration;

            requestedConfiguration = CreateProjectConfiguration(configName, platform);
            configurationsList.Add(key, requestedConfiguration);
            return requestedConfiguration;
        }

        protected virtual ProjectConfig CreateProjectConfiguration(string configName, string platform)
        {
            if (configName == null)
                throw new ArgumentNullException("configName");
            if (platform == null)
                throw new ArgumentNullException("platform");

            return new ProjectConfig(this._project, configName, platform);
        }

        #endregion

        #region IVsProjectCfgProvider methods
        /// <summary>
        /// Provides access to the IVsProjectCfg interface implemented on a project's configuration object. 
        /// </summary>
        /// <param name="projectCfgCanonicalName">The canonical name of the configuration to access.</param>
        /// <param name="projectCfg">The IVsProjectCfg interface of the configuration identified by szProjectCfgCanonicalName.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code. </returns>
        public virtual int OpenProjectCfg(string projectCfgCanonicalName, out IVsProjectCfg projectCfg)
        {
            if (projectCfgCanonicalName == null)
                throw new ArgumentNullException("projectCfgCanonicalName");
            if (string.IsNullOrEmpty(projectCfgCanonicalName))
                throw new ArgumentException("projectCfgCanonicalName cannot be null or empty");

            projectCfg = null;

            // Be robust in release
            if(projectCfgCanonicalName == null)
            {
                return VSConstants.E_INVALIDARG;
            }

            Debug.Assert(this._project != null && this._project.BuildProject != null);

            string[] configs = GetPropertiesConditionedOn(ProjectFileConstants.Configuration);
            string[] platforms = GetPlatformsFromProject();

            foreach (string config in configs)
            {
                foreach (string platform in platforms)
                {
                    if (string.Equals(string.Format("{0}|{1}", config, platform), projectCfgCanonicalName, StringComparison.OrdinalIgnoreCase))
                    {
                        projectCfg = this.GetProjectConfiguration(config, platform);
                        if (projectCfg != null)
                            return VSConstants.S_OK;
                        else
                            return VSConstants.E_FAIL;
                    }
                }
            }

            return VSConstants.E_INVALIDARG;
        }

        /// <summary>
        /// Checks whether or not this configuration provider uses independent configurations. 
        /// </summary>
        /// <param name="usesIndependentConfigurations">true if independent configurations are used, false if they are not used. By default returns true.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code.</returns>
        public virtual int get_UsesIndependentConfigurations(out int usesIndependentConfigurations)
        {
            usesIndependentConfigurations = 1;
            return VSConstants.S_OK;
        }
        #endregion

        #region IVsCfgProvider2 methods

        /// <summary>
        /// Copies an existing configuration name or creates a new one. 
        /// </summary>
        /// <param name="name">The name of the new configuration.</param>
        /// <param name="cloneName">the name of the configuration to copy, or a null reference, indicating that AddCfgsOfCfgName should create a new configuration.</param>
        /// <param name="fPrivate">Flag indicating whether or not the new configuration is private. If fPrivate is set to true, the configuration is private. If set to false, the configuration is public. This flag can be ignored.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code. </returns>
        public virtual int AddCfgsOfCfgName(string name, string cloneName, int fPrivate)
        {
            // We need to QE/QS the project file
            if (!this.ProjectManager.QueryEditProjectFile(false))
            {
                throw Marshal.GetExceptionForHR(VSConstants.OLE_E_PROMPTSAVECANCELLED);
            }

            foreach (MSBuild.Project project in GetBuildProjects(true))
            {
                int hr = AddConfiguration(project, name, cloneName);
                if (ErrorHandler.Failed(hr))
                    return hr;
            }

            NotifyOnCfgNameAdded(name);
            return VSConstants.S_OK;
        }

        /// <summary>
        /// Copies an existing platform name or creates a new one. 
        /// </summary>
        /// <param name="platformName">The name of the new platform.</param>
        /// <param name="clonePlatformName">The name of the platform to copy, or a null reference, indicating that AddCfgsOfPlatformName should create a new platform.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code.</returns>
        public virtual int AddCfgsOfPlatformName(string platformName, string clonePlatformName)
        {
            // We need to QE/QS the project file
            if (!this.ProjectManager.QueryEditProjectFile(false))
            {
                throw Marshal.GetExceptionForHR(VSConstants.OLE_E_PROMPTSAVECANCELLED);
            }

            foreach (MSBuild.Project project in GetBuildProjects(true))
            {
                int hr = AddPlatform(project, platformName, clonePlatformName);
                if (ErrorHandler.Failed(hr))
                    return hr;
            }

            NotifyOnPlatformNameAdded(platformName);
            return VSConstants.S_OK;
        }

        /// <summary>
        /// Deletes a specified configuration name. 
        /// </summary>
        /// <param name="name">The name of the configuration to be deleted.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code. </returns>
        public virtual int DeleteCfgsOfCfgName(string name)
        {
            if (name == null)
                throw new ArgumentNullException("name");
            if (string.IsNullOrEmpty(name))
                throw new ArgumentException("name cannot be null or empty");

            // We need to QE/QS the project file
            if(!this.ProjectManager.QueryEditProjectFile(false))
            {
                throw Marshal.GetExceptionForHR(VSConstants.OLE_E_PROMPTSAVECANCELLED);
            }

            // Verify that this configuration exists
            string[] configs = GetPropertiesConditionedOn(ProjectFileConstants.Configuration);
            if (!configs.Contains(name, StringComparer.OrdinalIgnoreCase))
                return VSConstants.S_OK;

            foreach (MSBuild.Project project in GetBuildProjects(true))
            {
                int hr = DeleteConfiguration(project, name);
                if (ErrorHandler.Failed(hr))
                    return hr;
            }

            NotifyOnCfgNameDeleted(name);
            return VSConstants.S_OK;
        }

        /// <summary>
        /// Deletes a specified platform name. 
        /// </summary>
        /// <param name="platName">The platform name to delete.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code.</returns>
        public virtual int DeleteCfgsOfPlatformName(string platName)
        {
            if (platName == null)
                throw new ArgumentNullException("platName");
            if (string.IsNullOrEmpty(platName))
                throw new ArgumentException("platName cannot be null or empty");

            // We need to QE/QS the project file
            if (!this.ProjectManager.QueryEditProjectFile(false))
            {
                throw Marshal.GetExceptionForHR(VSConstants.OLE_E_PROMPTSAVECANCELLED);
            }

            // Verify that this configuration exists
            string[] platforms = GetPlatformsFromProject();
            if (!platforms.Contains(platName, StringComparer.OrdinalIgnoreCase))
                return VSConstants.S_OK;

            foreach (MSBuild.Project project in GetBuildProjects(true))
            {
                int hr = DeletePlatform(project, platName);
                if (ErrorHandler.Failed(hr))
                    return hr;
            }

            NotifyOnPlatformNameDeleted(platName);
            return VSConstants.S_OK;
        }

        /// <summary>
        /// Returns the existing configurations stored in the project file.
        /// </summary>
        /// <param name="celt">Specifies the requested number of property names. If this number is unknown, <paramref name="celt"/> can be zero.</param>
        /// <param name="names">On input, an allocated array to hold the number of configuration property names specified by <paramref name="celt"/>. This parameter can also be a <see langword="null"/> reference if the <paramref name="celt"/> parameter is zero. 
        /// On output, names contains configuration property names.</param>
        /// <param name="actual">The actual number of property names returned.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code.</returns>
        public virtual int GetCfgNames(uint celt, string[] names, uint[] actual)
        {
            // get's called twice, once for allocation, then for retrieval            
            int i = 0;

            string[] configList = GetPropertiesConditionedOn(ProjectFileConstants.Configuration);

            if(names != null)
            {
                foreach(string config in configList)
                {
                    names[i++] = config;
                    if(i == celt)
                        break;
                }
            }
            else
                i = configList.Length;

            if(actual != null)
            {
                actual[0] = (uint)i;
            }

            return VSConstants.S_OK;
        }

        /// <summary>
        /// Returns the configuration associated with a specified configuration or platform name. 
        /// </summary>
        /// <param name="name">The name of the configuration to be returned.</param>
        /// <param name="platName">The name of the platform for the configuration to be returned.</param>
        /// <param name="cfg">The implementation of the IVsCfg interface.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code.</returns>
        public virtual int GetCfgOfName(string name, string platName, out IVsCfg cfg)
        {
            cfg = null;
            cfg = this.GetProjectConfiguration(name, platName);

            return VSConstants.S_OK;
        }

        /// <summary>
        /// Returns a specified configuration property. 
        /// </summary>
        /// <param name="propid">Specifies the property identifier for the property to return. For valid values, see <see cref="__VSCFGPROPID"/> and <see cref="__VSCFGPROPID2"/>.</param>
        /// <param name="var">The value of the property.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code.</returns>
        public virtual int GetCfgProviderProperty(int propid, out object var)
        {
            switch ((__VSCFGPROPID)propid)
            {
            // If true, indicates that AddCfgsOfCfgName can be called on this object.
            case __VSCFGPROPID.VSCFGPROPID_SupportsCfgAdd:
                var = true;
                break;

            // If true, indicates that DeleteCfgsOfCfgName can be called on this object.
            case __VSCFGPROPID.VSCFGPROPID_SupportsCfgDelete:
                var = true;
                break;

            // If true, indicates that RenameCfgsOfCfgName can be called on this object.
            case __VSCFGPROPID.VSCFGPROPID_SupportsCfgRename:
                var = true;
                break;

            // If true, indicates that AddCfgsOfPlatformName can be called on this object.
            case __VSCFGPROPID.VSCFGPROPID_SupportsPlatformAdd:
                var = true;
                break;

            // If true, indicates that DeleteCfgsOfPlatformName can be called on this object.
            case __VSCFGPROPID.VSCFGPROPID_SupportsPlatformDelete:
                var = true;
                break;

            // Establishes the basis for automation extenders to make the configuration automation assignment extensible.
            case __VSCFGPROPID.VSCFGPROPID_IntrinsicExtenderCATID:
                var = null;
                return VSConstants.E_NOTIMPL;

            // Configurations will be hidden when this project is the active selected project in the selection context.
            case (__VSCFGPROPID)__VSCFGPROPID2.VSCFGPROPID_HideConfigurations:
                var = false;
                break;

            default:
                var = null;
                return VSConstants.E_NOTIMPL;
            }

            return VSConstants.S_OK;
        }

        /// <summary>
        /// Returns the per-configuration objects for this object. 
        /// </summary>
        /// <param name="celt">Number of configuration objects to be returned or zero, indicating a request for an unknown number of objects.</param>
        /// <param name="a">On input, pointer to an interface array or a null reference. On output, this parameter points to an array of IVsCfg interfaces belonging to the requested configuration objects.</param>
        /// <param name="actual">The number of configuration objects actually returned or a null reference, if this information is not necessary.</param>
        /// <param name="flags">Flags that specify settings for project configurations, or a null reference (Nothing in Visual Basic) if no additional flag settings are required. For valid prgrFlags values, see __VSCFGFLAGS.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code.</returns>
        public virtual int GetCfgs(uint celt, IVsCfg[] a, uint[] actual, uint[] flags)
        {
            if(flags != null)
                flags[0] = 0;

            int i = 0;
            string[] configList = GetPropertiesConditionedOn(ProjectFileConstants.Configuration);
            string[] platformList = GetPlatformsFromProject();

            if (a != null)
            {
                foreach (string configName in configList)
                {
                    foreach (string platform in platformList)
                    {
                        a[i] = this.GetProjectConfiguration(configName, platform);

                        i++;
                        if (i == celt)
                            break;
                    }

                    if (i == celt)
                        break;
                }
            }
            else
            {
                i = configList.Length * platformList.Length;
            }

            if(actual != null)
                actual[0] = (uint)i;

            return VSConstants.S_OK;
        }

        /// <summary>
        /// Returns one or more platform names. 
        /// </summary>
        /// <param name="celt">Specifies the requested number of platform names. If this number is unknown, <paramref name="celt"/> can be zero.</param>
        /// <param name="names">On input, an allocated array to hold the number of platform names specified by <paramref name="celt"/>. This parameter can also be <see langword="null"/> if the <paramref name="celt"/> parameter is zero. On output, <paramref name="names"/> contains platform names.</param>
        /// <param name="actual">The actual number of platform names returned.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code.</returns>
        public virtual int GetPlatformNames(uint celt, string[] names, uint[] actual)
        {
            string[] platforms = this.GetPlatformsFromProject();
            return GetPlatforms(celt, names, actual, platforms);
        }

        /// <summary>
        /// Returns the set of platforms that are installed on the user's machine. 
        /// </summary>
        /// <param name="celt">Specifies the requested number of supported platform names. If this number is unknown, <paramref name="celt"/> can be zero.</param>
        /// <param name="names">On input, an allocated array to hold the number of names specified by <paramref name="celt"/>. This parameter can also be <see langword="null"/> if the <paramref name="celt"/> parameter is zero. On output, <paramref name="names"/> contains the names of supported platforms</param>
        /// <param name="actual">The actual number of platform names returned.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code.</returns>
        public virtual int GetSupportedPlatformNames(uint celt, string[] names, uint[] actual)
        {
            string[] platforms = this.GetSupportedPlatformsFromProject();
            return GetPlatforms(celt, names, actual, platforms);
        }

        /// <summary>
        /// Assigns a new name to a configuration. 
        /// </summary>
        /// <param name="old">The old name of the target configuration.</param>
        /// <param name="newname">The new name of the target configuration.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code.</returns>
        public virtual int RenameCfgsOfCfgName(string old, string newname)
        {
            if (old == null)
                throw new ArgumentNullException("old");
            if (newname == null)
                throw new ArgumentNullException("newname");
            if (string.IsNullOrEmpty(old))
                throw new ArgumentException("old cannot be null or empty");
            if (string.IsNullOrEmpty(newname))
                throw new ArgumentException("newname cannot be null or empty");

            // We need to QE/QS the project file
            if (!this.ProjectManager.QueryEditProjectFile(false))
            {
                throw Marshal.GetExceptionForHR(VSConstants.OLE_E_PROMPTSAVECANCELLED);
            }

            foreach (MSBuild.Project project in GetBuildProjects(true))
            {
                int hr = RenameConfiguration(project, old, newname);
                if (ErrorHandler.Failed(hr))
                    return hr;
            }

            string[] platforms = GetPlatformsFromProject();
            foreach (var platform in platforms)
            {
                string oldKey = string.Format("{0}|{1}", old, platform);
                string newKey = string.Format("{0}|{1}", newname, platform);

                // Update the name in our configuration list
                ProjectConfig configuration;
                if (configurationsList.TryGetValue(oldKey, out configuration))
                {
                    configurationsList.Remove(oldKey);
                    configurationsList.Add(newKey, configuration);
                    // notify the configuration of its new name
                    configuration.ConfigName = newname;
                }
            }

            NotifyOnCfgNameRenamed(old, newname);

            return VSConstants.S_OK;
        }

        /// <summary>
        /// Cancels a registration for configuration event notification. 
        /// </summary>
        /// <param name="cookie">The cookie used for registration.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code.</returns>
        public virtual int UnadviseCfgProviderEvents(uint cookie)
        {
            this.cfgEventSinks.RemoveAt(cookie);
            return VSConstants.S_OK;
        }

        /// <summary>
        /// Registers the caller for configuration event notification. 
        /// </summary>
        /// <param name="sink">Reference to the IVsCfgProviderEvents interface to be called to provide notification of configuration events.</param>
        /// <param name="cookie">Reference to a token representing the completed registration</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code.</returns>
        public virtual int AdviseCfgProviderEvents(IVsCfgProviderEvents sink, out uint cookie)
        {
            cookie = this.cfgEventSinks.Add(sink);
            return VSConstants.S_OK;
        }
        #endregion

        protected virtual IEnumerable<MSBuild.Project> GetBuildProjects()
        {
            return GetBuildProjects(true);
        }

        protected virtual IEnumerable<MSBuild.Project> GetBuildProjects(bool includeUserBuildProjects)
        {
            IEnumerable<MSBuild.Project> result = new[] { _project.BuildProject };
            if (!includeUserBuildProjects || ProjectManager.UserBuildProject == null)
                return result;

            return result.Concat(new[] { ProjectManager.UserBuildProject });
        }

        protected virtual int AddConfiguration(MSBuild.Project project, string configurationName, string cloneConfigurationName)
        {
            if (!string.IsNullOrEmpty(cloneConfigurationName))
            {
                string[] existingConfigurations = GetPropertiesConditionedOn(ProjectFileConstants.Configuration);
                if (existingConfigurations.Contains(cloneConfigurationName, StringComparer.OrdinalIgnoreCase))
                    return CloneConfiguration(project, cloneConfigurationName, configurationName);
            }

            return AddConfiguration(project, configurationName);
        }

        protected virtual int RenameConfiguration(MSBuild.Project project, string oldConfigurationName, string newConfigurationName)
        {
            if (project == null)
                throw new ArgumentNullException("project");

            // First create the condition that represent the configuration we want to rename
            string condition = GetConfigurationCondition(oldConfigurationName).Trim();
            string[] platforms = GetPlatformsFromProject();

            foreach (ProjectPropertyGroupElement config in project.Xml.PropertyGroups.ToArray())
            {
                // Only care about conditional property groups
                if (config.Condition == null || config.Condition.Length == 0)
                    continue;

                if (string.Equals(config.Condition.Trim(), condition, StringComparison.OrdinalIgnoreCase))
                {
                    // Change the name 
                    config.Condition = GetConfigurationCondition(newConfigurationName);
                }

                foreach (var platform in platforms)
                {
                    string platformCondition = GetConfigurationPlatformCondition(oldConfigurationName, platform).Trim();
                    if (string.Equals(config.Condition.Trim(), platformCondition, StringComparison.OrdinalIgnoreCase))
                    {
                        // Change the name 
                        config.Condition = GetConfigurationPlatformCondition(newConfigurationName, platform);
                    }
                }
            }

            return VSConstants.S_OK;
        }

        protected virtual int DeleteConfiguration(MSBuild.Project project, string configurationName)
        {
            if (project == null)
                throw new ArgumentNullException("project");

            // Verify that this configuration exists
            string[] configs = GetPropertiesConditionedOn(ProjectFileConstants.Configuration);
            if (!configs.Contains(configurationName, StringComparer.OrdinalIgnoreCase))
                return VSConstants.S_OK;

            string[] platforms = GetPlatformsFromProject();

            foreach (string config in configs)
            {
                if (!string.Equals(config, configurationName, StringComparison.OrdinalIgnoreCase))
                    continue;

                foreach (string platform in platforms)
                {
                    // Create condition of configuration to remove
                    string configCondition = GetConfigurationCondition(config).Trim();
                    string configPlatformCondition = GetConfigurationPlatformCondition(config, platform).Trim();

                    foreach (ProjectPropertyGroupElement element in project.Xml.PropertyGroups.ToArray())
                    {
                        if (element.Condition == null)
                            continue;

                        if (string.Equals(element.Condition.Trim(), configCondition, StringComparison.OrdinalIgnoreCase)
                            || string.Equals(element.Condition.Trim(), configPlatformCondition, StringComparison.OrdinalIgnoreCase))
                        {
                            element.Parent.RemoveChild(element);
                        }
                    }
                }
            }

            return VSConstants.S_OK;
        }

        protected virtual int AddPlatform(MSBuild.Project project, string platformName, string clonePlatformName)
        {
            if (!string.IsNullOrEmpty(clonePlatformName))
            {
                string[] existingPlatforms = GetPlatformsFromProject();
                if (existingPlatforms.Contains(clonePlatformName, StringComparer.OrdinalIgnoreCase))
                    return ClonePlatform(project, clonePlatformName, platformName);
            }

            return AddPlatform(project, platformName);
        }

        protected virtual int DeletePlatform(MSBuild.Project project, string platformName)
        {
            if (project == null)
                throw new ArgumentNullException("project");

            // Verify that this configuration exists
            string[] platforms = GetPlatformsFromProject();
            if (!platforms.Contains(platformName, StringComparer.OrdinalIgnoreCase))
                return VSConstants.S_OK;

            string[] configs = GetPropertiesConditionedOn(ProjectFileConstants.Configuration);

            foreach (string platform in platforms)
            {
                if (!string.Equals(platform, platformName, StringComparison.OrdinalIgnoreCase))
                    continue;

                foreach (string config in configs)
                {
                    // Create condition of configuration to remove
                    string platformCondition = GetPlatformCondition(platform).Trim();
                    string configPlatformCondition = GetConfigurationPlatformCondition(config, platform).Trim();

                    foreach (ProjectPropertyGroupElement element in project.Xml.PropertyGroups.ToArray())
                    {
                        if (element.Condition == null)
                            continue;

                        if (string.Equals(element.Condition.Trim(), platformCondition, StringComparison.OrdinalIgnoreCase)
                            || string.Equals(element.Condition.Trim(), configPlatformCondition, StringComparison.OrdinalIgnoreCase))
                        {
                            element.Parent.RemoveChild(element);
                        }
                    }
                }
            }

            return VSConstants.S_OK;
        }

        protected virtual int AddConfiguration(MSBuild.Project project, string configurationName)
        {
            if (project == null)
                throw new ArgumentNullException("project");
            if (configurationName == null)
                throw new ArgumentNullException("configurationName");
            if (string.IsNullOrEmpty(configurationName))
                throw new ArgumentException("configurationName cannot be null or empty");

            MSBuildConstruction.ProjectElement lastRelevantElement = null;
            foreach (ProjectPropertyGroupElement group in project.Xml.PropertyGroupsReversed)
            {
                if (string.IsNullOrEmpty(group.Condition))
                    continue;

                if (group.Condition.IndexOf("'$(Configuration)'", StringComparison.OrdinalIgnoreCase) >= 0
                    || group.Condition.IndexOf("'$(Platform)'", StringComparison.OrdinalIgnoreCase) >= 0
                    || group.Condition.IndexOf("'$(Configuration)|$(Platform)'", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    lastRelevantElement = group;
                    break;
                }
            }

            if (lastRelevantElement == null)
                lastRelevantElement = project.Xml.PropertyGroupsReversed.First();

            string[] platformNames = GetPlatformsFromProject();
            foreach (var platformName in platformNames)
            {
                ProjectPropertyGroupElement element = project.Xml.CreatePropertyGroupElement();
                project.Xml.InsertAfterChild(element, lastRelevantElement);
                lastRelevantElement = element;

                element.Condition = GetConfigurationPlatformCondition(configurationName, platformName);

                /* TODO:
                 *  1. No need to create a property group if there are no properties to insert into in *and* this is a user build project.
                 *     If this is the main project, we still need to insert the group because the conditions are used to determine which
                 *     configurations/platforms are included in the project. For now, it's fine to always add the group.
                 *  2. Need a way to specify NewConfigProperties for each type of build project (main, user, etc).
                 */

                if (project == this._project.BuildProject)
                {
                    // Get the list of property name, condition value from the config provider
                    IEnumerable<KeyValuePair<KeyValuePair<string, string>, string>> propVals = this.NewConfigProperties;
                    foreach (KeyValuePair<KeyValuePair<string, string>, string> data in propVals)
                    {
                        KeyValuePair<string, string> propData = data.Key;
                        string value = data.Value;
                        ProjectPropertyElement newProperty = element.AddProperty(propData.Key, value);
                        if (!string.IsNullOrEmpty(propData.Value))
                            newProperty.Condition = propData.Value;
                    }

                    //add the output path
                    element.AddProperty("OutputPath", GetDefaultOutputPath(configurationName, platformName));
                }
            }

            return VSConstants.S_OK;
        }

        protected virtual int CloneConfiguration(MSBuild.Project project, string existingConfigurationName, string newConfigurationName)
        {
            if (project == null)
                throw new ArgumentNullException("project");
            if (existingConfigurationName == null)
                throw new ArgumentNullException("existingConfigurationName");
            if (newConfigurationName == null)
                throw new ArgumentNullException("newConfigurationName");
            if (string.IsNullOrEmpty(existingConfigurationName))
                throw new ArgumentException("existingConfigurationName cannot be null or empty");
            if (string.IsNullOrEmpty(newConfigurationName))
                throw new ArgumentException("newConfigurationName cannot be null or empty");

            string[] platformNames = GetPlatformsFromProject();

            string existingConfigurationCondition = GetConfigurationCondition(existingConfigurationName).Trim();
            string newConfigurationCondition = GetConfigurationCondition(newConfigurationName);

            string[] existingConfigurationPlatformConditions = new string[platformNames.Length];
            string[] newConfigurationPlatformConditions = new string[platformNames.Length];

            for (int i = 0; i < existingConfigurationPlatformConditions.Length; i++)
            {
                existingConfigurationPlatformConditions[i] = GetConfigurationPlatformCondition(existingConfigurationName, platformNames[i]).Trim();
                newConfigurationPlatformConditions[i] = GetConfigurationPlatformCondition(newConfigurationName, platformNames[i]);
            }

            foreach (var group in project.Xml.PropertyGroups.ToArray())
            {
                if (string.IsNullOrEmpty(group.Condition))
                    continue;

                if (string.Equals(group.Condition.Trim(), existingConfigurationCondition, StringComparison.OrdinalIgnoreCase))
                {
                    ProjectPropertyGroupElement clonedGroup = ClonePropertyGroup(project, group);
                    clonedGroup.Condition = newConfigurationCondition;
                }
                else
                {
                    int index = Array.FindIndex(existingConfigurationPlatformConditions, i => StringComparer.OrdinalIgnoreCase.Equals(i, group.Condition.Trim()));
                    if (index < 0)
                        continue;

                    ProjectPropertyGroupElement clonedGroup = ClonePropertyGroup(project, group);
                    clonedGroup.Condition = newConfigurationPlatformConditions[index];

                    // update the OutputPath property if it exists and isn't conditioned on $(Configuration)
                    foreach (var property in clonedGroup.Properties)
                    {
                        if (!string.Equals(property.Name, "OutputPath", StringComparison.OrdinalIgnoreCase))
                            continue;

                        if (!string.IsNullOrEmpty(property.Condition))
                            continue;

                        if (property.Value.IndexOf("$(Configuration)", StringComparison.OrdinalIgnoreCase) >= 0)
                            continue;

                        // update the output path
                        property.Value = GetDefaultOutputPath(newConfigurationName, platformNames[index]);
                    }
                }
            }

            return VSConstants.S_OK;
        }

        protected virtual int AddPlatform(MSBuild.Project project, string platformName)
        {
            if (project == null)
                throw new ArgumentNullException("project");
            if (platformName == null)
                throw new ArgumentNullException("platformName");
            if (string.IsNullOrEmpty(platformName))
                throw new ArgumentException("platformName cannot be null or empty");

            MSBuildConstruction.ProjectElement lastRelevantElement = null;
            foreach (ProjectPropertyGroupElement group in project.Xml.PropertyGroupsReversed)
            {
                if (string.IsNullOrEmpty(group.Condition))
                    continue;

                if (group.Condition.IndexOf("'$(Configuration)'", StringComparison.OrdinalIgnoreCase) >= 0
                    || group.Condition.IndexOf("'$(Platform)'", StringComparison.OrdinalIgnoreCase) >= 0
                    || group.Condition.IndexOf("'$(Configuration)|$(Platform)'", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    lastRelevantElement = group;
                    break;
                }
            }

            if (lastRelevantElement == null)
                lastRelevantElement = project.Xml.PropertyGroupsReversed.First();

            string[] configurationNames = GetPropertiesConditionedOn(ProjectFileConstants.Configuration);
            foreach (var configurationName in configurationNames)
            {
                ProjectPropertyGroupElement element = project.Xml.CreatePropertyGroupElement();
                project.Xml.InsertAfterChild(element, lastRelevantElement);
                lastRelevantElement = element;

                element.Condition = GetConfigurationPlatformCondition(configurationName, platformName);

                /* TODO:
                 *  1. No need to create a property group if there are no properties to insert into in *and* this is a user build project.
                 *     If this is the main project, we still need to insert the group because the conditions are used to determine which
                 *     configurations/platforms are included in the project. For now, it's fine to always add the group.
                 *  2. Need a way to specify NewConfigProperties for each type of build project (main, user, etc).
                 */

                if (project == this._project.BuildProject)
                {
                    // Get the list of property name, condition value from the config provider
                    IEnumerable<KeyValuePair<KeyValuePair<string, string>, string>> propVals = this.NewConfigProperties;
                    foreach (KeyValuePair<KeyValuePair<string, string>, string> data in propVals)
                    {
                        KeyValuePair<string, string> propData = data.Key;
                        string value = data.Value;
                        ProjectPropertyElement newProperty = element.AddProperty(propData.Key, value);
                        if (!string.IsNullOrEmpty(propData.Value))
                            newProperty.Condition = propData.Value;
                    }

                    //add the output path
                    element.AddProperty("OutputPath", GetDefaultOutputPath(configurationName, platformName));
                }
            }

            return VSConstants.S_OK;
        }

        protected virtual int ClonePlatform(MSBuild.Project project, string existingPlatformName, string newPlatformName)
        {
            if (project == null)
                throw new ArgumentNullException("project");
            if (existingPlatformName == null)
                throw new ArgumentNullException("existingPlatformName");
            if (newPlatformName == null)
                throw new ArgumentNullException("newPlatformName");
            if (string.IsNullOrEmpty(existingPlatformName))
                throw new ArgumentException("existingPlatformName cannot be null or empty");
            if (string.IsNullOrEmpty(newPlatformName))
                throw new ArgumentException("newPlatformName cannot be null or empty");

            string[] configurationNames = GetPropertiesConditionedOn(ProjectFileConstants.Configuration);

            string existingPlatformCondition = GetPlatformCondition(existingPlatformName).Trim();
            string newPlatformCondition = GetPlatformCondition(existingPlatformName);

            string[] existingConfigurationPlatformConditions = new string[configurationNames.Length];
            string[] newConfigurationPlatformConditions = new string[configurationNames.Length];

            for (int i = 0; i < existingConfigurationPlatformConditions.Length; i++)
            {
                existingConfigurationPlatformConditions[i] = GetConfigurationPlatformCondition(configurationNames[i], existingPlatformName).Trim();
                newConfigurationPlatformConditions[i] = GetConfigurationPlatformCondition(configurationNames[i], newPlatformName);
            }

            foreach (var group in project.Xml.PropertyGroups.ToArray())
            {
                if (string.IsNullOrEmpty(group.Condition))
                    continue;

                if (string.Equals(group.Condition.Trim(), existingPlatformCondition, StringComparison.OrdinalIgnoreCase))
                {
                    ProjectPropertyGroupElement clonedGroup = ClonePropertyGroup(project, group);
                    clonedGroup.Condition = newPlatformCondition;
                }
                else
                {
                    int index = Array.FindIndex(existingConfigurationPlatformConditions, i => StringComparer.OrdinalIgnoreCase.Equals(i, group.Condition.Trim()));
                    if (index < 0)
                        continue;

                    ProjectPropertyGroupElement clonedGroup = ClonePropertyGroup(project, group);
                    clonedGroup.Condition = newConfigurationPlatformConditions[index];

                    // update the OutputPath property if it exists and isn't conditioned on $(Platform)
                    foreach (var property in clonedGroup.Properties)
                    {
                        if (!string.Equals(property.Name, "OutputPath", StringComparison.OrdinalIgnoreCase))
                            continue;

                        if (!string.IsNullOrEmpty(property.Condition))
                            continue;

                        if (property.Value.IndexOf("$(Platform)", StringComparison.OrdinalIgnoreCase) >= 0)
                            continue;

                        // update the output path
                        property.Value = GetDefaultOutputPath(configurationNames[index], newPlatformName);
                    }
                }
            }

            return VSConstants.S_OK;
        }

        protected virtual string GetDefaultOutputPath(string configurationName, string platformName)
        {
            if (configurationName == null)
                throw new ArgumentNullException("configurationName");
            if (platformName == null)
                throw new ArgumentNullException("platformName");
            if (string.IsNullOrEmpty(configurationName))
                throw new ArgumentException("configurationName cannot be null or empty");
            if (string.IsNullOrEmpty(platformName))
                throw new ArgumentException("platformName cannot be null or empty");
            //Contract.Ensures(!string.IsNullOrEmpty(Contract.Result<string>()));

            string outputBasePath = ProjectManager.OutputBaseRelativePath;
            if (outputBasePath[outputBasePath.Length - 1] == Path.DirectorySeparatorChar || outputBasePath[outputBasePath.Length - 1] == Path.AltDirectorySeparatorChar)
                outputBasePath = Path.GetDirectoryName(outputBasePath);

            string platformProperty = GetPlatformPropertyFromPlatformName(platformName);
            if (!string.Equals(platformProperty, ProjectFileValues.AnyCPU, StringComparison.OrdinalIgnoreCase))
                outputBasePath = Path.Combine(outputBasePath, platformProperty);

            return Path.Combine(outputBasePath, configurationName) + Path.DirectorySeparatorChar;
        }

        /// <summary>
        /// For internal use only.
        /// This creates a copy of an existing configuration and add it to the project.
        /// Caller should change the condition on the PropertyGroup.
        /// If derived class want to accomplish this, they should call ConfigProvider.AddCfgsOfCfgName()
        /// It is expected that in the future MSBuild will have support for this so we don't have to
        /// do it manually.
        /// </summary>
        /// <param name="group">PropertyGroup to clone</param>
        /// <returns></returns>
        protected virtual ProjectPropertyGroupElement ClonePropertyGroup(MSBuild.Project project, ProjectPropertyGroupElement group)
        {
            if (project == null)
                throw new ArgumentNullException("project");
            if (group == null)
                throw new ArgumentNullException("group");

            // Create a new (empty) PropertyGroup
            ProjectPropertyGroupElement newPropertyGroup = project.Xml.CreatePropertyGroupElement();
            project.Xml.InsertAfterChild(newPropertyGroup, group);

            // Now copy everything from the group we are trying to clone to the group we are creating
            if (!String.IsNullOrEmpty(group.Condition))
                newPropertyGroup.Condition = group.Condition;

            foreach (ProjectPropertyElement prop in group.Properties)
            {
                ProjectPropertyElement newProperty = newPropertyGroup.AddProperty(prop.Name, prop.Value);
                if (!String.IsNullOrEmpty(prop.Condition))
                    newProperty.Condition = prop.Condition;
            }

            return newPropertyGroup;
        }

        #region IVsExtensibleObject Members

        /// <summary>
        /// Proved access to an IDispatchable object being a list of configuration properties
        /// </summary>
        /// <param name="configurationName">Combined Name and Platform for the configuration requested</param>
        /// <param name="configurationProperties">The IDispatchcable object</param>
        /// <returns>S_OK if successful</returns>
        public virtual int GetAutomationObject(string configurationName, out object configurationProperties)
        {
            //Init out param
            configurationProperties = null;

            string name, platform;
            if(!ProjectConfig.TrySplitConfigurationCanonicalName(configurationName, out name, out platform))
            {
                return VSConstants.E_INVALIDARG;
            }

            // Get the configuration
            IVsCfg cfg;
            ErrorHandler.ThrowOnFailure(this.GetCfgOfName(name, platform, out cfg));

            // Get the properties of the configuration
            configurationProperties = ((ProjectConfig)cfg).ConfigurationProperties;

            return VSConstants.S_OK;

        }
        #endregion

        #region helper methods
        /// <summary>
        /// Called when a new configuration name was added.
        /// </summary>
        /// <param name="name">The name of configuration just added.</param>
        protected virtual void NotifyOnCfgNameAdded(string name)
        {
            foreach(IVsCfgProviderEvents sink in this.cfgEventSinks)
            {
                ErrorHandler.ThrowOnFailure(sink.OnCfgNameAdded(name));
            }
        }

        /// <summary>
        /// Called when a config name was deleted.
        /// </summary>
        /// <param name="name">The name of the configuration.</param>
        protected virtual void NotifyOnCfgNameDeleted(string name)
        {
            foreach(IVsCfgProviderEvents sink in this.cfgEventSinks)
            {
                ErrorHandler.ThrowOnFailure(sink.OnCfgNameDeleted(name));
            }
        }

        /// <summary>
        /// Called when a config name was renamed
        /// </summary>
        /// <param name="oldName">Old configuration name</param>
        /// <param name="newName">New configuration name</param>
        protected virtual void NotifyOnCfgNameRenamed(string oldName, string newName)
        {
            foreach(IVsCfgProviderEvents sink in this.cfgEventSinks)
            {
                ErrorHandler.ThrowOnFailure(sink.OnCfgNameRenamed(oldName, newName));
            }
        }

        /// <summary>
        /// Called when a platform name was added
        /// </summary>
        /// <param name="platformName">The name of the platform.</param>
        protected virtual void NotifyOnPlatformNameAdded(string platformName)
        {
            foreach(IVsCfgProviderEvents sink in this.cfgEventSinks)
            {
                ErrorHandler.ThrowOnFailure(sink.OnPlatformNameAdded(platformName));
            }
        }

        /// <summary>
        /// Called when a platform name was deleted
        /// </summary>
        /// <param name="platformName">The name of the platform.</param>
        protected virtual void NotifyOnPlatformNameDeleted(string platformName)
        {
            foreach(IVsCfgProviderEvents sink in this.cfgEventSinks)
            {
                ErrorHandler.ThrowOnFailure(sink.OnPlatformNameDeleted(platformName));
            }
        }

        /// <summary>
        /// Gets all the platforms defined in the project
        /// </summary>
        /// <returns>An array of platform names.</returns>
        protected virtual string[] GetPlatformsFromProject()
        {
            string[] platforms = GetPropertiesConditionedOn(ProjectFileConstants.Platform);

            if (platforms == null || platforms.Length == 0)
            {
                return GetDefaultPlatforms();
            }

            for (int i = 0; i < platforms.Length; i++)
            {
                platforms[i] = GetPlatformNameFromPlatformProperty(platforms[i]);
            }

            return platforms;
        }

        protected virtual string[] GetDefaultPlatforms()
        {
            return new string[] { AnyCpuPlatform };
        }

        /// <summary>
        /// Return the supported platform names.
        /// </summary>
        /// <returns>An array of supported platform names.</returns>
        protected virtual string[] GetSupportedPlatformsFromProject()
        {
            string platformsString = this.ProjectManager.BuildProject.GetPropertyValue(ProjectFileConstants.AvailablePlatforms);

            if (platformsString == null)
            {
                return new string[0];
            }

            string[] platforms = platformsString.Split(',', ';');
            for (int i = 0; i < platforms.Length; i++)
            {
                platforms[i] = GetPlatformNameFromPlatformProperty(platforms[i]);
            }

            return platforms;
        }

        /// <summary>
        /// Helper function to convert AnyCPU to Any CPU.
        /// </summary>
        public virtual string GetPlatformNameFromPlatformProperty(string platformProperty)
        {
            if(String.Equals(platformProperty, ProjectFileValues.AnyCPU, StringComparison.OrdinalIgnoreCase))
            {
                return AnyCpuPlatform;
            }

            return platformProperty;
        }

        /// <summary>
        /// Helper function to convert Any CPU to AnyCPU.
        /// </summary>
        public virtual string GetPlatformPropertyFromPlatformName(string platformName)
        {
            if (String.Equals(platformName, AnyCpuPlatform, StringComparison.OrdinalIgnoreCase))
            {
                return ProjectFileValues.AnyCPU;
            }

            return platformName;
        }

        /// <summary>
        /// Common method for handling platform names.
        /// </summary>
        /// <param name="celt">Specifies the requested number of platform names. If this number is unknown, celt can be zero.</param>
        /// <param name="names">On input, an allocated array to hold the number of platform names specified by celt. This parameter can also be null if the celt parameter is zero. On output, names contains platform names</param>
        /// <param name="actual">A count of the actual number of platform names returned.</param>
        /// <param name="platforms">An array of available platform names</param>
        /// <returns>A count of the actual number of platform names returned.</returns>
        /// <devremark>The platforms array is never null. It is assured by the callers.</devremark>
        protected static int GetPlatforms(uint celt, string[] names, uint[] actual, string[] platforms)
        {
            Debug.Assert(platforms != null, "The plaforms array should never be null");
            if(names == null)
            {
                if(actual == null || actual.Length == 0)
                {
                    throw new ArgumentException(SR.GetString(SR.InvalidParameter, CultureInfo.CurrentUICulture), "actual");
                }

                actual[0] = (uint)platforms.Length;
                return VSConstants.S_OK;
            }

            //Degenarate case
            if(celt == 0)
            {
                if(actual != null && actual.Length != 0)
                {
                    actual[0] = (uint)platforms.Length;
                }

                return VSConstants.S_OK;
            }

            uint returned = 0;
            for(int i = 0; i < platforms.Length && names.Length > returned; i++)
            {
                names[returned] = platforms[i];
                returned++;
            }

            if(actual != null && actual.Length != 0)
            {
                actual[0] = returned;
            }

            if(celt > returned)
            {
                return VSConstants.S_FALSE;
            }

            return VSConstants.S_OK;
        }
        #endregion

        /// <summary>
        /// Get all the configurations in the project.
        /// </summary>
        protected virtual string[] GetPropertiesConditionedOn(string constant)
        {
            List<string> configurations = null;
            this._project.BuildProject.ReevaluateIfNecessary();
            this._project.BuildProject.ConditionedProperties.TryGetValue(constant, out configurations);

            return (configurations == null) ? new string[] { } : configurations.ToArray();
        }

    }
}
