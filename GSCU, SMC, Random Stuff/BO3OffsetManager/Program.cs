
// See https://aka.ms/new-console-template for more information

using BO3OffsetManager;

const string dbpath = "offsets.db";

void print_opts()
{
    Console.Clear();
    Console.WriteLine("BO3 Offset Manager");
    Console.WriteLine("Prefixes: ");
    Console.WriteLine("-: Delete an offset from the database.");
    Console.WriteLine("g: Globalize the output (add _g)");
    Console.WriteLine("#define <NAME> OFFSET(0x...): Automatically change to a named globalization const");
    Console.WriteLine("Enter an offset to autoconvert, lookup, or manually convert:");
}

s_db Database;
void db_init()
{
    Database = new s_db();

    if(!File.Exists(dbpath))
    {
        Database.Save(dbpath);
    }

    Database.Load(File.ReadAllBytes(dbpath));
}

void db_delete(ulong off)
{
    Database.Remove(off);
}

void db_commit()
{
    Database.Save(dbpath);
}

bool db_resolve(ulong offset, out ulong result)
{
    return Database.TryResolve(offset, out result);
}

void db_insert(ulong original, ulong newOff)
{
    Database.Add(original, newOff);
}

db_init();

while (true)
{
    print_opts();

    var off_str = Console.ReadLine() ?? "";
    ulong offset = 0;
    bool shouldDelete = false;
    bool shouldGlobalize = false;
    string gconsttemplate = null;
    try
    {
        if (off_str.StartsWith("-"))
        {
            offset = ulong.Parse(off_str.Replace("0x", "").Replace("L", "").Replace("-", "").Trim(), System.Globalization.NumberStyles.HexNumber);
            shouldDelete = true;
        }
        else if (off_str.StartsWith("g"))
        {
            shouldGlobalize = true;
            offset = ulong.Parse(off_str.Replace("0x", "").Replace("L", "").Replace("g", "").Trim(), System.Globalization.NumberStyles.HexNumber);
        }
        else if(off_str.StartsWith("#define"))
        {
            gconsttemplate = off_str;
            var tstr = off_str.Replace("0x", "").Replace("L", "").Trim();
            tstr = tstr.Substring(tstr.IndexOf("OFFSET(") + "OFFSET(".Length);
            tstr = tstr.Substring(0, tstr.IndexOf(")"));
            offset = ulong.Parse(tstr, System.Globalization.NumberStyles.HexNumber);
            shouldGlobalize = true;
        }
        else
        {
            offset = ulong.Parse(off_str.Replace("0x", "").Replace("L", "").Trim(), System.Globalization.NumberStyles.HexNumber);
        }
    }
    catch
    {
        Console.WriteLine("Error: Invalid offset. Press any key to continue...");
        Console.ReadKey(true);
        continue;
    }


    if(shouldDelete)
    {
        db_delete(offset);
        db_commit();
        Console.WriteLine("Database updated. Press any key to continue...");
        Console.ReadKey(true);
        continue;
    }

    ulong new_offset = 0;
    if (!db_resolve(offset, out new_offset))
    {
        Console.WriteLine($"Could not resolve offset (0x{offset:X}). Please enter a new offset:");
        try
        {
            off_str = Console.ReadLine() ?? "";
            new_offset = ulong.Parse(off_str.Replace("0x", "").Replace("L", "").Trim(), System.Globalization.NumberStyles.HexNumber);
        }
        catch
        {
            Console.WriteLine("Error: Invalid offset. Press any key to continue...");
            Console.ReadKey(true);
            continue;
        }
    }

    // offset is translated, commit to db
    db_insert(offset, new_offset);
    db_commit();
    Console.WriteLine("Database updated.");

    string outString = $"0x{new_offset:X}";

    if(shouldGlobalize)
    {
        outString += "_g";
    }

    if(!(gconsttemplate is null))
    {
        outString = gconsttemplate.Substring(0, gconsttemplate.IndexOf("OFFSET(")) + outString;
    }

    Console.WriteLine(outString);
    Console.WriteLine("Offset mapped. Press any key to continue...");
    Console.ReadKey(true);
}