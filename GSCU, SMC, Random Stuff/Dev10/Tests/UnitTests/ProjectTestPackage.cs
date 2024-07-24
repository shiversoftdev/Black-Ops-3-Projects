/***************************************************************************

Copyright (c) Microsoft Corporation. All rights reserved.
This code is licensed under the Visual Studio SDK license terms.
THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.

***************************************************************************/

using System;
using System.Runtime.InteropServices;

namespace Microsoft.VisualStudio.Project.UnitTests
{
	[ComVisible(true)]
	[Guid("5CD3E3D5-B93C-409C-BF93-EC27DF668C19")]
	internal class ProjectTestPackage : VisualStudio.Project.ProjectPackage
	{
		public override string ProductUserContext
		{
			get
			{
				throw new NotSupportedException();
			}
		}
	}
}
