using System;
using System.Text;
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.IO;

namespace t7dwidm_protect
{
    internal class Injector
    {

        [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
        internal static extern IntPtr GetModuleHandle(string lpModuleName);

        [DllImport("kernel32", CharSet = CharSet.Ansi, ExactSpelling = true, SetLastError = true)]
        internal static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

        [DllImport("kernel32.dll")]
        internal static extern IntPtr CreateRemoteThread(IntPtr hProcess,
            IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);

        [DllImport("psapi.dll", SetLastError = true)]
        internal static extern bool EnumProcessModulesEx(
            IntPtr hProcess,
            [Out] IntPtr lphModule,
            UInt32 cb,
            [MarshalAs(UnmanagedType.U4)] out UInt32 lpcbNeeded,
            DwFilterFlag dwff);

        [DllImport("psapi.dll")]
        internal static extern uint GetModuleFileNameEx(
            IntPtr hProcess,
            IntPtr hModule,
            [Out] StringBuilder lpBaseName,
            [In][MarshalAs(UnmanagedType.U4)] int nSize);

        // privileges
        internal const int PROCESS_CREATE_THREAD = 0x0002;

        [Flags]
        public enum ProcessAccessFlags : uint
        {
            All = 0x001F0FFF,
            Terminate = 0x00000001,
            CreateThread = 0x00000002,
            VirtualMemoryOperation = 0x00000008,
            VirtualMemoryRead = 0x00000010,
            VirtualMemoryWrite = 0x00000020,
            DuplicateHandle = 0x00000040,
            CreateProcess = 0x000000080,
            SetQuota = 0x00000100,
            SetInformation = 0x00000200,
            QueryInformation = 0x00000400,
            QueryLimitedInformation = 0x00001000,
            Synchronize = 0x00100000
        }

        public enum DwFilterFlag : uint
        {
            LIST_MODULES_DEFAULT = 0x0,    // This is the default one app would get without any flag.
            LIST_MODULES_32BIT = 0x01,   // list 32bit modules in the target process.
            LIST_MODULES_64BIT = 0x02,   // list all 64bit modules. 32bit exe will be stripped off.
            LIST_MODULES_ALL = (LIST_MODULES_32BIT | LIST_MODULES_64BIT)   // list all the modules
        }

        private static bool ModuleExists(IntPtr procPtr, string dllName)
        {
            var dllFileName = Path.GetFileName(dllName);

            IntPtr[] hMods = new IntPtr[1024];

            GCHandle gch = GCHandle.Alloc(hMods, GCHandleType.Pinned); // Don't forget to free this later
            IntPtr pModules = gch.AddrOfPinnedObject();

            // Setting up the rest of the parameters for EnumProcessModules
            var uiSize = (uint)(Marshal.SizeOf(typeof(IntPtr)) * (hMods.Length));

            bool foundModule = false;

            if (EnumProcessModulesEx(procPtr, pModules, uiSize, out var cbNeeded, DwFilterFlag.LIST_MODULES_64BIT))
            {
                Int32 uiTotalNumberofModules = (Int32)(cbNeeded / Marshal.SizeOf(typeof(IntPtr)));

                for (int i = 0; i < uiTotalNumberofModules; i++)
                {
                    StringBuilder sb = new StringBuilder(1024);

                    GetModuleFileNameEx(procPtr, hMods[i], sb, sb.Capacity);

                    if (Path.GetFileName(sb.ToString()) == dllFileName)
                    {
                        foundModule = true;
                        break;
                    }

                }
            }

            gch.Free();

            return foundModule;
        }
    }
}
