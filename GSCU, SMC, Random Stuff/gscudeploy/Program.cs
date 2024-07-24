using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace gscudeploy
{
    class Program
    {
        static void Main(string[] args)
        {
            if(args.Length != 2)
            {
                Console.Error.WriteLine("invalid arguments. expects args: <step> <solution directory>");
                Environment.Exit(1);
            }

            if(!Directory.Exists(args[1]))
            {
                Console.Error.WriteLine($"solution directory invalid. expects args: <step> <solution directory> ({args[1]}) does not exist)");
                Environment.Exit(1);
            }

            // expects args: <step> <solution directory>
            // valid steps: prebuild, postbuild

            // prebuild: runs before any other project is build, but after this project is built
            //      responsibilities:
            //          - Scramble gscu_api.h and gscu_api_private.h
            //          - Deploy gscu_api.h to solution/build/api/cpp/gscu_api.h
            // postbuild: runs after the extension is built
            //      responsibilities:
            //          - none

            switch (args[0].Trim().ToLower())
            {
                case "prebuild":
                    {
                        var result = Pre(args[1]);

                        if (!result.Item1)
                        {
                            Console.Error.WriteLine(result.Item2);
                            Environment.Exit(1);
                        }
                    }
                    break;

                case "postbuild":
                    {
                        var result = Post(args[1]);

                        if (!result.Item1)
                        {
                            Console.Error.WriteLine(result.Item2);
                            Environment.Exit(1);
                        }
                    }
                    break;

                default:
                    Console.Error.WriteLine("build step invalid. expects args: <step> <solution directory>");
                    Environment.Exit(1);
                    break;
            }

            Console.WriteLine($"Build: {args[0].Trim().ToLower()} finished.");
        }

        private static (bool, string) Pre(string solutionDir)
        {
            var res = PrepAPI(solutionDir);

            if(!res.Item1)
            {
                return res;
            }

            return (true, null);
        }

        private static (bool, string) Post(string solutionDir)
        {
            return (true, null);
        }

        private static (bool, string) PrepAPI(string solutionDir)
        {
            List<string> api_private = File.ReadAllLines(Path.Combine(solutionDir, @"Internal\gscu_api_private.h")).ToList();
            Random r = new Random();
            for(int i = 0; i < api_private.Count; i++)
            {
                if(api_private[i].Contains("/*BUILD_API_LINERNG_START*/"))
                {
                    
                    int end = -1;
                    for (int j = i + 1; j < api_private.Count; j++)
                    {
                        if(api_private[j].Contains("/*BUILD_API_LINERNG_END*/"))
                        {
                            end = j;
                            break;
                        }
                    }

                    if(end < 0)
                    {
                        continue;
                    }

                    List<string> tmp = new List<string>();

                    for(int j = i + 1; j < end; j++)
                    {
                        tmp.Add(api_private[i + 1]);
                        api_private.RemoveAt(i + 1);
                    }

                    while(tmp.Count > 0)
                    {
                        int indx = r.Next(0, tmp.Count);
                        api_private.Insert(i + 1, tmp[indx]);
                        tmp.RemoveAt(indx);
                    }
                }
            }

            File.WriteAllLines(Path.Combine(solutionDir, @"Internal\gscu_api_private.h"), api_private.ToArray());

            List<string> api_public = File.ReadAllLines(Path.Combine(solutionDir, @"Internal\gscu_api.h")).ToList();

            for (int i = 0; i < api_public.Count; i++)
            {
                if (api_public[i].Contains("/*BUILD_API_LINERNG_START*/"))
                {
                    int end = -1;
                    for (int j = i + 1; j < api_public.Count; j++)
                    {
                        if (api_public[j].Contains("/*BUILD_API_LINERNG_END*/"))
                        {
                            end = j;
                            break;
                        }
                    }

                    if (end < 0)
                    {
                        continue;
                    }

                    List<string> tmp = new List<string>();

                    for (int j = i + 1; j < end; j++)
                    {
                        tmp.Add(api_public[i + 1]);
                        api_public.RemoveAt(i + 1);
                    }

                    while (tmp.Count > 0)
                    {
                        int indx = r.Next(0, tmp.Count);
                        api_public.Insert(i + 1, tmp[indx]);
                        tmp.RemoveAt(indx);
                    }
                }
            }

            File.WriteAllLines(Path.Combine(solutionDir, @"Internal\gscu_api.h"), api_public.ToArray());

            for(int i = 0; i < api_public.Count; i++)
            {
                if(api_public[i].Contains("/*BUILD_API_LINERNG_START*/") || api_public[i].Contains("/*BUILD_API_LINERNG_END*/"))
                {
                    api_public.RemoveAt(i);
                    i--;
                    continue;
                }
            }

            var path = Path.Combine(solutionDir, @"build\api\cpp\gscu_api.h");
            if(!Directory.Exists(Path.GetDirectoryName(path)))
            {
                Directory.CreateDirectory(Path.GetDirectoryName(path));
            }

            File.WriteAllLines(Path.Combine(solutionDir, @"build\api\cpp\gscu_api.h"), api_public.ToArray());

            return (true, null);
        }
    }
}
