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

    /// <summary>
    /// Provides information about the current build status.
    /// </summary>
    public static class BuildStatus
    {
        private static BuildKind? currentBuild;

        private static readonly object Mutex = new object();

        /// <summary>
        /// Gets a value whether a build is in progress.
        /// </summary>
        public static bool IsInProgress
        {
            get { return BuildStatus.currentBuild.HasValue; }
        }

        /// <summary>
        /// Called when a build has started
        /// </summary>
        /// <param name="kind"></param>
        /// <returns></returns>
        public static bool StartBuild(BuildKind kind)
        {
            if (!BuildStatus.currentBuild.HasValue)
            {
                lock(BuildStatus.Mutex)
                {
                    BuildStatus.currentBuild = kind;
                }

                return true;
            }

            BuildKind currentBuildKind = BuildStatus.currentBuild.Value;

            switch (currentBuildKind)
            {
                case BuildKind.Sync:
                    // Attempt to start a build during sync build indicate reentrancy
                    Debug.Fail("Message pumping during sync build");
                    return false;

                case BuildKind.Async:
                    if (kind == BuildKind.Sync)
                    {
                        // if we need to do a sync build during async build, there is not much we can do:
                        // - the async build is user-invoked build
                        // - during that build UI thread is by design not blocked and messages are being pumped
                        // - therefore it is legitimate for other code to call Project System APIs and query for stuff
                        // In that case we just fail gracefully
                        return false;
                    }
                    else
                    {
                        // Somebody attempted to start a build while build is in progress, perhaps and Addin via
                        // the API. Inform them of an error in their ways.
                        throw new InvalidOperationException("Build is already in progress");
                    }
                default:
                    Debug.Fail("Unreachable");
                    return false;

            }
        }

        /// <summary>
        /// Called when a build is ended.
        /// </summary>
        public static void EndBuild()
        {
            Debug.Assert(IsInProgress, "Attempt to end a build that is not started");
            lock (Mutex)
            {
                BuildStatus.currentBuild = null;
            }
        }        
    }
}