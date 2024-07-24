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
    using System.CodeDom.Compiler;
    using System.Collections.Generic;
    using System.Collections.ObjectModel;
    using System.Collections.Specialized;
    using System.Diagnostics;
    using System.Diagnostics.CodeAnalysis;
    using System.Globalization;
    using System.IO;
    using System.Linq;
    using System.Runtime.InteropServices;
    using System.Runtime.Versioning;
    using System.Text;
    using System.Xml;
    using EnvDTE;
    using Microsoft.Build.Evaluation;
    using Microsoft.Build.Execution;
    using Microsoft.VisualStudio.OLE.Interop;
    using Microsoft.VisualStudio.Shell;
    using Microsoft.VisualStudio.Shell.Interop;
    using DialogResult = Microsoft.Internal.VisualStudio.PlatformUI.DialogResult;
    using IOleServiceProvider = Microsoft.VisualStudio.OLE.Interop.IServiceProvider;
    using IServiceProvider = System.IServiceProvider;
    using MSBuild = Microsoft.Build.Evaluation;
    using MSBuildConstruction = Microsoft.Build.Construction;
    using MSBuildExecution = Microsoft.Build.Execution;
    using OleConstants = Microsoft.VisualStudio.OLE.Interop.Constants;
    using prjBuildAction = VSLangProj.prjBuildAction;
    using VsCommands = Microsoft.VisualStudio.VSConstants.VSStd97CmdID;
    using VsCommands2K = Microsoft.VisualStudio.VSConstants.VSStd2KCmdID;

    /// <summary>
    /// Manages the persistent state of the project (References, options, files, etc.) and deals with user interaction via a GUI in the form a hierarchy.
    /// </summary>
    [CLSCompliant(false)]
    [ComVisible(true)]
    public abstract partial class ProjectNode : HierarchyNode,
        IVsGetCfgProvider,
        IVsProject3,
        IVsAggregatableProject,
        IVsProjectFlavorCfgProvider,
        IPersistFileFormat,
        IVsProjectBuildSystem,
        IVsBuildPropertyStorage,
        IVsComponentUser,
        IVsDependencyProvider,
        IVsSccProject2,
        IBuildDependencyUpdate,
        IProjectEventsListener,
        IProjectEventsProvider,
        IReferenceContainerProvider,
        IVsProjectSpecialFiles,
		IVsProjectUpgrade,
		IVsDesignTimeAssemblyResolution,
		IVsSetTargetFrameworkWorkerCallback
    {
        #region constants
        /// <summary>
        /// The user file extension.
        /// </summary>
        private const string _perUserFileExtension = ".user";

		#endregion

        #region fields

        private static readonly FrameworkName DefaultTargetFrameworkMoniker = new FrameworkName(".NETFramework", new Version(4, 0));

		protected static Guid AddComponentLastActiveTab = VSConstants.GUID_SolutionPage;

		protected static uint AddComponentDialogSizeX = 0;

		protected static uint AddComponentDialogSizeY = 0;

		/// <summary>
        /// List of output groups names and their associated target
        /// </summary>
        private static readonly KeyValuePair<string, string>[] outputGroupNames =
        {                                      // Name                    Target (MSBuild)
            new KeyValuePair<string, string>("Built",                 "BuiltProjectOutputGroup"),
            new KeyValuePair<string, string>("ContentFiles",          "ContentFilesProjectOutputGroup"),
            new KeyValuePair<string, string>("LocalizedResourceDlls", "SatelliteDllsProjectOutputGroup"),
            new KeyValuePair<string, string>("Documentation",         "DocumentationProjectOutputGroup"),
            new KeyValuePair<string, string>("Symbols",               "DebugSymbolsProjectOutputGroup"),
            new KeyValuePair<string, string>("SourceFiles",           "SourceFilesProjectOutputGroup"),
            new KeyValuePair<string, string>("XmlSerializer",         "SGenFilesOutputGroup"),
        };

        /// <summary>A project will only try to build if it can obtain a lock on this object</summary>
        private static readonly object BuildLock = new object();

        /// <summary>Maps integer ids to project item instances</summary>
        private HierarchyNodeCollection itemIdMap;

        /// <summary>A service provider call back object provided by the IDE hosting the project manager</summary>
        private ServiceProvider _site;

        public static ServiceProvider ServiceProvider { get; set; }

        private readonly TrackDocumentsHelper tracker;

        /// <summary>
        /// A cached copy of project options.
        /// </summary>
        private ProjectOptions _options;

        private bool showAllFilesEnabled;

        /// <summary>
        /// This property returns the time of the last change made to this project.
        /// It is not the time of the last change on the project file, but actually of
        /// the in memory project settings.  In other words, it is the last time that 
        /// SetProjectDirty was called.
        /// </summary>
        private DateTime lastModifiedTime;

        /// <summary>
        /// MSBuild engine we are going to use 
        /// </summary>
        private MSBuild.ProjectCollection buildEngine;

        private Microsoft.Build.Utilities.Logger buildLogger;

        private bool useProvidedLogger;

        private MSBuild.Project buildProject;

        private MSBuild.Project _userBuildProject;

        private MSBuildExecution.ProjectInstance currentConfig;

        private DesignTimeAssemblyResolution designTimeAssemblyResolution;

        private bool designTimeAssemblyResolutionFailed;

        private ConfigProvider configProvider;

        private TaskProvider taskProvider;

        private string _filename;

        private Microsoft.VisualStudio.Shell.Url baseUri;

        private bool _isDirty;

        private bool isNewProject;

        private bool projectOpened;

        private bool buildIsPrepared;

        private ImageHandler imageHandler;

        private string errorString;

        private string warningString;

        private Guid projectIdGuid;

        private bool isClosed;

        private SuppressEvents eventTriggeringFlag = SuppressEvents.None;

        private bool invokeMSBuildWhenResumed;

        private uint suspendMSBuildCounter;

        private bool canFileNodesHaveChilds;

        private bool isProjectEventsListener = true;

        /// <summary>
        /// The build dependency list passed to IVsDependencyProvider::EnumDependencies 
        /// </summary>
        private List<IVsBuildDependency> buildDependencyList = new List<IVsBuildDependency>();

        /// <summary>
        /// Defines if Project System supports Project Designer
        /// </summary>
        private bool supportsProjectDesigner;

        private bool showProjectInSolutionPage = true;

        private bool buildInProcess;

        /// <summary>
        /// Field for determining whether sourcecontrol should be disabled.
        /// </summary>
        private bool disableScc;

        private string _sccProjectName;

        private string _sccLocalPath;

        private string _sccAuxPath;

        private string _sccProvider;

        /// <summary>
        /// Flag for controling how many times we register with the Scc manager.
        /// </summary>
        private bool isRegisteredWithScc;

        /// <summary>
        /// Flag for controling query edit should communicate with the scc manager.
        /// </summary>
        private bool disableQueryEdit;

        /// <summary>
        /// Control if command with potential destructive behavior such as delete should
        /// be enabled for nodes of this project.
        /// </summary>
        private bool canProjectDeleteItems;

        /// <summary>
        /// Token processor used by the project sample.
        /// </summary>
        private TokenProcessor tokenProcessor;

        /// <summary>
        /// Member to store output base relative path. Used by OutputBaseRelativePath property
        /// </summary>
        private string outputBaseRelativePath = "bin";

        private IProjectEvents projectEventsProvider;

        /// <summary>
        /// Used for flavoring to hold the XML fragments
        /// </summary>
        private XmlDocument xmlFragments;

        /// <summary>
        /// Used to map types to CATID. This provide a generic way for us to do this
        /// and make it simpler for a project to provide it's CATIDs for the different type of objects
        /// for which it wants to support extensibility. This also enables us to have multiple
        /// type mapping to the same CATID if we choose to.
        /// </summary>
        private Dictionary<Type, Guid> catidMapping = new Dictionary<Type, Guid>();

        /// <summary>
        /// The internal package implementation.
        /// </summary>
        private readonly ProjectPackage package;

        // Has the object been disposed.
        private bool isDisposed;

        private readonly List<KeyValuePair<string, prjBuildAction>> _availableFileBuildActions = new List<KeyValuePair<string, prjBuildAction>>();
        #endregion

        #region abstract properties
        /// <summary>
        /// This Guid must match the Guid you registered under
        /// HKLM\Software\Microsoft\VisualStudio\%version%\Projects.
        /// Among other things, the Project framework uses this 
        /// guid to find your project and item templates.
        /// </summary>
        public abstract Guid ProjectGuid
        {
            get;
        }

        /// <summary>
        /// Returns a caption for VSHPROPID_TypeName.
        /// </summary>
        /// <returns></returns>
        public abstract string ProjectType
        {
            get;
        }
        #endregion

        #region virtual properties
        /// <summary>
        /// This is the project instance guid that is peristed in the project file
        /// </summary>
        [System.ComponentModel.BrowsableAttribute(false)]
        public virtual Guid ProjectIdGuid
        {
            get
            {
                return this.projectIdGuid;
            }
            set
            {
                if (this.projectIdGuid != value)
                {
                    this.projectIdGuid = value;
                    if (this.buildProject != null)
                    {
                        this.SetProjectProperty("ProjectGuid", _PersistStorageType.PST_PROJECT_FILE, this.projectIdGuid.ToString("B"));
                    }
                }
            }
        }
        #endregion

        #region properties

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1006:DoNotNestGenericTypesInMemberSignatures")]
        public ReadOnlyCollection<KeyValuePair<string, prjBuildAction>> AvailableFileBuildActions
        {
            get
            {
                return _availableFileBuildActions.AsReadOnly();
            }
        }

        #region overridden properties
        public override int MenuCommandId
        {
            get
            {
                return VsMenus.IDM_VS_CTXT_PROJNODE;
            }
        }

        public override string Url
        {
            get
            {
                return this.GetMKDocument();
            }
        }

        public override bool CanCacheCanonicalName
        {
            get
            {
                return true;
            }
        }

        public override string Caption
        {
            get
            {
                // Default to file name
                string caption = this.buildProject.FullPath;
                if (String.IsNullOrEmpty(caption))
                {
                    if (this.buildProject.GetProperty(ProjectFileConstants.Name) != null)
                    {
                        caption = this.buildProject.GetProperty(ProjectFileConstants.Name).EvaluatedValue;
                        if (caption == null || caption.Length == 0)
                        {
                            caption = this.ItemNode.GetMetadata(ProjectFileConstants.Include);
                        }
                    }
                }
                else
                {
                    caption = Path.GetFileNameWithoutExtension(caption);
                }

                return caption;
            }
        }

        public override Guid ItemTypeGuid
        {
            get
            {
                return this.ProjectGuid;
            }
        }

        public override int ImageIndex
        {
            get
            {
                return (int)ImageName.Application;
            }
        }

        #endregion

        #region virtual properties

        public virtual string ErrorString
        {
            get
            {
                if (this.errorString == null)
                {
                    this.errorString = SR.GetString(SR.Error, CultureInfo.CurrentUICulture);
                }

                return this.errorString;
            }
        }

        public virtual string WarningString
        {
            get
            {
                if (this.warningString == null)
                {
                    this.warningString = SR.GetString(SR.Warning, CultureInfo.CurrentUICulture);
                }

                return this.warningString;
            }
        }

        /// <summary>
        /// The target name that will be used for evaluating the project file (i.e., pseudo-builds).
        /// This target is used to trigger a build with when the project system changes. 
        /// Example: The language projrcts are triggering a build with the Compile target whenever 
        /// the project system changes.
        /// </summary>
        public virtual string ReevaluateProjectFileTargetName
        {
            get
            {
                return null;
            }
        }

        /// <summary>
        /// This is the object that will be returned by EnvDTE.Project.Object for this project
        /// </summary>
        public virtual object ProjectObject
        {
            get
            {
                return null;
            }
        }

        /// <summary>
        /// Override this property to specify when the project file is dirty.
        /// </summary>
        protected virtual bool IsProjectFileDirty
        {
            get
            {
                string document = this.GetMKDocument();

                if (String.IsNullOrEmpty(document))
                {
                    return this._isDirty;
                }

                return (this._isDirty || !File.Exists(document));
            }
        }

        /// <summary>
        /// True if the project uses the Project Designer Editor instead of the property page frame to edit project properties.
        /// </summary>
        protected virtual bool SupportsProjectDesigner
        {
            get
            {
                return this.supportsProjectDesigner;
            }

            set
            {
                this.supportsProjectDesigner = value;
            }

        }

        protected virtual Guid ProjectDesignerEditor
        {
            get
            {
                return VSConstants.GUID_ProjectDesignerEditor;
            }
        }

        /// <summary>
        /// Defines the flag that supports the VSHPROPID.ShowProjInSolutionPage
        /// </summary>
        protected virtual bool ShowProjectInSolutionPage
        {
            get
            {
                return this.showProjectInSolutionPage;
            }

            set
            {
                this.showProjectInSolutionPage = value;
            }
        }

        #endregion

        /// <summary>
        /// Gets or sets the ability of a project filenode to have child nodes (sub items).
        /// Example would be C#/VB forms having resx and designer files.
        /// </summary>
        public bool CanFileNodesHaveChilds
        {
            get
            {
                return canFileNodesHaveChilds;
            }

            set
            {
                canFileNodesHaveChilds = value;
            }
        }

        /// <summary>
        /// Get and set the Token processor.
        /// </summary>
        public TokenProcessor FileTemplateProcessor
        {
            get
            {
                if (tokenProcessor == null)
                    tokenProcessor = new TokenProcessor();
                return tokenProcessor;
            }

            set
            {
                tokenProcessor = value;
            }
        }

        /// <summary>
        /// Gets a service provider object provided by the IDE hosting the project
        /// </summary>
        [SuppressMessage("Microsoft.Naming", "CA1721:PropertyNamesShouldNotMatchGetMethods")]
        public IServiceProvider Site
        {
            get
            {
                return this._site;
            }
        }

        /// <summary>
        /// Gets an ImageHandler for the project node.
        /// </summary>
        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        public ImageHandler ImageHandler
        {
            get
            {
                if (null == imageHandler)
                {
                    imageHandler = new ImageHandler(typeof(ProjectNode).Assembly.GetManifestResourceStream("Microsoft.VisualStudio.Project.Resources.imagelis.bmp"));
                }
                return imageHandler;
            }
        }

        /// <summary>
        /// This property returns the time of the last change made to this project.
        /// It is not the time of the last change on the project file, but actually of
        /// the in memory project settings.  In other words, it is the last time that 
        /// SetProjectDirty was called.
        /// </summary>
        public DateTime LastModifiedTime
        {
            get
            {
                return this.lastModifiedTime;
            }
        }

        /// <summary>
        /// Determines whether this project is a new project.
        /// </summary>
        public bool IsNewProject
        {
            get
            {
                return this.isNewProject;
            }
        }

        /// <summary>
        /// Gets the path to the folder containing the project.
        /// </summary>
        public string ProjectFolder
        {
            get
            {
                return Path.GetDirectoryName(this.FileName);
            }
        }

        /// <summary>
        /// Gets or sets the project filename.
        /// </summary>
        public string ProjectFile
        {
            get
            {
                return Path.GetFileName(this.FileName);
            }

            set
            {
                this.SetEditLabel(value);
            }
        }

        /// <summary>
        /// Gets the Base Uniform Resource Identifier (URI).
        /// </summary>
        public Microsoft.VisualStudio.Shell.Url BaseUri
        {
            get
            {
                if (baseUri == null && this.buildProject != null)
                {
                    string path = System.IO.Path.GetDirectoryName(this.buildProject.FullPath);
                    // Uri/Url behave differently when you have trailing slash and when you dont
                    if (!path.EndsWith("\\", StringComparison.Ordinal) && !path.EndsWith("/", StringComparison.Ordinal))
                        path += "\\";
                    baseUri = new Url(path);
                }

                Debug.Assert(baseUri != null, "Base URL should not be null. Did you call BaseURI before loading the project?");
                return baseUri;
            }
        }

        /// <summary>
        /// Gets whether or not the project is closed.
        /// </summary>
        public bool IsClosed
        {
            get
            {
                return this.isClosed;
            }
        }

        /// <summary>
        /// Gets whether or not the project is being built.
        /// </summary>
        public bool BuildInProgress
        {
            get
            {
                return buildInProcess;
            }
        }

        /// <summary>
        /// Gets or set the relative path to the folder containing the project ouput. 
        /// </summary>
        public virtual string OutputBaseRelativePath
        {
            get
            {
                return this.outputBaseRelativePath;
            }

            set
            {
                if (value == null)
                    throw new ArgumentNullException("value");
                if (string.IsNullOrEmpty("value"))
                    throw new ArgumentException("value cannot be null or empty");
                if (Path.IsPathRooted(value))
                    throw new ArgumentException("Path must not be rooted.");

                this.outputBaseRelativePath = value;
            }
        }

        public FrameworkName TargetFrameworkMoniker
        {
            get
            {
				if (this._options == null)
				{
					GetProjectOptions();
				}
                if (this._options != null)
                {
                    return this._options.TargetFrameworkMoniker ?? DefaultTargetFrameworkMoniker;
                }
                else
                {
                    return DefaultTargetFrameworkMoniker;
                }
            }

            set
            {
				if (this._options == null)
				{
					GetProjectOptions();
				}

				if (value == null)
                {
					value = DefaultTargetFrameworkMoniker;
                }

                if (this._options.TargetFrameworkMoniker != value)
                {
                    this.OnTargetFrameworkMonikerChanged(this._options, this._options.TargetFrameworkMoniker, value);
                }
            }
        }

        /// <summary>
        /// Version of this node as an IVsHierarchy that can be safely passed to native code from a background thread. 
        /// </summary>
        public IVsHierarchy InteropSafeIVsHierarchy
        {
            get;
            protected set;
        }

        /// <summary>
        /// Version of this node as an IVsUIHierarchy that can be safely passed to native code from a background thread. 
        /// </summary>
        public IVsUIHierarchy InteropSafeIVsUIHierarchy
        {
            get;
            protected set;
        }

        /// <summary>
        /// Version of this node as an IVsProject3 that can be safely passed to native code from a background thread. 
        /// </summary>
        public IVsProject3 InteropSafeIVsProject3
        {
            get;
            protected set;
        }

        /// <summary>
        /// Version of this node as an IVsSccProject2 that can be safely passed to native code from a background thread. 
        /// </summary>
        public IVsSccProject2 InteropSafeIVsSccProject2
        {
            get;
            protected set;
        }

        /// <summary>
        /// Version of this node as an IVsUIHierWinClipboardHelperEvents that can be safely passed to native code from a background thread. 
        /// </summary>
        public IVsUIHierWinClipboardHelperEvents InteropSafeIVsUIHierWinClipboardHelperEvents
        {
            get;
            protected set;
        }

        public IVsComponentUser InteropSafeIVsComponentUser
        {
            get;
            protected set;
        }

        /// <summary>
        /// Gets or sets the flag whether query edit should communicate with the scc manager.
        /// </summary>
        protected bool DisableQueryEdit
        {
            get
            {
                return this.disableQueryEdit;
            }

            set
            {
                this.disableQueryEdit = value;
            }
        }

        /// <summary>
        /// Gets a collection of integer ids that maps to project item instances
        /// </summary>
        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        public HierarchyNodeCollection ItemIdMap
        {
            get
            {
                if (this.itemIdMap == null)
                    this.itemIdMap = CreateHierarchyNodeCollection();

                return this.itemIdMap;
            }
        }

        /// <summary>
        /// Get the helper object that track document changes.
        /// </summary>
        public TrackDocumentsHelper Tracker
        {
            get
            {
                return this.tracker;
            }
        }

        /// <summary>
        /// Gets or sets the build logger.
        /// </summary>
        protected Microsoft.Build.Utilities.Logger BuildLogger
        {
            get
            {
                return this.buildLogger;
            }

            set
            {
                this.buildLogger = value;
                this.useProvidedLogger = true;
            }
        }

        /// <summary>
        /// Gets the taskprovider.
        /// </summary>
        protected TaskProvider TaskProvider
        {
            get
            {
                return this.taskProvider;
            }
        }

        /// <summary>
        /// Gets the project file name.
        /// </summary>
        protected string FileName
        {
            get
            {
                return this._filename;
            }

            set
            {
                if (this._filename == value)
                    return;

                this._filename = value;
                ItemIdMap.UpdateCanonicalName(this);
            }
        }

        protected virtual string UserFileName
        {
            get
            {
                return FileName + PerUserFileExtension;
            }
        }

        protected virtual string PerUserFileExtension
        {
            get
            {
                return _perUserFileExtension;
            }
        }

		protected bool IsIdeInCommandLineMode
		{
			get
			{
				bool cmdline = false;
				var shell = this._site.GetService(typeof(SVsShell)) as IVsShell;
				if (shell != null)
				{
					object obj;
					Marshal.ThrowExceptionForHR(shell.GetProperty((int)__VSSPROPID.VSSPROPID_IsInCommandLineMode, out obj));
					cmdline = (bool)obj;
				}
				return cmdline;
			}
		}

        /// <summary>
        /// Gets the configuration provider.
        /// </summary>
        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        public ConfigProvider ConfigProvider
        {
            get
            {
                if (this.configProvider == null)
                {
                    this.configProvider = CreateConfigProvider();
                }

                return this.configProvider;
            }
        }

        /// <summary>
        /// Gets or sets whether or not source code control is disabled for this project.
        /// </summary>
        [SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "Scc")]
        protected bool IsSccDisabled
        {
            get
            {
                return this.disableScc;
            }

            set
            {
                this.disableScc = value;
            }
        }

        /// <summary>
        /// Gets or set whether items can be deleted for this project.
        /// Enabling this feature can have the potential destructive behavior such as deleting files from disk.
        /// </summary>
        public virtual bool CanProjectDeleteItems
        {
            get
            {
                return canProjectDeleteItems;
            }

            set
            {
                canProjectDeleteItems = value;
            }
        }

        /// <summary>
        /// Determines whether the project was fully opened. This is set when the OnAfterOpenProject has triggered.
        /// </summary>
        public bool HasProjectOpened
        {
            get
            {
                return this.projectOpened;
            }
        }

        /// <summary>
        /// Gets or sets event triggering flags.
        /// </summary>
        public SuppressEvents EventTriggeringFlag
        {
            get
            {
                return this.eventTriggeringFlag;
            }
            set
            {
                this.eventTriggeringFlag = value;
            }
        }

        /// <summary>
        /// Defines the build project that has loaded the project file.
        /// </summary>
        public MSBuild.Project BuildProject
        {
            get
            {
                return this.buildProject;
            }

            set
            {
                SetBuildProject(value);
            }
        }

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        public MSBuild.Project UserBuildProject
        {
            get
            {
                if (_userBuildProject == null && File.Exists(UserFileName))
                    _userBuildProject = CreateUserBuildProject();

                return _userBuildProject;
            }
        }

        /// <summary>
        /// Gets the current config.
        /// </summary>
        /// <value>The current config.</value>
        public Microsoft.Build.Execution.ProjectInstance CurrentConfig
        {
            get { return this.currentConfig; }
        }

        /// <summary>
        /// Defines the build engine that is used to build the project file.
        /// </summary>
        public MSBuild.ProjectCollection BuildEngine
        {
            get
            {
                return this.buildEngine;
            }
            set
            {
                this.buildEngine = value;
            }
        }

        /// <summary>
        /// The internal package implementation.
        /// </summary>
        public ProjectPackage Package
        {
            get
            {
                return this.package;
            }
        }

        /// <summary>
        /// Gets if the ShowAllFiles is enabled or not.
        /// </summary>
        /// <value>true if the ShowAllFiles option is enabled, false otherwise.</value>
        public bool ShowAllFilesEnabled
        {
            get
            {
                return this.showAllFilesEnabled;
            }
        }
        #endregion

        #region ctor

        protected ProjectNode(ProjectPackage package)
            : base(VSConstants.VSITEMID.Root)
        {
            if (package == null)
                throw new ArgumentNullException("package");

            this.package = package;
            this.tracker = new TrackDocumentsHelper(this);
        }

        #endregion

        #region static methods

        /// <summary>
        /// Adds the <see cref="Path.DirectorySeparatorChar"/> character to the end of the path if it doesn't already exist at the end.
        /// </summary>
        /// <param name="path">The string to add the trailing directory separator character to.</param>
        /// <returns>The original string with the specified character at the end.</returns>
        [SuppressMessage("Microsoft.Interoperability", "CA1407:AvoidStaticMembersInComVisibleTypes")]
        public static string EnsureTrailingDirectoryChar(string path)
        {
            return EnsureTrailingChar(path, Path.DirectorySeparatorChar);
        }

        /// <summary>
        /// Adds the specified character to the end of the string if it doesn't already exist at the end.
        /// </summary>
        /// <param name="value">The string to add the trailing character to.</param>
        /// <param name="charToEnsure">The character that will be at the end of the string upon return.</param>
        /// <returns>The original string with the specified character at the end.</returns>
        [SuppressMessage("Microsoft.Interoperability", "CA1407:AvoidStaticMembersInComVisibleTypes")]
        public static string EnsureTrailingChar(string value, char charToEnsure)
        {
            if (value == null)
                throw new ArgumentNullException("value");

            VerifyStringArgument(value, "value");

            if (value[value.Length - 1] != charToEnsure)
            {
                value += charToEnsure;
            }

            return value;
        }

        /// <summary>
        /// Adds non member items to the hierarchy.
        /// </summary>
        public virtual void AddNonmemberItems()
        {
            IList<string> files = new List<string>();
            IList<string> folders = new List<string>();

            // obtain the list of files and folders under the project folder.
            GetRelativeFileSystemEntries(this.ProjectFolder, null, files, folders);

            // exclude the items which are the part of the build.
            this.ExcludeProjectBuildItems(files, folders);

            var oldEventTriggeringFlag = EventTriggeringFlag;
            EventTriggeringFlag = SuppressEvents.Hierarchy;
            try
            {
                this.AddNonmemberFolderItems(folders);
                this.AddNonmemberFileItems(files);
            }
            finally
            {
                EventTriggeringFlag = oldEventTriggeringFlag;
            }

            // walk the expanded folders of the hierarchy looking for visible non-member items
            List<HierarchyNode> visibleNonMemberItems = GetVisibleNonMemberItems();
            foreach (var node in visibleNonMemberItems)
                OnItemAdded(node.Parent, node);
        }

        protected virtual List<HierarchyNode> GetVisibleNonMemberItems()
        {
            List<HierarchyNode> result = new List<HierarchyNode>();
            Queue<HierarchyNode> workList = new Queue<HierarchyNode>();
            workList.Enqueue(this);

            while (workList.Count > 0)
            {
                HierarchyNode node = workList.Dequeue();
                for (HierarchyNode child = node.FirstChild; child != null; child = child.NextSibling)
                {
                    if (child.IsExpanded)
                        workList.Enqueue(child);

                    object nonMemberItem = child.GetProperty((int)__VSHPROPID.VSHPROPID_IsNonMemberItem);
                    if (nonMemberItem is bool && (bool)nonMemberItem)
                        result.Add(child);
                }
            }

            return result;
        }

        /// <summary>
        /// Removes non member item nodes from hierarchy.
        /// </summary>
        public virtual void RemoveNonmemberItems()
        {
            IList<HierarchyNode> nodeList = new List<HierarchyNode>();
            FindNodes(nodeList, this, IsNodeNonmemberItem);
            for (int index = nodeList.Count - 1; index >= 0; index--)
            {
                HierarchyNode parent = nodeList[index].Parent;
                nodeList[index].OnItemDeleted();
                parent.RemoveChild(nodeList[index]);
            }
        }

        /// <summary>
        /// This is the filter for non member items.
        /// </summary>
        /// <param name="node">Node to be filtered.</param>
        /// <returns>Returns if the node is a non member item node or not.</returns>
        protected virtual bool IsNodeNonmemberItem(HierarchyNode node)
        {
            bool isNonmemberItem = false;
            if (node != null)
            {
                object propObj = node.GetProperty((int)__VSHPROPID.VSHPROPID_IsNonMemberItem);
                if (propObj != null)
                {
                    if (!bool.TryParse(propObj.ToString(), out isNonmemberItem))
                        isNonmemberItem = false;
                }
            }

            return isNonmemberItem;
        }

        /// <summary>
        /// Gets the file system entries of a folder and its all sub-folders with relative path.
        /// </summary>
        /// <param name="baseFolder">Base folder.</param>
        /// <param name="filter">Filter to be used. default is "*"</param>
        /// <param name="fileList">Files list containing the relative file paths.</param>
        /// <param name="folderList">Folders list containing the relative folder paths.</param>
        protected static void GetRelativeFileSystemEntries(string baseFolder, string filter, IList<string> fileList, IList<string> folderList)
        {
            if (baseFolder == null)
            {
                throw new ArgumentNullException("baseFolder");
            }

            if (String.IsNullOrEmpty(filter))
            {
                filter = "*";  // include all files and folders
            }

            if (fileList != null)
            {
                string[] fileEntries = Directory.GetFiles(baseFolder, filter, SearchOption.AllDirectories);
                foreach (string file in fileEntries)
                {
                    string fileRelativePath = GetRelativePath(baseFolder, file);
                    if (!String.IsNullOrEmpty(fileRelativePath))
                    {
                        fileList.Add(fileRelativePath);
                    }
                }
            }

            if (folderList != null)
            {
                string[] folderEntries = Directory.GetDirectories(baseFolder, filter, SearchOption.AllDirectories);
                foreach (string folder in folderEntries)
                {
                    string folderRelativePath = GetRelativePath(baseFolder, folder);
                    if (!String.IsNullOrEmpty(folderRelativePath))
                    {
                        folderList.Add(folderRelativePath);
                    }
                }
            }
        }

        /// <summary>
        /// Excludes the file and folder items from their corresponding maps if they are part of the build.
        /// </summary>
        /// <param name="fileList">List containing relative files paths.</param>
        /// <param name="folderList">List containing relative folder paths.</param>
        protected virtual void ExcludeProjectBuildItems(IList<string> fileList, IList<string> folderList)
        {
            if (fileList == null)
                throw new ArgumentNullException("fileList");
            if (folderList == null)
                throw new ArgumentNullException("folderList");

            ICollection<MSBuild.ProjectItem> projectItems = this.BuildProject.Items;

            if (projectItems == null)
            {
                return; // do nothig, just ignore it.
            }

            // we need these maps becuase we need to have both lowercase and actual case path information.
            // we use lower case paths for case-insesitive search of file entries and actual paths for 
            // creating hierarchy node. if we don't do that, we will end up with duplicate nodes when the
            // case of path in .wixproj file doesn't match with the actual file path on the disk.
            IDictionary<string, string> folderMap = null;
            IDictionary<string, string> fileMap = null;

            if (folderList != null)
            {
                folderMap = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
                foreach (string folder in folderList)
                {
                    folderMap.Add(folder, folder);
                }
            }

            if (fileList != null)
            {
                fileMap = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
                foreach (string file in fileList)
                {
                    fileMap.Add(file, file);
                }
            }

            foreach (MSBuild.ProjectItem buildItem in projectItems)
            {
                if (folderMap != null &&
                    folderMap.Count > 0 &&
                    IsFolderItem(buildItem))
                {
                    string relativePath = buildItem.EvaluatedInclude;
                    if (Path.IsPathRooted(relativePath)) // if not the relative path, make it relative
                    {
                        relativePath = GetRelativePath(this.ProjectFolder, relativePath);
                    }

                    if (folderMap.ContainsKey(relativePath))
                    {
                        folderList.Remove(folderMap[relativePath]); // remove it from the actual list.
                        folderMap.Remove(relativePath);
                    }
                }
                else if (fileMap != null &&
                    fileMap.Count > 0 &&
                    IsFileItem(buildItem))
                {
                    string relativePath = buildItem.EvaluatedInclude;
                    if (Path.IsPathRooted(relativePath)) // if not the relative path, make it relative
                    {
                        relativePath = GetRelativePath(this.ProjectFolder, relativePath);
                    }

                    if (fileMap.ContainsKey(relativePath))
                    {
                        fileList.Remove(fileMap[relativePath]); // remove it from the actual list.
                        fileMap.Remove(relativePath);
                    }
                }
            }
        }

        /// <summary>
        /// Adds non member folder items to the hierarcy.
        /// </summary>
        /// <param name="folderList">Folders list containing the folder names.</param>
        protected virtual void AddNonmemberFolderItems(IList<string> folderList)
        {
            if (folderList == null)
            {
                throw new ArgumentNullException("folderList");
            }

            foreach (string folderKey in folderList)
            {
                HierarchyNode parentNode = this;
                string[] folders = folderKey.Split(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
                FolderNode topFolderNode = null;
                foreach (string folder in folders)
                {
                    string childNodeId = Path.Combine(parentNode.VirtualNodeName, folder);
                    HierarchyNode childNode = parentNode.FindChild(childNodeId, false);
                    if (childNode == null)
                    {
                        if (topFolderNode == null)
                        {
                            topFolderNode = parentNode as FolderNode;
                            if (topFolderNode != null && (!topFolderNode.IsNonmemberItem) && topFolderNode.IsExpanded)
                            {
                                topFolderNode = null;
                            }
                        }

                        ProjectElement element = new ProjectElement(this, null, true);
                        FolderNode folderNode = this.CreateFolderNode(childNodeId, element);
                        childNode = folderNode;
                        parentNode.AddChild(childNode);
                    }

                    parentNode = childNode;
                }

                if (topFolderNode != null)
                {
                    topFolderNode.CollapseFolder();
                }
            }
        }

        /// <summary>
        /// Adds non member file items to the hierarcy.
        /// </summary>
        /// <param name="fileList">Files containing the information about the non member file items.</param>
        protected virtual void AddNonmemberFileItems(IList<string> fileList)
        {
            if (fileList == null)
                throw new ArgumentNullException("fileList");

            foreach (string fileKey in fileList)
            {
                HierarchyNode parentNode = this;
                FolderNode topFolderNode = null;

                string canonicalName = fileKey;
                if (!Path.IsPathRooted(canonicalName))
                    canonicalName = Path.Combine(ProjectManager.BaseUri.AbsoluteUrl, fileKey);

                if (fileKey.IndexOfAny(new[] { Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar }) < 0)
                {
                    // the parent is the project node, just make sure this isn't the project file itself
                    if (NativeMethods.IsSamePath(ProjectFile, canonicalName))
                        continue;
                }
                else
                {
                    string directoryCanonicalName = Path.GetDirectoryName(canonicalName) + '\\';
                    ReadOnlyCollection<HierarchyNode> parentFolderNodes = itemIdMap.GetNodesByName(directoryCanonicalName);
                    if (parentFolderNodes.Count == 1)
                    {
                        parentNode = parentFolderNodes[0];
                        for (HierarchyNode parentChain = parentNode; parentChain != null; parentChain = parentChain.Parent)
                        {
                            FolderNode folderNode = parentChain as FolderNode;
                            if (folderNode != null)
                                topFolderNode = folderNode;
                        }

                        if (topFolderNode != null && !topFolderNode.IsNonmemberItem && topFolderNode.IsExpanded)
                            topFolderNode = null;
                    }
                }

                ProjectElement element = new ProjectElement(this, null, true);
                element.Rename(canonicalName);
                element.SetMetadata(ProjectFileConstants.Name, canonicalName);
                HierarchyNode childNode = this.CreateFileNode(element);
                parentNode.AddChild(childNode);

                if (topFolderNode != null)
                {
                    topFolderNode.CollapseFolder();
                }
            }
        }

        /// <summary>
        /// Walks up in the hierarchy and ensures that all parent folder nodes of 'node' are included in the project.
        /// </summary>
        /// <param name="node">Start hierarchy node.</param>
        public static void EnsureParentFolderIncluded(HierarchyNode node)
        {
            if (node == null)
            {
                throw new ArgumentNullException("node");
            }

            // use stack to make sure all parent folders are included in the project.
            Stack<FolderNode> stack = new Stack<FolderNode>();

            // Find out the parent folder nodes if any.
            FolderNode parentFolderNode = node.Parent as FolderNode;
            while (parentFolderNode != null && parentFolderNode.IsNonmemberItem)
            {
                stack.Push(parentFolderNode);
                parentFolderNode.CreateDirectory(); // ensure that the folder is there on file system
                parentFolderNode = parentFolderNode.Parent as FolderNode;
            }

            // include all parent folders in the project.
            while (stack.Count > 0)
            {
                FolderNode folderNode = stack.Pop();
                ((IProjectSourceNode)folderNode).IncludeInProject(false);
            }
        }

        /// <summary>
        /// Finds child nodes uner the parent node and places them in the currentList.
        /// </summary>
        /// <param name="currentList">List to be populated with the nodes.</param>
        /// <param name="parent">Parent node under which the nodes should be searched.</param>
        /// <param name="filter">Filter to be used while selecting the node.</param>
        [SuppressMessage("Microsoft.Interoperability", "CA1407:AvoidStaticMembersInComVisibleTypes")]
        public static void FindNodes(IList<HierarchyNode> currentList, HierarchyNode parent, Func<HierarchyNode, bool> filter)
        {
            if (currentList == null)
            {
                throw new ArgumentNullException("currentList");
            }

            if (parent == null)
            {
                throw new ArgumentNullException("parent");
            }

            if (filter == null)
            {
                throw new ArgumentNullException("filter");
            }

            for (HierarchyNode child = parent.FirstChild; child != null; child = child.NextSibling)
            {
                if (filter(child))
                {
                    currentList.Add(child);
                }

                FindNodes(currentList, child, filter);
            }
        }

        /// <summary>
        /// Makes subPath relative with respect to basePath.
        /// </summary>
        /// <param name="basePath">Base folder path.</param>
        /// <param name="subpath">Path of the sub folder or file.</param>
        /// <returns>The relative path for the subPath if it shares the same root with basePath or subPath otherwise.</returns>
        /// <remarks>
        /// We introduced GetRelativePath method because the Microsoft.VisualStudio.Shell.PackageUtilities.MakeRelative() doesn't
        /// work as expected in some cases (as of 11/12/2007). For example:
        /// Test # 1
        /// Base Path:      C:\a\b\r\d\..\..\e\f
        /// Sub Path:       c:\a\b\e\f\g\h\..\i\j.txt
        /// Expected:       g\i\j.txt
        /// Actual:         c:\a\b\e\f\g\h\..\i\j.txt
        /// -------------
        /// Test # 2
        /// Base Path:      \\mghaznawks\a\e\f
        /// Sub Path:       \\mghaznawks\e\f\g\h\i\j.txt
        /// Expected:       \\mghaznawks\e\f\g\h\i\j.txt
        /// Actual:         ..\..\..\e\f\g\h\i\j.txt
        /// Note that the base root path is \\mghaznawks\a\   Ref: System.IO.Path.GetPathRoot(string)
        /// -------------
        /// Test # 3
        /// Base Path:      \\mghaznawks\C$\a\..\e\f
        /// Sub Path:       \\mghaznawks\D$\e\f\g\h\i\j.txt
        /// Expected:       \\mghaznawks\D$\e\f\g\h\i\j.txt
        /// Actual:         ..\..\..\..\..\D$\e\f\g\h\i\j.txt
        /// -------------
        /// Test # 4
        /// Base Path:      \\mghaznawks\C$\a\..\e\f
        /// Sub Path:       \\mghaznawks\c$\e\f\g\h\i\j.txt
        /// Expected:       g\h\i\j.txt
        /// Actual:         ..\..\..\..\..\c$\e\f\g\h\i\j.txt
        /// </remarks>
        [SuppressMessage("Microsoft.Interoperability", "CA1407:AvoidStaticMembersInComVisibleTypes")]
        [SuppressMessage("Microsoft.Design", "CA1062:Validate arguments of public methods", MessageId = "0")]
        [SuppressMessage("Microsoft.Globalization", "CA1303:DoNotPassLiteralsAsLocalizedParameters", MessageId = "System.ArgumentException.#ctor(System.String)")]
        public static string GetRelativePath(string basePath, string subpath)
        {
            VerifyStringArgument(basePath, "basePath");
            VerifyStringArgument(subpath, "subpath");

            if (!Path.IsPathRooted(basePath))
            {
                throw new ArgumentException("The 'basePath' is not rooted.");
            }

            if (!Path.IsPathRooted(subpath))
            {
                return subpath;
            }

            if (!String.Equals(Path.GetPathRoot(basePath), Path.GetPathRoot(subpath), StringComparison.OrdinalIgnoreCase))
            {
                // both paths have different roots so we can't make them relative
                return subpath;
            }

            // Url.MakeRelative method requires the base path to be ended with a '\' if it is a folder,
            // otherwise it considers it as a file so we need to make sure that the folder path is right
            basePath = EnsureTrailingDirectoryChar(basePath.Trim());

            Url url = new Url(basePath);
            return url.MakeRelative(new Url(subpath));
        }

        public static void RefreshPropertyBrowser()
        {
            IVsUIShell vsuiShell = Microsoft.VisualStudio.Shell.Package.GetGlobalService(typeof(SVsUIShell)) as IVsUIShell;

            if (vsuiShell == null)
            {
                throw new InvalidOperationException();
            }
            else
            {
                ErrorHandler.ThrowOnFailure(vsuiShell.RefreshPropertyBrowser(0));
            }
        }

        public static void ExploreFolderInWindows(string folderPath)
        {
            if (folderPath == null)
                throw new ArgumentNullException("folderPath");

            string explorerPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Windows), "explorer.exe");
            System.Diagnostics.Process.Start(explorerPath, string.Format("\"{0}\"", folderPath));
        }

        /// <summary>
        /// Returns if the buildItem is a file item or not.
        /// </summary>
        /// <param name="buildItem">BuildItem to be checked.</param>
        /// <returns>Returns true if the buildItem is a file item, false otherwise.</returns>
        public virtual bool IsFileItem(MSBuild.ProjectItem buildItem)
        {
            if (buildItem == null)
            {
                throw new ArgumentNullException("buildItem");
            }

            bool isFileItem = false;
            if (String.Equals(buildItem.ItemType, ProjectFileConstants.Compile, StringComparison.OrdinalIgnoreCase))
            {
                isFileItem = true;
            }
            else if (String.Equals(buildItem.ItemType, ProjectFileConstants.EmbeddedResource, StringComparison.OrdinalIgnoreCase))
            {
                isFileItem = true;
            }
            else if (String.Equals(buildItem.ItemType, ProjectFileConstants.Content, StringComparison.OrdinalIgnoreCase))
            {
                isFileItem = true;
            }
            else if (String.Equals(buildItem.ItemType, ProjectFileConstants.None, StringComparison.OrdinalIgnoreCase))
            {
                isFileItem = true;
            }

            return isFileItem;
        }

        public virtual bool IsFolderItem(MSBuild.ProjectItem buildItem)
        {
            if (buildItem == null)
                throw new ArgumentNullException("buildItem");

            if (string.Equals(buildItem.ItemType, ProjectFileConstants.Folder, StringComparison.OrdinalIgnoreCase))
                return true;

            return false;
        }

        /// <summary>
        /// Verifies that the specified string argument is non-null and non-empty, asserting if it
        /// is not and throwing a new <see cref="ArgumentException"/>.
        /// </summary>
        /// <param name="argument">The argument to check.</param>
        /// <param name="argumentName">The name of the argument.</param>
        [SuppressMessage("Microsoft.Interoperability", "CA1407:AvoidStaticMembersInComVisibleTypes")]
        public static void VerifyStringArgument(string argument, string argumentName)
        {
            if (argument == null || argument.Length == 0 || argument.Trim().Length == 0)
            {
                string message = String.Format(CultureInfo.InvariantCulture, "The string argument '{0}' is null or empty.", argumentName);
                Trace.WriteLine("Invalid string argument", message);
                throw new ArgumentException(message, argumentName);
            }
        }
        #endregion

        #region overridden methods
        protected override NodeProperties CreatePropertiesObject()
        {
            return new ProjectNodeProperties(this);
        }

        /// <summary>
        /// Sets the properties for the project node.
        /// </summary>
        /// <param name="propid">Identifier of the hierarchy property. For a list of propid values, <see cref="__VSHPROPID"/> </param>
        /// <param name="value">The value to set. </param>
        /// <returns>A success or failure value.</returns>
        public override int SetProperty(int propid, object value)
        {
            __VSHPROPID id = (__VSHPROPID)propid;

            switch (id)
            {
                case __VSHPROPID.VSHPROPID_ShowProjInSolutionPage:
                    this.ShowProjectInSolutionPage = (bool)value;
                    return VSConstants.S_OK;
            }

            return base.SetProperty(propid, value);
        }

        /// <summary>
        /// Renames the project node.
        /// </summary>
        /// <param name="label">The new name</param>
        /// <returns>A success or failure value.</returns>
        public override int SetEditLabel(string label)
        {
            // Validate the filename. 
            if (String.IsNullOrEmpty(label))
            {
                throw new InvalidOperationException(SR.GetString(SR.ErrorInvalidFileName, CultureInfo.CurrentUICulture));
            }
            else if (this.ProjectFolder.Length + label.Length + 1 > NativeMethods.MAX_PATH)
            {
                throw new InvalidOperationException(String.Format(CultureInfo.CurrentCulture, SR.GetString(SR.PathTooLong, CultureInfo.CurrentUICulture), label));
            }
            else if (Utilities.IsFileNameInvalid(label))
            {
                throw new InvalidOperationException(SR.GetString(SR.ErrorInvalidFileName, CultureInfo.CurrentUICulture));
            }

            string fileName = Path.GetFileNameWithoutExtension(label);

            // if there is no filename or it starts with a leading dot issue an error message and quit.
            if (String.IsNullOrEmpty(fileName) || fileName[0] == '.')
            {
                throw new InvalidOperationException(SR.GetString(SR.FileNameCannotContainALeadingPeriod, CultureInfo.CurrentUICulture));
            }

            // Nothing to do if the name is the same
            string oldFileName = Path.GetFileNameWithoutExtension(this.Url);
            if (String.Equals(oldFileName, label, StringComparison.Ordinal))
            {
                return VSConstants.S_FALSE;
            }

            // Now check whether the original file is still there. It could have been renamed.
            if (!File.Exists(this.Url))
            {
                throw new InvalidOperationException(String.Format(CultureInfo.CurrentCulture, SR.GetString(SR.FileOrFolderCannotBeFound, CultureInfo.CurrentUICulture), this.ProjectFile));
            }

            // Get the full file name and then rename the project file.
            string newFile = Path.Combine(this.ProjectFolder, label);
            string extension = Path.GetExtension(this.Url);

            // Make sure it has the correct extension
            if (!String.Equals(Path.GetExtension(newFile), extension, StringComparison.OrdinalIgnoreCase))
            {
                newFile += extension;
            }

            this.RenameProjectFile(newFile);
            return VSConstants.S_OK;
        }

        /// <summary>
        /// Gets the automation object for the project node.
        /// </summary>
        /// <returns>An instance of an EnvDTE.Project implementation object representing the automation object for the project.</returns>
        public override object GetAutomationObject()
        {
            return new Automation.OAProject(this);
        }

        /// <summary>
        /// Closes the project node.
        /// </summary>
        /// <returns>A success or failure value.</returns>
        public override int Close()
        {
            int hr = VSConstants.S_OK;
            try
            {
                // Walk the tree and close all nodes.
                // This has to be done before the project closes, since we want still state available for the ProjectManager on the nodes 
                // when nodes are closing.
                try
                {
                    CloseAllNodes(this);
                }
                finally
                {
                    this.Dispose(true);
                }
            }
            catch (COMException e)
            {
                hr = e.ErrorCode;
            }
            finally
            {
                ErrorHandler.ThrowOnFailure(base.Close());
            }

            this.isClosed = true;

            return hr;
        }

        /// <summary>
        /// Sets the service provider from which to access the services. 
        /// </summary>
        /// <param name="site">An instance to an Microsoft.VisualStudio.OLE.Interop object</param>
        /// <returns>A success or failure value.</returns>
        public override int SetSite(Microsoft.VisualStudio.OLE.Interop.IServiceProvider site)
        {
            CciTracing.TraceCall();
            this._site = new ServiceProvider(site);
			ServiceProvider = this._site;

            if (taskProvider != null)
            {
                taskProvider.Dispose();
            }
            taskProvider = new TaskProvider(this._site);

            return VSConstants.S_OK;
        }

        /// <summary>
        /// Gets the properties of the project node. 
        /// </summary>
        /// <param name="propId">The __VSHPROPID of the property.</param>
        /// <returns>A property dependent value. See: <see cref="__VSHPROPID"/> for details.</returns>
        public override object GetProperty(int propId)
        {
            switch ((__VSHPROPID)propId)
            {
                case __VSHPROPID.VSHPROPID_ConfigurationProvider:
                    return this.ConfigProvider;

                case __VSHPROPID.VSHPROPID_ProjectName:
                    return this.Caption;

                case __VSHPROPID.VSHPROPID_ProjectDir:
                    return this.ProjectFolder;

                case __VSHPROPID.VSHPROPID_TypeName:
                    return this.ProjectType;

                case __VSHPROPID.VSHPROPID_ShowProjInSolutionPage:
                    return this.ShowProjectInSolutionPage;

                case __VSHPROPID.VSHPROPID_ExpandByDefault:
                    return true;

                // Use the same icon as if the folder was closed
                case __VSHPROPID.VSHPROPID_OpenFolderIconIndex:
                    return GetProperty((int)__VSHPROPID.VSHPROPID_IconIndex);
            }

            switch ((__VSHPROPID2)propId)
            {
                case __VSHPROPID2.VSHPROPID_SupportsProjectDesigner:
                    return this.SupportsProjectDesigner;

                case __VSHPROPID2.VSHPROPID_PropertyPagesCLSIDList:
                    return Utilities.CreateSemicolonDelimitedListOfStringFromGuids(this.GetConfigurationIndependentPropertyPages());

                case __VSHPROPID2.VSHPROPID_CfgPropertyPagesCLSIDList:
                    return Utilities.CreateSemicolonDelimitedListOfStringFromGuids(this.GetConfigurationDependentPropertyPages());

                case __VSHPROPID2.VSHPROPID_PriorityPropertyPagesCLSIDList:
                    return Utilities.CreateSemicolonDelimitedListOfStringFromGuids(this.GetPriorityProjectDesignerPages());

                case __VSHPROPID2.VSHPROPID_Container:
                    return true;
                default:
                    break;
            }

            return base.GetProperty(propId);
        }

        /// <summary>
        /// Gets the GUID value of the node. 
        /// </summary>
        /// <param name="propid">A __VSHPROPID or __VSHPROPID2 value of the guid property</param>
        /// <param name="guid">The guid to return for the property.</param>
        /// <returns>A success or failure value.</returns>
        public override int GetGuidProperty(int propid, out Guid guid)
        {
            guid = Guid.Empty;
            if ((__VSHPROPID)propid == __VSHPROPID.VSHPROPID_ProjectIDGuid)
            {
                guid = this.ProjectIdGuid;
            }
            else if (propid == (int)__VSHPROPID.VSHPROPID_CmdUIGuid)
            {
                guid = this.ProjectGuid;
            }
            else if ((__VSHPROPID2)propid == __VSHPROPID2.VSHPROPID_ProjectDesignerEditor && this.SupportsProjectDesigner)
            {
                guid = this.ProjectDesignerEditor;
            }
            else
            {
                base.GetGuidProperty(propid, out guid);
            }

            if (guid.CompareTo(Guid.Empty) == 0)
            {
                return VSConstants.DISP_E_MEMBERNOTFOUND;
            }

            return VSConstants.S_OK;
        }

        /// <summary>
        /// Sets Guid properties for the project node.
        /// </summary>
        /// <param name="propid">A __VSHPROPID or __VSHPROPID2 value of the guid property</param>
        /// <param name="guid">The guid value to set.</param>
        /// <returns>A success or failure value.</returns>
        public override int SetGuidProperty(int propid, ref Guid guid)
        {
            switch ((__VSHPROPID)propid)
            {
                case __VSHPROPID.VSHPROPID_ProjectIDGuid:
                    this.ProjectIdGuid = guid;
                    return VSConstants.S_OK;
            }
            CciTracing.TraceCall(String.Format(CultureInfo.CurrentCulture, "Property {0} not found", propid));
            return VSConstants.DISP_E_MEMBERNOTFOUND;
        }

        /// <summary>
        /// Removes items from the hierarchy. 
        /// </summary>
        /// <devdoc>Project overwrites this.</devdoc>
        public override void Remove(bool removeFromStorage)
        {
            // the project will not be deleted from disk, just removed      
            if (removeFromStorage)
            {
                return;
            }

            // Remove the entire project from the solution
            IVsSolution solution = this.Site.GetService(typeof(SVsSolution)) as IVsSolution;
            uint iOption = 1; // SLNSAVEOPT_PromptSave
            ErrorHandler.ThrowOnFailure(solution.CloseSolutionElement(iOption, this.InteropSafeIVsHierarchy, 0));
        }

        /// <summary>
        /// Gets the moniker for the project node. That is the full path of the project file.
        /// </summary>
        /// <returns>The moniker for the project file.</returns>
        public override string GetMKDocument()
        {
            Debug.Assert(!String.IsNullOrEmpty(this.FileName));
            Debug.Assert(this.BaseUri != null && !String.IsNullOrEmpty(this.BaseUri.AbsoluteUrl));
            return Path.Combine(this.BaseUri.AbsoluteUrl, this.FileName);
        }

        protected virtual HierarchyNodeCollection CreateHierarchyNodeCollection()
        {
            return new HierarchyNodeCollection(this, StringComparer.OrdinalIgnoreCase);
        }

        /// <summary>
        /// Disposes the project node object.
        /// </summary>
        /// <param name="disposing">Flag determining ehether it was deterministic or non deterministic clean up.</param>
        protected override void Dispose(bool disposing)
        {
            if (this.isDisposed)
            {
                return;
            }

            try
            {
                try
                {
                    this.UnregisterProject();
                }
                finally
                {
                    try
                    {
                        this.RegisterClipboardNotifications(false);
                    }
                    finally
                    {
                        try
                        {
                            if (this.projectEventsProvider != null)
                            {
                                this.projectEventsProvider.ProjectFileOpened -= this.OnAfterProjectOpen;
                            }
                            if (this.taskProvider != null)
                            {
                                taskProvider.Tasks.Clear();
                                this.taskProvider.Dispose();
                                this.taskProvider = null;
                            }

                            if (this.buildLogger != null)
                            {
                                this.buildLogger.Shutdown();
                                buildLogger = null;
                            }

                            if (this._site != null)
                            {
                                this._site.Dispose();
                            }

                            if (this.itemIdMap != null)
                            {
                                this.itemIdMap.Dispose();
                            }
                        }
                        finally
                        {
                            this.buildEngine = null;
                        }
                    }
                }

                if (this.buildProject != null)
                {
                    this.buildProject.ProjectCollection.UnloadProject(this.buildProject);
                    this.buildProject.ProjectCollection.UnloadProject(this.buildProject.Xml);
                    this.buildProject = null;
                }

                if (this._userBuildProject != null)
                {
                    this._userBuildProject.ProjectCollection.UnloadProject(this._userBuildProject);
                    this._userBuildProject.ProjectCollection.UnloadProject(this._userBuildProject.Xml);
                    this._userBuildProject = null;
                }

                if (null != imageHandler)
                {
                    imageHandler.Close();
                    imageHandler = null;
                }
            }
            finally
            {
                base.Dispose(disposing);
                this.isDisposed = true;
            }
        }

        protected override vsCommandStatus QueryStatusCommandFromOleCommandTarget(Guid cmdGroup, uint cmd, out bool handled)
        {
            if (cmdGroup == VsMenus.guidStandardCommandSet2K)
            {
                switch ((VsCommands2K)cmd)
                {
                case ProjectFileConstants.CommandExploreFolderInWindows:
                    handled = true;
                    return vsCommandStatus.vsCommandStatusEnabled | vsCommandStatus.vsCommandStatusSupported;
                }
            }

            return base.QueryStatusCommandFromOleCommandTarget(cmdGroup, cmd, out handled);
        }

        /// <summary>
        /// Handles command status on the project node. If a command cannot be handled then the base should be called.
        /// </summary>
        /// <param name="cmdGroup">A unique identifier of the command group. The pguidCmdGroup parameter can be NULL to specify the standard group.</param>
        /// <param name="cmd">The command to query status for.</param>
        /// <param name="pCmdText">Pointer to an OLECMDTEXT structure in which to return the name and/or status information of a single command. Can be NULL to indicate that the caller does not require this information.</param>
        /// <param name="result">An out parameter specifying the QueryStatusResult of the command.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code.</returns>
        protected override int QueryStatusOnNode(Guid cmdGroup, uint cmd, IntPtr pCmdText, ref vsCommandStatus result)
        {
            if (cmdGroup == VsMenus.guidStandardCommandSet97)
            {
                switch ((VsCommands)cmd)
                {
                    case VsCommands.Copy:
                    case VsCommands.Paste:
                    case VsCommands.Cut:
                    case VsCommands.Rename:
                    case VsCommands.Exit:
                    case VsCommands.ProjectSettings:
                    case VsCommands.BuildSln:
                    case VsCommands.UnloadProject:
                        result |= vsCommandStatus.vsCommandStatusSupported | vsCommandStatus.vsCommandStatusEnabled;
                        return VSConstants.S_OK;

                    case VsCommands.ViewForm:
                        if (this.HasDesigner)
                        {
                            result |= vsCommandStatus.vsCommandStatusSupported | vsCommandStatus.vsCommandStatusEnabled;
                            return VSConstants.S_OK;
                        }
                        break;

                    case VsCommands.CancelBuild:
                        result |= vsCommandStatus.vsCommandStatusSupported;
                        if (this.buildInProcess)
                            result |= vsCommandStatus.vsCommandStatusEnabled;
                        else
                            result |= vsCommandStatus.vsCommandStatusInvisible;
                        return VSConstants.S_OK;

                    case VsCommands.NewFolder:
                    case VsCommands.AddNewItem:
                    case VsCommands.AddExistingItem:
                        result |= vsCommandStatus.vsCommandStatusSupported | vsCommandStatus.vsCommandStatusEnabled;
                        return VSConstants.S_OK;

                    case VsCommands.SetStartupProject:
                        result |= vsCommandStatus.vsCommandStatusSupported | vsCommandStatus.vsCommandStatusEnabled;
                        return VSConstants.S_OK;
                }
            }
            else if (cmdGroup == VsMenus.guidStandardCommandSet2K)
            {

                switch ((VsCommands2K)cmd)
                {
                    case VsCommands2K.ADDREFERENCE:
                        result |= vsCommandStatus.vsCommandStatusSupported;
                        if (GetReferenceContainer() != null)
                            result |= vsCommandStatus.vsCommandStatusEnabled;
                        return VSConstants.S_OK;

                    case VsCommands2K.EXCLUDEFROMPROJECT:
                        result |= vsCommandStatus.vsCommandStatusSupported | vsCommandStatus.vsCommandStatusInvisible;
                        return VSConstants.S_OK;

                    case VsCommands2K.SLNREFRESH:
                        result |= vsCommandStatus.vsCommandStatusSupported | vsCommandStatus.vsCommandStatusEnabled;
                        return VSConstants.S_OK;
                }
            }
            else
            {
                return (int)OleConstants.OLECMDERR_E_UNKNOWNGROUP;
            }

            return base.QueryStatusOnNode(cmdGroup, cmd, pCmdText, ref result);
        }

        /// <summary>
        /// Handles command execution.
        /// </summary>
        /// <param name="cmdGroup">Unique identifier of the command group</param>
        /// <param name="cmd">The command to be executed.</param>
        /// <param name="nCmdexecopt">Values describe how the object should execute the command.</param>
        /// <param name="pvaIn">Pointer to a VARIANTARG structure containing input arguments. Can be NULL</param>
        /// <param name="pvaOut">VARIANTARG structure to receive command output. Can be NULL.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code.</returns>
        protected override int ExecCommandOnNode(Guid cmdGroup, uint cmd, OLECMDEXECOPT nCmdexecopt, IntPtr pvaIn, IntPtr pvaOut)
        {
            if (cmdGroup == VsMenus.guidStandardCommandSet97)
            {
                switch ((VsCommands)cmd)
                {

                    case VsCommands.UnloadProject:
                        return this.UnloadProject();
                    case VsCommands.CleanSel:
                    case VsCommands.CleanCtx:
                        return this.CleanProject();
                }
            }
            else if (cmdGroup == VsMenus.guidStandardCommandSet2K)
            {
                switch ((VsCommands2K)cmd)
                {
                    case VsCommands2K.ADDREFERENCE:
                        return this.AddProjectReference();

                    case VsCommands2K.ADDWEBREFERENCE:
                    case VsCommands2K.ADDWEBREFERENCECTX:
                        return this.AddWebReference();

                    case VsCommands2K.SLNREFRESH:
                        RefreshProject();
                        return VSConstants.S_OK;

                    case ProjectFileConstants.CommandExploreFolderInWindows:
                        ExploreFolderInWindows(this.ProjectFolder);
                        return VSConstants.S_OK;
                }
            }

            return base.ExecCommandOnNode(cmdGroup, cmd, nCmdexecopt, pvaIn, pvaOut);
        }

        /// <summary>
        /// Get the boolean value for the deletion of a project item
        /// </summary>
        /// <param name="deleteOperation">A flag that specifies the type of delete operation (delete from storage or remove from project)</param>
        /// <returns>true if item can be deleted from project</returns>
        protected override bool CanDeleteItem(__VSDELETEITEMOPERATION deleteOperation)
        {
            if (deleteOperation == __VSDELETEITEMOPERATION.DELITEMOP_RemoveFromProject)
            {
                return true;
            }
            return false;
        }

        /// <summary>
        /// Returns a specific Document manager to handle opening and closing of the Project(Application) Designer if projectdesigner is supported.
        /// </summary>
        /// <returns>Document manager object</returns>
        public override DocumentManager GetDocumentManager()
        {
            if (this.SupportsProjectDesigner)
            {
                return new ProjectDesignerDocumentManager(this);
            }
            return null;
        }

        #endregion

        #region virtual methods

        public virtual MSBuild.Project GetOrCreateUserBuildProject()
        {
            var userBuildProject = UserBuildProject;
            if (userBuildProject == null)
                _userBuildProject = CreateUserBuildProject();

            return UserBuildProject;
        }

        protected virtual MSBuild.Project CreateUserBuildProject()
        {
            if (!File.Exists(UserFileName))
            {
                MSBuild.Project userBuildProject = new MSBuild.Project();
                userBuildProject.Save(UserFileName);
            }

            return BuildEngine.LoadProject(UserFileName);
        }

        /// <summary>
        /// Executes a wizard.
        /// </summary>
        /// <param name="parentNode">The node to which the wizard should add item(s).</param>
        /// <param name="itemName">The name of the file that the user typed in.</param>
        /// <param name="wizardToRun">The name of the wizard to run.</param>
        /// <param name="dlgOwner">The owner of the dialog box.</param>
        /// <returns>A VSADDRESULT enum value describing success or failure.</returns>
        [SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "dlg")]
        public virtual VSADDRESULT RunWizard(HierarchyNode parentNode, string itemName, string wizardToRun, IntPtr dlgOwner)
        {
            Debug.Assert(!String.IsNullOrEmpty(itemName), "The Add item dialog was passing in a null or empty item to be added to the hierrachy.");
            Debug.Assert(!String.IsNullOrEmpty(this.ProjectFolder), "The Project Folder is not specified for this project.");

            if (parentNode == null)
            {
                throw new ArgumentNullException("parentNode");
            }

            if (String.IsNullOrEmpty(itemName))
            {
                throw new ArgumentNullException("itemName");
            }

            // We just validate for length, since we assume other validation has been performed by the dlgOwner.
            if (this.ProjectFolder.Length + itemName.Length + 1 > NativeMethods.MAX_PATH)
            {
                string errorMessage = String.Format(CultureInfo.CurrentCulture, SR.GetString(SR.PathTooLong, CultureInfo.CurrentUICulture), itemName);
                if (!Utilities.IsInAutomationFunction(this.Site))
                {
                    string title = null;
                    OLEMSGICON icon = OLEMSGICON.OLEMSGICON_CRITICAL;
                    OLEMSGBUTTON buttons = OLEMSGBUTTON.OLEMSGBUTTON_OK;
                    OLEMSGDEFBUTTON defaultButton = OLEMSGDEFBUTTON.OLEMSGDEFBUTTON_FIRST;
                    VsShellUtilities.ShowMessageBox(this.Site, title, errorMessage, icon, buttons, defaultButton);
                    return VSADDRESULT.ADDRESULT_Failure;
                }
                else
                {
                    throw new InvalidOperationException(errorMessage);
                }
            }


            // Build up the ContextParams safearray
            //  [0] = Wizard type guid  (bstr)
            //  [1] = Project name  (bstr)
            //  [2] = ProjectItems collection (bstr)
            //  [3] = Local Directory (bstr)
            //  [4] = Filename the user typed (bstr)
            //  [5] = Product install Directory (bstr)
            //  [6] = Run silent (bool)

            object[] contextParams = new object[7];
            contextParams[0] = EnvDTE.Constants.vsWizardAddItem;
            contextParams[1] = this.Caption;
            object automationObject = parentNode.GetAutomationObject();
            EnvDTE.Project project = automationObject as EnvDTE.Project;
            if (project != null)
            {
                contextParams[2] = project.ProjectItems;
            }
            else
            {
                // This would normally be a folder unless it is an item with subitems
                EnvDTE.ProjectItem item = (EnvDTE.ProjectItem)automationObject;
                contextParams[2] = item.ProjectItems;
            }

            contextParams[3] = this.ProjectFolder;

            contextParams[4] = itemName;

            object objInstallationDir = null;
            IVsShell shell = (IVsShell)this.GetService(typeof(IVsShell));
            ErrorHandler.ThrowOnFailure(shell.GetProperty((int)__VSSPROPID.VSSPROPID_InstallDirectory, out objInstallationDir));
            string installDir = (string)objInstallationDir;

            // append a '\' to the install dir to mimic what the shell does (though it doesn't add one to destination dir)
            if (!installDir.EndsWith("\\", StringComparison.Ordinal))
            {
                installDir += "\\";
            }

            contextParams[5] = installDir;

            contextParams[6] = true;

            IVsExtensibility3 ivsExtensibility = this.GetService(typeof(IVsExtensibility)) as IVsExtensibility3;
            Debug.Assert(ivsExtensibility != null, "Failed to get IVsExtensibility3 service");
            if (ivsExtensibility == null)
            {
                return VSADDRESULT.ADDRESULT_Failure;
            }

            // Determine if we have the trust to run this wizard.
            IVsDetermineWizardTrust wizardTrust = this.GetService(typeof(SVsDetermineWizardTrust)) as IVsDetermineWizardTrust;
            if (wizardTrust != null)
            {
                Guid guidProjectAdding = Guid.Empty;
                ErrorHandler.ThrowOnFailure(wizardTrust.OnWizardInitiated(wizardToRun, ref guidProjectAdding));
            }

            int wizResultAsInt;
            try
            {
                Array contextParamsAsArray = contextParams;

                int result = ivsExtensibility.RunWizardFile(wizardToRun, (int)dlgOwner, ref contextParamsAsArray, out wizResultAsInt);

                if (!ErrorHandler.Succeeded(result) && result != VSConstants.OLE_E_PROMPTSAVECANCELLED)
                {
                    ErrorHandler.ThrowOnFailure(result);
                }
            }
            finally
            {
                if (wizardTrust != null)
                {
                    ErrorHandler.ThrowOnFailure(wizardTrust.OnWizardCompleted());
                }
            }

            EnvDTE.wizardResult wizardResult = (EnvDTE.wizardResult)wizResultAsInt;

            switch (wizardResult)
            {
                default:
                    return VSADDRESULT.ADDRESULT_Cancel;
                case wizardResult.wizardResultSuccess:
                    return VSADDRESULT.ADDRESULT_Success;
                case wizardResult.wizardResultFailure:
                    return VSADDRESULT.ADDRESULT_Failure;
            }
        }

        /// <summary>
        /// Override this method if you want to modify the behavior of the Add Reference dialog
        /// By example you could change which pages are visible and which is visible by default.
        /// </summary>
        /// <returns></returns>
        public virtual int AddProjectReference()
        {
            CciTracing.TraceCall();

            IVsComponentSelectorDlg4 componentDialog;
            string strBrowseLocations = Path.GetDirectoryName(this.BaseUri.Uri.LocalPath);
            var tabInitList = GetComponentSelectorTabList().ToArray();
            for (int i = 0; i < tabInitList.Length; i++)
                tabInitList[i].dwSize = (uint)Marshal.SizeOf(typeof(VSCOMPONENTSELECTORTABINIT));

            componentDialog = this.GetService(typeof(IVsComponentSelectorDlg)) as IVsComponentSelectorDlg4;
            try
            {
                // call the container to open the add reference dialog.
                if (componentDialog != null)
                {
                    // Let the project know not to show itself in the Add Project Reference Dialog page
                    this.ShowProjectInSolutionPage = false;
                    // call the container to open the add reference dialog.
                    string browseFilters = GetComponentSelectorBrowseFilters();
                    ErrorHandler.ThrowOnFailure(componentDialog.ComponentSelectorDlg5(
                        (System.UInt32)(__VSCOMPSELFLAGS.VSCOMSEL_MultiSelectMode | __VSCOMPSELFLAGS.VSCOMSEL_IgnoreMachineName),
                        this.InteropSafeIVsComponentUser,
                        0,
						null,
						SR.GetString(SR.AddReferenceDialogTitle, CultureInfo.CurrentUICulture),   // Title
                        "VS.AddReference",                          // Help topic
                        AddComponentDialogSizeX,
                        AddComponentDialogSizeY,
                        (uint)tabInitList.Length,
                        tabInitList.ToArray(),
                        ref AddComponentLastActiveTab,
						browseFilters,
                        ref strBrowseLocations,
						this.TargetFrameworkMoniker.FullName));
                }
            }
            catch (COMException e)
            {
                Trace.WriteLine("Exception : " + e.Message);
                return e.ErrorCode;
            }
            finally
            {
                // Let the project know it can show itself in the Add Project Reference Dialog page
                this.ShowProjectInSolutionPage = true;
            }
            return VSConstants.S_OK;
        }

        protected virtual string GetComponentSelectorBrowseFilters()
        {
            return "Component Files (*.exe;*.dll)\0*.exe;*.dll\0";
        }

        protected virtual ReadOnlyCollection<VSCOMPONENTSELECTORTABINIT> GetComponentSelectorTabList()
        {
            return new List<VSCOMPONENTSELECTORTABINIT>()
			{
				new VSCOMPONENTSELECTORTABINIT {
					guidTab = VSConstants.GUID_COMPlusPage,
					varTabInitInfo = GetComponentPickerDirectories(),
				},
                new VSCOMPONENTSELECTORTABINIT {
                    guidTab = VSConstants.GUID_COMClassicPage,
                },
				new VSCOMPONENTSELECTORTABINIT {
		            // Tell the Add Reference dialog to call hierarchies GetProperty with the following
		            // propID to enablefiltering out ourself from the Project to Project reference
					varTabInitInfo = (int)__VSHPROPID.VSHPROPID_ShowProjInSolutionPage,
					guidTab = VSConstants.GUID_SolutionPage,
				},
	            // Add the Browse for file page            
				new VSCOMPONENTSELECTORTABINIT {
					varTabInitInfo = 0,
					guidTab = VSConstants.GUID_BrowseFilePage,
				},
				new VSCOMPONENTSELECTORTABINIT {
					guidTab = new Guid(ComponentSelectorGuids80.MRUPage),
				},
			}.AsReadOnly();
        }

        /// <summary>
        /// Returns the Compiler associated to the project 
        /// </summary>
        /// <returns>Null</returns>
        public virtual ICodeCompiler GetCompiler()
        {

            return null;
        }

        /// <summary>
        /// Override this method if you have your own project specific
        /// subclass of ProjectOptions
        /// </summary>
        /// <returns>This method returns a new instance of the ProjectOptions base class.</returns>
        public virtual ProjectOptions CreateProjectOptions()
        {
            return new ProjectOptions();
        }

        /// <summary>
        /// Loads a project file. Called from the factory CreateProject to load the project.
        /// </summary>
        /// <param name="fileName">File name of the project that will be created. </param>
        /// <param name="location">Location where the project will be created.</param>
        /// <param name="name">If applicable, the name of the template to use when cloning a new project.</param>
        /// <param name="flags">Set of flag values taken from the VSCREATEPROJFLAGS enumeration.</param>
        /// <param name="iidProject">Identifier of the interface that the caller wants returned. </param>
        /// <param name="canceled">An out parameter specifying if the project creation was canceled</param>
        [SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "iid")]
        public virtual void Load(string fileName, string location, string name, uint flags, ref Guid iidProject, out int canceled)
        {
            try
            {
                this.disableQueryEdit = true;

                // set up internal members and icons
                canceled = 0;

                this.isNewProject = false;

                if ((flags & (uint)__VSCREATEPROJFLAGS.CPF_CLONEFILE) == (uint)__VSCREATEPROJFLAGS.CPF_CLONEFILE)
                {
                    // we need to generate a new guid for the project
                    this.projectIdGuid = Guid.NewGuid();
                }
                else
                {
                    this.SetProjectGuidFromProjectFile();
                }

                // This is almost a No op if the engine has already been instantiated in the factory.
                this.buildEngine = Utilities.InitializeMsBuildEngine(this.buildEngine, this.Site);

                // based on the passed in flags, this either reloads/loads a project, or tries to create a new one
                // now we create a new project... we do that by loading the template and then saving under a new name
                // we also need to copy all the associated files with it.					
                if ((flags & (uint)__VSCREATEPROJFLAGS.CPF_CLONEFILE) == (uint)__VSCREATEPROJFLAGS.CPF_CLONEFILE)
                {
                    Debug.Assert(!String.IsNullOrEmpty(fileName) && File.Exists(fileName), "Invalid filename passed to load the project. A valid filename is expected");

                    this.isNewProject = true;

                    // This should be a very fast operation if the build project is already initialized by the Factory.
                    SetBuildProject(Utilities.ReinitializeMsBuildProject(this.buildEngine, fileName, this.buildProject));

                    // Compute the file name
                    // We try to solve two problems here. When input comes from a wizzard in case of zipped based projects 
                    // the parameters are different.
                    // In that case the filename has the new filename in a temporay path.

                    // First get the extension from the template.
                    // Then get the filename from the name.
                    // Then create the new full path of the project.
                    string extension = Path.GetExtension(fileName);

                    string tempName = String.Empty;

                    // We have to be sure that we are not going to loose data here. If the project name is a.b.c then for a project that was based on a zipped template(the wizzard calls us) GetFileNameWithoutExtension will suppress "c".
                    // We are going to check if the parameter "name" is extension based and the extension is the same as the one from the "filename" parameter.
                    string tempExtension = Path.GetExtension(name);
                    if (!String.IsNullOrEmpty(tempExtension))
                    {
                        bool isSameExtension = String.Equals(tempExtension, extension, StringComparison.OrdinalIgnoreCase);

                        if (isSameExtension)
                        {
                            tempName = Path.GetFileNameWithoutExtension(name);
                        }
                        // If the tempExtension is not the same as the extension that the project name comes from then assume that the project name is a dotted name.
                        else
                        {
                            tempName = Path.GetFileName(name);
                        }
                    }
                    else
                    {
                        tempName = Path.GetFileName(name);
                    }

                    Debug.Assert(!String.IsNullOrEmpty(tempName), "Could not compute project name");
                    string tempProjectFileName = tempName + extension;
                    this.FileName = Path.Combine(location, tempProjectFileName);

                    // Initialize the common project properties.
                    this.InitializeProjectProperties();

                    ErrorHandler.ThrowOnFailure(this.Save(this.FileName, 1, 0));

                    // now we do have the project file saved. we need to create embedded files.
                    foreach (MSBuild.ProjectItem item in this.BuildProject.Items)
                    {
                        // Ignore the item if it is a reference or folder
                        if (this.FilterItemTypeToBeAddedToHierarchy(item.ItemType))
                        {
                            continue;
                        }

                        // MSBuilds tasks/targets can create items (such as object files),
                        // such items are not part of the project per say, and should not be displayed.
                        // so ignore those items.
                        if (!this.IsItemTypeFileType(item.ItemType))
                        {
                            continue;
                        }

                        string strRelFilePath = item.EvaluatedInclude;
                        string basePath = Path.GetDirectoryName(fileName);
                        string strPathToFile;
                        string newFileName;
                        // taking the base name from the project template + the relative pathname,
                        // and you get the filename
                        strPathToFile = Path.Combine(basePath, strRelFilePath);
                        // the new path should be the base dir of the new project (location) + the rel path of the file
                        newFileName = Path.Combine(location, strRelFilePath);
                        // now the copy file
                        AddFileFromTemplate(strPathToFile, newFileName);
                    }
                }
                else
                {
                    this.FileName = fileName;
                }

                // now reload to fix up references
                this.Reload();
            }
            finally
            {
                this.disableQueryEdit = false;
            }
        }

        /// <summary>
        /// Called to add a file to the project from a template.
        /// Override to do it yourself if you want to customize the file
        /// </summary>
        /// <param name="source">Full path of template file</param>
        /// <param name="target">Full path of file once added to the project</param>
        public virtual void AddFileFromTemplate(string source, string target)
        {
            if (String.IsNullOrEmpty(source))
            {
                throw new ArgumentNullException("source");
            }
            if (String.IsNullOrEmpty(target))
            {
                throw new ArgumentNullException("target");
            }

            try
            {
                string directory = Path.GetDirectoryName(target);
                if (!String.IsNullOrEmpty(directory) && !Directory.Exists(directory))
                {
                    Directory.CreateDirectory(directory);
                }

                FileInfo fiOrg = new FileInfo(source);
                FileInfo fiNew = fiOrg.CopyTo(target, true);

                fiNew.Attributes = FileAttributes.Normal; // remove any read only attributes.
            }
            catch (IOException e)
            {
                Trace.WriteLine("Exception : " + e.Message);
            }
            catch (UnauthorizedAccessException e)
            {
                Trace.WriteLine("Exception : " + e.Message);
            }
            catch (ArgumentException e)
            {
                Trace.WriteLine("Exception : " + e.Message);
            }
            catch (NotSupportedException e)
            {
                Trace.WriteLine("Exception : " + e.Message);
            }
        }

        /// <summary>
        /// Called when the project opens an editor window for the given file
        /// </summary>
        public virtual void OnOpenItem(string fullPathToSourceFile)
        {
        }

        /// <summary>
        /// This add methos adds the "key" item to the hierarchy, potentially adding other subitems in the process
        /// This method may recurse if the parent is an other subitem
        /// 
        /// </summary>
        /// <param name="subitems">List of subitems not yet added to the hierarchy</param>
        /// <param name="key">Key to retrieve the target item from the subitems list</param>
        /// <returns>Newly added node</returns>
        /// <remarks>If the parent node was found we add the dependent item to it otherwise we add the item ignoring the "DependentUpon" metatdata</remarks>
        protected virtual HierarchyNode AddDependentFileNode(IDictionary<String, MSBuild.ProjectItem> subitems, string key, IDictionary<string, HierarchyNode> nodeCache)
        {
            if (subitems == null)
            {
                throw new ArgumentNullException("subitems");
            }

            MSBuild.ProjectItem item = subitems[key];
            subitems.Remove(key);

            HierarchyNode newNode;
            HierarchyNode parent = null;

            string dependentOf = item.GetMetadataValue(ProjectFileConstants.DependentUpon);
            Debug.Assert(!String.Equals(dependentOf, key, StringComparison.OrdinalIgnoreCase), "File dependent upon itself is not valid. Ignoring the DependentUpon metadata");
            if (subitems.ContainsKey(dependentOf))
            {
                // The parent item is an other subitem, so recurse into this method to add the parent first
                parent = AddDependentFileNode(subitems, dependentOf, nodeCache);
            }
            else
            {
                // See if the parent node already exist in the hierarchy
                uint parentItemID;
                string path = Path.Combine(this.ProjectFolder, dependentOf);

                if (nodeCache == null || !nodeCache.TryGetValue(path, out parent))
                {
                    ErrorHandler.ThrowOnFailure(this.ParseCanonicalName(path, out parentItemID));
                    if (parentItemID != (uint)VSConstants.VSITEMID.Nil)
                    {
                        parent = this.NodeFromItemId(parentItemID);
                        if (parent != null && nodeCache != null)
                            nodeCache.Add(path, parent);
                    }
                }

                Debug.Assert(parent != null, "File dependent upon a non existing item or circular dependency. Ignoring the DependentUpon metadata");
            }

            // If the parent node was found we add the dependent item to it otherwise we add the item ignoring the "DependentUpon" metatdata
            if (parent != null)
                newNode = this.AddDependentFileNodeToNode(item, parent);
            else
                newNode = this.AddIndependentFileNode(item, nodeCache);

            return newNode;
        }

        /// <summary>
        /// This is called from the main thread before the background build starts.
        ///  cleanBuild is not part of the vsopts, but passed down as the callpath is differently
        ///  PrepareBuild mainly creates directories and cleans house if cleanBuild is true
        /// </summary>
        /// <param name="config"></param>
        /// <param name="cleanBuild"></param>
        public virtual void PrepareBuild(string config, string platform, bool cleanBuild)
        {
            if (this.buildIsPrepared && !cleanBuild) return;

            ProjectOptions options = this.GetProjectOptions(config, platform);
            string outputPath = Path.GetDirectoryName(options.OutputAssembly);

            if (cleanBuild && this.currentConfig.Targets.ContainsKey(MSBuildTarget.Clean))
            {
                this.InvokeMSBuild(MSBuildTarget.Clean);
            }

            PackageUtilities.EnsureOutputPath(outputPath);
            if (!String.IsNullOrEmpty(options.XmlDocFileName))
            {
                PackageUtilities.EnsureOutputPath(Path.GetDirectoryName(options.XmlDocFileName));
            }

            this.buildIsPrepared = true;
        }

        /// <summary>
        /// Do the build by invoking msbuild
        /// </summary>
        [SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "vsopts")]
        public virtual MSBuildResult Build(uint vsopts, string config, string platform, IVsOutputWindowPane output, string target)
        {
            lock (ProjectNode.BuildLock)
            {
                bool engineLogOnlyCritical = this.BuildPrelude(output);

                MSBuildResult result = MSBuildResult.Failed;

                try
                {
                    this.SetBuildConfigurationProperties(config, platform);

                    result = this.InvokeMSBuild(target);
                }
                finally
                {
                    // Unless someone specifically request to use an output window pane, we should not output to it
                    if (null != output)
                    {
                        this.SetOutputLogger(null);
                        BuildEngine.OnlyLogCriticalEvents = engineLogOnlyCritical;
                    }
                }

                return result;
            }
        }


        /// <summary>
        /// Do the build by invoking msbuild
        /// </summary>
        [SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "vsopts")]
        public virtual void BuildAsync(uint vsopts, string config, string platform, IVsOutputWindowPane output, string target, Action<MSBuildResult, string> uiThreadCallback)
        {
            this.BuildPrelude(output);
            this.SetBuildConfigurationProperties(config, platform);
            this.DoMSBuildSubmission(BuildKind.Async, target, uiThreadCallback);
        }

        /// <summary>
        /// Return the value of a project property
        /// </summary>
        /// <param name="propertyName">Name of the property to get</param>
        /// <param name="resetCache">True to avoid using the cache</param>
        /// <returns>null if property does not exist, otherwise value of the property</returns>
        public virtual string GetProjectProperty(string propertyName, _PersistStorageType storageType, bool resetCache)
        {
            MSBuildExecution.ProjectPropertyInstance property = GetMsBuildProperty(propertyName, storageType, resetCache);
            if (property == null)
                return null;

            return property.EvaluatedValue;
        }

        /// <summary>
        /// Set value of project property
        /// </summary>
        /// <param name="propertyName">Name of property</param>
        /// <param name="propertyValue">Value of property</param>
        public virtual void SetProjectProperty(string propertyName, _PersistStorageType storageType, string propertyValue)
        {
            if (propertyName == null)
                throw new ArgumentNullException("propertyName", "Cannot set a null project property");

            string oldValue = null;
            ProjectPropertyInstance oldProp = GetMsBuildProperty(propertyName, storageType, true);
            if (oldProp != null)
                oldValue = oldProp.EvaluatedValue;

            if (propertyValue == null)
            {
                // if property already null, do nothing
                if (oldValue == null)
                    return;

                // otherwise, set it to empty
                propertyValue = String.Empty;
            }

            // Only do the work if this is different to what we had before
            if (!String.Equals(oldValue, propertyValue, StringComparison.Ordinal))
            {
                // Check out the project file.
                if (storageType == _PersistStorageType.PST_PROJECT_FILE && !this.ProjectManager.QueryEditProjectFile(false))
                {
                    throw Marshal.GetExceptionForHR(VSConstants.OLE_E_PROMPTSAVECANCELLED);
                }

                MSBuild.Project project = (storageType == _PersistStorageType.PST_PROJECT_FILE) ? this.BuildProject : this.GetOrCreateUserBuildProject();
                project.SetProperty(propertyName, propertyValue);
                OnProjectPropertyChanged(new ProjectPropertyChangedArgs(propertyName, oldValue, propertyValue));

                // property cache will need to be updated
                this.currentConfig = null;
                this.SetProjectFileDirty(true);
            }
        }

        public virtual void SetPropertyUnderCondition(string propertyName, _PersistStorageType storageType, string condition, string propertyValue)
        {
            if (propertyName == null)
                throw new ArgumentNullException("propertyName");

            if (string.IsNullOrWhiteSpace(condition))
            {
                SetProjectProperty(propertyName, storageType, propertyValue);
                return;
            }

            string conditionTrimmed = condition.Trim();
            MSBuild.Project project = (storageType == _PersistStorageType.PST_PROJECT_FILE) ? BuildProject : GetOrCreateUserBuildProject();
            MSBuildConstruction.ProjectPropertyGroupElement destinationGroup = null;
            foreach (MSBuildConstruction.ProjectPropertyGroupElement group in project.Xml.PropertyGroups)
            {
                if (String.Equals(group.Condition.Trim(), conditionTrimmed, StringComparison.OrdinalIgnoreCase))
                {
                    destinationGroup = group;
                    break;
                }
            }

            if (destinationGroup == null)
            {
                MSBuildConstruction.ProjectElement lastRelevantElement = null;
                foreach (MSBuildConstruction.ProjectPropertyGroupElement group in project.Xml.PropertyGroupsReversed)
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
                    lastRelevantElement = project.Xml.PropertyGroupsReversed.FirstOrDefault();

                destinationGroup = project.Xml.CreatePropertyGroupElement();
                project.Xml.InsertAfterChild(destinationGroup, lastRelevantElement);
                destinationGroup.Condition = condition;
            }

            foreach (MSBuildConstruction.ProjectPropertyElement property in destinationGroup.PropertiesReversed) // If there's dupes, pick the last one so we win
            {
                if (String.Equals(property.Name, propertyName, StringComparison.OrdinalIgnoreCase) && property.Condition.Length == 0)
                {
                    property.Value = propertyValue;
                    return;
                }
            }

            destinationGroup.AddProperty(propertyName, propertyValue);
        }

        public virtual ProjectOptions GetProjectOptions()
        {
            return GetProjectOptions(null, null);
        }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Maintainability", "CA1502:AvoidExcessiveComplexity"), System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Globalization", "CA1308:NormalizeStringsToUppercase")]
        public virtual ProjectOptions GetProjectOptions(string config, string platform)
        {
            if ((!string.IsNullOrEmpty(config) && string.IsNullOrEmpty(platform))
                || (string.IsNullOrEmpty(config) && !string.IsNullOrEmpty(platform)))
            {
                throw new ArgumentException("Either both or neither the configuration and platform should be specified.");
            }

			if (string.IsNullOrEmpty(config))
			{
				EnvDTE.Project automationObject = this.GetAutomationObject() as EnvDTE.Project;
                try
                {
                    config = Utilities.GetActiveConfigurationName(automationObject);
                    platform = Utilities.GetActivePlatformName(automationObject);
                }
                catch (InvalidOperationException)
                {
                    // Can't figure out the active configuration.  Perhaps during solution load, or in a unit test.
                }
				catch (COMException)
				{
					// We may be in solution load and don't have an active config yet.
				}
			}

            // Even though the options are the same, when this config was originally set, it may have been before 
            // the project system was ready to set up its configuration, so go ahead and call through to SetConfiguration 
            // anyway -- it should do effectively nothing if the config is the same and all the initialization has 
            // already occurred. 
            if (this._options != null
                && string.Equals(this._options.Config, config, StringComparison.OrdinalIgnoreCase)
                && string.Equals(this._options.Platform, platform, StringComparison.OrdinalIgnoreCase))
            {
                if (config != null && platform != null)
                {
                    // Fancy dance with the options required because SetConfiguration nulls out this.options 
                    // even if the configuration itself has not changed; whereas we're only calling SetConfiguration 
                    // for purposes of initializing some other fields here; since we know the config is the same, it
                    // should be perfectly safe to keep the same options as before.  
                    ProjectOptions currentOptions = this._options;
                    this.SetConfiguration(config, platform);
                    this._options = currentOptions;
                }

                return this._options;
            }

            ProjectOptions options = CreateProjectOptions();
			options.Config = config;
            options.Platform = platform;

            string targetFrameworkMoniker = GetProjectProperty("TargetFrameworkMoniker", _PersistStorageType.PST_PROJECT_FILE, false);

			if (!string.IsNullOrEmpty(targetFrameworkMoniker))
			{
				try
				{
					options.TargetFrameworkMoniker = new FrameworkName(targetFrameworkMoniker);
				}
				catch (ArgumentException e)
				{
					Trace.WriteLine("Exception : " + e.Message);
				}
			}

			if (config == null)
			{
				this._options = options;
				return options;
			}

            options.GenerateExecutable = true;

            this.SetConfiguration(config, platform);

            string outputPath = GetOutputPath(this.currentConfig);
            if (!String.IsNullOrEmpty(outputPath))
            {
                // absolutize relative to project folder location
                outputPath = Path.Combine(this.ProjectFolder, outputPath);
            }

            // Set some default values
            options.OutputAssembly = outputPath + this.Caption + ".exe";
            options.ModuleKind = ModuleKind.ConsoleApplication;

            options.RootNamespace = GetProjectProperty(ProjectFileConstants.RootNamespace, _PersistStorageType.PST_PROJECT_FILE, false);
            options.OutputAssembly = outputPath + this.GetAssemblyName(config, platform);

            string outputtype = GetProjectProperty(ProjectFileConstants.OutputType, _PersistStorageType.PST_PROJECT_FILE, false);
            if (!string.IsNullOrEmpty(outputtype))
            {
                outputtype = outputtype.ToLower(CultureInfo.InvariantCulture);
            }

            if (outputtype == "library")
            {
                options.ModuleKind = ModuleKind.DynamicallyLinkedLibrary;
                options.GenerateExecutable = false; // DLL's have no entry point.
            }
            else if (outputtype == "winexe")
                options.ModuleKind = ModuleKind.WindowsApplication;
            else
                options.ModuleKind = ModuleKind.ConsoleApplication;

            options.Win32Icon = GetProjectProperty("ApplicationIcon", _PersistStorageType.PST_PROJECT_FILE, false);
            options.MainClass = GetProjectProperty("StartupObject", _PersistStorageType.PST_PROJECT_FILE, false);

            //    other settings from CSharp we may want to adopt at some point...
            //    AssemblyKeyContainerName = ""  //This is the key file used to sign the interop assembly generated when importing a com object via add reference
            //    AssemblyOriginatorKeyFile = ""
            //    DelaySign = "false"
            //    DefaultClientScript = "JScript"
            //    DefaultHTMLPageLayout = "Grid"
            //    DefaultTargetSchema = "IE50"
            //    PreBuildEvent = ""
            //    PostBuildEvent = ""
            //    RunPostBuildEvent = "OnBuildSuccess"

            // transfer all config build options...
            if (GetBoolAttr(this.currentConfig, "AllowUnsafeBlocks"))
            {
                options.AllowUnsafeCode = true;
            }

            if (GetProjectProperty("BaseAddress", _PersistStorageType.PST_PROJECT_FILE, false) != null)
            {
                try
                {
                    options.BaseAddress = Int64.Parse(GetProjectProperty("BaseAddress", _PersistStorageType.PST_PROJECT_FILE, false), CultureInfo.InvariantCulture);
                }
                catch (ArgumentNullException e)
                {
                    Trace.WriteLine("Exception : " + e.Message);
                }
                catch (ArgumentException e)
                {
                    Trace.WriteLine("Exception : " + e.Message);
                }
                catch (FormatException e)
                {
                    Trace.WriteLine("Exception : " + e.Message);
                }
                catch (OverflowException e)
                {
                    Trace.WriteLine("Exception : " + e.Message);
                }
            }

            if (GetBoolAttr(this.currentConfig, "CheckForOverflowUnderflow"))
            {
                options.CheckedArithmetic = true;
            }

            if (GetProjectProperty("DefineConstants", _PersistStorageType.PST_PROJECT_FILE, false) != null)
            {
                options.DefinedPreprocessorSymbols = new StringCollection();
                foreach (string s in GetProjectProperty("DefineConstants", _PersistStorageType.PST_PROJECT_FILE, false).Replace(" \t\r\n", "").Split(';'))
                {
                    options.DefinedPreprocessorSymbols.Add(s);
                }
            }

            string docFile = GetProjectProperty("DocumentationFile", _PersistStorageType.PST_PROJECT_FILE, false);
            if (!String.IsNullOrEmpty(docFile))
            {
                options.XmlDocFileName = Path.Combine(this.ProjectFolder, docFile);
            }

            if (GetBoolAttr(this.currentConfig, "DebugSymbols"))
            {
                options.IncludeDebugInformation = true;
            }

            if (GetProjectProperty("FileAlignment", _PersistStorageType.PST_PROJECT_FILE, false) != null)
            {
                try
                {
                    options.FileAlignment = Int32.Parse(GetProjectProperty("FileAlignment", _PersistStorageType.PST_PROJECT_FILE, false), CultureInfo.InvariantCulture);
                }
                catch (ArgumentNullException e)
                {
                    Trace.WriteLine("Exception : " + e.Message);
                }
                catch (ArgumentException e)
                {
                    Trace.WriteLine("Exception : " + e.Message);
                }
                catch (FormatException e)
                {
                    Trace.WriteLine("Exception : " + e.Message);
                }
                catch (OverflowException e)
                {
                    Trace.WriteLine("Exception : " + e.Message);
                }
            }

            if (GetBoolAttr(this.currentConfig, "IncrementalBuild"))
            {
                options.IncrementalCompile = true;
            }

            if (GetBoolAttr(this.currentConfig, "Optimize"))
            {
                options.Optimize = true;
            }

            if (GetBoolAttr(this.currentConfig, "RegisterForComInterop"))
            {
            }

            if (GetBoolAttr(this.currentConfig, "RemoveIntegerChecks"))
            {
            }

            if (GetBoolAttr(this.currentConfig, "TreatWarningsAsErrors"))
            {
                options.TreatWarningsAsErrors = true;
            }

            if (GetProjectProperty("WarningLevel", _PersistStorageType.PST_PROJECT_FILE, false) != null)
            {
                try
                {
                    options.WarningLevel = Int32.Parse(GetProjectProperty("WarningLevel", _PersistStorageType.PST_PROJECT_FILE, false), CultureInfo.InvariantCulture);
                }
                catch (ArgumentNullException e)
                {
                    Trace.WriteLine("Exception : " + e.Message);
                }
                catch (ArgumentException e)
                {
                    Trace.WriteLine("Exception : " + e.Message);
                }
                catch (FormatException e)
                {
                    Trace.WriteLine("Exception : " + e.Message);
                }
                catch (OverflowException e)
                {
                    Trace.WriteLine("Exception : " + e.Message);
                }
            }

			this._options = options; // do this AFTER setting configuration so it doesn't clear it.
			return options;
        }

        public virtual void OnTargetFrameworkMonikerChanged(ProjectOptions options, FrameworkName currentTargetFramework, FrameworkName newTargetFramework)
        {
			if (currentTargetFramework == null)
			{
				throw new ArgumentNullException("currentTargetFramework");
			}
			if (newTargetFramework == null)
			{
				throw new ArgumentNullException("newTargetFramework");
			}

			var retargetingService = this._site.GetService(typeof(SVsTrackProjectRetargeting)) as IVsTrackProjectRetargeting;
            if (retargetingService == null)
            {
                // Probably in a unit test.
                ////throw new InvalidOperationException("Unable to acquire the SVsTrackProjectRetargeting service.");
                Marshal.ThrowExceptionForHR(UpdateTargetFramework(this.InteropSafeIVsHierarchy, currentTargetFramework.FullName, newTargetFramework.FullName));
            }
            else
            {
                Marshal.ThrowExceptionForHR(retargetingService.OnSetTargetFramework(this.InteropSafeIVsHierarchy, currentTargetFramework.FullName, newTargetFramework.FullName, this, true));
            }
		}

        [SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "Attr")]
        [SuppressMessage("Microsoft.Naming", "CA1720:IdentifiersShouldNotContainTypeNames", MessageId = "bool")]
        public virtual bool GetBoolAttr(string config, string platform, string name)
        {
            this.SetConfiguration(config, platform);
            return GetBoolAttr(this.currentConfig, name);
        }

        /// <summary>
        /// Get the assembly name for a give configuration
        /// </summary>
        /// <param name="config">the matching configuration in the msbuild file</param>
        /// <returns>assembly name</returns>
        public virtual string GetAssemblyName(string config, string platform)
        {
            this.SetConfiguration(config, platform);
            return GetAssemblyFileName(this.currentConfig);
        }

        /// <summary>
        /// Determines whether a file is a code file.
        /// </summary>
        /// <param name="fileName">Name of the file to be evaluated</param>
        /// <returns>false by default for any fileName</returns>
        public virtual bool IsCodeFile(string fileName)
        {
            return false;
        }

        /// <summary>
        /// Determines whether the given file is a resource file (resx file).
        /// </summary>
        /// <param name="fileName">Name of the file to be evaluated.</param>
        /// <returns>true if the file is a resx file, otherwise false.</returns>
        public virtual bool IsEmbeddedResource(string fileName)
        {
            if (String.Equals(Path.GetExtension(fileName), ".ResX", StringComparison.OrdinalIgnoreCase))
                return true;
            return false;
        }

        /// <summary>
        /// Create a file node based on an msbuild item.
        /// </summary>
        /// <param name="item">msbuild item</param>
        /// <returns>FileNode added</returns>
        public virtual FileNode CreateFileNode(ProjectElement item)
        {
            return new FileNode(this, item);
        }

        /// <summary>
        /// Create a file node based on a string.
        /// </summary>
        /// <param name="file">filename of the new filenode</param>
        /// <returns>File node added</returns>
        public virtual FileNode CreateFileNode(string file)
        {
            ProjectElement item = this.AddFileToMSBuild(file);
            return this.CreateFileNode(item);
        }

        /// <summary>
        /// Create dependent file node based on an msbuild item
        /// </summary>
        /// <param name="item">msbuild item</param>
        /// <returns>dependent file node</returns>
        public virtual DependentFileNode CreateDependentFileNode(ProjectElement item)
        {
            return new DependentFileNode(this, item);
        }

        /// <summary>
        /// Create a dependent file node based on a string.
        /// </summary>
        /// <param name="file">filename of the new dependent file node</param>
        /// <returns>Dependent node added</returns>
        public virtual DependentFileNode CreateDependentFileNode(string file)
        {
            ProjectElement item = this.AddFileToMSBuild(file);
            return this.CreateDependentFileNode(item);
        }

        /// <summary>
        /// Walks the subpaths of a project relative path and checks if the folder nodes hierarchy is already there, if not creates it.
        /// </summary>
        /// <param name="path">Path of the folder, can be relative to project or absolute</param>
        public virtual HierarchyNode CreateFolderNodes(string path)
        {
            return CreateFolderNodes(path, null);
        }

        public virtual HierarchyNode CreateFolderNodes(string path, IDictionary<string, HierarchyNode> nodeCache)
        {
            if (String.IsNullOrEmpty(path))
            {
                throw new ArgumentNullException("path");
            }

            if (Path.IsPathRooted(path))
            {
                // Ensure we are using a relative path
                if (String.Compare(this.ProjectFolder, 0, path, 0, this.ProjectFolder.Length, StringComparison.OrdinalIgnoreCase) != 0)
                    throw new ArgumentException("The path is not relative", "path");

                path = path.Substring(this.ProjectFolder.Length);
            }

            string[] parts;
            HierarchyNode curParent;

            parts = path.Split(Path.DirectorySeparatorChar);
            path = String.Empty;
            curParent = this;

            // now we have an array of subparts....
            for (int i = 0; i < parts.Length; i++)
            {
                if (parts[i].Length > 0)
                {
                    path += parts[i] + "\\";
                    curParent = VerifySubfolderExists(path, curParent, nodeCache);
                }
            }
            return curParent;
        }

        /// <summary>
        /// Defines if Node has Designer. By default we do not support designers for nodes
        /// </summary>
        /// <param name="itemPath">Path to item to query for designer support</param>
        /// <returns>true if node has designer</returns>
        public virtual bool NodeHasDesigner(string itemPath)
        {
            return false;
        }

        /// <summary>
        /// List of Guids of the config independent property pages. It is called by the GetProperty for VSHPROPID_PropertyPagesCLSIDList property.
        /// </summary>
        /// <returns></returns>
        protected virtual Guid[] GetConfigurationIndependentPropertyPages()
        {
            return new Guid[] { Guid.Empty };
        }

        /// <summary>
        /// Returns a list of Guids of the configuration dependent property pages. It is called by the GetProperty for VSHPROPID_CfgPropertyPagesCLSIDList property.
        /// </summary>
        /// <returns></returns>
        protected virtual Guid[] GetConfigurationDependentPropertyPages()
        {
            return new Guid[0];
        }

        /// <summary>
        /// An ordered list of guids of the prefered property pages. See <see cref="__VSHPROPID2.VSHPROPID_PriorityPropertyPagesCLSIDList"/>
        /// </summary>
        /// <returns>An array of guids.</returns>
        protected virtual Guid[] GetPriorityProjectDesignerPages()
        {
            return new Guid[] { Guid.Empty };
        }

        /// <summary>
        /// Takes a path and verifies that we have a node with that name.
        /// It is meant to be a helper method for CreateFolderNodes().
        /// For some scenario it may be useful to override.
        /// </summary>
        /// <param name="path">full path to the subfolder we want to verify.</param>
        /// <param name="parent">the parent node where to add the subfolder if it does not exist.</param>
        /// <returns>the foldernode correcsponding to the path.</returns>
        protected virtual FolderNode VerifySubfolderExists(string path, HierarchyNode parent)
        {
            return VerifySubfolderExists(path, parent, null);
        }

        protected virtual FolderNode VerifySubfolderExists(string path, HierarchyNode parent, IDictionary<string, HierarchyNode> nodeCache)
        {
            FolderNode folderNode = null;
            uint uiItemId;
            Url url = new Url(this.BaseUri, path);
            string strFullPath = url.AbsoluteUrl;

            HierarchyNode cachedNode = null;
            if (nodeCache == null || !nodeCache.TryGetValue(strFullPath, out cachedNode))
            {
                // Folders end in our storage with a backslash, so add one...
                this.ParseCanonicalName(strFullPath, out uiItemId);
                if (uiItemId != (uint)VSConstants.VSITEMID.Nil)
                {
                    Debug.Assert(this.NodeFromItemId(uiItemId) is FolderNode, "Not a FolderNode");
                    cachedNode = this.NodeFromItemId(uiItemId);
                    if (cachedNode != null && nodeCache != null)
                        nodeCache.Add(strFullPath, cachedNode);
                }
            }

            folderNode = (FolderNode)cachedNode;
            if (folderNode == null && path != null && parent != null)
            {
                // folder does not exist yet...
                // We could be in the process of loading so see if msbuild knows about it
                ProjectElement item = null;
                foreach (MSBuild.ProjectItem folder in buildProject.Items.Where(IsFolderItem))
                {
                    if (String.Equals(folder.EvaluatedInclude.TrimEnd('\\'), path.TrimEnd('\\'), StringComparison.OrdinalIgnoreCase))
                    {
                        item = new ProjectElement(this, folder, false);
                        break;
                    }
                }

                // If MSBuild did not know about it, create a new one
                if (item == null)
                    item = this.AddFolderToMSBuild(path);

                folderNode = this.CreateFolderNode(path, item);
                parent.AddChild(folderNode);
                if (nodeCache != null)
                    nodeCache.Add(strFullPath, folderNode);
            }

            return folderNode;
        }

        /// <summary>
        /// To support virtual folders, override this method to return your own folder nodes
        /// </summary>
        /// <param name="path">Path to store for this folder</param>
        /// <param name="element">Element corresponding to the folder</param>
        /// <returns>A FolderNode that can then be added to the hierarchy</returns>
        public virtual FolderNode CreateFolderNode(string path, ProjectElement element)
        {
            if (element == null)
                throw new ArgumentNullException("element");

            FolderNode folderNode = new FolderNode(this, path, element);
            return folderNode;
        }

        /// <summary>
        /// Gets the list of selected HierarchyNode objects
        /// </summary>
        /// <returns>A list of HierarchyNode objects</returns>
        public virtual IList<HierarchyNode> GetSelectedNodes()
        {
            // Retrieve shell interface in order to get current selection
            IVsMonitorSelection monitorSelection = this.GetService(typeof(IVsMonitorSelection)) as IVsMonitorSelection;

            if (monitorSelection == null)
            {
                throw new InvalidOperationException();
            }

            List<HierarchyNode> selectedNodes = new List<HierarchyNode>();
            IntPtr hierarchyPtr = IntPtr.Zero;
            IntPtr selectionContainer = IntPtr.Zero;
            try
            {
                // Get the current project hierarchy, project item, and selection container for the current selection
                // If the selection spans multiple hierachies, hierarchyPtr is Zero
                uint itemid;
                IVsMultiItemSelect multiItemSelect = null;
                ErrorHandler.ThrowOnFailure(monitorSelection.GetCurrentSelection(out hierarchyPtr, out itemid, out multiItemSelect, out selectionContainer));

                // We only care if there are one ore more nodes selected in the tree
                if (itemid != VSConstants.VSITEMID_NIL && hierarchyPtr != IntPtr.Zero)
                {
                    IVsHierarchy hierarchy = Marshal.GetObjectForIUnknown(hierarchyPtr) as IVsHierarchy;

                    if (itemid != VSConstants.VSITEMID_SELECTION)
                    {
                        // This is a single selection. Compare hirarchy with our hierarchy and get node from itemid
                        if (Utilities.IsSameComObject(this.InteropSafeIVsHierarchy, hierarchy))
                        {
                            HierarchyNode node = this.NodeFromItemId(itemid);
                            if (node != null)
                            {
                                selectedNodes.Add(node);
                            }
                        }
                        else
                        {
                            NestedProjectNode node = this.GetNestedProjectForHierarchy(hierarchy);
                            if (node != null)
                            {
                                selectedNodes.Add(node);
                            }
                        }
                    }
                    else if (multiItemSelect != null)
                    {
                        // This is a multiple item selection.

                        //Get number of items selected and also determine if the items are located in more than one hierarchy
                        uint numberOfSelectedItems;
                        int isSingleHierarchyInt;
                        ErrorHandler.ThrowOnFailure(multiItemSelect.GetSelectionInfo(out numberOfSelectedItems, out isSingleHierarchyInt));
                        bool isSingleHierarchy = (isSingleHierarchyInt != 0);

                        // Now loop all selected items and add to the list only those that are selected within this hierarchy
                        if (!isSingleHierarchy || (isSingleHierarchy && Utilities.IsSameComObject(this.InteropSafeIVsHierarchy, hierarchy)))
                        {
                            Debug.Assert(numberOfSelectedItems > 0, "Bad number of selected itemd");
                            VSITEMSELECTION[] vsItemSelections = new VSITEMSELECTION[numberOfSelectedItems];
                            uint flags = (isSingleHierarchy) ? (uint)__VSGSIFLAGS.GSI_fOmitHierPtrs : 0;
                            ErrorHandler.ThrowOnFailure(multiItemSelect.GetSelectedItems(flags, numberOfSelectedItems, vsItemSelections));
                            foreach (VSITEMSELECTION vsItemSelection in vsItemSelections)
                            {
                                if (isSingleHierarchy || Utilities.IsSameComObject(this.InteropSafeIVsHierarchy, vsItemSelection.pHier))
                                {
                                    HierarchyNode node = this.NodeFromItemId(vsItemSelection.itemid);
                                    if (node != null)
                                    {
                                        selectedNodes.Add(node);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            finally
            {
                if (hierarchyPtr != IntPtr.Zero)
                {
                    Marshal.Release(hierarchyPtr);
                }
                if (selectionContainer != IntPtr.Zero)
                {
                    Marshal.Release(selectionContainer);
                }
            }

            return selectedNodes;
        }

        /// <summary>
        /// Recursevily walks the hierarchy nodes and redraws the state icons
        /// </summary>
        public override void UpdateSccStateIcons()
        {
            if (this.FirstChild == null)
            {
                return;
            }

            for (HierarchyNode n = this.FirstChild; n != null; n = n.NextSibling)
            {
                n.UpdateSccStateIcons();
            }
        }

        public virtual void RefreshProject()
        {
            ToggleShowAllFiles();
            ToggleShowAllFiles();
        }

        /// <summary>
        /// Toggles the state of Show all files
        /// </summary>
        /// <returns>S_OK if it's possible to toggle the state, OLECMDERR_E_NOTSUPPORTED if not</returns>
        public virtual int ToggleShowAllFiles()
        {
            if (this.ProjectManager == null || this.ProjectManager.IsClosed)
            {
                return (int)OleConstants.OLECMDERR_E_NOTSUPPORTED;
            }

            //using ( WixHelperMethods.NewWaitCursor() )
            //{
            this.showAllFilesEnabled = !this.showAllFilesEnabled; // toggle the flag

            if (this.ShowAllFilesEnabled)
            {
                this.AddNonmemberItems();
            }
            else
            {
                this.RemoveNonmemberItems();
            }
            //}

            return VSConstants.S_OK;
        }

        /// <summary>
        /// Handles the Add web reference command.
        /// </summary>
        /// <returns></returns>
        public virtual int AddWebReference()
        {
            return (int)OleConstants.OLECMDERR_E_NOTSUPPORTED;
        }

        /// <summary>
        /// Unloads the project.
        /// </summary>
        /// <returns></returns>
        public virtual int UnloadProject()
        {
            return (int)OleConstants.OLECMDERR_E_NOTSUPPORTED;
        }

        /// <summary>
        /// Handles the clean project command.
        /// </summary>
        /// <returns></returns>
        protected virtual int CleanProject()
        {
            return (int)OleConstants.OLECMDERR_E_NOTSUPPORTED;
        }

        /// <summary>
        /// Reload project from project file
        /// </summary>
        protected virtual void Reload()
        {
            Debug.Assert(this.buildEngine != null, "There is no build engine defined for this project");

            try
            {
                this.disableQueryEdit = true;

                this.isClosed = false;
                this.eventTriggeringFlag = SuppressEvents.Hierarchy | SuppressEvents.Tracker;

                SetBuildProject(Utilities.ReinitializeMsBuildProject(this.buildEngine, this.FileName, this.buildProject));

                // Load the guid
                this.SetProjectGuidFromProjectFile();

                this.ProcessReferences();

                Dictionary<string, HierarchyNode> nodeCache = new Dictionary<string, HierarchyNode>(StringComparer.OrdinalIgnoreCase);

                this.ProcessFiles(nodeCache);

                this.ProcessFolders(nodeCache);

                this.LoadNonBuildInformation();

                this.InitSccInfo();

                this.RegisterSccProject();
            }
            finally
            {
                this.SetProjectFileDirty(false);
                this.eventTriggeringFlag = SuppressEvents.None;
                this.disableQueryEdit = false;
            }
        }

        /// <summary>
        /// Renames the project file
        /// </summary>
        /// <param name="newFile">The full path of the new project file.</param>
        protected virtual void RenameProjectFile(string newFile)
        {
            IVsUIShell shell = this.Site.GetService(typeof(SVsUIShell)) as IVsUIShell;
            Debug.Assert(shell != null, "Could not get the ui shell from the project");
            if (shell == null)
            {
                throw new InvalidOperationException();
            }

            // Do some name validation
            if (Microsoft.VisualStudio.Project.Utilities.ContainsInvalidFileNameChars(newFile))
            {
                throw new InvalidOperationException(SR.GetString(SR.ErrorInvalidProjectName, CultureInfo.CurrentUICulture));
            }

            // Figure out what the new full name is
            string oldFile = this.Url;

            int canContinue = 0;
            IVsSolution vsSolution = (IVsSolution)this.GetService(typeof(SVsSolution));
            if (ErrorHandler.Succeeded(vsSolution.QueryRenameProject(this.InteropSafeIVsProject3, oldFile, newFile, 0, out canContinue))
                && canContinue != 0)
            {
                bool isFileSame = NativeMethods.IsSamePath(oldFile, newFile);

                // If file already exist and is not the same file with different casing
                if (!isFileSame && File.Exists(newFile))
                {
                    // Prompt the user for replace
                    string message = SR.GetString(SR.FileAlreadyExists, newFile);

                    if (!Utilities.IsInAutomationFunction(this.Site))
                    {
                        if (!VsShellUtilities.PromptYesNo(message, null, OLEMSGICON.OLEMSGICON_WARNING, shell))
                        {
                            throw Marshal.GetExceptionForHR(VSConstants.OLE_E_PROMPTSAVECANCELLED);
                        }
                    }
                    else
                    {
                        throw new InvalidOperationException(message);
                    }

                    // Delete the destination file after making sure it is not read only
                    File.SetAttributes(newFile, FileAttributes.Normal);
                    File.Delete(newFile);
                }

                SuspendFileChanges fileChanges = new SuspendFileChanges(this.Site, this.FileName);
                fileChanges.Suspend();
                try
                {
                    // Actual file rename
                    this.SaveMSBuildProjectFileAs(newFile);

                    this.SetProjectFileDirty(false);

                    if (!isFileSame)
                    {
                        // Now that the new file name has been created delete the old one.
                        // TODO: Handle source control issues.
                        File.SetAttributes(oldFile, FileAttributes.Normal);
                        File.Delete(oldFile);
                    }

                    this.OnPropertyChanged(this, (int)__VSHPROPID.VSHPROPID_Caption, 0);

                    // Update solution
                    ErrorHandler.ThrowOnFailure(vsSolution.OnAfterRenameProject((IVsProject)this, oldFile, newFile, 0));

                    ErrorHandler.ThrowOnFailure(shell.RefreshPropertyBrowser(0));

                    ItemIdMap.UpdateAllCanonicalNames();
                }
                finally
                {
                    fileChanges.Resume();
                }
            }
            else
            {
                throw Marshal.GetExceptionForHR(VSConstants.OLE_E_PROMPTSAVECANCELLED);
            }
        }

        /// <summary>
        /// Called by the project to know if the item is a file (that is part of the project)
        /// or an intermediate file used by the MSBuild tasks/targets
        /// Override this method if your project has more types or different ones
        /// </summary>
        /// <param name="type">Type name</param>
        /// <returns>True = items of this type should be included in the project</returns>
        protected virtual bool IsItemTypeFileType(string type)
        {
            return _availableFileBuildActions.Any(i => string.Equals(i.Key, type, StringComparison.OrdinalIgnoreCase));
        }

        /// <summary>
        /// Filter items that should not be processed as file items. Example: Folders and References.
        /// </summary>
        protected virtual bool FilterItemTypeToBeAddedToHierarchy(string itemType)
        {
            return (String.Equals(itemType, ProjectFileConstants.Reference, StringComparison.OrdinalIgnoreCase)
                    || String.Equals(itemType, ProjectFileConstants.ProjectReference, StringComparison.OrdinalIgnoreCase)
                    || String.Equals(itemType, ProjectFileConstants.COMReference, StringComparison.OrdinalIgnoreCase)
                    || String.Equals(itemType, ProjectFileConstants.Folder, StringComparison.OrdinalIgnoreCase)
                    || String.Equals(itemType, ProjectFileConstants.WebReference, StringComparison.OrdinalIgnoreCase)
                    || String.Equals(itemType, ProjectFileConstants.WebReferenceFolder, StringComparison.OrdinalIgnoreCase));
        }

        /// <summary>
        /// Associate window output pane to the build logger
        /// </summary>
        /// <param name="output"></param>
        protected virtual void SetOutputLogger(IVsOutputWindowPane output)
        {
            // Create our logger, if it was not specified
            if (!this.useProvidedLogger || this.buildLogger == null)
            {
                // Because we may be aggregated, we need to make sure to get the outer IVsHierarchy
                IntPtr unknown = IntPtr.Zero;
                IVsHierarchy hierarchy = null;
                try
                {
                    unknown = Marshal.GetIUnknownForObject(this);
                    hierarchy = Marshal.GetTypedObjectForIUnknown(unknown, typeof(IVsHierarchy)) as IVsHierarchy;
                }
                finally
                {
                    if (unknown != IntPtr.Zero)
                        Marshal.Release(unknown);
                }
                // Create the logger
                this.BuildLogger = new IdeBuildLogger(output, this.TaskProvider, hierarchy);

                // To retrive the verbosity level, the build logger depends on the registry root 
                // (otherwise it will used an hardcoded default)
                ILocalRegistry2 registry = this.GetService(typeof(SLocalRegistry)) as ILocalRegistry2;
                if (null != registry)
                {
                    string registryRoot;
                    ErrorHandler.ThrowOnFailure(registry.GetLocalRegistryRoot(out registryRoot));
                    IdeBuildLogger logger = this.BuildLogger as IdeBuildLogger;
                    if (!String.IsNullOrEmpty(registryRoot) && (null != logger))
                    {
                        logger.BuildVerbosityRegistryRoot = registryRoot;
                        logger.ErrorString = this.ErrorString;
                        logger.WarningString = this.WarningString;
                    }
                }
            }
            else
            {
                ((IdeBuildLogger)this.BuildLogger).OutputWindowPane = output;
            }
        }

        /// <summary>
        /// Set configuration properties for a specific configuration
        /// </summary>
        /// <param name="config">configuration name</param>
        protected virtual void SetBuildConfigurationProperties(string config, string platform)
        {
            ProjectOptions options = null;

            if (!string.IsNullOrEmpty(config) && !string.IsNullOrEmpty(platform))
            {
                options = this.GetProjectOptions(config, platform);
            }

            if (options != null && this.buildProject != null)
            {
                // Make sure the project configuration is set properly
                this.SetConfiguration(config, platform);
            }
        }

        /// <summary>
        /// This execute an MSBuild target for a design-time build.
        /// </summary>
        /// <param name="target">Name of the MSBuild target to execute</param>
        /// <returns>Result from executing the target (success/failure)</returns>
        /// <remarks>
        /// If you depend on the items/properties generated by the target
        /// you should be aware that any call to BuildTarget on any project
        /// will reset the list of generated items/properties
        /// </remarks>
        protected virtual MSBuildResult InvokeMSBuild(string target)
        {
            MSBuildResult result = MSBuildResult.Failed;
            const bool designTime = true;
            bool requiresUIThread = UIThread.Instance.IsUIThread; // we don't run tasks that require calling the STA thread, so unless we're ON it, we don't need it.

            IVsBuildManagerAccessor accessor = this.Site.GetService(typeof(SVsBuildManagerAccessor)) as IVsBuildManagerAccessor;
            BuildSubmission submission = null;

            if (this.buildProject != null)
            {
                if (!TryBeginBuild(designTime, requiresUIThread))
                {
                    throw new InvalidOperationException("A build is already in progress.");
                }

                try
                {
                    // Do the actual Build
                    string[] targetsToBuild = new string[target != null ? 1 : 0];
                    if (target != null)
                    {
                        targetsToBuild[0] = target;
                    }

                    currentConfig = BuildProject.CreateProjectInstance();

                    BuildRequestData requestData = new BuildRequestData(currentConfig, targetsToBuild, this.BuildProject.ProjectCollection.HostServices, BuildRequestDataFlags.ReplaceExistingProjectInstance);
                    submission = BuildManager.DefaultBuildManager.PendBuildRequest(requestData);
                    if (accessor != null)
                    {
                        ErrorHandler.ThrowOnFailure(accessor.RegisterLogger(submission.SubmissionId, this.buildLogger));
                    }

                    BuildResult buildResult = submission.Execute();

                    result = (buildResult.OverallResult == BuildResultCode.Success) ? MSBuildResult.Successful : MSBuildResult.Failed;
                }
                finally
                {
                    EndBuild(submission, designTime, requiresUIThread);
                }
            }

            return result;
        }

        /// <summary>
        /// Start MSBuild build submission
        /// </summary>
        /// If buildKind is ASync, this method starts the submission and returns. uiThreadCallback will be called on UI thread once submissions completes.
        /// if buildKind is Sync, this method executes the submission and runs uiThreadCallback
        /// <param name="buildKind">Is it a Sync or ASync build</param>
        /// <param name="target">target to build</param>
        /// <param name="uiThreadCallback">callback to be run UI thread </param>
        /// <returns>A Build submission instance.</returns>
        protected virtual BuildSubmission DoMSBuildSubmission(BuildKind buildKind, string target, Action<MSBuildResult, string> uiThreadCallback)
        {
            const bool designTime = false;
            bool requiresUIThread = buildKind == BuildKind.Sync && UIThread.Instance.IsUIThread; // we don't run tasks that require calling the STA thread, so unless we're ON it, we don't need it.

            IVsBuildManagerAccessor accessor = (IVsBuildManagerAccessor)this.Site.GetService(typeof(SVsBuildManagerAccessor));
            if (accessor == null)
            {
                throw new InvalidOperationException();
            }

            if (!TryBeginBuild(designTime, requiresUIThread))
            {
                if (uiThreadCallback != null)
                {
                    uiThreadCallback(MSBuildResult.Failed, target);
                }

                return null;
            }

            string[] targetsToBuild = new string[target != null ? 1 : 0];
            if (target != null)
            {
                targetsToBuild[0] = target;
            }

            MSBuildExecution.ProjectInstance projectInstance = BuildProject.CreateProjectInstance();

            projectInstance.SetProperty(GlobalProperty.VisualStudioStyleErrors.ToString(), "true");
            projectInstance.SetProperty("UTFOutput", "true");
            projectInstance.SetProperty(GlobalProperty.BuildingInsideVisualStudio.ToString(), "true");

            this.BuildProject.ProjectCollection.HostServices.SetNodeAffinity(projectInstance.FullPath, NodeAffinity.InProc);
            BuildRequestData requestData = new BuildRequestData(projectInstance, targetsToBuild, this.BuildProject.ProjectCollection.HostServices, BuildRequestDataFlags.ReplaceExistingProjectInstance);
            BuildSubmission submission = BuildManager.DefaultBuildManager.PendBuildRequest(requestData);
            try
            {
                if (useProvidedLogger && buildLogger != null)
                {
                    ErrorHandler.ThrowOnFailure(accessor.RegisterLogger(submission.SubmissionId, buildLogger));
                }

                if (buildKind == BuildKind.Async)
                {
                    submission.ExecuteAsync(sub =>
                    {
                        UIThread.Instance.Run(() =>
                        {
                            this.FlushBuildLoggerContent();
                            EndBuild(sub, designTime, requiresUIThread);
                            uiThreadCallback((sub.BuildResult.OverallResult == BuildResultCode.Success) ? MSBuildResult.Successful : MSBuildResult.Failed, target);
                        });
                    }, null);
                }
                else
                {
                    submission.Execute();
                    EndBuild(submission, designTime, requiresUIThread);
                    MSBuildResult msbuildResult = (submission.BuildResult.OverallResult == BuildResultCode.Success) ? MSBuildResult.Successful : MSBuildResult.Failed;
                    if (uiThreadCallback != null)
                    {
                        uiThreadCallback(msbuildResult, target);
                    }
                }
            }
            catch (Exception e)
            {
                Debug.Fail(e.ToString());
                EndBuild(submission, designTime, requiresUIThread);
                if (uiThreadCallback != null)
                {
                    uiThreadCallback(MSBuildResult.Failed, target);
                }

                throw;
            }

            return submission;
        }

        /// <summary>
        /// Initialize common project properties with default value if they are empty
        /// </summary>
        /// <remarks>The following common project properties are defaulted to projectName (if empty):
        ///    AssemblyName, Name and RootNamespace.
        /// If the project filename is not set then no properties are set</remarks>
        protected virtual void InitializeProjectProperties()
        {
            // Get projectName from project filename. Return if not set
            string projectName = Path.GetFileNameWithoutExtension(this.FileName);
            if (String.IsNullOrEmpty(projectName))
            {
                return;
            }

            if (String.IsNullOrEmpty(GetProjectProperty(ProjectFileConstants.AssemblyName, _PersistStorageType.PST_PROJECT_FILE)))
            {
                SetProjectProperty(ProjectFileConstants.AssemblyName, _PersistStorageType.PST_PROJECT_FILE, projectName);
            }
            if (String.IsNullOrEmpty(GetProjectProperty(ProjectFileConstants.Name, _PersistStorageType.PST_PROJECT_FILE)))
            {
                SetProjectProperty(ProjectFileConstants.Name, _PersistStorageType.PST_PROJECT_FILE, projectName);
            }
            if (String.IsNullOrEmpty(GetProjectProperty(ProjectFileConstants.RootNamespace, _PersistStorageType.PST_PROJECT_FILE)))
            {
                SetProjectProperty(ProjectFileConstants.RootNamespace, _PersistStorageType.PST_PROJECT_FILE, projectName);
            }
        }

        /// <summary>
        /// Factory method for configuration provider
        /// </summary>
        /// <returns>Non-null configuration provider created</returns>
        protected virtual ConfigProvider CreateConfigProvider()
        {
            return new ConfigProvider(this);
        }

        /// <summary>
        /// Factory method for reference container node
        /// </summary>
        /// <returns>ReferenceContainerNode created</returns>
        protected virtual ReferenceContainerNode CreateReferenceContainerNode()
        {
            return new ReferenceContainerNode(this);
        }

        /// <summary>
        /// Saves the project file on a new name.
        /// </summary>
        /// <param name="newFileName">The new name of the project file.</param>
        /// <returns>Success value or an error code.</returns>
        protected virtual int SaveAs(string newFileName)
        {
            Debug.Assert(!String.IsNullOrEmpty(newFileName), "Cannot save project file for an empty or null file name");
            if (String.IsNullOrEmpty(newFileName))
            {
                throw new ArgumentNullException("newFileName");
            }

            newFileName = newFileName.Trim();

            string errorMessage = String.Empty;

            if (newFileName.Length > NativeMethods.MAX_PATH)
            {
                errorMessage = String.Format(CultureInfo.CurrentCulture, SR.GetString(SR.PathTooLong, CultureInfo.CurrentUICulture), newFileName);
            }
            else
            {
                string fileName = String.Empty;

                try
                {
                    fileName = Path.GetFileNameWithoutExtension(newFileName);
                }
                // We want to be consistent in the error message and exception we throw. fileName could be for example #¤&%"¤&"%  and that would trigger an ArgumentException on Path.IsRooted.
                catch (ArgumentException)
                {
                    errorMessage = SR.GetString(SR.ErrorInvalidFileName, CultureInfo.CurrentUICulture);
                }

                if (errorMessage.Length == 0)
                {
                    // If there is no filename or it starts with a leading dot issue an error message and quit.
                    // For some reason the save as dialog box allows to save files like "......ext"
                    if (String.IsNullOrEmpty(fileName) || fileName[0] == '.')
                    {
                        errorMessage = SR.GetString(SR.FileNameCannotContainALeadingPeriod, CultureInfo.CurrentUICulture);
                    }
                    else if (Utilities.ContainsInvalidFileNameChars(newFileName))
                    {
                        errorMessage = SR.GetString(SR.ErrorInvalidFileName, CultureInfo.CurrentUICulture);
                    }
                    else
                    {
                        string url = Path.GetDirectoryName(newFileName);
                        string oldUrl = Path.GetDirectoryName(this.Url);

                        if (!NativeMethods.IsSamePath(oldUrl, url))
                        {
                            errorMessage = String.Format(CultureInfo.CurrentCulture, SR.GetString(SR.SaveOfProjectFileOutsideCurrentDirectory, CultureInfo.CurrentUICulture), this.ProjectFolder);
                        }
                    }
                }
            }
            if (errorMessage.Length > 0)
            {
                // If it is not called from an automation method show a dialog box.
                if (!Utilities.IsInAutomationFunction(this.Site))
                {
                    string title = null;
                    OLEMSGICON icon = OLEMSGICON.OLEMSGICON_CRITICAL;
                    OLEMSGBUTTON buttons = OLEMSGBUTTON.OLEMSGBUTTON_OK;
                    OLEMSGDEFBUTTON defaultButton = OLEMSGDEFBUTTON.OLEMSGDEFBUTTON_FIRST;
                    VsShellUtilities.ShowMessageBox(this.Site, title, errorMessage, icon, buttons, defaultButton);
                    return VSConstants.OLE_E_PROMPTSAVECANCELLED;
                }

                throw new InvalidOperationException(errorMessage);
            }

            string oldName = this.FileName;

            IVsSolution solution = this.Site.GetService(typeof(IVsSolution)) as IVsSolution;
            Debug.Assert(solution != null, "Could not retrieve the solution form the service provider");
            if (solution == null)
            {
                throw new InvalidOperationException();
            }

            int canRenameContinue = 0;
            ErrorHandler.ThrowOnFailure(solution.QueryRenameProject(this.InteropSafeIVsProject3, this.FileName, newFileName, 0, out canRenameContinue));

            if (canRenameContinue == 0)
            {
                return VSConstants.OLE_E_PROMPTSAVECANCELLED;
            }

            SuspendFileChanges fileChanges = new SuspendFileChanges(this.Site, oldName);
            fileChanges.Suspend();
            try
            {
                // Save the project file and project file related properties.
                this.SaveMSBuildProjectFileAs(newFileName);

                this.SetProjectFileDirty(false);


                // TODO: If source control is enabled check out the project file.

                //Redraw.
                this.OnPropertyChanged(this, (int)__VSHPROPID.VSHPROPID_Caption, 0);

                ErrorHandler.ThrowOnFailure(solution.OnAfterRenameProject(this.InteropSafeIVsProject3, oldName, this.FileName, 0));

                IVsUIShell shell = this.Site.GetService(typeof(SVsUIShell)) as IVsUIShell;
                Debug.Assert(shell != null, "Could not get the ui shell from the project");
                if (shell == null)
                {
                    throw new InvalidOperationException();
                }

                ErrorHandler.ThrowOnFailure(shell.RefreshPropertyBrowser(0));
                ItemIdMap.UpdateAllCanonicalNames();
            }
            finally
            {
                fileChanges.Resume();
            }

            return VSConstants.S_OK;
        }

        /// <summary>
        /// Saves project file related information to the new file name. It also calls msbuild API to save the project file.
        /// It is called by the SaveAs method and the SetEditLabel before the project file rename related events are triggered. 
        /// An implementer can override this method to provide specialized semantics on how the project file is renamed in the msbuild file.
        /// </summary>
        /// <param name="newFileName">The new full path of the project file</param>
        protected virtual void SaveMSBuildProjectFileAs(string newFileName)
        {
            Debug.Assert(!String.IsNullOrEmpty(newFileName), "Cannot save project file for an empty or null file name");

            this.buildProject.FullPath = newFileName;
            this.baseUri = null;

            this.FileName = newFileName;

            string newFileNameWithoutExtension = Path.GetFileNameWithoutExtension(newFileName);

            // Refresh solution explorer
            this.SetProjectProperty(ProjectFileConstants.Name, _PersistStorageType.PST_PROJECT_FILE, newFileNameWithoutExtension);

            // Saves the project file on disk.
            this.buildProject.Save(newFileName);

            if (_userBuildProject != null)
                _userBuildProject.Save(UserFileName);
        }

        /// <summary>
        /// Adds a file to the msbuild project.
        /// </summary>
        /// <param name="file">The file to be added.</param>
        /// <returns>A non-null ProjectElement describing the newly added file.</returns>
        public virtual ProjectElement AddFileToMSBuild(string file)
        {
            if (file == null)
                throw new ArgumentNullException("file");
            if (string.IsNullOrEmpty(file))
                throw new ArgumentException("file cannot be null or empty");

            string itemPath = PackageUtilities.MakeRelativeIfRooted(file, this.BaseUri);
            Debug.Assert(!Path.IsPathRooted(itemPath), "Cannot add item with full path.");

            ProjectElement newItem;

            if (this.IsCodeFile(itemPath))
            {
                newItem = AddFileToMSBuild(file, ProjectFileConstants.Compile, ProjectFileAttributeValue.Code);
            }
            else if (this.IsEmbeddedResource(itemPath))
            {
                newItem = AddFileToMSBuild(file, ProjectFileConstants.EmbeddedResource, null);
            }
            else
            {
                newItem = AddFileToMSBuild(file, ProjectFileConstants.Content, ProjectFileConstants.Content);
            }

            return newItem;
        }

        /// <summary>
        /// Adds a file to the msbuild project.
        /// </summary>
        /// <param name="file">The file to be added.</param>
        /// <returns>A non-null ProjectElement describing the newly added file.</returns>
        public virtual ProjectElement AddFileToMSBuild(string file, string itemType, string subtype)
        {
            if (file == null)
                throw new ArgumentNullException("file");
            if (itemType == null)
                throw new ArgumentNullException("itemType");
            if (string.IsNullOrEmpty(file))
                throw new ArgumentException("file cannot be null or empty");
            if (string.IsNullOrEmpty(itemType))
                throw new ArgumentException("itemType cannot be null or empty");

            string itemPath = PackageUtilities.MakeRelativeIfRooted(file, this.BaseUri);
            Debug.Assert(!Path.IsPathRooted(itemPath), "Cannot add item with full path.");

            ProjectElement newItem = this.CreateMSBuildFileItem(itemPath, itemType);
            if (!string.IsNullOrEmpty(subtype))
                newItem.SetMetadata(ProjectFileConstants.SubType, subtype);

            return newItem;
        }

        /// <summary>
        /// Adds a folder to the msbuild project.
        /// </summary>
        /// <param name="folder">The folder to be added.</param>
        /// <returns>A non-null ProjectElement describing the newly added folder.</returns>
        protected virtual ProjectElement AddFolderToMSBuild(string folder)
        {
            if (folder == null)
                throw new ArgumentNullException("folder");
            if (string.IsNullOrEmpty(folder))
                throw new ArgumentException("folder cannot be null or empty");

            return AddFolderToMSBuild(folder, ProjectFileConstants.Folder);
        }

        /// <summary>
        /// Adds a folder to the msbuild project.
        /// </summary>
        /// <param name="folder">The folder to be added.</param>
        /// <returns>A non-null ProjectElement describing the newly added folder.</returns>
        protected virtual ProjectElement AddFolderToMSBuild(string folder, string itemType)
        {
            if (folder == null)
                throw new ArgumentNullException("folder");
            if (itemType == null)
                throw new ArgumentNullException("itemType");
            if (string.IsNullOrEmpty(folder))
                throw new ArgumentException("folder cannot be null or empty");
            if (string.IsNullOrEmpty(itemType))
                throw new ArgumentException("itemType cannot be null or empty");

            string itemPath = PackageUtilities.MakeRelativeIfRooted(folder, this.BaseUri);
            Debug.Assert(!Path.IsPathRooted(itemPath), "Cannot add item with full path.");

            ProjectElement newItem = this.CreateMSBuildFileItem(itemPath, itemType);

            return newItem;
        }

        /// <summary>
        /// Determines whether an item can be owerwritten in the hierarchy.
        /// </summary>
        /// <param name="originalFileName">The orginal filname.</param>
        /// <param name="computedNewFileName">The computed new file name, that will be copied to the project directory or into the folder .</param>
        /// <returns>S_OK for success, or an error message</returns>
        protected virtual int CanOverwriteExistingItem(string originalFileName, string computedNewFileName)
        {
            if (String.IsNullOrEmpty(originalFileName) || String.IsNullOrEmpty(computedNewFileName))
            {
                return VSConstants.E_INVALIDARG;
            }

            string message = String.Empty;
            string title = String.Empty;
            OLEMSGICON icon = OLEMSGICON.OLEMSGICON_CRITICAL;
            OLEMSGBUTTON buttons = OLEMSGBUTTON.OLEMSGBUTTON_OK;
            OLEMSGDEFBUTTON defaultButton = OLEMSGDEFBUTTON.OLEMSGDEFBUTTON_FIRST;

            // If the document is open then return error message.
            IVsUIHierarchy hier;
            IVsWindowFrame windowFrame;
            uint itemid = VSConstants.VSITEMID_NIL;

            bool isOpen = VsShellUtilities.IsDocumentOpen(this.Site, computedNewFileName, Guid.Empty, out hier, out itemid, out windowFrame);

            if (isOpen)
            {
                message = String.Format(CultureInfo.CurrentCulture, SR.GetString(SR.CannotAddFileThatIsOpenInEditor, CultureInfo.CurrentUICulture), Path.GetFileName(computedNewFileName));
                VsShellUtilities.ShowMessageBox(this.Site, title, message, icon, buttons, defaultButton);
                return VSConstants.E_ABORT;
            }


            // File already exists in project... message box
            message = SR.GetString(SR.FileAlreadyInProject, CultureInfo.CurrentUICulture);
            icon = OLEMSGICON.OLEMSGICON_QUERY;
            buttons = OLEMSGBUTTON.OLEMSGBUTTON_YESNO;
            int msgboxResult = VsShellUtilities.ShowMessageBox(this.Site, title, message, icon, buttons, defaultButton);
            if (msgboxResult != DialogResult.Yes)
            {
                return (int)OleConstants.OLECMDERR_E_CANCELED;
            }

            return VSConstants.S_OK;
        }

        /// <summary>
        /// Handle owerwriting of an existing item in the hierarchy.
        /// </summary>
        /// <param name="existingNode">The node that exists.</param>
        protected virtual void OverwriteExistingItem(HierarchyNode existingNode)
        {

        }

        /// <summary>
        /// Adds a new file node to the hierarchy.
        /// </summary>
        /// <param name="parentNode">The parent of the new fileNode</param>
        /// <param name="fileName">The file name</param>
        protected virtual void AddNewFileNodeToHierarchy(HierarchyNode parentNode, string fileName, string linkPath)
        {
            if (parentNode == null)
            {
                throw new ArgumentNullException("parentNode");
            }

            HierarchyNode child;

            // In the case of subitem, we want to create dependent file node
            // and set the DependentUpon property
            if (this.canFileNodesHaveChilds && (parentNode is FileNode || parentNode is DependentFileNode))
            {
                child = this.CreateDependentFileNode(fileName);
                child.ItemNode.SetMetadata(ProjectFileConstants.DependentUpon, parentNode.ItemNode.GetMetadata(ProjectFileConstants.Include));

                // Make sure to set the HasNameRelation flag on the dependent node if it is related to the parent by name
                if (!child.HasParentNodeNameRelation && string.Equals(child.GetRelationalName(), parentNode.GetRelationalName(), StringComparison.OrdinalIgnoreCase))
                {
                    child.HasParentNodeNameRelation = true;
                }
            }
            else
            {
                //Create and add new filenode to the project
                child = this.CreateFileNode(fileName);
                child.ItemNode.SetMetadata(ProjectFileConstants.Link, linkPath);
            }

            parentNode.AddChild(child);

            // TODO : Revisit the VSADDFILEFLAGS here. Can it be a nested project?
            this.tracker.OnItemAdded(fileName, VSADDFILEFLAGS.VSADDFILEFLAGS_NoFlags);
        }

        /// <summary>
        /// Defines whther the current mode of the project is in a supress command mode.
        /// </summary>
        /// <returns></returns>
        public virtual bool IsCurrentStateASuppressCommandsMode()
        {
            if (VsShellUtilities.IsSolutionBuilding(this.Site))
            {
                return true;
            }

            DBGMODE dbgMode = VsShellUtilities.GetDebugMode(this.Site) & ~DBGMODE.DBGMODE_EncMask;
            if (dbgMode == DBGMODE.DBGMODE_Run || dbgMode == DBGMODE.DBGMODE_Break)
            {
                return true;
            }

            return false;

        }


        /// <summary>
        /// This is the list of output groups that the configuration object should
        /// provide.
        /// The first string is the name of the group.
        /// The second string is the target name (MSBuild) for that group.
        /// 
        /// To add/remove OutputGroups, simply override this method and edit the list.
        /// 
        /// To get nice display names and description for your groups, override:
        ///        - GetOutputGroupDisplayName
        ///        - GetOutputGroupDescription
        /// </summary>
        /// <returns>List of output group name and corresponding MSBuild target</returns>
        public virtual IList<KeyValuePair<string, string>> GetOutputGroupNames()
        {
            return new List<KeyValuePair<string, string>>(outputGroupNames);
        }

        /// <summary>
        /// Get the display name of the given output group.
        /// </summary>
        /// <param name="canonicalName">Canonical name of the output group</param>
        /// <returns>Display name</returns>
        public virtual string GetOutputGroupDisplayName(string canonicalName)
        {
            string result = SR.GetString(String.Format(CultureInfo.InvariantCulture, "Output{0}", canonicalName), CultureInfo.CurrentUICulture);
            if (String.IsNullOrEmpty(result))
                result = canonicalName;
            return result;
        }

        /// <summary>
        /// Get the description of the given output group.
        /// </summary>
        /// <param name="canonicalName">Canonical name of the output group</param>
        /// <returns>Description</returns>
        public virtual string GetOutputGroupDescription(string canonicalName)
        {
            string result = SR.GetString(String.Format(CultureInfo.InvariantCulture, "Output{0}Description", canonicalName), CultureInfo.CurrentUICulture);
            if (String.IsNullOrEmpty(result))
                result = canonicalName;
            return result;
        }

        /// <summary>
        /// Set the configuration in MSBuild.
        /// This does not get persisted and is used to evaluate msbuild conditions
        /// which are based on the $(Configuration) property.
        /// </summary>
        public virtual void SetCurrentConfiguration()
        {
            if (this.BuildInProgress)
            {
                // we are building so this should already be the current configuration
                return;
            }

            // Can't ask for the active config until the project is opened, so do nothing in that scenario
            if (!this.projectOpened)
                return;

            EnvDTE.Project automationObject = this.GetAutomationObject() as EnvDTE.Project;

            this.SetConfiguration(Utilities.GetActiveConfigurationName(automationObject), Utilities.GetActivePlatformName(automationObject));
        }

        /// <summary>
        /// Set the configuration property in MSBuild.
        /// This does not get persisted and is used to evaluate msbuild conditions
        /// which are based on the $(Configuration) property.
        /// </summary>
        /// <param name="config">Configuration name</param>
        public virtual void SetConfiguration(string config, string platform)
        {
            if (config == null)
                throw new ArgumentNullException("config");
            if (platform == null)
                throw new ArgumentNullException("platform");

            // Can't ask for the active config until the project is opened, so do nothing in that scenario
            if (!projectOpened)
                return;

            // We cannot change properties during the build so if the config
            // we want to set is the current, we do nothing otherwise we fail.
            if (this.BuildInProgress)
            {
                EnvDTE.Project automationObject = this.GetAutomationObject() as EnvDTE.Project;
                string currentConfigName = Utilities.GetActiveConfigurationName(automationObject);
                string currentPlatformName = Utilities.GetActivePlatformName(automationObject);
                bool configsAreEqual =
                    string.Equals(currentConfigName, config, StringComparison.OrdinalIgnoreCase)
                    && string.Equals(currentPlatformName, platform, StringComparison.OrdinalIgnoreCase);

                if (configsAreEqual)
                {
                    return;
                }

                throw new InvalidOperationException("Cannot change configurations during a build.");
            }

            bool propertiesChanged = this.buildProject.SetGlobalProperty(ProjectFileConstants.Configuration, config);
            propertiesChanged |= this.buildProject.SetGlobalProperty(ProjectFileConstants.Platform, ConfigProvider.GetPlatformPropertyFromPlatformName(platform));

            var userBuildProject = UserBuildProject;
            if (userBuildProject != null)
            {
                propertiesChanged |= userBuildProject.SetGlobalProperty(ProjectFileConstants.Configuration, config);
                propertiesChanged |= userBuildProject.SetGlobalProperty(ProjectFileConstants.Platform, ConfigProvider.GetPlatformPropertyFromPlatformName(platform));
            }

            if (this.currentConfig == null || propertiesChanged)
            {
                this.currentConfig = this.buildProject.CreateProjectInstance();
            }

			if (propertiesChanged || (this.designTimeAssemblyResolution == null && !this.designTimeAssemblyResolutionFailed))
			{
				this.designTimeAssemblyResolutionFailed = false;

				if (this.designTimeAssemblyResolution == null)
				{
					this.designTimeAssemblyResolution = new DesignTimeAssemblyResolution();
				}

				try
				{
					this.designTimeAssemblyResolution.Initialize(this);
				}
				catch (InvalidOperationException)
				{
					this.designTimeAssemblyResolution = null;
					this.designTimeAssemblyResolutionFailed = true;
				}
			}

            this._options = null;
        }

        /// <summary>
        /// Loads reference items from the project file into the hierarchy.
        /// </summary>
        public virtual void ProcessReferences()
        {
            IReferenceContainer container = GetReferenceContainer();
            if (null == container)
            {
                // Process References
                ReferenceContainerNode referencesFolder = CreateReferenceContainerNode();
                if (null == referencesFolder)
                {
                    // This project type does not support references or there is a problem
                    // creating the reference container node.
                    // In both cases there is no point to try to process references, so exit.
                    return;
                }
                this.AddChild(referencesFolder);
                container = referencesFolder;
            }

            // Load the referernces.
            container.LoadReferencesFromBuildProject(buildProject);
        }

        /// <summary>
        /// Loads folders from the project file into the hierarchy.
        /// </summary>
        public virtual void ProcessFolders(IDictionary<string, HierarchyNode> nodeCache)
        {
            // Process Folders (useful to persist empty folder)
            foreach (MSBuild.ProjectItem folder in this.buildProject.Items.Where(IsFolderItem).ToArray())
            {
                string strPath = folder.EvaluatedInclude;

                // We do not need any special logic for assuring that a folder is only added once to the ui hierarchy.
                // The below method will only add once the folder to the ui hierarchy
                this.CreateFolderNodes(strPath, nodeCache);
            }
        }

        /// <summary>
        /// Loads file items from the project file into the hierarchy.
        /// </summary>
        public virtual void ProcessFiles(IDictionary<string, HierarchyNode> nodeCache)
        {
            List<String> subitemsKeys = new List<String>();
            Dictionary<String, MSBuild.ProjectItem> subitems = new Dictionary<String, MSBuild.ProjectItem>();

            // Define a set for our build items. The value does not really matter here.
            Dictionary<String, MSBuild.ProjectItem> items = new Dictionary<String, MSBuild.ProjectItem>();

            // Process Files
            foreach (MSBuild.ProjectItem item in this.buildProject.Items.ToArray())
            {
                // Ignore the item if it is a reference or folder
                if (this.FilterItemTypeToBeAddedToHierarchy(item.ItemType))
                    continue;

                // MSBuilds tasks/targets can create items (such as object files),
                // such items are not part of the project per say, and should not be displayed.
                // so ignore those items.
                if (!this.IsItemTypeFileType(item.ItemType))
                    continue;

                // If the item is already contained do nothing.
                // TODO: possibly report in the error list that the the item is already contained in the project file similar to Language projects.
                if (items.ContainsKey(item.EvaluatedInclude.ToUpperInvariant()))
                    continue;

                // Make sure that we do not want to add the item, dependent, or independent twice to the ui hierarchy
                items.Add(item.EvaluatedInclude.ToUpperInvariant(), item);

                string dependentOf = item.GetMetadataValue(ProjectFileConstants.DependentUpon);

                if (!this.CanFileNodesHaveChilds || String.IsNullOrEmpty(dependentOf))
                {
                    AddIndependentFileNode(item, nodeCache);
                }
                else
                {
                    // We will process dependent items later.
                    // Note that we use 2 lists as we want to remove elements from
                    // the collection as we loop through it
                    subitemsKeys.Add(item.EvaluatedInclude);
                    subitems.Add(item.EvaluatedInclude, item);
                }
            }

            // Now process the dependent items.
            if (this.CanFileNodesHaveChilds)
            {
                ProcessDependentFileNodes(subitemsKeys, subitems, nodeCache);
            }

        }

        /// <summary>
        /// Processes dependent filenodes from list of subitems. Multi level supported, but not circular dependencies.
        /// </summary>
        /// <param name="subitemsKeys">List of sub item keys </param>
        /// <param name="subitems"></param>
        public virtual void ProcessDependentFileNodes(IList<String> subitemsKeys, Dictionary<String, MSBuild.ProjectItem> subitems, IDictionary<string, HierarchyNode> nodeCache)
        {
            if (subitemsKeys == null || subitems == null)
            {
                return;
            }

            foreach (string key in subitemsKeys)
            {
                // A previous pass could have removed the key so make sure it still needs to be added
                if (!subitems.ContainsKey(key))
                    continue;

                AddDependentFileNode(subitems, key, nodeCache);
            }
        }

        /// <summary>
        /// For flavored projects which implement IPersistXMLFragment, load the information now
        /// </summary>
        public virtual void LoadNonBuildInformation()
        {
            IPersistXMLFragment outerHierarchy = this.InteropSafeIVsHierarchy as IPersistXMLFragment;
            if (outerHierarchy != null)
            {
                this.LoadXmlFragment(outerHierarchy, null);
            }
        }

        /// <summary>
        /// Used to sort nodes in the hierarchy.
        /// <note type="caller">
        /// This method returns inverted values when compared to other compare operations such as <see cref="Comparer{T}.Compare"/>.
        /// </note>
        /// </summary>
        /// <param name="node1">The first hierarchy node.</param>
        /// <param name="node2">The second hierarchy node.</param>
        /// <returns>
        /// A signed integer indicating the relative position of <paramref name="node1"/> and <paramref name="node2"/>, as shown in the following table.
        /// <list type="table">
        /// <listheader>
        /// <term>Value</term>
        /// <term>Meaning</term>
        /// </listheader>
        /// <item>
        /// <description>Less than zero</description>
        /// <description><paramref name="node1"/> appears after <paramref name="node2"/>.</description>
        /// </item>
        /// <item>
        /// <description>Zero</description>
        /// <description><paramref name="node1"/> is unordered with respect to <paramref name="node2"/>.</description>
        /// </item>
        /// <item>
        /// <description>Greater than zero</description>
        /// <description><paramref name="node1"/> appears before <paramref name="node2"/>.</description>
        /// </item>
        /// </list>
        /// </returns>
        /// <exception cref="ArgumentNullException">
        /// If <paramref name="node1"/> is <see langword="null"/>.
        /// <para>-or-</para>
        /// <para>If <paramref name="node2"/> is <see langword="null"/>.</para>
        /// </exception>
        public virtual int CompareNodes(HierarchyNode node1, HierarchyNode node2)
        {
            Debug.Assert(node1 != null && node2 != null);
            if (node1 == null)
            {
                throw new ArgumentNullException("node1");
            }

            if (node2 == null)
            {
                throw new ArgumentNullException("node2");
            }

            if (node1.SortPriority == node2.SortPriority)
            {
                return String.Compare(node2.Caption, node1.Caption, true, CultureInfo.CurrentCulture);
            }
            else
            {
                return node2.SortPriority - node1.SortPriority;
            }
        }

        /// <summary>
        /// Handles global properties related to configuration and platform changes invoked by a change in the active configuration.
        /// </summary>
        /// <param name="sender">The sender of the event.</param>
        /// <param name="eventArgs">The event args</param>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Security", "CA2109:ReviewVisibleEventHandlers",
            Justification = "This method will give the opportunity to update global properties based on active configuration change. " +
            "There is no security threat that could otherwise not be reached by listening to configuration chnage events.")]
        protected virtual void OnHandleConfigurationRelatedGlobalProperties(object sender, ActiveConfigurationChangedEventArgs eventArgs)
        {
            Debug.Assert(eventArgs != null, "Wrong hierarchy passed as event arg for the configuration change listener.");

            // If (eventArgs.Hierarchy == NULL) then we received this event because the solution configuration
            // was changed.
            // If it is not null we got the event because a project in teh configuration manager has changed its active configuration.
            // We care only about our project in the default implementation.
            if (eventArgs == null || eventArgs.Hierarchy == null || !Utilities.IsSameComObject(eventArgs.Hierarchy, this.InteropSafeIVsHierarchy))
            {
                return;
            }

            string name, platform;
            if (!Utilities.TryGetActiveConfigurationAndPlatform(this.Site, this.InteropSafeIVsHierarchy, out name, out platform))
            {
                throw new InvalidOperationException();
            }

            this.buildProject.SetGlobalProperty(GlobalProperty.Configuration.ToString(), name);

            // If the platform is "Any CPU" then it should be set to AnyCPU, since that is the property value in MsBuild terms.
            platform = ConfigProvider.GetPlatformPropertyFromPlatformName(platform);
            if (String.Equals(platform, ConfigProvider.AnyCpuPlatform, StringComparison.Ordinal))
            {
                platform = ProjectFileValues.AnyCPU;
            }

            this.buildProject.SetGlobalProperty(GlobalProperty.Platform.ToString(), platform);
        }

        /// <summary>
        /// Flush any remaining content from build logger.
        /// This method is called as part of the callback method passed to the buildsubmission during async build
        /// so that results can be printed the the build is finished.
        /// </summary>
        protected virtual void FlushBuildLoggerContent()
        {
        }
        #endregion

        #region non-virtual methods

        /// <summary>
        /// Suspends MSBuild
        /// </summary>
        public virtual void SuspendMSBuild()
        {
            this.suspendMSBuildCounter++;
        }

        /// <summary>
        /// Resumes MSBuild.
        /// </summary>
        public virtual void ResumeMSBuild(string config, string platform, IVsOutputWindowPane output, string target)
        {
            this.suspendMSBuildCounter--;

            if (this.suspendMSBuildCounter == 0 && this.invokeMSBuildWhenResumed)
            {
                try
                {
                    this.Build(config, platform, output, target);
                }
                finally
                {
                    this.invokeMSBuildWhenResumed = false;
                }
            }
        }

        /// <summary>
        /// Resumes MSBuild.
        /// </summary>
        public virtual void ResumeMSBuild(string config, string platform, string target)
        {
            this.ResumeMSBuild(config, platform, null, target);
        }

        /// <summary>
        /// Resumes MSBuild.
        /// </summary>
        public virtual void ResumeMSBuild(string target)
        {
            this.ResumeMSBuild(string.Empty, string.Empty, null, target);
        }

        /// <summary>
        /// Calls MSBuild if it is not suspended. If it is suspended then it will remember to call when msbuild is resumed.
        /// </summary>
        public virtual MSBuildResult CallMSBuild(string config, string platform, IVsOutputWindowPane output, string target)
        {
            if (this.suspendMSBuildCounter > 0)
            {
                // remember to invoke MSBuild
                this.invokeMSBuildWhenResumed = true;
                return MSBuildResult.Suspended;
            }
            else
            {
                return this.Build(config, platform, output, target);
            }
        }

        /// <summary>
        /// Overloaded method. Calls MSBuild if it is not suspended. Does not log on the outputwindow. If it is suspended then it will remeber to call when msbuild is resumed.
        /// </summary>
        public virtual MSBuildResult CallMSBuild(string config, string platform, string target)
        {
            return this.CallMSBuild(config, platform, null, target);
        }

        /// <summary>
        /// Calls MSBuild if it is not suspended. Does not log and uses current configuration. If it is suspended then it will remeber to call when msbuild is resumed.
        /// </summary>
        public virtual MSBuildResult CallMSBuild(string target)
        {
            return this.CallMSBuild(string.Empty, string.Empty, null, target);
        }

        /// <summary>
        /// Calls MSBuild if it is not suspended. Uses current configuration. If it is suspended then it will remeber to call when msbuild is resumed.
        /// </summary>
        public virtual MSBuildResult CallMSBuild(string target, IVsOutputWindowPane output)
        {
            return this.CallMSBuild(string.Empty, string.Empty, output, target);
        }

        /// <summary>
        /// Overloaded method to invoke MSBuild
        /// </summary>
        public virtual MSBuildResult Build(string config, string platform, IVsOutputWindowPane output, string target)
        {
            return this.Build(0, config, platform, output, target);
        }

        /// <summary>
        /// Overloaded method to invoke MSBuild. Does not log build results to the output window pane.
        /// </summary>
        public virtual MSBuildResult Build(string config, string platform, string target)
        {
            return this.Build(0, config, platform, null, target);
        }

        /// <summary>
        /// Overloaded method. Invokes MSBuild using the default configuration and does without logging on the output window pane.
        /// </summary>
        public virtual MSBuildResult Build(string target)
        {
            return this.Build(0, string.Empty, string.Empty, null, target);
        }

        /// <summary>
        /// Overloaded method. Invokes MSBuild using the default configuration.
        /// </summary>
        public virtual MSBuildResult Build(string target, IVsOutputWindowPane output)
        {
            return this.Build(0, string.Empty, string.Empty, output, target);
        }

        /// <summary>
        /// Get the output path for a specific configuration name
        /// </summary>
        /// <param name="config">name of configuration</param>
        /// <returns>Output path</returns>
        public virtual string GetOutputPath(string config, string platform)
        {
            this.SetConfiguration(config, platform);
            return GetOutputPath(this.currentConfig);
        }

        /// <summary>
        /// Get value of Project property
        /// </summary>
        /// <param name="propertyName">Name of Property to retrieve</param>
        /// <returns>Evaluated value of property.</returns>
        public virtual string GetProjectProperty(string propertyName, _PersistStorageType storageType)
        {
            return this.GetProjectProperty(propertyName, storageType, true);
        }

		/// <summary>
		/// Gets the unevaluated value of a project property.
		/// </summary>
		/// <param name="propertyName">The name of the property to retrieve.</param>
		/// <returns>Unevaluated value of the property.</returns>
		public virtual string GetProjectPropertyUnevaluated(string propertyName)
		{
			return this.buildProject.GetProperty(propertyName).UnevaluatedValue;
		}

        /// <summary>
        /// Set dirty state of project
        /// </summary>
        /// <param name="value">boolean value indicating dirty state</param>
        public virtual void SetProjectFileDirty(bool value)
        {
            this._isDirty = value;
            if (this._isDirty)
            {
                this.lastModifiedTime = DateTime.Now;
                this.buildIsPrepared = false;
            }
        }

        /// <summary>
        /// Get output assembly for a specific configuration name
        /// </summary>
        /// <param name="config">Name of configuration</param>
        /// <returns>Name of output assembly</returns>
        public virtual string GetOutputAssembly(string config, string platform)
        {
            ProjectOptions options = this.GetProjectOptions(config, platform);

            return options.OutputAssembly;
        }

        /// <summary>
        /// Get Node from ItemID.
        /// </summary>
        /// <param name="itemId">ItemID for the requested node</param>
        /// <returns>Node if found</returns>
        public virtual HierarchyNode NodeFromItemId(uint itemId)
        {
            if (VSConstants.VSITEMID_ROOT == itemId)
            {
                return this;
            }
            else if (VSConstants.VSITEMID_NIL == itemId)
            {
                return null;
            }
            else if (VSConstants.VSITEMID_SELECTION == itemId)
            {
                throw new NotImplementedException();
            }

            return (HierarchyNode)this.ItemIdMap[itemId];
        }

        /// <summary>
        /// This method return new project element, and add new MSBuild item to the project/build hierarchy
        /// </summary>
        /// <param name="file">file name</param>
        /// <param name="itemType">MSBuild item type</param>
        /// <returns>new project element</returns>
        public virtual ProjectElement CreateMSBuildFileItem(string file, string itemType)
        {
            return new ProjectElement(this, file, itemType);
        }

        /// <summary>
        /// This method returns new project element based on existing MSBuild item. It does not modify/add project/build hierarchy at all.
        /// </summary>
        /// <param name="item">MSBuild item instance</param>
        /// <returns>wrapping project element</returns>
        public virtual ProjectElement GetProjectElement(MSBuild.ProjectItem item)
        {
            return new ProjectElement(this, item, false);
        }

        /// <summary>
        /// Create FolderNode from Path
        /// </summary>
        /// <param name="path">Path to folder</param>
        /// <returns>FolderNode created that can be added to the hierarchy</returns>
        public virtual FolderNode CreateFolderNode(string path)
        {
            ProjectElement item = this.AddFolderToMSBuild(path);
            FolderNode folderNode = CreateFolderNode(path, item);
            return folderNode;
        }

        /// <summary>
        /// Verify if the file can be written to.
        /// Return false if the file is read only and/or not checked out
        /// and the user did not give permission to change it.
        /// Note that exact behavior can also be affected based on the SCC
        /// settings under Tools->Options.
        /// </summary>
        public virtual bool QueryEditProjectFile(bool suppressUI)
        {
            bool result = true;
            if (this._site == null)
            {
                // We're already zombied. Better return FALSE.
                result = false;
            }
            else if (this.disableQueryEdit)
            {
                return true;
            }
            else
            {
                IVsQueryEditQuerySave2 queryEditQuerySave = this.GetService(typeof(SVsQueryEditQuerySave)) as IVsQueryEditQuerySave2;
                if (queryEditQuerySave != null)
                {   // Project path dependends on server/client project
                    string path = this.FileName;

                    tagVSQueryEditFlags qef = tagVSQueryEditFlags.QEF_AllowInMemoryEdits;
                    if (suppressUI)
                        qef |= tagVSQueryEditFlags.QEF_SilentMode;

                    // If we are debugging, we want to prevent our project from being reloaded. To 
                    // do this, we pass the QEF_NoReload flag
                    if (!Utilities.IsVisualStudioInDesignMode(this.Site))
                        qef |= tagVSQueryEditFlags.QEF_NoReload;

                    uint verdict;
                    uint moreInfo;
                    string[] files = new string[1];
                    files[0] = path;
                    uint[] flags = new uint[1];
                    VSQEQS_FILE_ATTRIBUTE_DATA[] attributes = new VSQEQS_FILE_ATTRIBUTE_DATA[1];
                    int hr = queryEditQuerySave.QueryEditFiles(
                                    (uint)qef,
                                    1, // 1 file
                                    files, // array of files
                                    flags, // no per file flags
                                    attributes, // no per file file attributes
                                    out verdict,
                                    out moreInfo /* ignore additional results */);

                    tagVSQueryEditResult qer = (tagVSQueryEditResult)verdict;
                    if (ErrorHandler.Failed(hr) || (qer != tagVSQueryEditResult.QER_EditOK))
                    {
                        if (!suppressUI && !Utilities.IsInAutomationFunction(this.Site))
                        {
                            string message = SR.GetString(SR.CancelQueryEdit, path);
                            string title = string.Empty;
                            OLEMSGICON icon = OLEMSGICON.OLEMSGICON_CRITICAL;
                            OLEMSGBUTTON buttons = OLEMSGBUTTON.OLEMSGBUTTON_OK;
                            OLEMSGDEFBUTTON defaultButton = OLEMSGDEFBUTTON.OLEMSGDEFBUTTON_FIRST;
                            VsShellUtilities.ShowMessageBox(this.Site, title, message, icon, buttons, defaultButton);
                        }
                        result = false;
                    }
                }
            }
            return result;
        }

        /// <summary>
        /// Checks whether a hierarchy is a nested project.
        /// </summary>
        /// <param name="hierarchy"></param>
        /// <returns></returns>
        public virtual NestedProjectNode GetNestedProjectForHierarchy(IVsHierarchy hierarchy)
        {
            IVsProject3 project = hierarchy as IVsProject3;

            if (project != null)
            {
                string mkDocument = String.Empty;
                ErrorHandler.ThrowOnFailure(project.GetMkDocument(VSConstants.VSITEMID_ROOT, out mkDocument));

                if (!String.IsNullOrEmpty(mkDocument))
                {
                    HierarchyNode node = this.FindChild(mkDocument);

                    return node as NestedProjectNode;
                }
            }

            return null;
        }

        /// <summary>
        /// Given a node determines what is the directory that can accept files.
        /// If the node is a FoldeNode than it is the Url of the Folder.
        /// If the node is a ProjectNode it is the project folder.
        /// Otherwise (such as FileNode subitem) it delegate the resolution to the parent node.
        /// </summary>
        public virtual string GetBaseDirectoryForAddingFiles(HierarchyNode nodeToAddFile)
        {
            string baseDir = String.Empty;

            if (nodeToAddFile is FolderNode)
            {
                baseDir = nodeToAddFile.Url;
            }
            else if (nodeToAddFile is ProjectNode)
            {
                baseDir = this.ProjectFolder;
            }
            else if (nodeToAddFile != null)
            {
                baseDir = GetBaseDirectoryForAddingFiles(nodeToAddFile.Parent);
            }

            return baseDir;
        }

        /// <summary>
        /// Get the project extensions
        /// </summary>
        /// <returns></returns>
        public virtual MSBuildConstruction.ProjectExtensionsElement GetProjectExtensions()
        {
            var extensionsElement = this.buildProject.Xml.ChildrenReversed.OfType<MSBuildConstruction.ProjectExtensionsElement>().FirstOrDefault();

            if (extensionsElement == null)
            {
                extensionsElement = this.buildProject.Xml.CreateProjectExtensionsElement();
                this.buildProject.Xml.AppendChild(extensionsElement);
            }

            return extensionsElement;
        }

        /// <summary>
        /// Set the xmlText as a project extension element with the id passed.
        /// </summary>
        /// <param name="id">The id of the project extension element.</param>
        /// <param name="xmlText">The value to set for a project extension.</param>
        public virtual void SetProjectExtensions(string id, string xmlText)
        {
            MSBuildConstruction.ProjectExtensionsElement element = this.GetProjectExtensions();

            // If it doesn't already have a value and we're asked to set it to
            // nothing, don't do anything. Same as old OM. Keeps project neat.
            if (element == null)
            {
                if (xmlText.Length == 0)
                {
                    return;
                }

                element = this.buildProject.Xml.CreateProjectExtensionsElement();
                this.buildProject.Xml.AppendChild(element);
            }

            element[id] = xmlText;
        }

        /// <summary>
        /// Register the project with the Scc manager.
        /// </summary>
        [SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "Scc")]
        protected virtual void RegisterSccProject()
        {

            if (this.IsSccDisabled || this.isRegisteredWithScc || String.IsNullOrEmpty(this._sccProjectName))
            {
                return;
            }

            IVsSccManager2 sccManager = this.Site.GetService(typeof(SVsSccManager)) as IVsSccManager2;

            if (sccManager != null)
            {
                ErrorHandler.ThrowOnFailure(sccManager.RegisterSccProject(this.InteropSafeIVsSccProject2, this._sccProjectName, this._sccAuxPath, this._sccLocalPath, this._sccProvider));

                this.isRegisteredWithScc = true;
            }
        }

        /// <summary>
        ///  Unregisters us from the SCC manager
        /// </summary>
        protected virtual void UnregisterProject()
        {
            if (this.IsSccDisabled || !this.isRegisteredWithScc)
            {
                return;
            }

            IVsSccManager2 sccManager = this.Site.GetService(typeof(SVsSccManager)) as IVsSccManager2;

            if (sccManager != null)
            {
                ErrorHandler.ThrowOnFailure(sccManager.UnregisterSccProject(this.InteropSafeIVsSccProject2));
                this.isRegisteredWithScc = false;
            }
        }

        /// <summary>
        /// Get the CATID corresponding to the specified type.
        /// </summary>
        /// <param name="type">Type of the object for which you want the CATID</param>
        /// <returns>CATID</returns>
        public virtual Guid GetCatIdForType(Type type)
        {
            if (type == null)
                throw new ArgumentNullException("type");

            if (catidMapping.ContainsKey(type))
                return catidMapping[type];
            // If you get here and you want your object to be extensible, then add a call to AddCATIDMapping() in your project constructor
            return Guid.Empty;
        }

        /// <summary>
        /// This is used to specify a CATID corresponding to a BrowseObject or an ExtObject.
        /// The CATID can be any GUID you choose. For types which are your owns, you could use
        /// their type GUID, while for other types (such as those provided in the MPF) you should
        /// provide a different GUID.
        /// </summary>
        /// <param name="type">Type of the extensible object</param>
        /// <param name="catId">GUID that extender can use to uniquely identify your object type</param>
        protected virtual void AddCatIdMapping(Type type, Guid catId)
        {
            catidMapping.Add(type, catId);
        }

        /// <summary>
        /// Initialize an object with an XML fragment.
        /// </summary>
        /// <param name="persistXmlFragment">Object that support being initialized with an XML fragment</param>
        /// <param name="configName">Name of the configuration being initialized, null if it is the project</param>
        public virtual void LoadXmlFragment(IPersistXMLFragment persistXmlFragment, string configName)
        {
            if (persistXmlFragment == null)
            {
                throw new ArgumentNullException("persistXmlFragment");
            }

            if (xmlFragments == null)
            {
                // Retrieve the xml fragments from MSBuild
                xmlFragments = new XmlDocument();

                string fragments = GetProjectExtensions()[ProjectFileConstants.VisualStudio];
                fragments = String.Format(CultureInfo.InvariantCulture, "<root>{0}</root>", fragments);
                xmlFragments.LoadXml(fragments);
            }

            // We need to loop through all the flavors
            string flavorsGuid;
            ErrorHandler.ThrowOnFailure(((IVsAggregatableProject)this).GetAggregateProjectTypeGuids(out flavorsGuid));
            foreach (Guid flavor in Utilities.GuidsArrayFromSemicolonDelimitedStringOfGuids(flavorsGuid))
            {
                // Look for a matching fragment
                string flavorGuidString = flavor.ToString("B");
                string fragment = null;
                XmlNode node = null;
                foreach (XmlNode child in xmlFragments.FirstChild.ChildNodes)
                {
                    if (child.Attributes.Count > 0)
                    {
                        string guid = String.Empty;
                        string configuration = String.Empty;
                        if (child.Attributes[ProjectFileConstants.Guid] != null)
                            guid = child.Attributes[ProjectFileConstants.Guid].Value;
                        if (child.Attributes[ProjectFileConstants.Configuration] != null)
                            configuration = child.Attributes[ProjectFileConstants.Configuration].Value;

                        if (String.Equals(child.Name, ProjectFileConstants.FlavorProperties, StringComparison.OrdinalIgnoreCase)
                                && String.Equals(guid, flavorGuidString, StringComparison.OrdinalIgnoreCase)
                                && ((String.IsNullOrEmpty(configName) && String.IsNullOrEmpty(configuration))
                                    || (String.Equals(configuration, configName, StringComparison.OrdinalIgnoreCase))))
                        {
                            // we found the matching fragment
                            fragment = child.InnerXml;
                            node = child;
                            break;
                        }
                    }
                }

                Guid flavorGuid = flavor;
                if (String.IsNullOrEmpty(fragment))
                {
                    // the fragment was not found so init with default values
                    ErrorHandler.ThrowOnFailure(persistXmlFragment.InitNew(ref flavorGuid, (uint)_PersistStorageType.PST_PROJECT_FILE));
                    // While we don't yet support user files, our flavors might, so we will store that in the project file until then
                    // TODO: Refactor this code when we support user files
                    ErrorHandler.ThrowOnFailure(persistXmlFragment.InitNew(ref flavorGuid, (uint)_PersistStorageType.PST_USER_FILE));
                }
                else
                {
                    ErrorHandler.ThrowOnFailure(persistXmlFragment.Load(ref flavorGuid, (uint)_PersistStorageType.PST_PROJECT_FILE, fragment));
                    // While we don't yet support user files, our flavors might, so we will store that in the project file until then
                    // TODO: Refactor this code when we support user files
                    if (node.NextSibling != null && node.NextSibling.Attributes[ProjectFileConstants.User] != null)
                        ErrorHandler.ThrowOnFailure(persistXmlFragment.Load(ref flavorGuid, (uint)_PersistStorageType.PST_USER_FILE, node.NextSibling.InnerXml));
                }
            }
        }

        /// <summary>
        /// Retrieve all XML fragments that need to be saved from the flavors and store the information in msbuild.
        /// </summary>
        protected virtual void PersistXmlFragments()
        {
            if (this.IsFlavorDirty() != 0)
            {
                XmlDocument doc = new XmlDocument();
                XmlElement root = doc.CreateElement("ROOT");

                // We will need the list of configuration inside the loop, so get it before entering the loop
                uint[] count = new uint[1];
                IVsCfg[] configs = null;
                int hr = this.ConfigProvider.GetCfgs(0, null, count, null);
                if (ErrorHandler.Succeeded(hr) && count[0] > 0)
                {
                    configs = new IVsCfg[count[0]];
                    hr = this.ConfigProvider.GetCfgs((uint)configs.Length, configs, count, null);
                    if (ErrorHandler.Failed(hr))
                        count[0] = 0;
                }
                if (count[0] == 0)
                    configs = new IVsCfg[0];

                // We need to loop through all the flavors
                string flavorsGuid;
                ErrorHandler.ThrowOnFailure(((IVsAggregatableProject)this).GetAggregateProjectTypeGuids(out flavorsGuid));
                foreach (Guid flavor in Utilities.GuidsArrayFromSemicolonDelimitedStringOfGuids(flavorsGuid))
                {
                    IPersistXMLFragment outerHierarchy = this.InteropSafeIVsHierarchy as IPersistXMLFragment;
                    // First check the project
                    if (outerHierarchy != null)
                    {
                        // Retrieve the XML fragment
                        string fragment = string.Empty;
                        Guid flavorGuid = flavor;
                        ErrorHandler.ThrowOnFailure((outerHierarchy).Save(ref flavorGuid, (uint)_PersistStorageType.PST_PROJECT_FILE, out fragment, 1));
                        if (!String.IsNullOrEmpty(fragment))
                        {
                            // Add the fragment to our XML
                            WrapXmlFragment(doc, root, flavor, null, fragment);
                        }
                        // While we don't yet support user files, our flavors might, so we will store that in the project file until then
                        // TODO: Refactor this code when we support user files
                        fragment = String.Empty;
                        ErrorHandler.ThrowOnFailure((outerHierarchy).Save(ref flavorGuid, (uint)_PersistStorageType.PST_USER_FILE, out fragment, 1));
                        if (!String.IsNullOrEmpty(fragment))
                        {
                            // Add the fragment to our XML
                            XmlElement node = WrapXmlFragment(doc, root, flavor, null, fragment);
                            node.Attributes.Append(doc.CreateAttribute(ProjectFileConstants.User));
                        }
                    }

                    // Then look at the configurations
                    foreach (IVsCfg config in configs)
                    {
                        // Get the fragment for this flavor/config pair
                        string fragment;
                        ErrorHandler.ThrowOnFailure(((ProjectConfig)config).GetXmlFragment(flavor, _PersistStorageType.PST_PROJECT_FILE, out fragment));
                        if (!String.IsNullOrEmpty(fragment))
                        {
                            string configName;
                            ErrorHandler.ThrowOnFailure(config.get_DisplayName(out configName));
                            WrapXmlFragment(doc, root, flavor, configName, fragment);
                        }
                    }
                }
                if (root.ChildNodes != null && root.ChildNodes.Count > 0)
                {
                    // Save our XML (this is only the non-build information for each flavor) in msbuild
                    SetProjectExtensions(ProjectFileConstants.VisualStudio, root.InnerXml.ToString());
                }
            }
        }

        #endregion

        #region IVsGetCfgProvider Members
        //=================================================================================

        public virtual int GetCfgProvider(out IVsCfgProvider p)
        {
            CciTracing.TraceCall();
            // Be sure to call the property here since that is doing a polymorhic ProjectConfig creation.
            p = this.ConfigProvider;
            return (p == null ? VSConstants.E_NOTIMPL : VSConstants.S_OK);
        }
        #endregion

        #region IPersist Members

        public virtual int GetClassID(out Guid clsid)
        {
            clsid = this.ProjectGuid;
            return VSConstants.S_OK;
        }
        #endregion

        #region IPersistFileFormat Members

        int IPersistFileFormat.GetClassID(out Guid clsid)
        {
            clsid = this.ProjectGuid;
            return VSConstants.S_OK;
        }

        public virtual int GetCurFile(out string name, out uint formatIndex)
        {
            name = this.FileName;
            formatIndex = 0;
            return VSConstants.S_OK;
        }

        public virtual int GetFormatList(out string formatlist)
        {
            formatlist = String.Empty;
            return VSConstants.S_OK;
        }

        public virtual int InitNew(uint formatIndex)
        {
            return VSConstants.S_OK;
        }

        public virtual int IsDirty(out int isDirty)
        {
            isDirty = 0;
            if (this.buildProject.Xml.HasUnsavedChanges || this.IsProjectFileDirty)
            {
                isDirty = 1;
                return VSConstants.S_OK;
            }

            isDirty = IsFlavorDirty();

            return VSConstants.S_OK;
        }

        protected virtual int IsFlavorDirty()
        {
            int isDirty = 0;
            // See if one of our flavor consider us dirty
            IPersistXMLFragment outerHierarchy = this.InteropSafeIVsHierarchy as IPersistXMLFragment;
            if (outerHierarchy != null)
            {
                // First check the project
                ErrorHandler.ThrowOnFailure(outerHierarchy.IsFragmentDirty((uint)_PersistStorageType.PST_PROJECT_FILE, out isDirty));
                // While we don't yet support user files, our flavors might, so we will store that in the project file until then
                // TODO: Refactor this code when we support user files
                if (isDirty == 0)
                    ErrorHandler.ThrowOnFailure(outerHierarchy.IsFragmentDirty((uint)_PersistStorageType.PST_USER_FILE, out isDirty));
            }
            if (isDirty == 0)
            {
                // Then look at the configurations
                uint[] count = new uint[1];
                int hr = this.ConfigProvider.GetCfgs(0, null, count, null);
                if (ErrorHandler.Succeeded(hr) && count[0] > 0)
                {
                    // We need to loop through the configurations
                    IVsCfg[] configs = new IVsCfg[count[0]];
                    hr = this.ConfigProvider.GetCfgs((uint)configs.Length, configs, count, null);
                    Debug.Assert(ErrorHandler.Succeeded(hr), "failed to retrieve configurations");
                    foreach (IVsCfg config in configs)
                    {
                        isDirty = ((ProjectConfig)config).IsFlavorDirty(_PersistStorageType.PST_PROJECT_FILE);
                        if (isDirty != 0)
                            break;
                    }
                }
            }
            return isDirty;
        }

        public virtual int Load(string fileName, uint mode, int readOnly)
        {
            this.FileName = fileName;
            this.Reload();
            return VSConstants.S_OK;
        }

        public virtual int Save(string fileToBeSaved, int remember, uint formatIndex)
        {
            // The file name can be null. Then try to use the Url.
            string tempFileToBeSaved = fileToBeSaved;
            if (String.IsNullOrEmpty(tempFileToBeSaved) && !String.IsNullOrEmpty(this.Url))
            {
                tempFileToBeSaved = this.Url;
            }

            if (String.IsNullOrEmpty(tempFileToBeSaved))
            {
                throw new ArgumentException(SR.GetString(SR.InvalidParameter, CultureInfo.CurrentUICulture), "fileToBeSaved");
            }

            bool setProjectFileDirtyAfterSave = false;
            if (remember == 0)
            {
                setProjectFileDirtyAfterSave = this.IsProjectFileDirty;
            }

            // Update the project with the latest flavor data (if needed)
            PersistXmlFragments();

            int result = VSConstants.S_OK;
            bool saveAs = true;
            if (NativeMethods.IsSamePath(tempFileToBeSaved, this.FileName))
            {
                saveAs = false;
            }
            if (!saveAs)
            {
                SuspendFileChanges fileChanges = new SuspendFileChanges(this.Site, this.FileName);
                fileChanges.Suspend();
                try
                {
                    // Ensure the directory exist
                    string saveFolder = Path.GetDirectoryName(tempFileToBeSaved);
                    if (!Directory.Exists(saveFolder))
                        Directory.CreateDirectory(saveFolder);

                    // Save the project
                    this.buildProject.Save(tempFileToBeSaved);
                    if (_userBuildProject != null)
                        _userBuildProject.Save(UserFileName);

                    this.SetProjectFileDirty(false);
                }
                finally
                {
                    fileChanges.Resume();
                }
            }
            else
            {
                result = this.SaveAs(tempFileToBeSaved);
                if (result != VSConstants.OLE_E_PROMPTSAVECANCELLED)
                {
                    ErrorHandler.ThrowOnFailure(result);
                }

            }

            if (setProjectFileDirtyAfterSave)
            {
                this.SetProjectFileDirty(true);
            }

            return result;
        }

        public virtual int SaveCompleted(string filename)
        {
            // TODO: turn file watcher back on.
            return VSConstants.S_OK;
        }
        #endregion

        #region IVsProject3 Members

        /// <summary>
        /// Callback from the additem dialog. Deals with adding new and existing items
        /// </summary>
        public virtual int GetMkDocument(uint itemId, out string mkDoc)
        {
            mkDoc = null;
            if (itemId == VSConstants.VSITEMID_SELECTION)
            {
                return VSConstants.E_UNEXPECTED;
            }

            HierarchyNode n = this.NodeFromItemId(itemId);
            if (n == null)
            {
                return VSConstants.E_INVALIDARG;
            }

            mkDoc = n.GetMKDocument();

            if (String.IsNullOrEmpty(mkDoc))
            {
                return VSConstants.E_FAIL;
            }

            return VSConstants.S_OK;
        }


        public virtual int AddItem(uint itemIdLoc, VSADDITEMOPERATION op, string itemName, uint filesToOpen, string[] files, IntPtr dlgOwner, VSADDRESULT[] result)
        {
            Guid empty = Guid.Empty;

            return AddItemWithSpecific(itemIdLoc, op, itemName, filesToOpen, files, dlgOwner, 0, ref empty, null, ref empty, result);
        }

        /// <summary>
        /// Creates new items in a project, adds existing files to a project, or causes Add Item wizards to be run
        /// </summary>
        /// <param name="itemIdLoc"></param>
        /// <param name="op"></param>
        /// <param name="itemName"></param>
        /// <param name="filesToOpen"></param>
        /// <param name="files">Array of file names. 
        /// If dwAddItemOperation is VSADDITEMOP_CLONEFILE the first item in the array is the name of the file to clone. 
        /// If dwAddItemOperation is VSADDITEMOP_OPENDIRECTORY, the first item in the array is the directory to open. 
        /// If dwAddItemOperation is VSADDITEMOP_RUNWIZARD, the first item is the name of the wizard to run, 
        /// and the second item is the file name the user supplied (same as itemName).</param>
        /// <param name="dlgOwner"></param>
        /// <param name="editorFlags"></param>
        /// <param name="editorType"></param>
        /// <param name="physicalView"></param>
        /// <param name="logicalView"></param>
        /// <param name="result"></param>
        /// <returns>S_OK if it succeeds </returns>
        /// <remarks>The result array is initalized to failure.</remarks>
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Maintainability", "CA1506:AvoidExcessiveClassCoupling"), System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Maintainability", "CA1502:AvoidExcessiveComplexity")]
        public virtual int AddItemWithSpecific(uint itemIdLoc, VSADDITEMOPERATION op, string itemName, uint filesToOpen, string[] files, IntPtr dlgOwner, uint editorFlags, ref Guid editorType, string physicalView, ref Guid logicalView, VSADDRESULT[] result)
        {
            if (files == null || result == null || files.Length == 0 || result.Length == 0)
            {
                return VSConstants.E_INVALIDARG;
            }

            // Locate the node to be the container node for the file(s) being added
            // only projectnode or foldernode and file nodes are valid container nodes
            // We need to locate the parent since the item wizard expects the parent to be passed.
            HierarchyNode n = this.NodeFromItemId(itemIdLoc);
            if (n == null)
            {
                return VSConstants.E_INVALIDARG;
            }

            while ((!(n is ProjectNode)) && (!(n is FolderNode)) && (!this.CanFileNodesHaveChilds || !(n is FileNode)))
            {
                n = n.Parent;
            }
            Debug.Assert(n != null, "We should at this point have either a ProjectNode or FolderNode or a FileNode as a container for the new filenodes");

            if (op == VSADDITEMOPERATION.VSADDITEMOP_RUNWIZARD)
            {
                result[0] = this.RunWizard(n, itemName, files[0], dlgOwner);
                return VSConstants.S_OK;
            }

            string[] actualFiles = new string[files.Length];


            VSQUERYADDFILEFLAGS[] flags = this.GetQueryAddFileFlags(files);

            string baseDir = this.GetBaseDirectoryForAddingFiles(n);
            // If we did not get a directory for node that is the parent of the item then fail.
            if (String.IsNullOrEmpty(baseDir))
            {
                return VSConstants.E_FAIL;
            }

            // Pre-calculates some paths that we can use when calling CanAddItems
            List<string> filesToAdd = new List<string>();
            for (int index = 0; index < files.Length; index++)
            {
                string newFileName = String.Empty;

                string file = files[index];

                switch (op)
                {
                    case VSADDITEMOPERATION.VSADDITEMOP_CLONEFILE:
                        {
                            string fileName = Path.GetFileName(itemName);
                            newFileName = Path.Combine(baseDir, fileName);
                        }
                        break;
                    case VSADDITEMOPERATION.VSADDITEMOP_OPENFILE:
                    case VSADDITEMOPERATION.VSADDITEMOP_LINKTOFILE:
                        {
                            string fileName = Path.GetFileName(file);
                            newFileName = Path.Combine(baseDir, fileName);
                        }
                        break;
                }
                filesToAdd.Add(newFileName);
            }

            // Ask tracker objects if we can add files
            if (!this.tracker.CanAddItems(filesToAdd.ToArray(), flags))
            {
                // We were not allowed to add the files
                return VSConstants.E_FAIL;
            }

            if (!this.ProjectManager.QueryEditProjectFile(false))
            {
                throw Marshal.GetExceptionForHR(VSConstants.OLE_E_PROMPTSAVECANCELLED);
            }

            // Add the files to the hierarchy
            int actualFilesAddedIndex = 0;
            for (int index = 0; index < filesToAdd.Count; index++)
            {
                HierarchyNode child;
                bool overwrite = false;
                string newFileName = filesToAdd[index];

                string file = files[index];
                result[0] = VSADDRESULT.ADDRESULT_Failure;

                child = this.FindChild(newFileName);
                if (child != null)
                {
                    // If the file to be added is an existing file part of the hierarchy then continue.
                    if (NativeMethods.IsSamePath(file, newFileName))
                    {
                        result[0] = VSADDRESULT.ADDRESULT_Cancel;
                        continue;
                    }

                    int canOverWriteExistingItem = this.CanOverwriteExistingItem(file, newFileName);

                    if (canOverWriteExistingItem == (int)OleConstants.OLECMDERR_E_CANCELED)
                    {
                        result[0] = VSADDRESULT.ADDRESULT_Cancel;
                        return canOverWriteExistingItem;
                    }
                    else if (canOverWriteExistingItem == VSConstants.S_OK)
                    {
                        overwrite = true;
                    }
                    else
                    {
                        return canOverWriteExistingItem;
                    }
                }

                // If the file to be added is not in the same path copy it.
                if (op != VSADDITEMOPERATION.VSADDITEMOP_LINKTOFILE && NativeMethods.IsSamePath(file, newFileName) == false)
                {
                    if (!overwrite && File.Exists(newFileName))
                    {
                        string message = String.Format(CultureInfo.CurrentCulture, SR.GetString(SR.FileAlreadyExists, CultureInfo.CurrentUICulture), newFileName);
                        string title = string.Empty;
                        OLEMSGICON icon = OLEMSGICON.OLEMSGICON_QUERY;
                        OLEMSGBUTTON buttons = OLEMSGBUTTON.OLEMSGBUTTON_YESNO;
                        OLEMSGDEFBUTTON defaultButton = OLEMSGDEFBUTTON.OLEMSGDEFBUTTON_FIRST;
                        int messageboxResult = VsShellUtilities.ShowMessageBox(this.Site, title, message, icon, buttons, defaultButton);
                        if (messageboxResult == DialogResult.No)
                        {
                            result[0] = VSADDRESULT.ADDRESULT_Cancel;
                            return (int)OleConstants.OLECMDERR_E_CANCELED;
                        }
                    }

                    // Copy the file to the correct location.
                    // We will suppress the file change events to be triggered to this item, since we are going to copy over the existing file and thus we will trigger a file change event. 
                    // We do not want the filechange event to ocur in this case, similar that we do not want a file change event to occur when saving a file.
                    IVsFileChangeEx fileChange = this._site.GetService(typeof(SVsFileChangeEx)) as IVsFileChangeEx;
                    if (fileChange == null)
                    {
                        throw new InvalidOperationException();
                    }

                    try
                    {
                        ErrorHandler.ThrowOnFailure(fileChange.IgnoreFile(VSConstants.VSCOOKIE_NIL, newFileName, 1));
                        if (op == VSADDITEMOPERATION.VSADDITEMOP_CLONEFILE)
                        {
                            this.AddFileFromTemplate(file, newFileName);
                        }
                        else
                        {
                            PackageUtilities.CopyUrlToLocal(new Uri(file), newFileName);
                        }
                    }
                    finally
                    {
                        ErrorHandler.ThrowOnFailure(fileChange.IgnoreFile(VSConstants.VSCOOKIE_NIL, newFileName, 0));
                    }
                }

                if (overwrite)
                {
                    this.OverwriteExistingItem(child);
                }
                else if (op == VSADDITEMOPERATION.VSADDITEMOP_LINKTOFILE)
                {
                    Url baseUrl = new Url(this.ProjectFolder + Path.DirectorySeparatorChar);
                    string relativePath = baseUrl.MakeRelative(new Url(file));
                    string linkPath = baseUrl.MakeRelative(new Url(newFileName));
                    this.AddNewFileNodeToHierarchy(n, relativePath, linkPath);
                }
                else
                {
                    //Add new filenode/dependentfilenode
                    this.AddNewFileNodeToHierarchy(n, newFileName, null);
                }

                result[0] = VSADDRESULT.ADDRESULT_Success;
                actualFiles[actualFilesAddedIndex++] = newFileName;
            }

            // Notify listeners that items were appended.
            if (actualFilesAddedIndex > 0)
                n.OnItemsAppended(n);

            //Open files if this was requested through the editorFlags
            bool openFiles = (editorFlags & (uint)__VSSPECIFICEDITORFLAGS.VSSPECIFICEDITOR_DoOpen) != 0;
            if (openFiles && actualFiles.Length <= filesToOpen)
            {
                for (int i = 0; i < filesToOpen; i++)
                {
                    if (!String.IsNullOrEmpty(actualFiles[i]))
                    {
                        string name = actualFiles[i];
                        HierarchyNode child = this.FindChild(name);
                        Debug.Assert(child != null, "We should have been able to find the new element in the hierarchy");
                        if (child != null)
                        {
                            IVsWindowFrame frame;
                            if (editorType == Guid.Empty)
                            {
                                Guid view = Guid.Empty;
                                ErrorHandler.ThrowOnFailure(this.OpenItem(child.Id, ref view, IntPtr.Zero, out frame));
                            }
                            else
                            {
                                ErrorHandler.ThrowOnFailure(this.OpenItemWithSpecific(child.Id, editorFlags, ref editorType, physicalView, ref logicalView, IntPtr.Zero, out frame));
                            }

                            // Show the window frame in the UI and make it the active window
                            if (frame != null)
                            {
                                ErrorHandler.ThrowOnFailure(frame.Show());
                            }
                        }
                    }
                }
            }

            return VSConstants.S_OK;
        }

        /// <summary>
        /// for now used by add folder. Called on the ROOT, as only the project should need
        /// to implement this.
        /// for folders, called with parent folder, blank extension and blank suggested root
        /// </summary>
        public virtual int GenerateUniqueItemName(uint itemIdLoc, string ext, string suggestedRoot, out string itemName)
        {
            string rootName = String.Empty;
            string extToUse = String.Empty;
            itemName = String.Empty;

            //force new items to have a number
            int cb = 1;
            bool found = false;
            bool fFolderCase = false;
            HierarchyNode parent = this.NodeFromItemId(itemIdLoc);

            if (!String.IsNullOrEmpty(ext))
            {
                extToUse = ext.Trim();
            }

            if (!String.IsNullOrEmpty(suggestedRoot))
            {
                suggestedRoot = suggestedRoot.Trim();
            }

            if (suggestedRoot == null || suggestedRoot.Length == 0)
            {
                // foldercase, we assume... 
                suggestedRoot = "NewFolder";
                fFolderCase = true;
            }

            while (!found)
            {
                rootName = suggestedRoot;
                if (cb > 0)
                    rootName += cb.ToString(CultureInfo.CurrentCulture);

                if (extToUse.Length > 0)
                {
                    rootName += extToUse;
                }

                cb++;
                found = true;
                for (HierarchyNode n = parent.FirstChild; n != null; n = n.NextSibling)
                {
                    if (rootName == n.GetEditLabel())
                    {
                        found = false;
                        break;
                    }

                    //if parent is a folder, we need the whole url
                    string parentFolder = parent.Url;
                    if (parent is ProjectNode)
                        parentFolder = Path.GetDirectoryName(parent.Url);

                    string checkFile = Path.Combine(parentFolder, rootName);

                    if (fFolderCase)
                    {
                        if (Directory.Exists(checkFile))
                        {
                            found = false;
                            break;
                        }
                    }
                    else
                    {
                        if (File.Exists(checkFile))
                        {
                            found = false;
                            break;
                        }
                    }
                }
            }

            itemName = rootName;
            return VSConstants.S_OK;
        }


        public virtual int GetItemContext(uint itemId, out Microsoft.VisualStudio.OLE.Interop.IServiceProvider psp)
        {
            CciTracing.TraceCall();
            psp = null;
            HierarchyNode child = this.NodeFromItemId(itemId);
            if (child != null)
            {
                psp = child.OleServiceProvider as IOleServiceProvider;
            }
            return VSConstants.S_OK;
        }


        public virtual int IsDocumentInProject(string mkDoc, out int found, VSDOCUMENTPRIORITY[] pri, out uint itemId)
        {
            CciTracing.TraceCall();
            if (pri != null && pri.Length >= 1)
            {
                pri[0] = VSDOCUMENTPRIORITY.DP_Unsupported;
            }
            found = 0;
            itemId = 0;

            // If it is the project file just return.
            if (NativeMethods.IsSamePath(mkDoc, this.GetMKDocument()))
            {
                found = 1;
                itemId = VSConstants.VSITEMID_ROOT;
            }
            else
            {
                HierarchyNode child = this.FindChild(mkDoc);
                if (child != null)
                {
                    found = 1;
                    itemId = child.Id;
                }
            }

            if (found == 1)
            {
                if (pri != null && pri.Length >= 1)
                {
                    pri[0] = VSDOCUMENTPRIORITY.DP_Standard;
                }
            }

            return VSConstants.S_OK;

        }


        public virtual int OpenItem(uint itemId, ref Guid logicalView, IntPtr punkDocDataExisting, out IVsWindowFrame frame)
        {
            // Init output params
            frame = null;

            HierarchyNode n = this.NodeFromItemId(itemId);
            if (n == null)
            {
                throw new ArgumentException(SR.GetString(SR.ParameterMustBeAValidItemId, CultureInfo.CurrentUICulture), "itemId");
            }

            // Delegate to the document manager object that knows how to open the item
            DocumentManager documentManager = n.GetDocumentManager();
            if (documentManager != null)
            {
                return documentManager.Open(ref logicalView, punkDocDataExisting, out frame, WindowFrameShowAction.DoNotShow);
            }

            // This node does not have an associated document manager and we must fail
            return VSConstants.E_FAIL;
        }


        public virtual int OpenItemWithSpecific(uint itemId, uint editorFlags, ref Guid editorType, string physicalView, ref Guid logicalView, IntPtr docDataExisting, out IVsWindowFrame frame)
        {
            // Init output params
            frame = null;

            HierarchyNode n = this.NodeFromItemId(itemId);
            if (n == null)
            {
                throw new ArgumentException(SR.GetString(SR.ParameterMustBeAValidItemId, CultureInfo.CurrentUICulture), "itemId");
            }

            // Delegate to the document manager object that knows how to open the item
            DocumentManager documentManager = n.GetDocumentManager();
            if (documentManager != null)
            {
                return documentManager.OpenWithSpecific(editorFlags, ref editorType, physicalView, ref logicalView, docDataExisting, out frame, WindowFrameShowAction.DoNotShow);
            }

            // This node does not have an associated document manager and we must fail
            return VSConstants.E_FAIL;
        }


        public virtual int RemoveItem(uint reserved, uint itemId, out int result)
        {
            HierarchyNode n = this.NodeFromItemId(itemId);
            if (n == null)
            {
                throw new ArgumentException(SR.GetString(SR.ParameterMustBeAValidItemId, CultureInfo.CurrentUICulture), "itemId");
            }
            n.Remove(true);
            result = 1;
            return VSConstants.S_OK;
        }


        public virtual int ReopenItem(uint itemId, ref Guid editorType, string physicalView, ref Guid logicalView, IntPtr docDataExisting, out IVsWindowFrame frame)
        {
            // Init output params
            frame = null;

            HierarchyNode n = this.NodeFromItemId(itemId);
            if (n == null)
            {
                throw new ArgumentException(SR.GetString(SR.ParameterMustBeAValidItemId, CultureInfo.CurrentUICulture), "itemId");
            }

            // Delegate to the document manager object that knows how to open the item
            DocumentManager documentManager = n.GetDocumentManager();
            if (documentManager != null)
            {
                return documentManager.OpenWithSpecific(0, ref editorType, physicalView, ref logicalView, docDataExisting, out frame, WindowFrameShowAction.DoNotShow);
            }

            // This node does not have an associated document manager and we must fail
            return VSConstants.E_FAIL;
        }


        /// <summary>
        /// Implements IVsProject3::TransferItem
        /// This function is called when an open miscellaneous file is being transferred
        /// to our project. The sequence is for the shell to call AddItemWithSpecific and
        /// then use TransferItem to transfer the open document to our project.
        /// </summary>
        /// <param name="oldMkDoc">Old document name</param>
        /// <param name="newMkDoc">New document name</param>
        /// <param name="frame">Optional frame if the document is open</param>
        /// <returns></returns>
        public virtual int TransferItem(string oldMkDoc, string newMkDoc, IVsWindowFrame frame)
        {
            // Fail if hierarchy already closed
            if (this.ProjectManager == null || this.ProjectManager.IsClosed)
            {
                return VSConstants.E_FAIL;
            }
            //Fail if the document names passed are null.
            if (oldMkDoc == null || newMkDoc == null)
                return VSConstants.E_INVALIDARG;

            int hr = VSConstants.S_OK;
            VSDOCUMENTPRIORITY[] priority = new VSDOCUMENTPRIORITY[1];
            uint itemid = VSConstants.VSITEMID_NIL;
            uint cookie = 0;
            uint grfFlags = 0;

            IVsRunningDocumentTable pRdt = GetService(typeof(IVsRunningDocumentTable)) as IVsRunningDocumentTable;
            if (pRdt == null)
                return VSConstants.E_ABORT;

            string doc;
            int found;
            IVsHierarchy pHier;
            uint id, readLocks, editLocks;
            IntPtr docdataForCookiePtr = IntPtr.Zero;
            IntPtr docDataPtr = IntPtr.Zero;
            IntPtr hierPtr = IntPtr.Zero;

            // We get the document from the running doc table so that we can see if it is transient
            try
            {
                ErrorHandler.ThrowOnFailure(pRdt.FindAndLockDocument((uint)_VSRDTFLAGS.RDT_NoLock, oldMkDoc, out pHier, out id, out docdataForCookiePtr, out cookie));
            }
            finally
            {
                if (docdataForCookiePtr != IntPtr.Zero)
                    Marshal.Release(docdataForCookiePtr);
            }

            //Get the document info
            try
            {
                ErrorHandler.ThrowOnFailure(pRdt.GetDocumentInfo(cookie, out grfFlags, out readLocks, out editLocks, out doc, out pHier, out id, out docDataPtr));
            }
            finally
            {
                if (docDataPtr != IntPtr.Zero)
                    Marshal.Release(docDataPtr);
            }

            // Now see if the document is in the project. If not, we fail
            try
            {
                ErrorHandler.ThrowOnFailure(IsDocumentInProject(newMkDoc, out found, priority, out itemid));
                Debug.Assert(itemid != VSConstants.VSITEMID_NIL && itemid != VSConstants.VSITEMID_ROOT);
                hierPtr = Marshal.GetComInterfaceForObject(this, typeof(IVsUIHierarchy));
                // Now rename the document
                ErrorHandler.ThrowOnFailure(pRdt.RenameDocument(oldMkDoc, newMkDoc, hierPtr, itemid));
            }
            finally
            {
                if (hierPtr != IntPtr.Zero)
                    Marshal.Release(hierPtr);
            }

            //Change the caption if we are passed a window frame
            if (frame != null)
            {
                string caption = "%2";
                hr = frame.SetProperty((int)(__VSFPROPID.VSFPROPID_OwnerCaption), caption);
            }
            return hr;
        }

        #endregion

        #region IVsProjectBuidSystem Members
        public virtual int SetHostObject(string targetName, string taskName, object hostObject)
        {
            Debug.Assert(targetName != null && taskName != null && this.buildProject != null && this.buildProject.Targets != null);

            if (targetName == null || taskName == null || this.buildProject == null || this.buildProject.Targets == null)
            {
                return VSConstants.E_INVALIDARG;
            }

            this.buildProject.ProjectCollection.HostServices.RegisterHostObject(this.buildProject.FullPath, targetName, taskName, (Microsoft.Build.Framework.ITaskHost)hostObject);

            return VSConstants.S_OK;
        }

        public virtual int BuildTarget(string targetName, out bool success)
        {
            success = false;

            MSBuildResult result = this.Build(targetName);

            if (result == MSBuildResult.Successful)
            {
                success = true;
            }

            return VSConstants.S_OK;
        }

        public virtual int CancelBatchEdit()
        {
            return VSConstants.E_NOTIMPL;
        }

        public virtual int EndBatchEdit()
        {
            return VSConstants.E_NOTIMPL;
        }

        public virtual int StartBatchEdit()
        {
            return VSConstants.E_NOTIMPL;
        }

        /// <summary>
        /// Used to determine the kind of build system, in VS 2005 there's only one defined kind: MSBuild 
        /// </summary>
        /// <param name="kind"></param>
        /// <returns></returns>
        public virtual int GetBuildSystemKind(out uint kind)
        {
            kind = (uint)_BuildSystemKindFlags2.BSK_MSBUILD_VS10;
            return VSConstants.S_OK;
        }

        #endregion

        #region IVsComponentUser methods

        /// <summary>
        /// Add Components to the Project.
        /// Used by the environment to add components specified by the user in the Component Selector dialog 
        /// to the specified project
        /// </summary>
        /// <param name="dwAddCompOperation">The component operation to be performed.</param>
        /// <param name="cComponents">Number of components to be added</param>
        /// <param name="rgpcsdComponents">array of component selector data</param>
        /// <param name="hwndDialog">Handle to the component picker dialog</param>
        /// <param name="pResult">Result to be returned to the caller</param>
        public virtual int AddComponent(VSADDCOMPOPERATION dwAddCompOperation, uint cComponents, System.IntPtr[] rgpcsdComponents, System.IntPtr hwndDialog, VSADDCOMPRESULT[] pResult)
        {
            if (rgpcsdComponents == null || pResult == null)
            {
                return VSConstants.E_FAIL;
            }

            //initalize the out parameter
            pResult[0] = VSADDCOMPRESULT.ADDCOMPRESULT_Success;

            IReferenceContainer references = GetReferenceContainer();
            if (null == references)
            {
                // This project does not support references or the reference container was not created.
                // In both cases this operation is not supported.
                return VSConstants.E_NOTIMPL;
            }
            for (int cCount = 0; cCount < cComponents; cCount++)
            {
                VSCOMPONENTSELECTORDATA selectorData = new VSCOMPONENTSELECTORDATA();
                IntPtr ptr = rgpcsdComponents[cCount];
                selectorData = (VSCOMPONENTSELECTORDATA)Marshal.PtrToStructure(ptr, typeof(VSCOMPONENTSELECTORDATA));
                if (null == references.AddReferenceFromSelectorData(selectorData))
                {
                    //Skip further proccessing since a reference has to be added
                    pResult[0] = VSADDCOMPRESULT.ADDCOMPRESULT_Failure;
                    return VSConstants.S_OK;
                }
            }
            return VSConstants.S_OK;
        }
        #endregion

        #region IVsDependencyProvider Members
        public virtual int EnumDependencies(out IVsEnumDependencies enumDependencies)
        {
            enumDependencies = new EnumDependencies(this.buildDependencyList);
            return VSConstants.S_OK;
        }

        public virtual int OpenDependency(string szDependencyCanonicalName, out IVsDependency dependency)
        {
            dependency = null;
            return VSConstants.S_OK;
        }

        #endregion

        #region IVsSccProject2 Members
        /// <summary>
        /// This method is called to determine which files should be placed under source control for a given VSITEMID within this hierarchy.
        /// </summary>
        /// <param name="itemid">Identifier for the VSITEMID being queried.</param>
        /// <param name="stringsOut">Pointer to an array of CALPOLESTR strings containing the file names for this item.</param>
        /// <param name="flagsOut">Pointer to a CADWORD array of flags stored in DWORDs indicating that some of the files have special behaviors.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code. </returns>
        public virtual int GetSccFiles(uint itemid, CALPOLESTR[] stringsOut, CADWORD[] flagsOut)
        {
            if (itemid == VSConstants.VSITEMID_SELECTION)
            {
                throw new ArgumentException(SR.GetString(SR.InvalidParameter, CultureInfo.CurrentUICulture), "itemid");
            }

            HierarchyNode n = this.NodeFromItemId(itemid);
            if (n == null)
            {
                throw new ArgumentException(SR.GetString(SR.InvalidParameter, CultureInfo.CurrentUICulture), "itemid");
            }

            List<string> files = new List<string>();
            List<tagVsSccFilesFlags> flags = new List<tagVsSccFilesFlags>();

            n.GetSccFiles(files, flags);

            if (stringsOut != null && stringsOut.Length > 0)
            {
                stringsOut[0] = Utilities.CreateCALPOLESTR(files);
            }

            if (flagsOut != null && flagsOut.Length > 0)
            {
                flagsOut[0] = Utilities.CreateCADWORD(flags);
            }

            return VSConstants.S_OK;
        }

        /// <summary>
        /// This method is called to discover special (hidden files) associated with a given VSITEMID within this hierarchy. 
        /// </summary>
        /// <param name="itemid">Identifier for the VSITEMID being queried.</param>
        /// <param name="sccFile">One of the files associated with the node</param>
        /// <param name="stringsOut">Pointer to an array of CALPOLESTR strings containing the file names for this item.</param>
        /// <param name="flagsOut">Pointer to a CADWORD array of flags stored in DWORDs indicating that some of the files have special behaviors.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code. </returns>
        /// <remarks>This method is called to discover any special or hidden files associated with an item in the project hierarchy. It is called when GetSccFiles returns with the SFF_HasSpecialFiles flag set for any of the files associated with the node.</remarks>
        public virtual int GetSccSpecialFiles(uint itemid, string sccFile, CALPOLESTR[] stringsOut, CADWORD[] flagsOut)
        {
            if (itemid == VSConstants.VSITEMID_SELECTION)
            {
                throw new ArgumentException(SR.GetString(SR.InvalidParameter, CultureInfo.CurrentUICulture), "itemid");
            }

            HierarchyNode n = this.NodeFromItemId(itemid);
            if (n == null)
            {
                throw new ArgumentException(SR.GetString(SR.InvalidParameter, CultureInfo.CurrentUICulture), "itemid");
            }

            List<string> files = new List<string>();

            List<tagVsSccFilesFlags> flags = new List<tagVsSccFilesFlags>();

            n.GetSccSpecialFiles(sccFile, files, flags);

            if (stringsOut != null && stringsOut.Length > 0)
            {
                stringsOut[0] = Utilities.CreateCALPOLESTR(files);
            }

            if (flagsOut != null && flagsOut.Length > 0)
            {
                flagsOut[0] = Utilities.CreateCADWORD(flags);
            }

            return VSConstants.S_OK;

        }

        /// <summary>
        /// This method is called by the source control portion of the environment to inform the project of changes to the source control glyph on various nodes. 
        /// </summary>
        /// <param name="affectedNodes">Count of changed nodes.</param>
        /// <param name="itemidAffectedNodes">An array of VSITEMID identifiers of the changed nodes.</param>
        /// <param name="newGlyphs">An array of VsStateIcon glyphs representing the new state of the corresponding item in rgitemidAffectedNodes.</param>
        /// <param name="newSccStatus">An array of status flags from SccStatus corresponding to rgitemidAffectedNodes. </param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code. </returns>
        public virtual int SccGlyphChanged(int affectedNodes, uint[] itemidAffectedNodes, VsStateIcon[] newGlyphs, uint[] newSccStatus)
        {
            // if all the paramaters are null adn the count is 0, it means scc wants us to updated everything
            if (affectedNodes == 0 && itemidAffectedNodes == null && newGlyphs == null && newSccStatus == null)
            {
                this.Redraw(UIHierarchyElements.SccState);
                this.UpdateSccStateIcons();
            }
            else if (affectedNodes > 0 && itemidAffectedNodes != null && newGlyphs != null && newSccStatus != null)
            {
                for (int i = 0; i < affectedNodes; i++)
                {
                    HierarchyNode n = this.NodeFromItemId(itemidAffectedNodes[i]);
                    if (n == null)
                    {
                        throw new ArgumentException(SR.GetString(SR.InvalidParameter, CultureInfo.CurrentUICulture), "itemidAffectedNodes");
                    }

                    n.Redraw(UIHierarchyElements.SccState);
                }
            }
            return VSConstants.S_OK;
        }

        /// <summary>
        /// This method is called by the source control portion of the environment when a project is initially added to source control, or to change some of the project's settings.
        /// </summary>
        /// <param name="sccProjectName">String, opaque to the project, that identifies the project location on the server. Persist this string in the project file. </param>
        /// <param name="sccLocalPath">String, opaque to the project, that identifies the path to the server. Persist this string in the project file.</param>
        /// <param name="sccAuxPath">String, opaque to the project, that identifies the local path to the project. Persist this string in the project file.</param>
        /// <param name="sccProvider">String, opaque to the project, that identifies the source control package. Persist this string in the project file.</param>
        /// <returns>If the method succeeds, it returns S_OK. If it fails, it returns an error code.</returns>
        public virtual int SetSccLocation(string sccProjectName, string sccAuxPath, string sccLocalPath, string sccProvider)
        {
            if (this.IsSccDisabled)
            {
                throw new NotImplementedException();
            }

            if (sccProjectName == null)
            {
                throw new ArgumentNullException("sccProjectName");
            }

            if (sccAuxPath == null)
            {
                throw new ArgumentNullException("sccAuxPath");
            }

            if (sccLocalPath == null)
            {
                throw new ArgumentNullException("sccLocalPath");
            }

            if (sccProvider == null)
            {
                throw new ArgumentNullException("sccProvider");
            }

            // Save our settings (returns true if something changed)
            if (!this.SetSccSettings(sccProjectName, sccLocalPath, sccAuxPath, sccProvider))
            {
                return VSConstants.S_OK;
            }

            bool unbinding = (sccProjectName.Length == 0 && sccProvider.Length == 0);

            if (unbinding || this.QueryEditProjectFile(false))
            {
                this.buildProject.SetProperty(ProjectFileConstants.SccProjectName, sccProjectName);
                this.buildProject.SetProperty(ProjectFileConstants.SccProvider, sccProvider);
                this.buildProject.SetProperty(ProjectFileConstants.SccAuxPath, sccAuxPath);
                this.buildProject.SetProperty(ProjectFileConstants.SccLocalPath, sccLocalPath);
            }

            this.isRegisteredWithScc = true;

            return VSConstants.S_OK;
        }
        #endregion

        #region IVsProjectSpecialFiles Members
        /// <summary>
        /// Allows you to query the project for special files and optionally create them. 
        /// </summary>
        /// <param name="fileId">__PSFFILEID of the file</param>
        /// <param name="flags">__PSFFLAGS flags for the file</param>
        /// <param name="itemid">The itemid of the node in the hierarchy</param>
        /// <param name="fileName">The file name of the special file.</param>
        /// <returns></returns>
        public virtual int GetFile(int fileId, uint flags, out uint itemid, out string fileName)
        {
            itemid = VSConstants.VSITEMID_NIL;
            fileName = String.Empty;

            // We need to return S_OK, otherwise the property page tabs will not be shown.
            return VSConstants.E_NOTIMPL;
        }
        #endregion

        #region IAggregatedHierarchy Members

        /// <summary>
        /// Get the inner object of an aggregated hierarchy
        /// </summary>
        /// <returns>A HierarchyNode</returns>
        public virtual HierarchyNode GetInner()
        {
            return this;
        }

        #endregion

        #region IBuildDependencyUpdate Members

        public virtual IVsBuildDependency[] BuildDependencies
        {
            get
            {
                return this.buildDependencyList.ToArray();
            }
        }

        public virtual void AddBuildDependency(IVsBuildDependency dependency)
        {
            if (this.isClosed || dependency == null)
            {
                return;
            }

            if (!this.buildDependencyList.Contains(dependency))
            {
                this.buildDependencyList.Add(dependency);
            }
        }

        public virtual void RemoveBuildDependency(IVsBuildDependency dependency)
        {
            if (this.isClosed || dependency == null)
            {
                return;
            }

            if (this.buildDependencyList.Contains(dependency))
            {
                this.buildDependencyList.Remove(dependency);
            }
        }

        #endregion

        #region IReferenceDataProvider Members
        /// <summary>
        /// Returns the reference container node.
        /// </summary>
        /// <returns></returns>
        public virtual IReferenceContainer GetReferenceContainer()
        {
            return this.FindChild(ReferenceContainerNode.ReferencesNodeVirtualName) as IReferenceContainer;
        }

        #endregion

        #region IProjectEventsListener Members
        public virtual bool IsProjectEventsListener
        {
            get { return this.isProjectEventsListener; }
            set { this.isProjectEventsListener = value; }
        }
        #endregion

        #region IProjectEventsProvider Members

        /// <summary>
        /// Defines the provider for the project events
        /// </summary>
        IProjectEvents IProjectEventsProvider.ProjectEventsProvider
        {
            get
            {
                return this.projectEventsProvider;
            }
            set
            {
                if (null != this.projectEventsProvider)
                {
                    this.projectEventsProvider.ProjectFileOpened -= this.OnAfterProjectOpen;
                }
                this.projectEventsProvider = value;
                if (null != this.projectEventsProvider)
                {
                    this.projectEventsProvider.ProjectFileOpened += this.OnAfterProjectOpen;
                }
            }
        }

        #endregion

        #region IVsAggregatableProject Members

        /// <summary>
        /// Retrieve the list of project GUIDs that are aggregated together to make this project.
        /// </summary>
        /// <param name="projectTypeGuids">Semi colon separated list of Guids. Typically, the last GUID would be the GUID of the base project factory</param>
        /// <returns>HResult</returns>
        public virtual int GetAggregateProjectTypeGuids(out string projectTypeGuids)
        {
            projectTypeGuids = this.GetProjectProperty(ProjectFileConstants.ProjectTypeGuids, _PersistStorageType.PST_PROJECT_FILE);
            // In case someone manually removed this from our project file, default to our project without flavors
            if (String.IsNullOrEmpty(projectTypeGuids))
                projectTypeGuids = this.ProjectGuid.ToString("B");
            return VSConstants.S_OK;
        }

        /// <summary>
        /// This is where the initialization occurs.
        /// </summary>
        public virtual int InitializeForOuter(string filename, string location, string name, uint flags, ref Guid iid, out IntPtr projectPointer, out int canceled)
        {
            canceled = 0;
            projectPointer = IntPtr.Zero;

            // Initialize the interop-safe versions of this node's implementations of various VS interfaces,
            // which point to the outer object. The project node itself should never be passed to unmanaged 
            // code -- we should always use these properties instead. 
            this.InteropSafeIVsHierarchy = Utilities.GetOuterAs<IVsHierarchy>(this);
            this.InteropSafeIVsUIHierarchy = Utilities.GetOuterAs<IVsUIHierarchy>(this);
            this.InteropSafeIVsProject3 = Utilities.GetOuterAs<IVsProject3>(this);
            this.InteropSafeIVsSccProject2 = Utilities.GetOuterAs<IVsSccProject2>(this);
            this.InteropSafeIVsUIHierWinClipboardHelperEvents = Utilities.GetOuterAs<IVsUIHierWinClipboardHelperEvents>(this);
            this.InteropSafeIVsComponentUser = Utilities.GetOuterAs<IVsComponentUser>(this);

            // Initialize the project
            this.Load(filename, location, name, flags, ref iid, out canceled);

            if (canceled != 1)
            {
                // Set ourself as the project
                return Marshal.QueryInterface(Marshal.GetIUnknownForObject(this), ref iid, out projectPointer);
            }

            return VSConstants.OLE_E_PROMPTSAVECANCELLED;
        }

        /// <summary>
        /// This is called after the project is done initializing the different layer of the aggregations
        /// </summary>
        /// <returns>HResult</returns>
        public virtual int OnAggregationComplete()
        {
            return VSConstants.S_OK;
        }

        /// <summary>
        /// Set the list of GUIDs that are aggregated together to create this project.
        /// </summary>
        /// <param name="projectTypeGuids">Semi-colon separated list of GUIDs, the last one is usually the project factory of the base project factory</param>
        /// <returns>HResult</returns>
        public virtual int SetAggregateProjectTypeGuids(string projectTypeGuids)
        {
            this.SetProjectProperty(ProjectFileConstants.ProjectTypeGuids, _PersistStorageType.PST_PROJECT_FILE, projectTypeGuids);
            return VSConstants.S_OK;
        }

        /// <summary>
        /// We are always the inner most part of the aggregation
        /// and as such we don't support setting an inner project
        /// </summary>
        public virtual int SetInnerProject(object innerProject)
        {
            return VSConstants.E_NOTIMPL;
        }

        #endregion

        #region IVsProjectFlavorCfgProvider Members

        int IVsProjectFlavorCfgProvider.CreateProjectFlavorCfg(IVsCfg pBaseProjectCfg, out IVsProjectFlavorCfg ppFlavorCfg)
        {
            // Our config object is also our IVsProjectFlavorCfg object
            ppFlavorCfg = pBaseProjectCfg as IVsProjectFlavorCfg;

            return VSConstants.S_OK;
        }

        #endregion

        #region IVsBuildPropertyStorage Members

        /// <summary>
        /// Get the property of an item
        /// </summary>
        /// <param name="item">ItemID</param>
        /// <param name="attributeName">Name of the property</param>
        /// <param name="attributeValue">Value of the property (out parameter)</param>
        /// <returns>HRESULT</returns>
        int IVsBuildPropertyStorage.GetItemAttribute(uint item, string attributeName, out string attributeValue)
        {
            attributeValue = null;

            HierarchyNode node = NodeFromItemId(item);
            if (node == null)
                throw new ArgumentException("Invalid item id", "item");

            attributeValue = node.ItemNode.GetMetadata(attributeName);
            return VSConstants.S_OK;
        }

        /// <summary>
        /// Get the value of the property in the project file
        /// </summary>
        /// <param name="propertyName">Name of the property to remove</param>
        /// <param name="configName">Configuration for which to remove the property</param>
        /// <param name="storage">Project or user file (_PersistStorageType)</param>
        /// <param name="propertyValue">Value of the property (out parameter)</param>
        /// <returns>HRESULT</returns>
        int IVsBuildPropertyStorage.GetPropertyValue(string propertyName, string configName, uint storage, out string propertyValue)
        {
            // TODO: when adding support for User files, we need to update this method
            propertyValue = null;
            if (string.IsNullOrEmpty(configName))
            {
                propertyValue = this.GetProjectProperty(propertyName, (_PersistStorageType)storage);
            }
            else
            {
                IVsCfg configurationInterface;
                ErrorHandler.ThrowOnFailure(this.ConfigProvider.GetCfgOfName(configName, string.Empty, out configurationInterface));
                ProjectConfig config = (ProjectConfig)configurationInterface;
                propertyValue = config.GetConfigurationProperty(propertyName, (_PersistStorageType)storage, true);
            }

            return VSConstants.S_OK;
        }

        /// <summary>
        /// Delete a property
        /// In our case this simply mean defining it as null
        /// </summary>
        /// <param name="propertyName">Name of the property to remove</param>
        /// <param name="configName">Configuration for which to remove the property</param>
        /// <param name="storage">Project or user file (_PersistStorageType)</param>
        /// <returns>HRESULT</returns>
        int IVsBuildPropertyStorage.RemoveProperty(string propertyName, string configName, uint storage)
        {
            return ((IVsBuildPropertyStorage)this).SetPropertyValue(propertyName, configName, storage, null);
        }

        /// <summary>
        /// Set a property on an item
        /// </summary>
        /// <param name="item">ItemID</param>
        /// <param name="attributeName">Name of the property</param>
        /// <param name="attributeValue">New value for the property</param>
        /// <returns>HRESULT</returns>
        int IVsBuildPropertyStorage.SetItemAttribute(uint item, string attributeName, string attributeValue)
        {
            HierarchyNode node = NodeFromItemId(item);

            if (node == null)
                throw new ArgumentException("Invalid item id", "item");

            attributeValue = ProjectCollection.Escape(attributeValue);
            node.ItemNode.SetMetadata(attributeName, attributeValue);
            return VSConstants.S_OK;
        }

        /// <summary>
        /// Set a project property
        /// </summary>
        /// <param name="propertyName">Name of the property to set</param>
        /// <param name="configName">Configuration for which to set the property</param>
        /// <param name="storage">Project file or user file (_PersistStorageType)</param>
        /// <param name="propertyValue">New value for that property</param>
        /// <returns>HRESULT</returns>
        int IVsBuildPropertyStorage.SetPropertyValue(string propertyName, string configName, uint storage, string propertyValue)
        {
            // TODO: when adding support for User files, we need to update this method
            if (string.IsNullOrEmpty(configName))
            {
                this.SetProjectProperty(propertyName, (_PersistStorageType)storage, propertyValue);
            }
            else
            {
                IVsCfg configurationInterface;
                ErrorHandler.ThrowOnFailure(this.ConfigProvider.GetCfgOfName(configName, string.Empty, out configurationInterface));
                ProjectConfig config = (ProjectConfig)configurationInterface;
                config.SetConfigurationProperty(propertyName, (_PersistStorageType)storage, propertyValue);
            }

            return VSConstants.S_OK;
        }

        #endregion

		#region IVsDesignTimeAssemblyResolution methods

		public virtual int GetTargetFramework(out string ppTargetFramework)
		{
			ppTargetFramework = this.ProjectManager.TargetFrameworkMoniker.FullName;
			return VSConstants.S_OK;
		}

		public virtual int ResolveAssemblyPathInTargetFx(string[] prgAssemblySpecs, uint cAssembliesToResolve, VsResolvedAssemblyPath[] prgResolvedAssemblyPaths, out uint pcResolvedAssemblyPaths)
		{
			if (prgAssemblySpecs == null || cAssembliesToResolve == 0 || prgResolvedAssemblyPaths == null)
			{
				throw new ArgumentException("One or more of the arguments are invalid.");
			}

			pcResolvedAssemblyPaths = 0;

			if (designTimeAssemblyResolution == null)
				return VSConstants.E_FAIL;

			try
			{
				var results = designTimeAssemblyResolution.Resolve(prgAssemblySpecs.Take((int)cAssembliesToResolve));
				results.CopyTo(prgResolvedAssemblyPaths, 0);
				pcResolvedAssemblyPaths = (uint)results.Length;
			}
			catch (Exception ex)
			{
				return Marshal.GetHRForException(ex);
			}

			return VSConstants.S_OK;
		}

		#endregion

		#region private helper methods

        /// <summary>
        /// Add an item to the hierarchy based on the item path
        /// </summary>
        /// <param name="item">Item to add</param>
        /// <returns>Added node</returns>
        protected virtual HierarchyNode AddIndependentFileNode(MSBuild.ProjectItem item, IDictionary<string, HierarchyNode> parentNodeCache)
        {
            if (item == null)
                throw new ArgumentNullException("item");
            if (parentNodeCache == null)
                throw new ArgumentNullException("parentNodeCache");
            //Contract.Ensures(Contract.Result<HierarchyNode>() != null);

            // Make sure the item is within the project folder hierarchy. If not, link it.
            string linkPath = item.GetMetadataValue(ProjectFileConstants.Link);
            if (String.IsNullOrEmpty(linkPath))
            {
                string projectFolder = new Uri(this.ProjectFolder).LocalPath;
                string itemPath = new Uri(Path.Combine(this.ProjectFolder, item.EvaluatedInclude)).LocalPath;
                if (!itemPath.StartsWith(projectFolder, StringComparison.OrdinalIgnoreCase))
                {
                    linkPath = Path.GetFileName(item.EvaluatedInclude);
                    item.SetMetadataValue(ProjectFileConstants.Link, linkPath);
                }
            }

            HierarchyNode currentParent = GetItemParentNode(item, parentNodeCache);
            return AddFileNodeToNode(item, currentParent);
        }

        /// <summary>
        /// Add a dependent file node to the hierarchy
        /// </summary>
        /// <param name="item">msbuild item to add</param>
        /// <param name="parentNode">Parent Node</param>
        /// <returns>Added node</returns>
        protected virtual HierarchyNode AddDependentFileNodeToNode(MSBuild.ProjectItem item, HierarchyNode parentNode)
        {
            FileNode node = this.CreateDependentFileNode(new ProjectElement(this, item, false));
            parentNode.AddChild(node);

            // Make sure to set the HasNameRelation flag on the dependent node if it is related to the parent by name
            if (!node.HasParentNodeNameRelation && string.Equals(node.GetRelationalName(), parentNode.GetRelationalName(), StringComparison.OrdinalIgnoreCase))
            {
                node.HasParentNodeNameRelation = true;
            }

            return node;
        }

        /// <summary>
        /// Add a file node to the hierarchy
        /// </summary>
        /// <param name="item">msbuild item to add</param>
        /// <param name="parentNode">Parent Node</param>
        /// <returns>Added node</returns>
        protected virtual HierarchyNode AddFileNodeToNode(MSBuild.ProjectItem item, HierarchyNode parentNode)
        {
            FileNode node = this.CreateFileNode(new ProjectElement(this, item, false));
            parentNode.AddChild(node);
            return node;
        }

        /// <summary>
        /// Get the parent node of an msbuild item
        /// </summary>
        /// <param name="item">msbuild item</param>
        /// <returns>parent node</returns>
        protected virtual HierarchyNode GetItemParentNode(MSBuild.ProjectItem item, IDictionary<string, HierarchyNode> nodeCache)
        {
            if (item == null)
                throw new ArgumentNullException("item");
            if (nodeCache == null)
                throw new ArgumentNullException("nodeCache");
            //Contract.Ensures(Contract.Result<HierarchyNode>() != null);

            HierarchyNode currentParent = this;
            string strPath = item.EvaluatedInclude;
            string link = item.GetMetadataValue(ProjectFileConstants.Link);
            if (!string.IsNullOrEmpty(link))
                strPath = link;

            strPath = Path.GetDirectoryName(strPath);
            if (strPath.Length > 0)
            {
                if (!nodeCache.TryGetValue(strPath, out currentParent))
                {
                    // Use the relative to verify the folders...
                    currentParent = this.CreateFolderNodes(strPath, nodeCache);
                    nodeCache.Add(strPath, currentParent);
                }
            }

            return currentParent;
        }

        protected virtual MSBuildExecution.ProjectPropertyInstance GetMsBuildProperty(string propertyName, _PersistStorageType storageType, bool resetCache)
        {
            ProjectInstance projectInstance = this.currentConfig;
            if (resetCache || this.currentConfig == null || storageType == _PersistStorageType.PST_USER_FILE)
            {
                // Get properties from project file and cache it
                this.SetCurrentConfiguration();
                this.currentConfig = this.buildProject.CreateProjectInstance();
                if (storageType == _PersistStorageType.PST_PROJECT_FILE)
                    projectInstance = this.currentConfig;
                else if (UserBuildProject != null)
                    projectInstance = UserBuildProject.CreateProjectInstance();
            }

            if (projectInstance == null)
            {
                if (storageType == _PersistStorageType.PST_PROJECT_FILE)
                    throw new InvalidOperationException(String.Format(CultureInfo.CurrentCulture, SR.GetString(SR.FailedToRetrieveProperties, CultureInfo.CurrentUICulture), propertyName));

                return null;
            }

            // return property asked for
            return GetMsBuildProperty(projectInstance, propertyName);
        }

        protected static ProjectPropertyInstance GetMsBuildProperty(ProjectInstance projectInstance, string propertyName)
        {
            return projectInstance.GetProperty(propertyName);
        }

        protected static string GetOutputPath(MSBuildExecution.ProjectInstance properties)
        {
            ProjectPropertyInstance property = GetMsBuildProperty(properties, "OutputPath");
            string outputPath = property != null ? property.EvaluatedValue : null;

            if (!String.IsNullOrEmpty(outputPath))
            {
                outputPath = outputPath.Replace('/', Path.DirectorySeparatorChar);
                if (outputPath[outputPath.Length - 1] != Path.DirectorySeparatorChar)
                    outputPath += Path.DirectorySeparatorChar;
            }

            return outputPath;
        }

        protected static bool GetBoolAttr(MSBuildExecution.ProjectInstance properties, string name)
        {
            ProjectPropertyInstance property = GetMsBuildProperty(properties, name);
            string stringValue = property != null ? property.EvaluatedValue : null;
            return string.Equals("true", stringValue, StringComparison.OrdinalIgnoreCase);
        }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Globalization", "CA1308:NormalizeStringsToUppercase")]
        protected virtual string GetAssemblyFileName(MSBuildExecution.ProjectInstance properties)
        {
            this.currentConfig = properties;
            string name = null;

            ProjectPropertyInstance property = GetMsBuildProperty(properties, ProjectFileConstants.IntermediateAssembly);
            name = property != null ? property.EvaluatedValue : null;
            if (!string.IsNullOrWhiteSpace(name))
                return Path.GetFileName(name);

            property = GetMsBuildProperty(properties, ProjectFileConstants.AssemblyName);
            name = property != null ? property.EvaluatedValue : null;
            if (name == null)
                name = this.Caption;

            string outputtype = GetProjectProperty(ProjectFileConstants.OutputType, _PersistStorageType.PST_PROJECT_FILE, false);

            if (outputtype == "library")
            {
                outputtype = outputtype.ToLowerInvariant();
                name += ".dll";
            }
            else
            {
                name += ".exe";
            }

            return name;
        }

        /// <summary>
        /// Updates our scc project settings. 
        /// </summary>
        /// <param name="sccProjectName">String, opaque to the project, that identifies the project location on the server. Persist this string in the project file. </param>
        /// <param name="sccLocalPath">String, opaque to the project, that identifies the path to the server. Persist this string in the project file.</param>
        /// <param name="sccAuxPath">String, opaque to the project, that identifies the local path to the project. Persist this string in the project file.</param>
        /// <param name="sccProvider">String, opaque to the project, that identifies the source control package. Persist this string in the project file.</param>
        /// <returns>Returns true if something changed.</returns>
        protected virtual bool SetSccSettings(string sccProjectName, string sccLocalPath, string sccAuxPath, string sccProvider)
        {
            bool changed = false;
            Debug.Assert(sccProjectName != null && sccLocalPath != null && sccAuxPath != null && sccProvider != null);
            if (!String.Equals(sccProjectName, this._sccProjectName, StringComparison.OrdinalIgnoreCase) ||
                !String.Equals(sccLocalPath, this._sccLocalPath, StringComparison.OrdinalIgnoreCase) ||
                !String.Equals(sccAuxPath, this._sccAuxPath, StringComparison.OrdinalIgnoreCase) ||
                !String.Equals(sccProvider, this._sccProvider, StringComparison.OrdinalIgnoreCase))
            {
                changed = true;
                this._sccProjectName = sccProjectName;
                this._sccLocalPath = sccLocalPath;
                this._sccAuxPath = sccAuxPath;
                this._sccProvider = sccProvider;
            }


            return changed;
        }

        /// <summary>
        /// Sets the scc info from the project file.
        /// </summary>
        protected virtual void InitSccInfo()
        {
            this._sccProjectName = this.GetProjectProperty(ProjectFileConstants.SccProjectName, _PersistStorageType.PST_PROJECT_FILE);
            this._sccLocalPath = this.GetProjectProperty(ProjectFileConstants.SccLocalPath, _PersistStorageType.PST_PROJECT_FILE);
            this._sccProvider = this.GetProjectProperty(ProjectFileConstants.SccProvider, _PersistStorageType.PST_PROJECT_FILE);
            this._sccAuxPath = this.GetProjectProperty(ProjectFileConstants.SccAuxPath, _PersistStorageType.PST_PROJECT_FILE);
        }

        protected virtual void OnAfterProjectOpen(object sender, ProjectFileOpenedEventArgs e)
        {
            this.projectOpened = true;
        }

        protected static XmlElement WrapXmlFragment(XmlDocument document, XmlElement root, Guid flavor, string configuration, string fragment)
        {
            XmlElement node = document.CreateElement(ProjectFileConstants.FlavorProperties);
            XmlAttribute attribute = document.CreateAttribute(ProjectFileConstants.Guid);
            attribute.Value = flavor.ToString("B");
            node.Attributes.Append(attribute);
            if (!String.IsNullOrEmpty(configuration))
            {
                attribute = document.CreateAttribute(ProjectFileConstants.Configuration);
                attribute.Value = configuration;
                node.Attributes.Append(attribute);
            }
            node.InnerXml = fragment;
            root.AppendChild(node);
            return node;
        }

        /// <summary>
        /// Sets the project guid from the project file. If no guid is found a new one is created and assigne for the instance project guid.
        /// </summary>
        protected virtual void SetProjectGuidFromProjectFile()
        {
            string projectGuid = this.GetProjectProperty(ProjectFileConstants.ProjectGuid, _PersistStorageType.PST_PROJECT_FILE);
            if (String.IsNullOrEmpty(projectGuid))
            {
                this.projectIdGuid = Guid.NewGuid();
            }
            else
            {
                Guid guid = new Guid(projectGuid);
                if (guid != this.projectIdGuid)
                {
                    this.projectIdGuid = guid;
                }
            }
        }

        /// <summary>
        /// Helper for sharing common code between Build() and BuildAsync()
        /// </summary>
        /// <param name="output"></param>
        /// <returns></returns>
        protected virtual bool BuildPrelude(IVsOutputWindowPane output)
        {
            bool engineLogOnlyCritical = false;
            // If there is some output, then we can ask the build engine to log more than
            // just the critical events.
            if (null != output)
            {
                engineLogOnlyCritical = BuildEngine.OnlyLogCriticalEvents;
                BuildEngine.OnlyLogCriticalEvents = false;
            }

            this.SetOutputLogger(output);
            return engineLogOnlyCritical;
        }

        /// <summary>
        /// Recusively parses the tree and closes all nodes.
        /// </summary>
        /// <param name="node">The subtree to close.</param>
        protected static void CloseAllNodes(HierarchyNode node)
        {
            if (node == null)
                throw new ArgumentNullException("node");

            for (HierarchyNode n = node.FirstChild; n != null; n = n.NextSibling)
            {
                if (n.FirstChild != null)
                {
                    CloseAllNodes(n);
                }

                n.Close();
            }
        }

        /// <summary>
        /// Set the build project with the new project instance value
        /// </summary>
        /// <param name="project">The new build project instance</param>
        protected virtual void SetBuildProject(MSBuild.Project project)
        {
            this.buildProject = project;
            this.baseUri = null;
            if (this.buildProject != null)
            {
                SetupProjectGlobalPropertiesThatAllProjectSystemsMustSet();

                _availableFileBuildActions.Clear();
                _availableFileBuildActions.Add(new KeyValuePair<string, prjBuildAction>("None", prjBuildAction.prjBuildActionNone));
                _availableFileBuildActions.Add(new KeyValuePair<string, prjBuildAction>("Compile", prjBuildAction.prjBuildActionCompile));
                _availableFileBuildActions.Add(new KeyValuePair<string, prjBuildAction>("Content", prjBuildAction.prjBuildActionContent));
                _availableFileBuildActions.Add(new KeyValuePair<string, prjBuildAction>("EmbeddedResource", prjBuildAction.prjBuildActionEmbeddedResource));
                ICollection<MSBuild.ProjectItem> availableItemNames = buildProject.GetItems("AvailableItemName");
                foreach (var itemName in availableItemNames)
                {
                    if (!_availableFileBuildActions.Any(i => string.Equals(i.Key, itemName.EvaluatedInclude, StringComparison.OrdinalIgnoreCase)))
                        _availableFileBuildActions.Add(new KeyValuePair<string, prjBuildAction>(itemName.EvaluatedInclude, (prjBuildAction)_availableFileBuildActions.Count));
                }
            }
        }

        /// <summary>
        /// Setup the global properties for project instance.
        /// </summary>
        protected virtual void SetupProjectGlobalPropertiesThatAllProjectSystemsMustSet()
        {
            string solutionDirectory = null;
            string solutionFile = null;
            string userOptionsFile = null;

            IVsSolution solution = this.Site.GetService(typeof(SVsSolution)) as IVsSolution;
            if (solution != null)
            {
                // We do not want to throw. If we cannot set the solution related constants we set them to empty string.
                if (ErrorHandler.Failed(solution.GetSolutionInfo(out solutionDirectory, out solutionFile, out userOptionsFile)))
                {
                    solutionDirectory = null;
                    solutionFile = null;
                    userOptionsFile = null;
                }
            }

            if (solutionDirectory == null)
            {
                solutionDirectory = String.Empty;
            }

            if (solutionFile == null)
            {
                solutionFile = String.Empty;
            }

            string solutionFileName = (solutionFile.Length == 0) ? String.Empty : Path.GetFileName(solutionFile);

            string solutionName = (solutionFile.Length == 0) ? String.Empty : Path.GetFileNameWithoutExtension(solutionFile);

            string solutionExtension = String.Empty;
            if (solutionFile.Length > 0 && Path.HasExtension(solutionFile))
            {
                solutionExtension = Path.GetExtension(solutionFile);
            }

            this.buildProject.SetGlobalProperty(GlobalProperty.SolutionDir.ToString(), solutionDirectory);
            this.buildProject.SetGlobalProperty(GlobalProperty.SolutionPath.ToString(), solutionFile);
            this.buildProject.SetGlobalProperty(GlobalProperty.SolutionFileName.ToString(), solutionFileName);
            this.buildProject.SetGlobalProperty(GlobalProperty.SolutionName.ToString(), solutionName);
            this.buildProject.SetGlobalProperty(GlobalProperty.SolutionExt.ToString(), solutionExtension);

            // Other misc properties
            this.buildProject.SetGlobalProperty(GlobalProperty.BuildingInsideVisualStudio.ToString(), "true");
            this.buildProject.SetGlobalProperty(GlobalProperty.Configuration.ToString(), ProjectConfig.Debug);
            this.buildProject.SetGlobalProperty(GlobalProperty.Platform.ToString(), ProjectConfig.AnyCPU);

            // DevEnvDir property
            object installDirAsObject = null;

            IVsShell shell = this.Site.GetService(typeof(SVsShell)) as IVsShell;
            if (shell != null)
            {
                // We do not want to throw. If we cannot set the solution related constants we set them to empty string.
                if (ErrorHandler.Failed(shell.GetProperty((int)__VSSPROPID.VSSPROPID_InstallDirectory, out installDirAsObject)))
                    installDirAsObject = null;
            }

            string installDir = ((string)installDirAsObject);

            if (String.IsNullOrEmpty(installDir))
            {
                installDir = String.Empty;
            }
            else
            {
                // Ensure that we have traimnling backslash as this is done for the langproj macros too.
                if (installDir[installDir.Length - 1] != Path.DirectorySeparatorChar)
                {
                    installDir += Path.DirectorySeparatorChar;
                }
            }

            this.buildProject.SetGlobalProperty(GlobalProperty.DevEnvDir.ToString(), installDir);
        }

        /// <summary>
        /// Attempts to lock in the privilege of running a build in Visual Studio.
        /// </summary>
        /// <param name="designTime"><c>false</c> if this build was called for by the Solution Build Manager; <c>true</c> otherwise.</param>
        /// <param name="requiresUIThread">
        /// Need to claim the UI thread for build under the following conditions:
        /// 1. The build must use a resource that uses the UI thread, such as
        /// - you set HostServices and you have a host object which requires (even indirectly) the UI thread (VB and C# compilers do this for instance.)
        /// or,
        /// 2. The build requires the in-proc node AND waits on the UI thread for the build to complete, such as:
        /// - you use a ProjectInstance to build, or
        /// - you have specified a host object, whether or not it requires the UI thread, or
        /// - you set HostServices and you have specified a node affinity.
        /// - In addition to the above you also call submission.Execute(), or you call submission.ExecuteAsync() and then also submission.WaitHandle.Wait*().
        /// </param>
        /// <returns>A value indicating whether a build may proceed.</returns>
        /// <remarks>
        /// This method must be called on the UI thread.
        /// </remarks>
        protected virtual bool TryBeginBuild(bool designTime, bool requiresUIThread = false)
        {
            IVsBuildManagerAccessor accessor = null;

            if (this.Site != null)
            {
                accessor = this.Site.GetService(typeof(SVsBuildManagerAccessor)) as IVsBuildManagerAccessor;
            }

            bool releaseUIThread = false;

            try
            {
                // If the SVsBuildManagerAccessor service is absent, we're not running within Visual Studio.
                if (accessor != null)
                {
                    if (requiresUIThread)
                    {
                        int result = accessor.ClaimUIThreadForBuild();
                        if (result < 0)
                        {
                            // Not allowed to claim the UI thread right now. Try again later.
                            return false;
                        }

                        releaseUIThread = true; // assume we need to release this immediately until we get through the whole gauntlet.
                    }

                    if (designTime)
                    {
                        int result = accessor.BeginDesignTimeBuild();
                        if (result < 0)
                        {
                            // Not allowed to begin a design-time build at this time. Try again later.
                            return false;
                        }
                    }

                    // We obtained all the resources we need.  So don't release the UI thread until after the build is finished.
                    releaseUIThread = false;
                }
                else
                {
                    BuildParameters buildParameters = new BuildParameters(this.buildEngine ?? ProjectCollection.GlobalProjectCollection);
                    BuildManager.DefaultBuildManager.BeginBuild(buildParameters);
                }

                this.buildInProcess = true;
                return true;
            }
            finally
            {
                // If we were denied the privilege of starting a design-time build,
                // we need to release the UI thread.
                if (releaseUIThread)
                {
                    Debug.Assert(accessor != null, "We think we need to release the UI thread for an accessor we don't have!");
                    Marshal.ThrowExceptionForHR(accessor.ReleaseUIThreadForBuild());
                }
            }
        }

        /// <summary>
        /// Lets Visual Studio know that we're done with our design-time build so others can use the build manager.
        /// </summary>
        /// <param name="submission">The build submission that built, if any.</param>
        /// <param name="designTime">This must be the same value as the one passed to <see cref="TryBeginBuild"/>.</param>
        /// <param name="requiresUIThread">This must be the same value as the one passed to <see cref="TryBeginBuild"/>.</param>
        /// <remarks>
        /// This method must be called on the UI thread.
        /// </remarks>
        protected virtual void EndBuild(BuildSubmission submission, bool designTime, bool requiresUIThread = false)
        {
            IVsBuildManagerAccessor accessor = null;

            if (this.Site != null)
            {
                accessor = this.Site.GetService(typeof(SVsBuildManagerAccessor)) as IVsBuildManagerAccessor;
            }

            if (accessor != null)
            {
                // It's very important that we try executing all three end-build steps, even if errors occur partway through.
                try
                {
                    if (submission != null)
                    {
                        Marshal.ThrowExceptionForHR(accessor.UnregisterLoggers(submission.SubmissionId));
                    }
                }
                catch (Exception ex)
                {
                    if (ErrorHandler.IsCriticalException(ex))
                    {
                        throw;
                    }

                    Trace.TraceError(ex.ToString());
                }

                try
                {
                    if (designTime)
                    {
                        Marshal.ThrowExceptionForHR(accessor.EndDesignTimeBuild());
                    }
                }
                catch (Exception ex)
                {
                    if (ErrorHandler.IsCriticalException(ex))
                    {
                        throw;
                    }

                    Trace.TraceError(ex.ToString());
                }


                try
                {
                    if (requiresUIThread)
                    {
                        Marshal.ThrowExceptionForHR(accessor.ReleaseUIThreadForBuild());
                    }
                }
                catch (Exception ex)
                {
                    if (ErrorHandler.IsCriticalException(ex))
                    {
                        throw;
                    }

                    Trace.TraceError(ex.ToString());
                }
            }
            else
            {
                BuildManager.DefaultBuildManager.EndBuild();
            }

            this.buildInProcess = false;
        }

		protected virtual string GetComponentPickerDirectories()
		{
			IVsComponentEnumeratorFactory4 enumFactory = this._site.GetService(typeof(SCompEnumService)) as IVsComponentEnumeratorFactory4;
			if (enumFactory == null)
			{
				throw new InvalidOperationException("Missing the SCompEnumService service.");
			}

			IEnumComponents enumerator;
			Marshal.ThrowExceptionForHR(enumFactory.GetReferencePathsForTargetFramework(this.TargetFrameworkMoniker.FullName, out enumerator));
			if (enumerator == null)
			{
				throw new ApplicationException("IVsComponentEnumeratorFactory4.GetReferencePathsForTargetFramework returned null.");
			}

			StringBuilder paths = new StringBuilder();
			VSCOMPONENTSELECTORDATA[] data = new VSCOMPONENTSELECTORDATA[1];
			uint fetchedCount;
			while (enumerator.Next(1, data, out fetchedCount) == VSConstants.S_OK && fetchedCount == 1)
			{
				Debug.Assert(data[0].type == VSCOMPONENTTYPE.VSCOMPONENTTYPE_Path);
				paths.Append(data[0].bstrFile);
				paths.Append(";");
			}

			// Trim off the last semicolon.
			if (paths.Length > 0)
			{
				paths.Length -= 1;
			}

			return paths.ToString();
		}

		#endregion

		public virtual int UpdateTargetFramework(IVsHierarchy pHier, string currentTargetFramework, string newTargetFramework)
		{
			FrameworkName moniker = new FrameworkName(newTargetFramework);
			SetProjectProperty("TargetFrameworkIdentifier", _PersistStorageType.PST_PROJECT_FILE, moniker.Identifier);
			SetProjectProperty("TargetFrameworkVersion", _PersistStorageType.PST_PROJECT_FILE, "v" + moniker.Version);
			SetProjectProperty("TargetFrameworkProfile", _PersistStorageType.PST_PROJECT_FILE, moniker.Profile);
			return VSConstants.S_OK;
		}

		public virtual int UpgradeProject(uint grfUpgradeFlags)
		{
			int hr = VSConstants.S_OK;

			if (!PerformTargetFrameworkCheck())
			{
				// Just return OLE_E_PROMPTSAVECANCELLED here which will cause the shell
				// to leave the project in an unloaded state.
				hr = VSConstants.OLE_E_PROMPTSAVECANCELLED;
			}

			return hr;
		}

		protected virtual bool PerformTargetFrameworkCheck()
		{
			if (this.IsFrameworkOnMachine())
			{
				// Nothing to do since the framework is present.
				return true;
			}

			return ShowRetargetingDialog();
		}

		/// <summary>
		/// 
		/// </summary>
		/// <returns>
		/// <c>true</c> if the project will be retargeted.  <c>false</c> to load project in unloaded state.
		/// </returns>
		protected virtual bool ShowRetargetingDialog()
		{
			var retargetDialog = this._site.GetService(typeof(SVsFrameworkRetargetingDlg)) as IVsFrameworkRetargetingDlg;
			if (retargetDialog == null)
			{
				throw new InvalidOperationException("Missing SVsFrameworkRetargetingDlg service.");
			}

			// We can only display the retargeting dialog if the IDE is not in command-line mode.
			if (IsIdeInCommandLineMode)
			{
				string message = SR.GetString(SR.CannotLoadUnknownTargetFrameworkProject, this.FileName, this.TargetFrameworkMoniker);
				var outputWindow = this._site.GetService(typeof(SVsOutputWindow)) as IVsOutputWindow;
				if (outputWindow != null)
				{
					IVsOutputWindowPane outputPane;
					Guid outputPaneGuid = VSConstants.GUID_BuildOutputWindowPane;
					if (outputWindow.GetPane(ref outputPaneGuid, out outputPane) >= 0 && outputPane != null)
					{
						Marshal.ThrowExceptionForHR(outputPane.OutputString(message));
					}
				}

				throw new InvalidOperationException(message);
			}
			else
			{
				uint outcome;
				int dontShowAgain;
				Marshal.ThrowExceptionForHR(retargetDialog.ShowFrameworkRetargetingDlg(
					this.Package.ProductUserContext,
					this.FileName,
					this.TargetFrameworkMoniker.FullName,
					(uint)__FRD_FLAGS.FRDF_DEFAULT,
					out outcome,
					out dontShowAgain));
				switch ((__FRD_OUTCOME)outcome)
				{
					case __FRD_OUTCOME.FRDO_GOTO_DOWNLOAD_SITE:
						Marshal.ThrowExceptionForHR(retargetDialog.NavigateToFrameworkDownloadUrl());
						return false;
					case __FRD_OUTCOME.FRDO_LEAVE_UNLOADED:
						return false;
					case __FRD_OUTCOME.FRDO_RETARGET_TO_40:
						// If we are retargeting to 4.0, then set the flag to set the appropriate Target Framework.
						// This will dirty the project file, so we check it out of source control now -- so that
						// the user can associate getting the checkout prompt with the "No Framework" dialog.
						if (QueryEditProjectFile(false /* bSuppressUI */))
						{
							var retargetingService = this._site.GetService(typeof(SVsTrackProjectRetargeting)) as IVsTrackProjectRetargeting;
							if (retargetingService != null)
							{
								// We surround our batch retargeting request with begin/end because in individual project load
								// scenarios the solution load context hasn't done it for us.
								Marshal.ThrowExceptionForHR(retargetingService.BeginRetargetingBatch());
								Marshal.ThrowExceptionForHR(retargetingService.BatchRetargetProject(this.InteropSafeIVsHierarchy, DefaultTargetFrameworkMoniker.FullName, true));
								Marshal.ThrowExceptionForHR(retargetingService.EndRetargetingBatch());
							}
							else
							{
								// Just setting the moniker to null will allow the default framework (.NETFX 4.0) to assert itself.
								this.TargetFrameworkMoniker = null;
							}

							return true;
						}
						else
						{
							return false;
						}
					default:
						throw new ArgumentException("Unexpected outcome from retargeting dialog.");
				}
			}
		}

		protected virtual bool IsFrameworkOnMachine()
		{
			var multiTargeting = this._site.GetService(typeof(SVsFrameworkMultiTargeting)) as IVsFrameworkMultiTargeting;
			Array frameworks;
			Marshal.ThrowExceptionForHR(multiTargeting.GetSupportedFrameworks(out frameworks));
			foreach (string fx in frameworks)
			{
				uint compat;
				int hr = multiTargeting.CheckFrameworkCompatibility(this.TargetFrameworkMoniker.FullName, fx, out compat);
				if (hr < 0)
				{
					break;
				}

				if ((__VSFRAMEWORKCOMPATIBILITY)compat == __VSFRAMEWORKCOMPATIBILITY.VSFRAMEWORKCOMPATIBILITY_COMPATIBLE)
				{
					return true;
				}
			}

			return false;
		}
	}
}
