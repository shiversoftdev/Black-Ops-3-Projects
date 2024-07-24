// See https://aka.ms/new-console-template for more information
Console.WriteLine("Drag a csv to generate autobalancer for.");

var file = Console.ReadLine().Replace("\"", "");

if(!File.Exists(file))
{
    Console.WriteLine("Error: File does not exist.");
    Console.ReadKey(true);
    return;
}

bool use_custom_split = false;
Console.WriteLine("Use advanced naming? (Y/N)");
use_custom_split = Console.ReadKey(false).Key == ConsoleKey.Y;

var lines = File.ReadAllLines(file);

var head = lines[0].Split(",");

int find_col(string val)
{
    for(int i = 0; i < head.Length; i++)
    {
        if (head[i] == val)
            return i;
    }

    return -1;
}

var i_name = find_col("name");
var i_mult = find_col("multiplier");
var i_head = find_col("headmultiplier");

if(i_name < 0 || i_mult < 0)
{
    Console.WriteLine("Error: File is missing critical header information. (name and multiplier must be defined. headmultiplier is optional)");
    Console.ReadKey(true);
    return;
}

List<string> out_lines = new List<string>();

(string, string) weapon_split(string wep)
{
    if(use_custom_split)
    {
        return (wep, "undefined");
    }
    if(wep.EndsWith("_upgraded"))
    {
        return (wep.Substring(0, wep.IndexOf("_upgraded")), wep);
    }
    if (wep.EndsWith("_up"))
    {
        return (wep.Substring(0, wep.IndexOf("_up")), wep);
    }

    Console.WriteLine("Error: One of the weapons has an invalid naming convention.");
    Console.ReadKey(true);
    Environment.Exit(0);
    return (null, null);
}

for(int i = 1; i < lines.Length; i++)
{
    var row = lines[i].Split(",");

    string name = row[i_name];
    string mult = row[i_mult];

    if(name.Length < 1)
    {
        continue;
    }

    if(!float.TryParse(mult, out float multiplier))
    {
        Console.WriteLine("Error: One of the weapons has an invalid multiplier.");
        Console.ReadKey(true);
        Environment.Exit(0);
    }

    var names = weapon_split(name);

    out_lines.Add($"\tregister_weapon_scalar(\"{names.Item1}\", \"{names.Item2}\", {multiplier});");

    if (i_head > 0)
    {
        mult = row[i_head];

        if (!float.TryParse(mult, out multiplier))
        {
            continue;
        }

        out_lines.Add($"\tregister_weapon_hd_modifier(\"{names.Item1}\", \"{names.Item2}\", {multiplier});");
        out_lines.Add($"\tregister_weapon_head_modifier(\"{names.Item1}\", \"{names.Item2}\", {multiplier});");
    }
}

File.WriteAllLines(file + ".paste.txt", out_lines);