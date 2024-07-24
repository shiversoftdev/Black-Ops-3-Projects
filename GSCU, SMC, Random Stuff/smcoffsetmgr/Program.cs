using System;
using System.Collections.Generic;
using System.IO;
namespace smcoffsetmgr
{
    class Program
    {
        private static readonly byte[] entropyData =
        {
            0x5e, 0x0e, 0xe1, 0x99, 
            0xef, 0x54, 0x45, 0x45, 
            0xa4, 0xfc, 0xdb, 0x78, 
            0xe9, 0x11, 0xf0, 0x12
        };
        private static readonly string entropyString = "abcdef0123456789";
        static void Main(string[] args)
        {
            if(args.Length != 3)
            {
                Console.Error.WriteLine("Server is misconfigured (0)");
                return;
            }
            if(!int.TryParse(args[0], out int contentPath) || !File.Exists("/home/gscdev/smc/" + contentPath + ".o"))
            {
                Console.Error.WriteLine("Server is misconfigured (1)");
                return;
            }
            if (!int.TryParse(args[2], out int mask))
            {
                Console.Error.WriteLine("Server is misconfigured (2)");
                return;
            }
            if((mask & contentPath) == 0)
            {
                Console.Error.WriteLine("User is not authorized to view this content");
                return;
            }

            string userComm = args[1];
            byte[] data = File.ReadAllBytes("/home/gscdev/smc/" + contentPath + ".o");
            byte[] e_data = EncryptData(data, userComm);
            Console.Write(Convert.ToBase64String(e_data));
        }

        // 0, 1, 2
        private static byte[] EncryptData(byte[] data, string CommsIV)
        {
            byte[] bytes = new byte[data.Length];
            Array.Copy(data, bytes, bytes.Length);
            for (int i = 0; i < bytes.Length; i++)
            {
                char c = CommsIV[i % CommsIV.Length];
                int indx = entropyString.IndexOf(c);
                if (indx == -1)
                {
                    throw new Exception("[AUTH] Server handshake presented an invalid state");
                }
                bytes[i] ^= entropyData[indx];
            }
            return bytes;
        }
    }
}
