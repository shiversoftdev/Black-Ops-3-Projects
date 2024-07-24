using System;
using System.Collections;
using System.IO;

namespace gscubuild
{
    class Program
    {
        private static string action;
        private static string output;
        private static string mode;
        private static string[] files;
        // compiler -a build -o "bin\debug" -m debug -f "file1;file2;file3"
        static void Main(string[] args)
        {
            for(int i = 0; i < args.Length; i++)
            {
                switch(args[i])
                {
                    case "-a":
                        if(args.Length - i < 2)
                        {
                            Error("action switch 'a' requires an action argument", 1);
                        }
                        action = args[++i].ToLower().Trim();
                        break;
                    case "-o":
                        if (args.Length - i < 2)
                        {
                            Error("output switch 'o' requires an output directory argument", 1);
                        }
                        output = args[++i].ToLower().Trim();
                        if(!Directory.Exists(output))
                        {
                            Error($"directory '{output}' doesnt exist", 1);
                        }
                        break;
                    case "-m":
                        if (args.Length - i < 2)
                        {
                            Error("mode switch 'm' requires a mode argument", 1);
                        }
                        mode = args[++i].ToLower().Trim();
                        break;
                    case "-f":
                        if (args.Length - i < 2)
                        {
                            Error("files switch 'f' requires a semicolon separated list of files", 1);
                        }
                        files = args[++i].ToLower().Trim().Split(";");
                        break;
                    default:
                        Error($"build switch {args[i]} unrecognized", 1);
                        break;
                }
            }

            switch(action)
            {
                case "build":
                    ValidateMode(mode);

                    foreach(string file in files)
                    {
                        GSCUCompiler.CompileSingle(file, Path.Combine(output, file + "c"));
                    }

                    // TODO: link the files too for intellisense

                    break;
                default:
                    Error($"unrecognized action '{action}'", 1);
                    break;
            }
        }

        static void ValidateMode(string m)
        {
            if(m != "debug" && m != "release")
            {
                Error($"unsupported mode '{m}'", 1);
            }
        }

        static void Error(string msg, int code)
        {
            Console.Error.WriteLine($"GSCUBUILD : error GSCU{code}: {msg}");
            Environment.Exit(0);
        }
    }
}
