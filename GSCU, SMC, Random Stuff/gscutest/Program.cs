using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace gscutest
{
    class Program
    {
        [DllImport("gscudrt.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern int exec(byte[] buffers, int[] sizes, int count);

        [DllImport("gscudrt.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern int tick();
        static void Main(string[] args)
        {
            // args: list of files to load
            int[] sizes = new int[args.Length];
            List<byte> buffers = new List<byte>();

            int i = 0;
            foreach(var f in args)
            {
                if(!File.Exists(f))
                {
                    Console.WriteLine($"unable to load {f}");
                    Console.ReadKey(false);
                    Environment.Exit(1);
                }

                sizes[i] = buffers.Count;
                buffers.AddRange(File.ReadAllBytes(args[i]));
                sizes[i] = buffers.Count - sizes[i];

                int added = 0;
                if (buffers.Count % 16 != 0)
                {
                    added = buffers.Count;
                    buffers.AddRange(new byte[16 - (buffers.Count % 16)]);
                    added = buffers.Count - added;
                }

                sizes[i++] += added;
            }

            Console.Title = "gscu test console";

            exec(buffers.ToArray(), sizes, args.Length);
            while (tick() == 0) { System.Threading.Thread.Sleep(5); }
        }
    }
}
