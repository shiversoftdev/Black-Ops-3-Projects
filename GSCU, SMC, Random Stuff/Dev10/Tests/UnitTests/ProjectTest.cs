/***************************************************************************

Copyright (c) Microsoft Corporation. All rights reserved.
This code is licensed under the Visual Studio SDK license terms.
THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.

***************************************************************************/

using System;
using System.IO;
using System.Reflection;
using EnvDTE;
using Microsoft.VisualStudio;
using Microsoft.VisualStudio.Shell.Interop;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Microsoft.VsSDK.UnitTestLibrary;
using System.Collections.Generic;

namespace Microsoft.VisualStudio.Project.UnitTests
{
	[TestClass()]
	public class PackageTest
	{
		/// <summary>
		/// This class is used to make sure that the OleServiceProvider is disposed and
		/// that the project is closed. It implements IDisposable so that the tests can
		/// use the standard "using" pattern so that the Dispose method is called also
		/// in case of exception.
		/// </summary>
		private class PackageTestEnvironment : IDisposable
		{
			private static FieldInfo projectOpened;
			private static string projectXml;

			private static GenericMockFactory extensibilityFactory;
			private static GenericMockFactory ExtensibilityFactory
			{
				get
				{
					if(null == extensibilityFactory)
					{
						extensibilityFactory = new GenericMockFactory("MockExtensibility", new Type[] { typeof(IVsExtensibility3) });
					}
					return extensibilityFactory;
				}
			}

			private static GenericMockFactory configManagerFactory;
			private static GenericMockFactory ConfigurationManagerFactory
			{
				get
				{
					if(null == configManagerFactory)
					{
						configManagerFactory = new GenericMockFactory("MockConfigManager", new Type[] { typeof(ConfigurationManager) });
					}
					return configManagerFactory;
				}
			}

			private ProjectTestClass project;
			private Microsoft.VsSDK.UnitTestLibrary.OleServiceProvider services;

			public PackageTestEnvironment()
			{
				// Create the project
				project = new ProjectTestClass(new ProjectTestPackage());

				// Site the project
				services = Microsoft.VsSDK.UnitTestLibrary.OleServiceProvider.CreateOleServiceProviderWithBasicServices();
				LocalRegistryMock localRegistry = new LocalRegistryMock();
				localRegistry.RegistryRoot = @"Software\Microsoft\VisualStudio\9.0";
				services.AddService(typeof(SLocalRegistry), localRegistry, true);

				BaseMock mockConfiguration = new GenericMockFactory("MockConfiguration", new[] { typeof(Configuration) }).GetInstance();
				mockConfiguration.AddMethodReturnValues(string.Format("{0}.{1}", typeof(Configuration).FullName, "ConfigurationName"), new[] { "Debug" });
				mockConfiguration.AddMethodReturnValues(string.Format("{0}.{1}", typeof(Configuration).FullName, "PlatformName"), new[] { "AnyCPU" });

				BaseMock mockConfigMgr = ConfigurationManagerFactory.GetInstance();
				mockConfigMgr.AddMethodReturnValues(string.Format("{0}.{1}", typeof(ConfigurationManager).FullName, ""), new[] { mockConfiguration });

				BaseMock extensibility = ExtensibilityFactory.GetInstance();
				extensibility.AddMethodReturnValues(
					string.Format("{0}.{1}", typeof(IVsExtensibility3).FullName, "GetConfigMgr"),
					new object[] { 0, null, null, mockConfigMgr });
				services.AddService(typeof(IVsExtensibility), extensibility, false);

				project.SetSite(services);

				// Init the msbuild engine
				Microsoft.Build.Evaluation.ProjectCollection engine = VisualStudio.Project.Utilities.InitializeMsBuildEngine(null, services);
				Assert.IsNotNull(engine, "MSBuild Engine could not be initialized");

				// Retrieve the project file content, load it and save it
				string fullpath = Path.Combine(new DirectoryInfo(Assembly.GetExecutingAssembly().Location).Parent.FullName, "TestProject.proj");
				if(string.IsNullOrEmpty(projectXml))
				{
					projectXml = Properties.Resources.TestProject;
					using(TextWriter writer = new StreamWriter(fullpath))
					{
						writer.Write(projectXml);
					}
				}

				// Init the msbuild project
				Microsoft.Build.Evaluation.Project buildProject = VisualStudio.Project.Utilities.InitializeMsBuildProject(engine, fullpath);
				Assert.IsNotNull(buildProject, "MSBuild project not initialized correctly in InitializeMsBuildProject");

                //Verify that we can set the build project on the projectnode
                project.BuildProject = buildProject;

		    	// Now the project is opened, so we can update its internal variable.
				if(null == projectOpened)
				{
					projectOpened = typeof(VisualStudio.Project.ProjectNode).GetField("projectOpened", BindingFlags.Instance | BindingFlags.NonPublic);
				}
				projectOpened.SetValue(project, true);
			}

			public ProjectTestClass Project
			{
				get { return project; }
			}

			public void Dispose()
			{
				IVsHierarchy hierarchy = project as IVsHierarchy;
				if(null != hierarchy)
				{
					hierarchy.Close();
				}
				project = null;

				if(null != services)
				{
					services.Dispose();
					services = null;
				}
			}
		}

