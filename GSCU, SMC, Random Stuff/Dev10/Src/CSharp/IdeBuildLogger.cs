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
    using System.Collections.Concurrent;
    using System.Diagnostics;
    using System.Diagnostics.CodeAnalysis;
    using System.Globalization;
    using System.Text;
    using System.Threading;
    using System.Windows.Forms.Design;
    using System.Windows.Threading;
    using Microsoft.Build.Framework;
    using Microsoft.Build.Utilities;
    using Microsoft.VisualStudio.Shell;
    using Microsoft.VisualStudio.Shell.Interop;
    using Microsoft.VisualStudio.TextManager.Interop;
    using Microsoft.Win32;
    using IOleServiceProvider = Microsoft.VisualStudio.OLE.Interop.IServiceProvider;

    /// <summary>
    /// This class implements an MSBuild logger that output events to VS outputwindow and tasklist.
    /// </summary>
    public class IdeBuildLogger : Logger, IDisposable
    {
        #region fields

        // TODO: Remove these constants when we have a version that supports getting the verbosity using automation.
        private string buildVerbosityRegistryRoot = @"Software\Microsoft\VisualStudio\10.0";
        private const string buildVerbosityRegistrySubKey = @"General";
        private const string buildVerbosityRegistryKey = "MSBuildLoggerVerbosity";

        private int currentIndent;
        private IVsOutputWindowPane outputWindowPane;
        private string errorString = SR.GetString(SR.Error, CultureInfo.CurrentUICulture);
        private string warningString = SR.GetString(SR.Warning, CultureInfo.CurrentUICulture);
        private TaskProvider taskProvider;
        private IVsHierarchy hierarchy;
        private ServiceProvider serviceProvider;
        private Dispatcher dispatcher;
        private bool haveCachedVerbosity = false;

        // Queues to manage Tasks and Error output plus message logging
        private ConcurrentQueue<Func<ErrorTask>> taskQueue;
        private ConcurrentQueue<string> outputQueue;

        #endregion

        #region properties

        public IServiceProvider ServiceProvider
        {
            get { return this.serviceProvider; }
        }

        public string WarningString
        {
            get { return this.warningString; }
            set { this.warningString = value; }
        }

        public string ErrorString
        {
            get { return this.errorString; }
            set { this.errorString = value; }
        }

        /// <summary>
        /// When the build is not a "design time" (background or secondary) build this is True
        /// </summary>
        /// <remarks>
        /// The only known way to detect an interactive build is to check this.outputWindowPane for null.
        /// </remarks>
        protected bool InteractiveBuild
        {
            get { return this.outputWindowPane != null; }
        }

        /// <summary>
        /// When building from within VS, setting this will
        /// enable the logger to retrieve the verbosity from
        /// the correct registry hive.
        /// </summary>
        public string BuildVerbosityRegistryRoot
        {
            get { return this.buildVerbosityRegistryRoot; }
            set 
            {
                this.buildVerbosityRegistryRoot = value;
            }
        }

        /// <summary>
        /// Set to null to avoid writing to the output window
        /// </summary>
        public IVsOutputWindowPane OutputWindowPane
        {
            get { return this.outputWindowPane; }
            set { this.outputWindowPane = value; }
        }

        #endregion

        #region constructors

        /// <summary>
        /// Constructor.  Initialize member data.
        /// </summary>
        public IdeBuildLogger(IVsOutputWindowPane output, TaskProvider taskProvider, IVsHierarchy hierarchy)
        {
            if (taskProvider == null)
                throw new ArgumentNullException("taskProvider");
            if (hierarchy == null)
                throw new ArgumentNullException("hierarchy");

            Trace.WriteLineIf(Thread.CurrentThread.GetApartmentState() != ApartmentState.STA, "WARNING: IDEBuildLogger constructor running on the wrong thread.");

            IOleServiceProvider site;
            Microsoft.VisualStudio.ErrorHandler.ThrowOnFailure(hierarchy.GetSite(out site));

            this.taskProvider = taskProvider;
            this.outputWindowPane = output;
            this.hierarchy = hierarchy;
            this.serviceProvider = new ServiceProvider(site);
            this.dispatcher = Dispatcher.CurrentDispatcher;
        }

        #endregion

        #region overridden methods

        /// <summary>
        /// Overridden from the Logger class.
        /// </summary>
        public override void Initialize(IEventSource eventSource)
        {
            if (null == eventSource)
            {
                throw new ArgumentNullException("eventSource");
            }

            this.taskQueue = new ConcurrentQueue<Func<ErrorTask>>();
            this.outputQueue = new ConcurrentQueue<string>();

            eventSource.BuildStarted += new BuildStartedEventHandler(BuildStartedHandler);
            eventSource.BuildFinished += new BuildFinishedEventHandler(BuildFinishedHandler);
            eventSource.ProjectStarted += new ProjectStartedEventHandler(ProjectStartedHandler);
            eventSource.ProjectFinished += new ProjectFinishedEventHandler(ProjectFinishedHandler);
            eventSource.TargetStarted += new TargetStartedEventHandler(TargetStartedHandler);
            eventSource.TargetFinished += new TargetFinishedEventHandler(TargetFinishedHandler);
            eventSource.TaskStarted += new TaskStartedEventHandler(TaskStartedHandler);
            eventSource.TaskFinished += new TaskFinishedEventHandler(TaskFinishedHandler);
            eventSource.CustomEventRaised += new CustomBuildEventHandler(CustomHandler);
            eventSource.ErrorRaised += new BuildErrorEventHandler(ErrorHandler);
            eventSource.WarningRaised += new BuildWarningEventHandler(WarningHandler);
            eventSource.MessageRaised += new BuildMessageEventHandler(MessageHandler);
        }

        #endregion

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (disposing)
            {
                if (serviceProvider != null)
                {
                    serviceProvider.Dispose();
                }
            }
        }

        #region event delegates

        /// <summary>
        /// This is the delegate for BuildStartedHandler events.
        /// </summary>
        protected virtual void BuildStartedHandler(object sender, BuildStartedEventArgs buildEvent)
        {
            // NOTE: This may run on a background thread!
            ClearCachedVerbosity();
            ClearQueuedOutput();
            ClearQueuedTasks();

            QueueOutputEvent(MessageImportance.Low, buildEvent);
        }

        /// <summary>
        /// This is the delegate for BuildFinishedHandler events.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="buildEvent"></param>
        protected virtual void BuildFinishedHandler(object sender, BuildFinishedEventArgs buildEvent)
        {
            if (buildEvent == null)
                throw new ArgumentNullException("buildEvent");

            // NOTE: This may run on a background thread!
            MessageImportance importance = buildEvent.Succeeded ? MessageImportance.Low : MessageImportance.High;
            QueueOutputText(importance, Environment.NewLine);
            QueueOutputEvent(importance, buildEvent);

            // flush output and error queues
            ReportQueuedOutput();
            ReportQueuedTasks();
        }

        /// <summary>
        /// This is the delegate for ProjectStartedHandler events.
        /// </summary>
        protected virtual void ProjectStartedHandler(object sender, ProjectStartedEventArgs buildEvent)
        {
            // NOTE: This may run on a background thread!
            QueueOutputEvent(MessageImportance.Low, buildEvent);
        }

        /// <summary>
        /// This is the delegate for ProjectFinishedHandler events.
        /// </summary>
        protected virtual void ProjectFinishedHandler(object sender, ProjectFinishedEventArgs buildEvent)
        {
            if (buildEvent == null)
                throw new ArgumentNullException("buildEvent");

            // NOTE: This may run on a background thread!
            QueueOutputEvent(buildEvent.Succeeded ? MessageImportance.Low : MessageImportance.High, buildEvent);
        }

        /// <summary>
        /// This is the delegate for TargetStartedHandler events.
        /// </summary>
        protected virtual void TargetStartedHandler(object sender, TargetStartedEventArgs buildEvent)
        {
            // NOTE: This may run on a background thread!
            QueueOutputEvent(MessageImportance.Low, buildEvent);
            IndentOutput();
        }

        /// <summary>
        /// This is the delegate for TargetFinishedHandler events.
        /// </summary>
        protected virtual void TargetFinishedHandler(object sender, TargetFinishedEventArgs buildEvent)
        {
            // NOTE: This may run on a background thread!
            UnindentOutput();
            QueueOutputEvent(MessageImportance.Low, buildEvent);
        }

        /// <summary>
        /// This is the delegate for TaskStartedHandler events.
        /// </summary>
        protected virtual void TaskStartedHandler(object sender, TaskStartedEventArgs buildEvent)
        {
            // NOTE: This may run on a background thread!
            QueueOutputEvent(MessageImportance.Low, buildEvent);
            IndentOutput();
        }

        /// <summary>
        /// This is the delegate for TaskFinishedHandler events.
        /// </summary>
        protected virtual void TaskFinishedHandler(object sender, TaskFinishedEventArgs buildEvent)
        {
            // NOTE: This may run on a background thread!
            UnindentOutput();
            QueueOutputEvent(MessageImportance.Low, buildEvent);
        }

        /// <summary>
        /// This is the delegate for CustomHandler events.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="buildEvent"></param>
        protected virtual void CustomHandler(object sender, CustomBuildEventArgs buildEvent)
        {
            // NOTE: This may run on a background thread!
            QueueOutputEvent(MessageImportance.High, buildEvent);
        }

        /// <summary>
        /// This is the delegate for error events.
        /// </summary>
        protected virtual void ErrorHandler(object sender, BuildErrorEventArgs errorEvent)
        {
            if (errorEvent == null)
                throw new ArgumentNullException("errorEvent");

            // NOTE: This may run on a background thread!
            QueueOutputText(GetFormattedErrorMessage(errorEvent.File, errorEvent.LineNumber, errorEvent.ColumnNumber, false, errorEvent.Code, errorEvent.Message));
            QueueTaskEvent(errorEvent);
        }

        /// <summary>
        /// This is the delegate for warning events.
        /// </summary>
        protected virtual void WarningHandler(object sender, BuildWarningEventArgs warningEvent)
        {
            if (warningEvent == null)
                throw new ArgumentNullException("warningEvent");

            // NOTE: This may run on a background thread!
            QueueOutputText(MessageImportance.High, GetFormattedErrorMessage(warningEvent.File, warningEvent.LineNumber, warningEvent.ColumnNumber, true, warningEvent.Code, warningEvent.Message));
            QueueTaskEvent(warningEvent);
        }

        /// <summary>
        /// This is the delegate for Message event types
        /// </summary>		
        protected virtual void MessageHandler(object sender, BuildMessageEventArgs messageEvent)
        {
            if (messageEvent == null)
                throw new ArgumentNullException("messageEvent");

            // NOTE: This may run on a background thread!
            QueueOutputEvent(messageEvent.Importance, messageEvent);
        }

        protected virtual void NavigateTo(object sender, EventArgs arguments)
        {
            Microsoft.VisualStudio.Shell.Task task = sender as Microsoft.VisualStudio.Shell.Task;
            if (task == null)
                throw new ArgumentException("The sender should be a Task.", "sender");

            // Get the doc data for the task's document
            if (String.IsNullOrEmpty(task.Document))
                return;

            IVsUIShellOpenDocument openDoc = serviceProvider.GetService(typeof(IVsUIShellOpenDocument)) as IVsUIShellOpenDocument;
            if (openDoc == null)
                return;

            IVsWindowFrame frame;
            IOleServiceProvider sp;
            IVsUIHierarchy hier;
            uint itemid;
            Guid logicalView = VSConstants.LOGVIEWID_Code;

            if (Microsoft.VisualStudio.ErrorHandler.Failed(openDoc.OpenDocumentViaProject(task.Document, ref logicalView, out sp, out hier, out itemid, out frame)) || frame == null)
                return;

            object docData;
            if (Microsoft.VisualStudio.ErrorHandler.Failed(frame.GetProperty((int)__VSFPROPID.VSFPROPID_DocData, out docData)))
                return;

            // Get the VsTextBuffer
            VsTextBuffer buffer = docData as VsTextBuffer;
            if (buffer == null)
            {
                IVsTextBufferProvider bufferProvider = docData as IVsTextBufferProvider;
                if (bufferProvider != null)
                {
                    IVsTextLines lines;
                    Microsoft.VisualStudio.ErrorHandler.ThrowOnFailure(bufferProvider.GetTextBuffer(out lines));
                    buffer = lines as VsTextBuffer;
                    Debug.Assert(buffer != null, "IVsTextLines does not implement IVsTextBuffer");
                    if (buffer == null)
                        return;
                }
            }

            // Finally, perform the navigation.
            IVsTextManager mgr = serviceProvider.GetService(typeof(VsTextManagerClass)) as IVsTextManager;
            if (mgr == null)
                return;

            Microsoft.VisualStudio.ErrorHandler.CallWithCOMConvention(() => mgr.NavigateToLineAndColumn(buffer, ref logicalView, task.Line, task.Column, task.Line, task.Column));
        }

        #endregion

        #region output queue

        protected virtual void QueueOutputEvent(MessageImportance importance, BuildEventArgs buildEvent)
        {
            if (buildEvent == null)
                throw new ArgumentNullException("buildEvent");

            // NOTE: This may run on a background thread!
            if (LogAtImportance(importance) && !string.IsNullOrEmpty(buildEvent.Message))
            {
                StringBuilder message = new StringBuilder(this.currentIndent + buildEvent.Message.Length);
                if (this.currentIndent > 0)
                {
                    message.Append('\t', this.currentIndent);
                }
                message.AppendLine(buildEvent.Message);

                QueueOutputText(message.ToString());
            }
        }

        protected virtual void QueueOutputText(MessageImportance importance, string text)
        {
            // NOTE: This may run on a background thread!
            if (LogAtImportance(importance))
            {
                QueueOutputText(text);
            }
        }

        protected virtual void QueueOutputText(string text)
        {
            // NOTE: This may run on a background thread!
            if (this.OutputWindowPane != null)
            {
                // Enqueue the output text
                this.outputQueue.Enqueue(text);

                // We want to interactively report the output. But we don't want to dispatch
                // more than one at a time, otherwise we might overflow the main thread's
                // message queue. So, we only report the output if the queue was empty.
                if (this.outputQueue.Count == 1)
                {
                    ReportQueuedOutput();
                }
            }
        }

        protected virtual void IndentOutput()
        {
            // NOTE: This may run on a background thread!
            this.currentIndent++;
        }

        protected virtual void UnindentOutput()
        {
            // NOTE: This may run on a background thread!
            this.currentIndent--;
        }

        protected virtual void ReportQueuedOutput()
        {
            // NOTE: This may run on a background thread!
            // We need to output this on the main thread. We must use BeginInvoke because the main thread may not be pumping events yet.
            BeginInvokeWithErrorMessage(this.serviceProvider, this.dispatcher, () =>
            {
                if (this.OutputWindowPane != null)
                {
                    string outputString;

                    while (this.outputQueue.TryDequeue(out outputString))
                    {
                        Microsoft.VisualStudio.ErrorHandler.ThrowOnFailure(this.OutputWindowPane.OutputString(outputString));
                    }
                }
            });
        }

        protected virtual void ClearQueuedOutput()
        {
            // NOTE: This may run on a background thread!
            this.outputQueue = new ConcurrentQueue<string>();
        }

        #endregion output queue

        #region task queue

        protected virtual void QueueTaskEvent(BuildEventArgs errorEvent)
        {
            this.taskQueue.Enqueue(() =>
            {
                ErrorTask task = new ErrorTask();

                if (errorEvent is BuildErrorEventArgs)
                {
                    BuildErrorEventArgs errorArgs = (BuildErrorEventArgs)errorEvent;
                    task.Document = errorArgs.File;
                    task.ErrorCategory = TaskErrorCategory.Error;
                    task.Line = errorArgs.LineNumber - 1; // The task list does +1 before showing this number.
                    task.Column = errorArgs.ColumnNumber;
                    task.Priority = TaskPriority.High;
                }
                else if (errorEvent is BuildWarningEventArgs)
                {
                    BuildWarningEventArgs warningArgs = (BuildWarningEventArgs)errorEvent;
                    task.Document = warningArgs.File;
                    task.ErrorCategory = TaskErrorCategory.Warning;
                    task.Line = warningArgs.LineNumber - 1; // The task list does +1 before showing this number.
                    task.Column = warningArgs.ColumnNumber;
                    task.Priority = TaskPriority.Normal;
                }

                task.Text = errorEvent.Message;
                task.Category = TaskCategory.BuildCompile;
                task.HierarchyItem = hierarchy;
                task.Navigate += NavigateTo;

                return task;
            });

            // NOTE: Unlike output we don't want to interactively report the tasks. So we never queue
            // call ReportQueuedTasks here. We do this when the build finishes.
        }

        protected virtual void ReportQueuedTasks()
        {
            // NOTE: This may run on a background thread!
            // We need to output this on the main thread. We must use BeginInvoke because the main thread may not be pumping events yet.
            BeginInvokeWithErrorMessage(this.serviceProvider, this.dispatcher, () =>
            {
                this.taskProvider.SuspendRefresh();
                try
                {
                    Func<ErrorTask> taskFunc;

                    while (this.taskQueue.TryDequeue(out taskFunc))
                    {
                        // Create the error task
                        ErrorTask task = taskFunc();

                        // Log the task
                        this.taskProvider.Tasks.Add(task);
                    }
                }
                finally
                {
                    this.taskProvider.ResumeRefresh();
                }
            });
        }

        protected virtual void ClearQueuedTasks()
        {
            // NOTE: This may run on a background thread!
            this.taskQueue = new ConcurrentQueue<Func<ErrorTask>>();

            if (this.InteractiveBuild)
            {
                // We need to clear this on the main thread. We must use BeginInvoke because the main thread may not be pumping events yet.
                BeginInvokeWithErrorMessage(this.serviceProvider, this.dispatcher, () =>
                {
                    this.taskProvider.Tasks.Clear();
                });
            }
        }

        #endregion task queue

        #region helpers

        /// <summary>
        /// This method takes a <see cref="MessageImportance"/> and returns <see langword="true"/> if messages
        /// at importance <paramref name="importance"/> should be logged.  Otherwise return <see langword="false"/>.
        /// </summary>
        protected virtual bool LogAtImportance(MessageImportance importance)
        {
            // If importance is too low for current settings, ignore the event
            bool logIt = false;

            this.SetVerbosity();

            switch (this.Verbosity)
            {
                case LoggerVerbosity.Quiet:
                    logIt = false;
                    break;
                case LoggerVerbosity.Minimal:
                    logIt = (importance == MessageImportance.High);
                    break;
                case LoggerVerbosity.Normal:
                // Falling through...
                case LoggerVerbosity.Detailed:
                    logIt = (importance != MessageImportance.Low);
                    break;
                case LoggerVerbosity.Diagnostic:
                    logIt = true;
                    break;
                default:
                    Debug.Fail("Unknown Verbosity level. Ignoring will cause everything to be logged");
                    break;
            }

            return logIt;
        }

        /// <summary>
        /// Format error messages for the task list
        /// </summary>
        protected virtual string GetFormattedErrorMessage(
            string fileName,
            int line,
            int column,
            bool isWarning,
            string errorNumber,
            string errorText)
        {
            string errorCode = isWarning ? this.WarningString : this.ErrorString;

            StringBuilder message = new StringBuilder();
            if (!string.IsNullOrEmpty(fileName))
            {
                message.AppendFormat(CultureInfo.CurrentCulture, "{0}({1},{2}):", fileName, line, column);
            }
            message.AppendFormat(CultureInfo.CurrentCulture, " {0} {1}: {2}", errorCode, errorNumber, errorText);
            message.AppendLine();

            return message.ToString();
        }

        /// <summary>
        /// Sets the verbosity level.
        /// </summary>
        protected virtual void SetVerbosity()
        {
            // TODO: This should be replaced when we have a version that supports automation.
            if (!this.haveCachedVerbosity)
            {
                string verbosityKey = String.Format(CultureInfo.InvariantCulture, @"{0}\{1}", BuildVerbosityRegistryRoot, buildVerbosityRegistrySubKey);
                using (RegistryKey subKey = Registry.CurrentUser.OpenSubKey(verbosityKey))
                {
                    if (subKey != null)
                    {
                        object valueAsObject = subKey.GetValue(buildVerbosityRegistryKey);
                        if (valueAsObject != null)
                        {
                            this.Verbosity = (LoggerVerbosity)((int)valueAsObject);
                        }
                    }
                }

                this.haveCachedVerbosity = true;
            }
        }

        /// <summary>
        /// Clear the cached verbosity, so that it will be re-evaluated from the build verbosity registry key.
        /// </summary>
        protected virtual void ClearCachedVerbosity()
        {
            this.haveCachedVerbosity = false;
        }

        #endregion helpers

        #region exception handling helpers

        /// <summary>
        /// Call Dispatcher.BeginInvoke, showing an error message if there was a non-critical exception.
        /// </summary>
        /// <param name="serviceProvider">service provider</param>
        /// <param name="dispatcher">dispatcher</param>
        /// <param name="action">action to invoke</param>
        protected static void BeginInvokeWithErrorMessage(IServiceProvider serviceProvider, Dispatcher dispatcher, Action action)
        {
            dispatcher.BeginInvoke(new Action(() => CallWithErrorMessage(serviceProvider, action)));
        }

        /// <summary>
        /// Show error message if exception is caught when invoking a method
        /// </summary>
        /// <param name="serviceProvider">service provider</param>
        /// <param name="action">action to invoke</param>
        protected static void CallWithErrorMessage(IServiceProvider serviceProvider, Action action)
        {
            try
            {
                action();
            }
            catch (Exception ex)
            {
                if (Microsoft.VisualStudio.ErrorHandler.IsCriticalException(ex))
                {
                    throw;
                }

                ShowErrorMessage(serviceProvider, ex);
            }
        }

        /// <summary>
        /// Show error window about the exception
        /// </summary>
        /// <param name="serviceProvider">service provider</param>
        /// <param name="exception">exception</param>
        protected static void ShowErrorMessage(IServiceProvider serviceProvider, Exception exception)
        {
            IUIService UIservice = (IUIService)serviceProvider.GetService(typeof(IUIService));
            if (UIservice != null && exception != null)
            {
                UIservice.ShowError(exception);
            }
        }

        #endregion exception handling helpers
    }
}