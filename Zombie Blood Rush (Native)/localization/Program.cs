using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace localization
{
    class Program
    {
        private static string[] languages = new string[]
        {
            "englisharabic",
            "french",
            "german",
            "italian",
            "japanese",
            "polish",
            "portuguese",
            "russian",
            "simplifiedchinese",
            "spanish",
            "traditionalchinese"
        };
        // Expects: arg[0] => C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Black Ops III\share\raw
        static void Main(string[] args)
        {
            if(args.Length < 1 || !Directory.Exists(args[0]))
            {
                Console.WriteLine("Error: Invalid path specified");
                return;
            }

            Environment.CurrentDirectory = args[0];

            if(!Directory.Exists("english\\localizedstrings"))
            {
                Console.WriteLine("No localization to be done; No english directory");
                return;
            }

            
            foreach(var file in Directory.GetFiles("english\\localizedstrings", "*.str", SearchOption.AllDirectories))
            {
                string[] ftemplate = File.ReadAllLines(file);
                List<string> LanguageEntries = new List<string>();

                bool is_copyall = false;
                foreach(var line in ftemplate)
                {
                    var current = line.Trim();
                    if (!current.ToLower().StartsWith("filenotes"))
                    {
                        continue;
                    }
                    
                    var split = current.Split(new char[] { ' ', '\t' }, StringSplitOptions.RemoveEmptyEntries);
                    if(split.Length < 2)
                    {
                        continue;
                    }

                    if(split[1].ToLower().Contains("copyall"))
                    {
                        is_copyall = true;
                        break;
                    }
                }

                if(!is_copyall)
                {
                    continue;
                }

                for(int i = 0; i < ftemplate.Length - 1; i++)
                {
                    var current = ftemplate[i].Trim();

                    if(!current.ToLower().StartsWith("reference"))
                    {
                        continue;
                    }

                    var split = current.Split(new char[] { ' ', '\t' }, StringSplitOptions.RemoveEmptyEntries);

                    var reference = split[1];
                    LanguageEntries.Add(reference);
                    i++;
                }

                foreach(var language in languages)
                {
                    var root = language;
                    if (!Directory.Exists(root))
                    {
                        Directory.CreateDirectory(root);
                    }

                    StringBuilder sb_file_contents = new StringBuilder();
                    sb_file_contents.AppendLine("FILENOTES		\"AUTOGEN\"");

                    string upper_cached = language.ToUpper();
                    foreach (var reference in LanguageEntries)
                    {
                        sb_file_contents.AppendLine($"REFERENCE {reference}");
                        sb_file_contents.AppendLine($"LANG_{upper_cached} #same");
                    }

                    sb_file_contents.AppendLine("ENDMARKER");

                    var base_dir = "english";
                    var desired_dir = Path.GetDirectoryName(Path.Combine(root, file.Substring(base_dir.Length + 1)));

                    if(!Directory.Exists(desired_dir))
                    {
                        Directory.CreateDirectory(desired_dir);
                    }

                    File.WriteAllText(Path.Combine(desired_dir, Path.GetFileName(file)), sb_file_contents.ToString());
                }
            }
        }
    }
}