		[TestMethod()]
		public void GlobalProperties()
		{
			using(PackageTestEnvironment testEnv = new PackageTestEnvironment())
			{
				IVsBuildPropertyStorage buildProperty = testEnv.Project as IVsBuildPropertyStorage;
				Assert.IsNotNull(buildProperty, "Project does not implements IVsBuildPropertyStorage.");

				// Get
				string propertyName = "GlobalProperty";
				string value = null;
				int hr = buildProperty.GetPropertyValue(propertyName, null, (uint)_PersistStorageType.PST_PROJECT_FILE, out value);
				Assert.AreEqual<int>(VSConstants.S_OK, hr, "GetPropertyValue failed");
				Assert.AreEqual("Global", value);

				// Set (with get to confirm)
				string newValue = "UpdatedGlobal";
				hr = buildProperty.SetPropertyValue(propertyName, null, (uint)_PersistStorageType.PST_PROJECT_FILE, newValue);
				Assert.AreEqual<int>(VSConstants.S_OK, hr, "SetPropertyValue failed");
				hr = buildProperty.GetPropertyValue(propertyName, null, (uint)_PersistStorageType.PST_PROJECT_FILE, out value);
				Assert.AreEqual<int>(VSConstants.S_OK, hr, "GetPropertyValue failed");
				Assert.AreEqual(newValue, value);

				// Remove (with get to confirm)
				hr = buildProperty.RemoveProperty(propertyName, null, (uint)_PersistStorageType.PST_PROJECT_FILE);
				Assert.AreEqual<int>(VSConstants.S_OK, hr, "RemoveProperty failed");
				hr = buildProperty.GetPropertyValue(propertyName, null, (uint)_PersistStorageType.PST_PROJECT_FILE, out value);
				Assert.AreEqual<int>(VSConstants.S_OK, hr, "GetPropertyValue failed");
				Assert.AreEqual(String.Empty, value);
			}
		}

		[TestMethod()]
		public void ConfigProperties()
		{
			using(PackageTestEnvironment testEnv = new PackageTestEnvironment())
			{
				IVsBuildPropertyStorage buildProperty = testEnv.Project as IVsBuildPropertyStorage;
				Assert.IsNotNull(buildProperty, "Project does not implements IVsBuildPropertyStorage.");

				// Get (2 different configs)
				string propertyName = "ConfigProperty";
				string value = null;
				int hr = buildProperty.GetPropertyValue(propertyName, "Debug", (uint)_PersistStorageType.PST_PROJECT_FILE, out value);
				Assert.AreEqual<int>(VSConstants.S_OK, hr, "GetPropertyValue failed");
				Assert.AreEqual("DebugValue", value);
				hr = buildProperty.GetPropertyValue(propertyName, "Release", (uint)_PersistStorageType.PST_PROJECT_FILE, out value);
				Assert.AreEqual<int>(VSConstants.S_OK, hr, "GetPropertyValue failed");
				Assert.AreEqual("ReleaseValue", value);

				// Set (with get to confirm)
				string newValue = "UpdatedConfig";
				hr = buildProperty.SetPropertyValue(propertyName, "Debug", (uint)_PersistStorageType.PST_PROJECT_FILE, newValue);
				Assert.AreEqual<int>(VSConstants.S_OK, hr, "SetPropertyValue failed");
				hr = buildProperty.GetPropertyValue(propertyName, "Debug", (uint)_PersistStorageType.PST_PROJECT_FILE, out value);
				Assert.AreEqual<int>(VSConstants.S_OK, hr, "GetPropertyValue failed");
				Assert.AreEqual(newValue, value);
			}
		}

		[TestMethod()]
		public void FileProperties()
		{
			using(PackageTestEnvironment testEnv = new PackageTestEnvironment())
			{
				Microsoft.Build.Evaluation.Project buildProject = testEnv.Project.BuildProject;

				// Add a node to the project map so it can be resolved
				IEnumerable<Microsoft.Build.Evaluation.ProjectItem> itemGroup = buildProject.GetItems("Compile");
                Microsoft.Build.Evaluation.ProjectItem item = null;
                foreach (Microsoft.Build.Evaluation.ProjectItem currentItem in itemGroup)
				{
					if(currentItem.EvaluatedInclude == "OtherFile.cs")
					{
						item = currentItem;
						break;
					}
				}
				VisualStudio.Project.FileNode node = new VisualStudio.Project.FileNode(testEnv.Project, testEnv.Project.GetProjectElement(item));
				uint itemID = node.Id;

				IVsBuildPropertyStorage buildProperty = testEnv.Project as IVsBuildPropertyStorage;
				Assert.IsNotNull(buildProperty, "Project does not implements IVsBuildPropertyStorage.");
				// Get
				string propertyName = "Metadata";
				string value = null;
				int hr = buildProperty.GetItemAttribute(itemID, propertyName, out value);
				Assert.AreEqual<int>(VSConstants.S_OK, hr, "GetItemAttribute failed");
				Assert.AreEqual("OtherFileProperty", value);

				// Set (with get to confirm)
				string newValue = "UpdatedFileProperty";
				hr = buildProperty.SetItemAttribute(itemID, propertyName, newValue);
				Assert.AreEqual<int>(VSConstants.S_OK, hr, "SetPropertyValue failed");
				hr = buildProperty.GetItemAttribute(itemID, propertyName, out value);
				Assert.AreEqual<int>(VSConstants.S_OK, hr, "GetItemAttribute failed");
				Assert.AreEqual(newValue, value);
			}
		}
	}
}
