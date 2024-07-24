using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoD
{
    public sealed class IWMap
    {
        private string MapName;
        private IWMWorld World;
        private IWMap()
        {

        }

        public static IWMap FromLines(string mapName, string[] lines)
        {
            IWMap map = new IWMap()
            {
                MapName = mapName

            };

            if(lines[0] != "iwmap 4")
            {
                throw new Exception("Invalid map. Unexpected version.");
            }

            map.World = new IWMWorld();
            map.World.Name = "world";

            IWMProp currentProp = map.World;
            for (int i = 1; i < lines.Length; )
            {
                currentProp.Interpret(lines, ref i, ref currentProp);
            }

            return map;
        }

        /// <summary>
        /// Set a world string property
        /// </summary>
        /// <param name="id"></param>
        /// <param name="value"></param>
        public void SetWorldStringProp(string id, string value)
        {
            id = $"\"{id}\"";
            if (!World.Props.ContainsKey(id))
            {
                World.Props[id] = new IWMStringProp();
                World.Props[id].Name = id;
                World.Props[id].Value = "\"\"";
            }
            World.Props[id].Value = $"\"{value}\"";
        }

        /// <summary>
        /// Set an entity property for all ents that already have this prop
        /// </summary>
        /// <param name="id"></param>
        /// <param name="value"></param>
        public void SetAllEntStringPropExisting(string id, string value)
        {
            id = $"\"{id}\"";

            foreach(var prop in World.Props)
            {
                if(prop.Value is IWMEnt ent)
                {
                    if(ent.Props.ContainsKey(id))
                    {
                        ent.Props[id].Value = $"\"{value}\"";
                    }
                }
            }
        }

        public override string ToString()
        {
            return World.Serialize();
        }

        public static List<Dictionary<string, string>> EntMatrixFromList(string mapEnts)
        {
            var split = mapEnts.Replace("\r", "").Split('\n');
            List<Dictionary<string, string>> EntMatrix = new List<Dictionary<string, string>>();
            for (int k = 0; k < split.Length; k++)
            {
                if(split[k].Length < 1)
                {
                    continue;
                }
                if (split[k] != "{")
                {
                    throw new Exception($"Unexpected token '{split[k]}'. Expected {{.");
                }
                k++;
                Dictionary<string, string> ent = new Dictionary<string, string>();
                while (split[k] != "}")
                {
                    string propname = split[k].Substring(0, split[k].IndexOf("\"", 1) + 1);
                    ent[propname] = split[k].Substring(propname.Length + 1);
                    k++;
                }
                EntMatrix.Add(ent);
            }
            return EntMatrix;
        }

        internal IWMEnt FindEnt(string id)
        {
            if (World.Props.ContainsKey(id))
            {
                return World.Props[id] as IWMEnt;
            }
            return null;
        }

        internal IWMEnt FindEnt(string propname, string value)
        {
            foreach(var prop in World.Props)
            {
                if(prop.Value is IWMEnt ent)
                {
                    if(!ent.Props.ContainsKey(propname))
                    {
                        continue;
                    }
                    if(ent.Props[propname].Value == value)
                    {
                        return ent;
                    }
                }
            }
            return null;
        }

        internal IWMEnt AddEnt()
        {
            var guid = $"{{{Guid.NewGuid()}}}";
            var name = $"// entity {guid}";
            var ent = new IWMEnt();
            ent.Name = name;
            ent.SetStringProp($"guid", $"\"{guid}\"");
            World.Props[name] = ent;
            return ent;
        }
    }

    internal class IWMEnt : IWMProp
    {
        public override void Interpret(string[] lines, ref int i, ref IWMProp currentProp)
        {
            if (lines[i].StartsWith("{"))
            {
                i++;
                return;
            }

            if (lines[i].StartsWith("}"))
            {
                i++;
                Parent.Props[Name] = this;
                currentProp = Parent;
                return;
            }

            if (lines[i].StartsWith("//"))
            {
                IWMBrush brushProp = new IWMBrush();
                brushProp.Parent = this;
                brushProp.Name = lines[i];
                currentProp = brushProp;
                i++;
                return;
            }

            if (lines[i].StartsWith("\""))
            {
                IWMStringProp stringProp = new IWMStringProp();
                stringProp.Parent = this;
                currentProp = stringProp;
                return;
            }

            if (lines[i].StartsWith("guid"))
            {
                IWMStringProp stringProp = new IWMStringProp();
                stringProp.Parent = this;
                stringProp.Name = "guid";
                stringProp.Value = lines[i].Substring("guid".Length + 1);
                Props[stringProp.Name] = stringProp;
                i++;
                return;
            }

            if (lines[i].StartsWith("layer"))
            {
                IWMStringProp stringProp = new IWMStringProp();
                stringProp.Parent = this;
                stringProp.Name = "layer";
                stringProp.Value = lines[i].Substring("layer".Length + 1);
                Props[stringProp.Name] = stringProp;
                i++;
                return;
            }

            throw new Exception($"Unexpected line start for entity. ({lines[i]})");
        }

        public override string Serialize()
        {
            return $"{Name}\n{{\n{SerializeProps()}}}";
        }

        public IWMBrush AddBrush()
        {
            var guid = $"{{{Guid.NewGuid()}}}";
            var name = $"// brush {guid}";
            var brush = new IWMBrush();
            brush.Name = name;
            brush.SetStringProp($"guid", $"\"{guid}\"");
            this.Props[name] = brush;
            return brush;
        }
    }

    internal abstract class IWMProp
    {
        public IWMProp Parent;
        public string Name { get; set; }
        public string Value { get; set; }
        public Dictionary<string, IWMProp> Props = new Dictionary<string, IWMProp>();

        public abstract void Interpret(string[] lines, ref int i, ref IWMProp currentProp);
        public abstract string Serialize();

        protected string SerializeProps()
        {
            StringBuilder sb = new StringBuilder();

            foreach (var p in Props)
            {
                sb.Append(p.Value.Serialize());
                sb.Append("\n");
            }

            return sb.ToString();
        }

        public void SetStringProp(string id, string value)
        {
            if(!Props.ContainsKey(id) || (Props[id] as IWMStringProp is null))
            {
                Props[id] = new IWMStringProp();
                Props[id].Name = id;
            }
            Props[id].Value = value;
        }
    }

    internal class IWMTri
    {
        public List<(float, float, float)> Verts = new List<(float, float, float)>();
        public string Tex;
        public float TexScaleX;
        public float TexScaleY;
        public float TexShiftX;
        public float TexShiftY;
        public float TexRotDeg;
        public float Unk6;
        public string LightMapTex;
        public float LightScaleX;
        public float LightScaleY;
        public float LightShiftX;
        public float LightShiftY;
        public float LightRotDeg;
        public float Unk12;

        internal IWMTri()
        {

        }

        public override string ToString()
        {
            return $"( {Verts[0].Item1} {Verts[0].Item2} {Verts[0].Item3} ) ( {Verts[1].Item1} {Verts[1].Item2} {Verts[1].Item3} ) ( {Verts[2].Item1} {Verts[2].Item2} {Verts[2].Item3} ) {string.Join(" ", Tex, TexScaleX, TexScaleY, TexShiftX, TexShiftY, TexRotDeg, Unk6, LightMapTex, LightScaleX, LightScaleY, LightShiftX, LightShiftY, LightRotDeg, Unk12)}";
        }

        public static IWMTri FromString(string line)
        {
            IWMTri tri = new IWMTri();

            int index = line.IndexOf("(") + 2;
            int index2;
            float v1 = float.Parse(line.Substring(index, index2 = (line.IndexOf(" ", index) - index)));
            index += index2 + 1;
            float v2 = float.Parse(line.Substring(index, index2 = (line.IndexOf(" ", index) - index)));
            index += index2 + 1;
            float v3 = float.Parse(line.Substring(index, index2 = (line.IndexOf(" ", index) - index)));
            index += index2 + 1;
            tri.Verts.Add((v1, v2, v3));

            index = line.IndexOf("(", index) + 2;
            v1 = float.Parse(line.Substring(index, index2 = (line.IndexOf(" ", index) - index)));
            index += index2 + 1;
            v2 = float.Parse(line.Substring(index, index2 = (line.IndexOf(" ", index) - index)));
            index += index2 + 1;
            v3 = float.Parse(line.Substring(index, index2 = (line.IndexOf(" ", index) - index)));
            index += index2 + 1;
            tri.Verts.Add((v1, v2, v3));
            index = line.IndexOf("(", index) + 2;
            v1 = float.Parse(line.Substring(index, index2 = (line.IndexOf(" ", index) - index)));
            index += index2 + 1;
            v2 = float.Parse(line.Substring(index, index2 = (line.IndexOf(" ", index) - index)));
            index += index2 + 1;
            v3 = float.Parse(line.Substring(index, index2 = (line.IndexOf(" ", index) - index)));
            index += index2 + 1;
            tri.Verts.Add((v1, v2, v3));

            index = line.IndexOf(")", index) + 2;
            var split = line.Substring(index).Split(' ');
            tri.Tex = split[0];
            tri.TexScaleX = float.Parse(split[1]);
            tri.TexScaleY = float.Parse(split[2]);
            tri.TexShiftX = float.Parse(split[3]);
            tri.TexShiftY = float.Parse(split[4]);
            tri.TexRotDeg = float.Parse(split[5]);
            tri.Unk6 = float.Parse(split[6]);
            tri.LightMapTex = split[7];
            tri.LightScaleX = float.Parse(split[8]);
            tri.LightScaleY = float.Parse(split[9]);
            tri.LightShiftX = float.Parse(split[10]);
            tri.LightShiftY = float.Parse(split[11]);
            tri.LightRotDeg = float.Parse(split[12]);
            tri.Unk12 = float.Parse(split[13]);


            return tri;
        }
    }

    internal class IWMBrush : IWMProp
    {
        public List<IWMTri> Tris = new List<IWMTri>();
        public override void Interpret(string[] lines, ref int i, ref IWMProp currentProp)
        {
            if (lines[i].StartsWith("{"))
            {
                i++;
                return;
            }

            if (lines[i].StartsWith("}"))
            {
                i++;
                Parent.Props[Name] = this;
                currentProp = Parent;
                return;
            }

            if (lines[i].StartsWith(" guid"))
            {
                IWMStringProp stringProp = new IWMStringProp();
                stringProp.Parent = this;
                stringProp.Name = "guid";
                stringProp.Value = lines[i].Substring(" guid".Length + 1);
                Props[stringProp.Name] = stringProp;
                i++;
                return;
            }

            if (lines[i].StartsWith(" ("))
            {
                Tris.Add(IWMTri.FromString(lines[i]));
                i++;
                return;
            }
        }

        public override string Serialize()
        {
            return $"{Name}\n{{\n{SerializeProps()}{string.Join("\n", Tris)}\n}}";
        }

        public IWMTri AddTri()
        {
            IWMTri tri = new IWMTri();
            Tris.Add(tri);
            return tri;
        }
    }

    internal class IWMStringProp : IWMProp
    {
        public override void Interpret(string[] lines, ref int i, ref IWMProp currentProp)
        {
            Name = lines[i].Substring(0, lines[i].IndexOf('"', 1) + 1);
            Value = lines[i].Substring(Name.Length + 1);

            // add self to parent props
            Parent.Props[Name] = this;
            currentProp = Parent;
            i++;
        }

        public override string Serialize()
        {
            return $"{Name} {Value}";
        }
    }

    internal class IWMWorld : IWMProp
    {
        public override void Interpret(string[] lines, ref int i, ref IWMProp currentProp)
        {
            if (lines[i].Length < 1)
            {
                i++;
                return;
            }

            if (lines[i].StartsWith("//"))
            {
                IWMEnt entProp = new IWMEnt();
                entProp.Parent = this;
                entProp.Name = lines[i];
                currentProp = entProp;
                i++;
                return;
            }

            if (lines[i].StartsWith("\""))
            {
                IWMStringProp stringProp = new IWMStringProp();
                stringProp.Parent = this;
                currentProp = stringProp;
                return;
            }

            throw new Exception($"Unexpected line start for root world (LINE: {lines[i]})");
        }

        public override string Serialize()
        {
            return $"iwmap 4\n{SerializeProps()}\n";
        }
    }
}
