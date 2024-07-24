using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using static gsc2c.OBJ_SERIALIZATION_RESULT;

namespace gsc2c
{
    internal enum OBJ_SERIALIZATION_RESULT
    {
        OSR_SUCCESS,
        OSR_FAILURE_UNIMPLEMENTED
    }

    internal class PrimeObjSerializer
    {
        public string SerializationMessage { get; private set; }
        private string Script;
        private bool IsCSC = false;
        private PrimeObj Prime;

        private static string TemplatedHeader;
        private static string TemplatedCode;
        private static string TemplatedASM;



        private PrimeObjSerializer()
        {
            SerializationMessage = "OK";
            Script = "scripts/unknown.gsc";
            Prime = PrimeObj.None;
        }

        static PrimeObjSerializer()
        {
            using (Stream? stream = Assembly.GetExecutingAssembly().GetManifestResourceStream("gsc2c.TEMPLATE_NAME.h"))
            {
                if(stream is null)
                {
                    throw new Exception("Unable to load resource header");
                }
                using (StreamReader reader = new StreamReader(stream))
                {
                    TemplatedHeader = reader.ReadToEnd();
                }
            }

            using (Stream? stream = Assembly.GetExecutingAssembly().GetManifestResourceStream("gsc2c.TEMPLATE_NAME.cpp"))
            {
                if (stream is null)
                {
                    throw new Exception("Unable to load resource code");
                }
                using (StreamReader reader = new StreamReader(stream))
                {
                    TemplatedCode = reader.ReadToEnd();
                }
            }

            using (Stream? stream = Assembly.GetExecutingAssembly().GetManifestResourceStream("gsc2c.TEMPLATE_NAME.asm"))
            {
                if (stream is null)
                {
                    throw new Exception("Unable to load resource asm");
                }
                using (StreamReader reader = new StreamReader(stream))
                {
                    TemplatedASM = reader.ReadToEnd();
                }
            }
        }

        internal static OBJ_SERIALIZATION_RESULT Serialize(PrimeObj prime, string scriptName, out PrimeObjSerializer serialized)
        {
            serialized = new PrimeObjSerializer();
            serialized.Prime = prime;
            serialized.Script = scriptName;
            serialized.IsCSC = serialized.Script.EndsWith(".csc");
            
            // TODO

            return OSR_SUCCESS;
        }

        internal string GenerateHeader()
        {
            string templatedSource = TemplatedHeader.Replace("TEMPLATE_NAME_NORMALIZED", Script.Replace(".", "_").Replace("/", "_"));

            return templatedSource;
        }

        internal string GenerateCode()
        {
            string templatedSource = TemplatedCode.Replace("TEMPLATE_NAME_NORMALIZED", Script.Replace(".", "_").Replace("/", "_"));

            ReplaceTemplatedValue(ref templatedSource, "MODULE_ID", PrimeObj.Hash64(Script.Bytes()).ToString());
            ReplaceTemplatedValue(ref templatedSource, "INCLUDES", string.Join(',', Prime.Includes) + ", 0");

            return templatedSource;
        }

        internal string GenerateASM()
        {
            string templatizedNameNormal = Script.Replace(".", "_").Replace("/", "_");
            string templatedSource = TemplatedASM.Replace("TEMPLATE_NAME_NORMALIZED", templatizedNameNormal);

            ReplaceTemplatedValue(ref templatedSource, "VM_INSTANCE", IsCSC ? "1" : "0");

            StringBuilder includesRetStack = new StringBuilder();

            int index = 0;
            foreach(var include in Prime.Includes)
            {
                includesRetStack.AppendLine("\tpush rdx");
                includesRetStack.AppendLine("\tpush 0");
                includesRetStack.AppendLine($"\tmov rax, [rcx+{index * 8}]");
                includesRetStack.AppendLine("\tpush rax");
                includesRetStack.AppendLine($"\tmov rax, {templatizedNameNormal}_RESTORE_CALL_CONTEXT");
                includesRetStack.AppendLine("\tpush rax");

                index++;
            }

            ReplaceTemplatedValue(ref templatedSource, "INCLUDE_RETS", includesRetStack.ToString());

            return templatedSource;
        }

        private void ReplaceTemplatedValue(ref string source, in string key, in string value)
        {
            string begin = $"/*{key}*/";
            string end = $"/*/{key}*/";

            StringBuilder result = new StringBuilder();

            int beginIndex, endIndex = 0, lastCopied = 0;

            while((beginIndex = source.IndexOf(begin, endIndex)) != -1 && beginIndex + begin.Length < source.Length && (endIndex = source.IndexOf(end, beginIndex + begin.Length)) != -1)
            {
                result.Append(source.Substring(lastCopied, beginIndex));
                result.Append(value);
                lastCopied = endIndex + end.Length;
            }

            if(lastCopied < source.Length)
            {
                result.Append(source.Substring(lastCopied));
            }

            source = result.ToString();
        }
    }
}
