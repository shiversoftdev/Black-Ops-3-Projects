using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO.Compression;
using System.IO;

namespace CoD
{
    /// <summary>
    /// Class container for map data before serializing to user maps directory
    /// </summary>
    public sealed class Map
    {
        public string MapName = null;
        public string RootFilepath = null;
        public GDT Assets = null;

        public string MapDiskName
        {
            get
            {
                return MapName.Replace("mp_", "") + "_m2l";
            }
        }

        public string MapNameMP
        {
            get
            {
                return "mp_" + MapDiskName;
            }
        }

        public string MapNameZM
        {
            get
            {
                return "zm_" + MapDiskName;
            }
        }

        public SkyboxOverride Skybox;

        public IWMap MP { get; private set; }
        public IWMap ZM { get; private set; }

        private IWZone MPZone;
        private IWZone ZMZone;
        private string zipPath;
        private string zipFolder;
        
        public void Init()
        {
            zipPath = Path.Combine(Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location), "maptmpl.zip");
            zipFolder = Path.Combine(Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location), "maptmpl");
            if (!File.Exists(zipPath))
            {
                using (var stream = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream("CoD.maptmpl.zip"))
                {
                    using (var file = new FileStream(zipPath, FileMode.Create, FileAccess.Write))
                    {
                        stream.CopyTo(file);
                    }
                }
            }

            if (!Directory.Exists(zipFolder))
            {
                ZipFile.ExtractToDirectory(zipPath, zipFolder);
            }

