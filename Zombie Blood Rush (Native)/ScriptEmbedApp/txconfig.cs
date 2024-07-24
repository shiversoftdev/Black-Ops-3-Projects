using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static ScriptEmbedApp.txconfig.TX_FIELDS;

namespace ScriptEmbedApp
{
    public static class txconfig
    {
        public enum TX_FIELDS
        {
            TX_Command = 0,
            TX_XAssets = 1,
            TX_Cbuff = 2,
            TX_IncludeName = 3,
            TX_SurrogateScript = 4,
            TX_HandlerTable = 5
        }

        public enum TX_Commands
        {
            TXC_Inject = 0
        }

        private static List<byte> CreateTX(byte VM_Revision)
        {
            List<byte> TXConf = new List<byte>();
            TXConf.AddRange(new byte[] { (byte)'T', (byte)'X', (byte)VM_Revision, (byte)0 });
            TXConf.AddRange(new byte[] { 0, 0, 0, 0 }); //tx entry count
            return TXConf;
        }

        public static List<byte> TX_VM_1C()
        {
            List<byte> tx = CreateTX(0x1C);
            AddTXField(tx, TX_XAssets, 0x9407AB0);
            AddTXField(tx, TX_HandlerTable, 0x32E8350);
            return tx;
        }

        public static List<byte> TX_VM_36()
        {
            List<byte> tx = CreateTX(0x36);
            AddTXField(tx, TX_XAssets, 0x889B350);
            //AddTXField(tx, TX_SurrogateScript, 0xFD2E9FE6934867);
            AddTXField(tx, TX_IncludeName, 0x124CECFF7280BE52);
            return tx;
        }

        //38685E3B Easy vtable
        public static List<byte> TX_VM_37()
        {
            List<byte> tx = CreateTX(0x37);
            AddTXField(tx, TX_XAssets, 0x10B0B060);
            //AddTXField(tx, TX_SurrogateScript, 0xFD2E9FE6934867);
            AddTXField(tx, TX_IncludeName, 0x124CECFF7280BE52);
            AddTXField(tx, TX_HandlerTable, 0xC0FA100);
            return tx;
        }

        public static void AddTXField(List<byte> TX, TX_FIELDS field, ulong Value)
        {
            uint ct = BitConverter.ToUInt32(TX.ToArray(), 4) + 1;
            TX.RemoveRange(4, 4);
            TX.InsertRange(4, BitConverter.GetBytes(ct));
            TX.AddRange(BitConverter.GetBytes((uint)field));
            TX.AddRange(BitConverter.GetBytes(Value));
        }

        public static void AddTXCommand(List<byte> TX, TX_Commands command)
        {
            AddTXField(TX, TX_Command, (ulong)command);
        }

        // encrypt txconfig with the module handle
        public static void EncryptTX(List<byte> TX, ulong XorKey)
        {
            while (TX.Count % 8 > 0) TX.Add(0);
            byte[] bytes = BitConverter.GetBytes(XorKey);
            for (int i = 8; i < TX.Count; i++) // skip header
            {
                TX[i] ^= bytes[i % bytes.Length];
            }
        }
    }
}
