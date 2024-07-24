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
	using System.Collections.Generic;
	using System.Globalization;
	using System.IO;
	using System.Linq;
	using System.Text;
	using Microsoft.Build.Framework;
	using Microsoft.Build.Utilities;
	using Microsoft.VisualStudio.Shell.Interop;

	public partial class DesignTimeAssemblyResolution
	{
		private const string OriginalItemSpec = "originalItemSpec";
	
		private const string FoundAssemblyVersion = "Version";
		
		private const string HighestVersionInRedistList = "HighestVersionInRedist";
		
		private const string OutOfRangeDependencies = "OutOfRangeDependencies";

		private RarInputs rarInputs;

		public bool EnableLogging { get; set; }

		[System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA2204:Literals should be spelled correctly", MessageId = "GetFrameworkPaths")]
		public virtual void Initialize(ProjectNode projectNode)
		{
			if (projectNode == null)
			{
				throw new ArgumentNullException("projectNode");
			}

			if (projectNode.CallMSBuild("GetFrameworkPaths") != MSBuildResult.Successful)
			{
				throw new InvalidOperationException("Build of GetFrameworkPaths failed.");
			}

			this.rarInputs = new RarInputs(projectNode.CurrentConfig);
		}

		public virtual VsResolvedAssemblyPath[] Resolve(IEnumerable<string> assemblies)
		{
			if (assemblies == null)
			{
				throw new ArgumentNullException("assemblies");
			}

			// Resolve references WITHOUT invoking MSBuild to avoid re-entrancy problems.
			const bool projectDtar = true;
			var rar = new Microsoft.Build.Tasks.ResolveAssemblyReference();
			var engine = new MockEngine(EnableLogging);
			rar.BuildEngine = engine;

			// first set common properties/items then if projectDtar then set additional projectDtar properties
			ITaskItem[] assemblyItems = assemblies.Select(assembly => new TaskItem(assembly)).ToArray();
			rar.Assemblies = assemblyItems;
			rar.SearchPaths = rarInputs.PdtarSearchPaths;

			rar.TargetFrameworkDirectories = rarInputs.TargetFrameworkDirectories;
			rar.AllowedAssemblyExtensions = rarInputs.AllowedAssemblyExtensions;
			rar.TargetProcessorArchitecture = rarInputs.TargetProcessorArchitecture;
			rar.TargetFrameworkVersion = rarInputs.TargetFrameworkVersion;
			rar.TargetFrameworkMoniker = rarInputs.TargetFrameworkMoniker;
			rar.TargetFrameworkMonikerDisplayName = rarInputs.TargetFrameworkMonikerDisplayName;
			rar.TargetedRuntimeVersion = rarInputs.TargetedRuntimeVersion;
			rar.FullFrameworkFolders = rarInputs.FullFrameworkFolders;
			rar.LatestTargetFrameworkDirectories = rarInputs.LatestTargetFrameworkDirectories;
			rar.FullTargetFrameworkSubsetNames = rarInputs.FullTargetFrameworkSubsetNames;
			rar.FullFrameworkAssemblyTables = rarInputs.FullFrameworkAssemblyTables;
			rar.IgnoreDefaultInstalledAssemblySubsetTables = rarInputs.IgnoreDefaultInstalledAssemblySubsetTables;
			rar.ProfileName = rarInputs.ProfileName;

			rar.Silent = !this.EnableLogging;
			rar.FindDependencies = true;
			rar.AutoUnify = false;
			rar.FindSatellites = false;
			rar.FindSerializationAssemblies = false;
			rar.FindRelatedFiles = false;

			// This set needs to be kept in sync with the set of project instance data that
			// is populated into RarInputs
			if (projectDtar)
			{
				// set project dtar specific properties 
				rar.CandidateAssemblyFiles = rarInputs.CandidateAssemblyFiles;
				rar.StateFile = rarInputs.StateFile;
				rar.InstalledAssemblySubsetTables = rarInputs.InstalledAssemblySubsetTables;
				rar.TargetFrameworkSubsets = rarInputs.TargetFrameworkSubsets;
			}

			IEnumerable<VsResolvedAssemblyPath> results;

			try
			{
				rar.Execute();
				results = FilterResults(rar.ResolvedFiles).Select(pair => new VsResolvedAssemblyPath
				{
					bstrOrigAssemblySpec = pair.Key,
					bstrResolvedAssemblyPath = pair.Value,
				});
			}
			catch (Exception ex)
			{
				if (ErrorHandler.IsCriticalException(ex))
				{
					throw;
				}

				engine.RecordRARExecutionException(ex);
				results = Enumerable.Empty<VsResolvedAssemblyPath>();
			}
			finally
			{
				if (this.EnableLogging)
				{
					WriteLogFile(engine, projectDtar, assemblies);
				}
			}

			return results.ToArray();
		}

		protected static IEnumerable<KeyValuePair<string, string>> FilterResults(IEnumerable<ITaskItem> resolvedFiles)
		{
			foreach (ITaskItem resolvedFile in resolvedFiles)
			{
				bool bAddResolvedAssemblyToResultList = true;

				// excludeVersionWarningsFromResult
				string foundAssemblyVersion = resolvedFile.GetMetadata(FoundAssemblyVersion);
				string highestVersionInRedist = resolvedFile.GetMetadata(HighestVersionInRedistList);

				Version asmVersion = null;
				bool parsedAsmVersion = Version.TryParse(foundAssemblyVersion, out asmVersion);

				Version redistVersion = null;
				bool parsedRedistVersion = Version.TryParse(highestVersionInRedist, out redistVersion);

				if ((parsedAsmVersion && parsedRedistVersion) && asmVersion > redistVersion)
				{
					// if the version of the assembly is greater than the highest version - for that assembly - found in 
					// the chained(possibly) redist lists; then the assembly does not belong to the target framework 
					bAddResolvedAssemblyToResultList = false;
				}

				// check outOfRangeDependencies
				string outOfRangeDependencies = resolvedFile.GetMetadata(OutOfRangeDependencies);
				if (!String.IsNullOrEmpty(outOfRangeDependencies))
				{
					// This metadata is a semi-colon delimited list of dependent assembly names which target
					// a higher framework. If this metadata is NOT EMPTY then
					// the current assembly does have dependencies which are greater than the current target framework

					// so let's exclude this assembly
					bAddResolvedAssemblyToResultList = false;
				}

				if (bAddResolvedAssemblyToResultList)
				{
					yield return new KeyValuePair<string, string>(resolvedFile.GetMetadata(OriginalItemSpec), resolvedFile.ItemSpec);
				}
			}
		}

		protected static void WriteLogFile(MockEngine engine, bool projectDtar, IEnumerable<string> assemblies)
		{
			string logFilePrefix = projectDtar ? "P" : "G";

			string logFilePath = Path.Combine(Path.GetTempPath(), logFilePrefix + @"Dtar" + (Guid.NewGuid()).ToString("N", CultureInfo.InvariantCulture) + ".log");

			StringBuilder inputs = new StringBuilder();

			Array.ForEach<string>(assemblies.ToArray(), assembly => { inputs.Append(assembly); inputs.Append(";"); inputs.Append("\n"); });

			string logAssemblies = "Inputs: \n" + inputs.ToString() + "\n\n";

			string finalLog = logAssemblies + engine.Log;

			string[] finalLogLines = finalLog.Split(new char[] { '\n' });

			File.WriteAllLines(logFilePath, finalLogLines);
		}
	}
}
