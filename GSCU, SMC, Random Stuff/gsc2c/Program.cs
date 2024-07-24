// args: <input file> <output directory> [options]

using gsc2c;
using System.IO;

const int EXIT_CODE_ARGUMENTS = 1;
const int EXIT_CODE_PARSING_FAILED = 2;
const int EXIT_CODE_SERIALIZING_FAILED = 3;

if (args.Length < 2)
{
    Console.Error.WriteLine("Invalid arguments; too few arguments were passed to the program. Expected: <input file> <output directory> [options]");
    Environment.Exit(EXIT_CODE_ARGUMENTS);
}

var input = args[0];
var output = args[1];

if(!File.Exists(input))
{
    Console.Error.WriteLine("Invalid arguments; input file does not exist. Expected: <input file> <output directory> [options]");
    Environment.Exit(EXIT_CODE_ARGUMENTS);
}

var normalizedInput = input.Replace('\\', '/');
if (normalizedInput.IndexOf("scripts/") == -1)
{
    Console.Error.WriteLine("Invalid arguments; input file needs to be in its correct filepath (scripts/my/script.gsc)");
    Environment.Exit(EXIT_CODE_ARGUMENTS);
}

var scriptName = normalizedInput.Substring(normalizedInput.IndexOf("scripts/")).ToLower();
if (!(scriptName.EndsWith(".gsc") || scriptName.EndsWith(".csc")))
{
    Console.Error.WriteLine("Invalid arguments; input file needs to be terminated with the correct file extension (.gsc or .csc)");
    Environment.Exit(EXIT_CODE_ARGUMENTS);
}

try
{
    output = Path.GetFullPath(output);
    if(!Directory.Exists(output))
    {
        Directory.CreateDirectory(output);
    }
}
catch
{
    Console.Error.WriteLine("Invalid arguments; output directory was unable to be created/validated");
    Environment.Exit(EXIT_CODE_ARGUMENTS);
}

var parseResult = PrimeObj.Parse(File.ReadAllBytes(input), out var prime);
if(parseResult != PrimeParseResult.PPR_SUCCESS)
{
    Console.Error.WriteLine($"Error parsing the input file: {parseResult.ToString()} (Parser Info: {prime.ParserMessage})");
    Environment.Exit(EXIT_CODE_PARSING_FAILED);
}

var serializerResult = PrimeObjSerializer.Serialize(prime, scriptName, out var serialized);
if(serializerResult != OBJ_SERIALIZATION_RESULT.OSR_SUCCESS)
{
    Console.Error.WriteLine($"Error serializing the input file: {serializerResult.ToString()} (Serializer Info: {serialized.SerializationMessage})");
    Environment.Exit(EXIT_CODE_SERIALIZING_FAILED);
}

try
{
    File.WriteAllText(Path.Combine(output, scriptName.Replace(".", "_").Replace("/", "_") + ".h"), serialized.GenerateHeader());
    File.WriteAllText(Path.Combine(output, scriptName.Replace(".", "_").Replace("/", "_") + ".cpp"), serialized.GenerateCode());
    File.WriteAllText(Path.Combine(output, scriptName.Replace(".", "_").Replace("/", "_") + "_asm.asm"), serialized.GenerateASM());
}
catch(Exception e)
{
    Console.Error.WriteLine($"Error serializing the input file: Writing finalized files failed ({e.Message})");
    Environment.Exit(EXIT_CODE_SERIALIZING_FAILED);
}

// TODO: modify the project file to include these if not already included

// design:
/* purpose of this program is to generate serialized GSC buffers. Execution of said buffers is up to other sources. 
 * stub script data will be emitted either as a linker stub or a builtin stub based on a supplied option.
 * stub script anatomy:
 *      - single entrypoint, custom opcode to fire our environment load and trigger autoexecs
 *      - export stubs that get linked by our entrypoint stub
 *      
 * TODO: exports deserialization and reserialization
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 */ 