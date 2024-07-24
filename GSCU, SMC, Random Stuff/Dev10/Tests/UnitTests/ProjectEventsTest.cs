/***************************************************************************

Copyright (c) Microsoft Corporation. All rights reserved.
This code is licensed under the Visual Studio SDK license terms.
THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.

***************************************************************************/

using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Microsoft.VisualStudio.Project.UnitTests
{
	public static class ProjectEventsUtilities
	{
		public static ProjectFileOpenedEventArgs CreateAfterProjectFileOpenedEventArgs(bool added)
		{
			return new ProjectFileOpenedEventArgs(added);
		}

		public static ProjectFileClosingEventArgs CreateBeforeProjectFileClosedEventArgs(bool removed)
		{
			return new ProjectFileClosingEventArgs(removed);
		}
	}

	[TestClass]
	public class ProjectEventsTest
	{
		private class ProjectEventsSource : IProjectEvents, IDisposable
		{
			public enum ProjectEventsSinkType
			{
				AfterOpened,
				BeforeClosed,
				AnyEvent
			}
			public event EventHandler<ProjectFileOpenedEventArgs> ProjectFileOpened;
			public event EventHandler<ProjectFileClosingEventArgs> ProjectFileClosing;

			public void SignalOpenStatus(bool isOpened)
			{
				if(isOpened)
				{
					if(null != ProjectFileOpened)
					{
						ProjectFileOpened(this, ProjectEventsUtilities.CreateAfterProjectFileOpenedEventArgs(true));
					}
				}
				else
				{
					if(null != ProjectFileClosing)
					{
						ProjectFileClosing(this, ProjectEventsUtilities.CreateBeforeProjectFileClosedEventArgs(true));
					}
				}
			}

			public bool IsSinkRegister(ProjectEventsSinkType sinkType)
			{
				if(ProjectEventsSinkType.AfterOpened == sinkType)
				{
					return (null != ProjectFileOpened);
				}
				if(ProjectEventsSinkType.BeforeClosed == sinkType)
				{
					return (null != ProjectFileClosing);
				}
				return (null != ProjectFileOpened) || (null != ProjectFileClosing);
			}

			public void Dispose()
			{
				Assert.IsFalse(IsSinkRegister(ProjectEventsSinkType.AnyEvent), "ProjectEvents sink registered at shutdown.");
			}
		}

		private static bool IsProjectOpened(ProjectNode project)
		{
			return project.HasProjectOpened;
		}

		[TestMethod]
		public void SetOpenStatusTest()
		{
			using(ProjectEventsSource eventSource = new ProjectEventsSource())
			{
				ProjectTestClass project = new ProjectTestClass(new ProjectTestPackage());
				IProjectEventsProvider eventProvider = project as IProjectEventsProvider;
				Assert.IsNotNull(eventProvider, "Project class does not implements IProjectEventsProvider.");
				Assert.IsFalse(IsProjectOpened(project), "Project is opened right after its creation.");
				eventProvider.ProjectEventsProvider = eventSource;
				eventSource.SignalOpenStatus(true);
				Assert.IsTrue(IsProjectOpened(project), "Project is not opened after the AfterProjectFileOpened is signaled.");
				project.Close();
			}
		}

		[TestMethod]
		public void SetMultipleSource()
		{
			using(ProjectEventsSource firstSource = new ProjectEventsSource())
			{
				using(ProjectEventsSource secondSource = new ProjectEventsSource())
				{
					ProjectTestClass project = new ProjectTestClass(new ProjectTestPackage());
					IProjectEventsProvider eventProvider = project as IProjectEventsProvider;
					Assert.IsNotNull(eventProvider, "Project class does not implements IProjectEventsProvider.");
					eventProvider.ProjectEventsProvider = firstSource;
					eventProvider.ProjectEventsProvider = secondSource;
					Assert.IsFalse(IsProjectOpened(project));
					firstSource.SignalOpenStatus(true);
					Assert.IsFalse(IsProjectOpened(project));
					secondSource.SignalOpenStatus(true);
					Assert.IsTrue(IsProjectOpened(project));
					project.Close();
				}
			}
		}

		[TestMethod]
		public void SetNullSource()
		{
			ProjectTestClass project = new ProjectTestClass(new ProjectTestPackage());
			IProjectEventsProvider eventProvider = project as IProjectEventsProvider;
			Assert.IsNotNull(eventProvider, "Project class does not implements IProjectEventsProvider.");
			eventProvider.ProjectEventsProvider = null;
			project.Close();
		}
	}
}