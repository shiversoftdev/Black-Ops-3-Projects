using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Diagnostics;

namespace CoD
{
    internal static class Util
    {
        /// <summary>
        /// Guarantee that a directory exists.
        /// </summary>
        /// <param name="paths"></param>
        public static void Ensure(params string[] paths)
        {
            string path = Path.Combine(paths);

            if(!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
        }

        /// <summary>
        /// Used for standardized image naming convention
        /// </summary>
        /// <param name="name"></param>
        /// <param name="ext"></param>
        /// <returns></returns>
        public static string GDT_IMAGE(string name, Games game)
        {
            return $"i_m2l_{game}_{name}";
        }

        /// <summary>
        /// Used for standardized material naming convention
        /// </summary>
        /// <param name="name"></param>
        /// <param name="ext"></param>
        /// <returns></returns>
        public static string GDT_MATERIAL(string name, Games game)
        {
            return $"mtl_m2l_{game}_{name}";
        }

        /// <summary>
        /// Used for standardized ssi naming convention
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        public static string GDT_SSI(string name, Games game)
        {
            return $"ssi_m2l_{game}_{name}";
        }

        /// <summary>
        /// Used for standardizing xmodel naming conventions
        /// </summary>
        /// <param name="name"></param>
        /// <param name="game"></param>
        /// <returns></returns>
        public static string GDT_MODEL(string name, Games game)
        {
            return $"mdl_m2l_{game}_{name}";
        }

        /// <summary>
        /// Convert 6 cubemap images into a sphere panorama. Returns exit code of python.
        /// </summary>
        /// <param name="frontPath"></param>
        public static int Cube2Sphere(string frontPath, string backPath, string rightPath, string leftPath, string topPath, string bottomPath, int length, int width, string outPath)
        {
            ProcessStartInfo psi = new ProcessStartInfo();
            psi.UseShellExecute = true;
            psi.FileName = "cube2sphere";
            psi.Arguments = $"\"{frontPath}\" \"{backPath}\" \"{rightPath}\" \"{leftPath}\" \"{topPath}\" \"{bottomPath}\" -r {length} {width} -f PNG -o \"{outPath}\" -b \"{Dumpa.GetBlenderPath()}\"";
            var proc = Process.Start(psi);
            proc.WaitForExit();
            return proc.ExitCode;
        }

        public static int PNGToEXR(string from)
        {
            ProcessStartInfo psi = new ProcessStartInfo();
            psi.UseShellExecute = true;
            psi.FileName = "magick";
            psi.Arguments = $"mogrify -auto-gamma -auto-level -format exr \"{from}\"";
            var proc = Process.Start(psi);
            proc.WaitForExit();
            return proc.ExitCode;
        }
    }
}
