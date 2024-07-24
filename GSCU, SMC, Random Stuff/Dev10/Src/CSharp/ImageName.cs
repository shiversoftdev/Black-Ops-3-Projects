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
    using System.Diagnostics.CodeAnalysis;

    public enum ImageName
    {
        OfflineWebApp = 0,
        WebReferencesFolder = 1,
        OpenReferenceFolder = 2,
        ReferenceFolder = 3,
        Reference = 4,
        SdlWebReference = 5,
        DiscoWebReference = 6,
        Folder = 7,
        OpenFolder = 8,
        ExcludedFolder = 9,
        OpenExcludedFolder = 10,
        ExcludedFile = 11,
        DependentFile = 12,
        MissingFile = 13,
        WindowsForm = 14,
        WindowsUserControl = 15,
        WindowsComponent = 16,
        XmlSchema = 17,
        XmlFile = 18,
        WebForm = 19,
        WebService = 20,
        WebUserControl = 21,
        WebCustomUserControl = 22,
        AspPage = 23,
        GlobalApplicationClass = 24,
        WebConfig = 25,
        HtmlPage = 26,
        StyleSheet = 27,
        ScriptFile = 28,
        TextFile = 29,
        SettingsFile = 30,
        Resources = 31,
        Bitmap = 32,
        Icon = 33,
        Image = 34,
        ImageMap = 35,
        XWorld = 36,
        Audio = 37,
        Video = 38,
        Cab = 39,
        Jar = 40,
        DataEnvironment = 41,
        PreviewFile = 42,
        DanglingReference = 43,
        XsltFile = 44,
        Cursor = 45,
        AppDesignerFolder = 46,
        Data = 47,
        Application = 48,
        DataSet = 49,
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "Pfx")]
        Pfx = 50,
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "Snk")]
        Snk = 51,

        ImageLast = 51
    }
}
