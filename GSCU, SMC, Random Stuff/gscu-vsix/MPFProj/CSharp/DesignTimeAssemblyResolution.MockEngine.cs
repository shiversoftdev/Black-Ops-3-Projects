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
	using System.Globalization;
	using System.Text;
	using Microsoft.Build.Framework;

	partial class DesignTimeAssemblyResolution
	{
		/// <summary>
		/// Engine required by RAR, primarily for collecting logs
		/// </summary>
		protected class MockEngine : IBuildEngine
		{
			private int messages = 0;
			private int warnings = 0;
			private int errors = 0;
			private readonly StringBuilder log = new StringBuilder();
			private readonly bool enableLog = false;

			public MockEngine(bool enableLog)
			{
				this.enableLog = enableLog;
			}

			public virtual void RecordRARExecutionException(Exception ex)
			{
				if (!enableLog) return;

				log.Append(String.Format(CultureInfo.InvariantCulture, "{0}", ex.ToString()));
			}

			public virtual void LogErrorEvent(BuildErrorEventArgs eventArgs)
			{
				if (eventArgs == null)
				{
					throw new ArgumentNullException("eventArgs");
				}

				if (!enableLog) return;

				if (eventArgs.File != null && eventArgs.File.Length > 0)
				{
					log.Append(String.Format(CultureInfo.InvariantCulture, "{0}({1},{2}): ", eventArgs.File, eventArgs.LineNumber, eventArgs.ColumnNumber));
				}

				log.Append("ERROR ");
				log.Append(eventArgs.Code);
				log.Append(": ");
				++errors;

				log.AppendLine(eventArgs.Message);
			}

			public virtual void LogWarningEvent(BuildWarningEventArgs eventArgs)
			{
				if (eventArgs == null)
				{
					throw new ArgumentNullException("eventArgs");
				}

				if (!enableLog) return;

				if (eventArgs.File != null && eventArgs.File.Length > 0)
				{
					log.Append(String.Format(CultureInfo.InvariantCulture, "{0}({1},{2}): ", eventArgs.File, eventArgs.LineNumber, eventArgs.ColumnNumber));
				}

				log.Append("WARNING ");
				log.Append(eventArgs.Code);
				log.Append(": ");
				++warnings;

				log.AppendLine(eventArgs.Message);
			}

			public virtual void LogCustomEvent(CustomBuildEventArgs eventArgs)
			{
				if (eventArgs == null)
				{
					throw new ArgumentNullException("eventArgs");
				}

				if (!enableLog) return;

				log.Append(eventArgs.Message);
				log.Append("\n");
			}

			public virtual void LogMessageEvent(BuildMessageEventArgs eventArgs)
			{
				if (eventArgs == null)
				{
					throw new ArgumentNullException("eventArgs");
				}

				log.Append(eventArgs.Message);
				log.Append("\n");

				++messages;
			}

			public bool ContinueOnError
			{
				get { return false; }
			}

			public string ProjectFileOfTaskNode
			{
				get { return String.Empty; }
			}

			public int LineNumberOfTaskNode
			{
				get { return 0; }
			}

			public int ColumnNumberOfTaskNode
			{
				get { return 0; }
			}

			public string Log
			{
				get { return log.ToString(); }
			}

			public virtual bool BuildProjectFile(string projectFileName, string[] targetNames, System.Collections.IDictionary globalProperties, System.Collections.IDictionary targetOutputs)
			{
				throw new NotImplementedException();
			}
		}
	}
}
