using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BO3OffsetManager
{
    class fn_info
    {
        public ulong start;
        public ulong end;
        public ulong hash;
    }

    class s_db
    {
        const string NEWPATH = "new.txt";
        const string OLDPATH = "original.txt";
        static List<fn_info> OldFunctions;
        static List<fn_info> NewFunctions;
        static Dictionary<ulong, fn_info> NewSigMap;
        static Dictionary<ulong, fn_info> OldFNMap;
        Dictionary<ulong, ulong> OffsetMap;

        static s_db()
        {
            OldFunctions = new List<fn_info>();
            NewFunctions = new List<fn_info>();
            NewSigMap = new Dictionary<ulong, fn_info>();
            OldFNMap = new Dictionary<ulong, fn_info>();

            foreach (var line in File.ReadAllLines(OLDPATH))
            {
                var split = line.Split("-");
                if(split.Length != 3)
                {
                    continue;
                }
                var inf = new fn_info();
                inf.start = ulong.Parse(split[0].Trim().Replace("0x", "").Replace("L", ""), System.Globalization.NumberStyles.HexNumber);
                inf.end = ulong.Parse(split[1].Trim().Replace("0x", "").Replace("L", ""), System.Globalization.NumberStyles.HexNumber);
                inf.hash = ulong.Parse(split[2].Trim().Replace("0x", "").Replace("L", ""), System.Globalization.NumberStyles.HexNumber);
                OldFunctions.Add(inf);
                OldFNMap[inf.start] = inf;
            }

            foreach (var line in File.ReadAllLines(NEWPATH))
            {
                var split = line.Split("-");
                if (split.Length != 3)
                {
                    continue;
                }
                var inf = new fn_info();
                inf.start = ulong.Parse(split[0].Trim().Replace("0x", "").Replace("L", ""), System.Globalization.NumberStyles.HexNumber);
                inf.end = ulong.Parse(split[1].Trim().Replace("0x", "").Replace("L", ""), System.Globalization.NumberStyles.HexNumber);
                inf.hash = ulong.Parse(split[2].Trim().Replace("0x", "").Replace("L", ""), System.Globalization.NumberStyles.HexNumber);
                NewFunctions.Add(inf);

                if (!NewSigMap.ContainsKey(inf.hash))
                    NewSigMap[inf.hash] = inf;
                else
                    NewSigMap[inf.hash] = null; // ambiguous
            }
        }

        public s_db()
        {
            OffsetMap = new Dictionary<ulong, ulong>();
        }

        public void Load(byte[] data)
        {
            using(BinaryReader br = new BinaryReader(new MemoryStream(data)))
            {
                while(br.BaseStream.Position < br.BaseStream.Length)
                {
                    var key = br.ReadUInt64();
                    OffsetMap[key] = br.ReadUInt64();
                }
                br.Close();
            }
        }

        public void Save(string path)
        {
            using(BinaryWriter bw = new BinaryWriter(File.OpenWrite(path)))
            {
                foreach(var kvp in OffsetMap)
                {
                    bw.Write(kvp.Key);
                    bw.Write(kvp.Value);
                }
                bw.Close();
            }
        }

        public void Remove(ulong offOld)
        {
            OffsetMap.Remove(offOld);
        }

        public void Add(ulong offOld, ulong offNew)
        {
            OffsetMap[offOld] = offNew;
        }

        public bool TryResolve(ulong offOld, out ulong offNew)
        {
            if(OffsetMap.TryGetValue(offOld, out offNew))
            {
                return true;
            }

            offNew = offOld;

            if(!OldFNMap.ContainsKey(offOld))
            {
                return false;
            }

            var hash = OldFNMap[offOld].hash;

            if(!NewSigMap.ContainsKey(hash) || NewSigMap[hash] is null)
            {
                return false;
            }

            offNew = NewSigMap[hash].start;
            return true;
        }
    }
}