            // map
            MP = IWMap.FromLines(MapNameMP, File.ReadAllLines(Path.Combine(zipFolder, "mp/mp_map.map")));
            ZM = IWMap.FromLines(MapNameMP, File.ReadAllLines(Path.Combine(zipFolder, "zm/zm_map.map")));
        }


        public void SaveToDisk()
        {
            if(!(Skybox is null))
            {
                MP.SetAllEntStringPropExisting("skyboxmodel", Skybox.SkyboxModel);
                ZM.SetAllEntStringPropExisting("skyboxmodel", Skybox.SkyboxModel);

                if(Skybox.SSIBaked != null)
                {
                    MP.SetAllEntStringPropExisting("ssi", Skybox.SSIBaked);
                    MP.SetAllEntStringPropExisting("wsi", Skybox.SSIBaked);
                    MP.SetAllEntStringPropExisting("ssi1", Skybox.SSIBaked);
                    ZM.SetAllEntStringPropExisting("ssi", Skybox.SSIBaked);
                    ZM.SetAllEntStringPropExisting("wsi", Skybox.SSIBaked);
                    ZM.SetAllEntStringPropExisting("ssi1", Skybox.SSIBaked);
                }
                else
                {
                    MP.SetAllEntStringPropExisting("ssi", Skybox.SSIRuntime);
                    MP.SetAllEntStringPropExisting("wsi", Skybox.SSIRuntime);
                    MP.SetAllEntStringPropExisting("ssi1", Skybox.SSIRuntime);
                    ZM.SetAllEntStringPropExisting("ssi", Skybox.SSIRuntime);
                    ZM.SetAllEntStringPropExisting("wsi", Skybox.SSIRuntime);
                    ZM.SetAllEntStringPropExisting("ssi1", Skybox.SSIRuntime);
                }

                if(Skybox.SSIRuntime != null)
                {
                    ForBoth((IWMap iwmap) =>
                    {
                        iwmap.FindEnt("\"classname\"", "\"volume_sun\"").SetStringProp("\"ssi1_runtime_override\"", $"\"{Skybox.SSIRuntime}\"");
                    });
                }
            }

            string mp_root = Path.Combine(RootFilepath, MapNameMP);
            string zm_root = Path.Combine(RootFilepath, MapNameZM);
            string mp_root_map = Path.Combine(RootFilepath, "..", "map_source", "mp", $"{MapNameMP}.map");
            string zm_root_map = Path.Combine(RootFilepath, "..", "map_source", "zm", $"{MapNameZM}.map");

            if(!Directory.Exists(Path.GetDirectoryName(mp_root_map)))
            {
                Directory.CreateDirectory(Path.GetDirectoryName(mp_root_map));
            }

            if (!Directory.Exists(Path.GetDirectoryName(zm_root_map)))
            {
                Directory.CreateDirectory(Path.GetDirectoryName(zm_root_map));
            }

            File.WriteAllText(mp_root_map, MP.ToString());
            File.WriteAllText(zm_root_map, ZM.ToString());

            EnsureBoth(mp_root, zm_root, "scripts");
            EnsureBoth(mp_root, zm_root, "sound", "zoneconfig");
            EnsureBoth(mp_root, zm_root, "zone");
            EnsureBoth(mp_root, zm_root, "zone_source");

            Ensure(mp_root, "scripts", "mp");
            Ensure(zm_root, "scripts", "zm");

            // zone
            string mp_zone_path = Path.Combine(zipFolder, "mp/mp_map/zone_source/mp_map.zone");
            string zm_zone_path = Path.Combine(zipFolder, "zm/zm_map/zone_source/zm_map.zone");

            MPZone = IWZone.FromLines(File.ReadAllLines(mp_zone_path));
            MPZone.ReplaceInValues("mp_map", MapNameMP);
            ZMZone = IWZone.FromLines(File.ReadAllLines(zm_zone_path));
            ZMZone.ReplaceInValues("zm_map", MapNameZM);

            if (!(Skybox is null))
            {
                MPZone.DeleteMatchingKVPs("xmodel", "skybox_default_day");
                MPZone.AddKVP("xmodel", Skybox.SkyboxModel);

                ZMZone.DeleteMatchingKVPs("xmodel", "skybox_default_day");
                ZMZone.AddKVP("xmodel", Skybox.SkyboxModel);
            }

            File.WriteAllText(Path.Combine(mp_root, "zone_source", $"{MapNameMP}.zone"), MPZone.ToString());
            File.WriteAllText(Path.Combine(zm_root, "zone_source", $"{MapNameZM}.zone"), ZMZone.ToString());

            // scripts
            File.Copy(Path.Combine(zipFolder, "zm", "zm_map", "scripts", "zm", "zm_map.csc"), Path.Combine(zm_root, "scripts", "zm", $"{MapNameZM}.csc"), true);
            File.Copy(Path.Combine(zipFolder, "zm", "zm_map", "scripts", "zm", "zm_map.gsc"), Path.Combine(zm_root, "scripts", "zm", $"{MapNameZM}.gsc"), true);

            File.Copy(Path.Combine(zipFolder, "mp", "mp_map", "scripts", "mp", "mp_map_fx.csc"), Path.Combine(mp_root, "scripts", "mp", $"{MapNameMP}_fx.csc"), true);
            File.Copy(Path.Combine(zipFolder, "mp", "mp_map", "scripts", "mp", "mp_map_fx.gsc"), Path.Combine(mp_root, "scripts", "mp", $"{MapNameMP}_fx.gsc"), true);
            File.Copy(Path.Combine(zipFolder, "mp", "mp_map", "scripts", "mp", "mp_map_sound.csc"), Path.Combine(mp_root, "scripts", "mp", $"{MapNameMP}_sound.csc"), true);
            File.Copy(Path.Combine(zipFolder, "mp", "mp_map", "scripts", "mp", "mp_map_sound.gsc"), Path.Combine(mp_root, "scripts", "mp", $"{MapNameMP}_sound.gsc"), true);
            File.WriteAllText(Path.Combine(mp_root, "scripts", "mp", $"{MapNameMP}.csc"), File.ReadAllText(Path.Combine(zipFolder, "mp", "mp_map", "scripts", "mp", "mp_map.csc")).Replace("mp_map", MapNameMP));
            File.WriteAllText(Path.Combine(mp_root, "scripts", "mp", $"{MapNameMP}.gsc"), File.ReadAllText(Path.Combine(zipFolder, "mp", "mp_map", "scripts", "mp", "mp_map.gsc")).Replace("mp_map", MapNameMP));

            // szc
            File.WriteAllText(Path.Combine(mp_root, "sound", "zoneconfig", $"{MapNameMP}.szc"), File.ReadAllText(Path.Combine(zipFolder, "mp", "mp_map", "sound", "zoneconfig", "mp_map.szc")).Replace("mp_map", MapNameMP));
            File.WriteAllText(Path.Combine(zm_root, "sound", "zoneconfig", $"{MapNameZM}.szc"), File.ReadAllText(Path.Combine(zipFolder, "zm", "zm_map", "sound", "zoneconfig", "zm_map.szc")).Replace("zm_map", MapNameZM));

            // loading images
            File.Copy(Path.Combine(zipFolder, "mp", "mp_map", "zone", "loadingimage.png"), Path.Combine(mp_root, "zone", "loadingimage.png"), true);
            File.Copy(Path.Combine(zipFolder, "mp", "mp_map", "zone", "previewimage.png"), Path.Combine(mp_root, "zone", "previewimage.png"), true);
            File.Copy(Path.Combine(zipFolder, "zm", "zm_map", "zone", "loadingimage.png"), Path.Combine(zm_root, "zone", "loadingimage.png"), true);
            File.Copy(Path.Combine(zipFolder, "zm", "zm_map", "zone", "previewimage.png"), Path.Combine(zm_root, "zone", "previewimage.png"), true);
        }

        private void EnsureBoth(string mp_root, string zm_root, params string[] path)
        {
            string subpath = string.Join(Path.DirectorySeparatorChar.ToString(), path);
            if (!Directory.Exists(Path.Combine(mp_root, subpath)))
            {
                Directory.CreateDirectory(Path.Combine(mp_root, subpath));
            }

            if (!Directory.Exists(Path.Combine(zm_root, subpath)))
            {
                Directory.CreateDirectory(Path.Combine(zm_root, subpath));
            }
        }

        private void Ensure(params string[] path)
        {
            if (!Directory.Exists(Path.Combine(path)))
            {
                Directory.CreateDirectory(Path.Combine(path));
            }
        }

        public delegate void IWMapAction(IWMap map);

        public void ForBoth(IWMapAction action)
        {
            action(MP);
            action(ZM);
        }

        public void ForMP(IWMapAction action)
        {
            action(MP);
        }

        public void ForZM(IWMapAction action)
        {
            action(ZM);
        }
    }

    public sealed class SkyboxOverride
    {
        public string SSIBaked;
        public string SSIRuntime;
        public string SkyboxModel;
    }
}
