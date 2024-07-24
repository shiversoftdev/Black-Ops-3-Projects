using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoD
{
    public sealed class IWZone
    {
        private List<string[]> KVPs = new List<string[]>();
        private IWZone()
        {

        }

        public static IWZone FromLines(string[] lines)
        {
            IWZone zone = new IWZone();

            foreach(var line in lines)
            {
                string pline = line.Trim();

                if(pline.StartsWith("//"))
                {
                    continue;
                }

                if(pline.Length < 1)
                {
                    continue;
                }

                if (pline.IndexOf(",") < 0)
                {
                    continue;
                }

                var split = pline.Split(',');
                zone.KVPs.Add(new string[] { split[0].Trim(), split[1].Trim() });
            }

            return zone;
        }

        public override string ToString()
        {
            StringBuilder sb = new StringBuilder();
            foreach(var kvp in KVPs)
            {
                sb.Append($"{kvp[0]},{kvp[1]}\n");
            }
            return sb.ToString();
        }

        public void ReplaceInValues(string find, string replace)
        {
            for(int i = 0; i < KVPs.Count; i++)
            {
                if(KVPs[i][1].Contains(find))
                {
                    KVPs[i][1] = KVPs[i][1].Replace(find, replace);
                }
            }
        }

        public void DeleteMatchingKVPs(string key, string value)
        {
            for (int i = 0; i < KVPs.Count; i++)
            {
                if (KVPs[i][0] == key && KVPs[i][1] == value)
                {
                    KVPs.RemoveAt(i);
                    i--;
                }
            }
        }

        public void AddKVP(string key, string value)
        {
            KVPs.Add(new string[] { key, value });
        }
    }
}
