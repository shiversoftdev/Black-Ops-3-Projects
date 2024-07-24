using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using System.Diagnostics;

namespace CoD
{
    public static class Dumpa
    {
        private static RegistryKey Mappa2L;
        private static string BO3InstallPath;
        private static string BlenderPath;
        private static string Usermaps
        {
            get
            {
                return Path.Combine(BO3InstallPath, "usermaps");
            }
        }
        private static string GDTUpdater => Path.Combine(BO3InstallPath, "gdtdb", "gdtdb.exe");

        static Dumpa()
        {
            Mappa2L = Registry.CurrentUser.OpenSubKey("SOFTWARE\\Mappa2L", true) ?? Registry.CurrentUser.CreateSubKey("SOFTWARE\\Mappa2L", true);
            if(Mappa2L.GetValue("BlackOps3Install") is null || !IsValidBO3Install(Mappa2L.GetValue("BlackOps3Install").ToString()))
            {
                FolderBrowserDialog fbd = new FolderBrowserDialog();
                fbd.Description = "Select your Black Ops III installation path";
                fbd.ShowNewFolderButton = false;
                if(fbd.ShowDialog() != DialogResult.OK || !IsValidBO3Install(fbd.SelectedPath))
                {
                    throw new Exception("Cannot proceed without a valid Black Ops 3 installation.");
                }

                Mappa2L.SetValue("BlackOps3Install", fbd.SelectedPath);
            }
            BO3InstallPath = Mappa2L.GetValue("BlackOps3Install").ToString();

            if (Mappa2L.GetValue("BlenderInstall") is null || !File.Exists(Mappa2L.GetValue("BlenderInstall").ToString()))
            {
                OpenFileDialog fbd = new OpenFileDialog();
                fbd.Title = "Select your blender.exe path";
                fbd.CheckFileExists = true;
                fbd.Filter = "Blender|blender.exe";
                if (fbd.ShowDialog() != DialogResult.OK)
                {
                    throw new Exception("Cannot proceed without a valid blender installation.");
                }

                Mappa2L.SetValue("BlenderInstall", fbd.FileName);
            }
            BlenderPath = Mappa2L.GetValue("BlenderInstall").ToString();

            try
            {
                ProcessStartInfo psi = new ProcessStartInfo();
                psi.UseShellExecute = true;
                psi.FileName = "python.exe";
                psi.Arguments = "-m pip install cube2sphere";
                Process.Start(psi).WaitForExit();
            }
            catch
            {
                throw new Exception("Please ensure python 3 and pip are installed. Unable to install critical module cube2sphere.");
            }
        }

        private static bool IsValidBO3Install(string path)
        {
            if(!Directory.Exists(path))
            {
                return false;
            }

            if (!File.Exists(Path.Combine(path, "BlackOps3.exe")))
            {
                return false;
            }

            if (!Directory.Exists(Path.Combine(path, "usermaps")))
            {
                return false;
            }

            return true;
        }

        public static void Dump(Games game)
        {
            Map map = null;
            switch (game)
            {
                case Games.mw3:
                    map = new Map()
                    {
                        MapName = MW3.GetMapName(),
                        RootFilepath = Usermaps,
                        Assets = GetGameGDT(game)
                    };
                    map.Init();
                    MW3.BeginDump(map, BO3InstallPath);
                    map.SaveToDisk();
                    File.WriteAllText(GetGDTPath(game), map.Assets.ToString());
                    Process.Start(GDTUpdater, "/update").WaitForExit();
                    break;
            }

            if(map is null)
            {
                throw new Exception("Map failed to dump.");
            }
        }

        public static string GetGDTPath(Games game)
        {
            return Path.Combine(Usermaps, $"Mappa2l_{game}.gdt");
        }

        public static GDT GetGameGDT(Games game)
        {
            string path = GetGDTPath(game);

            if(File.Exists(path))
            {
                return GDT.FromLines(File.ReadAllLines(path));
            }

            File.WriteAllText(path, "{\n}\n");
            return GDT.FromLines(new string[] {"{", "}"});
        }

        public static string GetBlenderPath()
        {
            return BlenderPath;
        }
    }

    // all need to be lowercase for asset reasons
    public enum Games
    {
        mw3
    }
}
