using Irony.Parsing;
using Irony.Interpreter.Ast;
using System;
using System.Collections.Generic;
using System.Text;

namespace shiversoft
{
    public class Resolver : shiversoft.IASTResolver
    {
        #region IASTResolver Members


        public IList<shiversoft.Declaration> FindCompletions(object result, int line, int col)
        {
            // Used for intellisense.
            List<shiversoft.Declaration> declarations = new List<shiversoft.Declaration>();

            // Add keywords defined by grammar
            foreach (KeyTerm key in Configuration.Grammar.keywords)
            {
                declarations.Add(new Declaration("", key.Name, 206, key.Name));
            }

            declarations.Sort();
            return declarations;
        }

        public IList<shiversoft.Declaration> FindMembers(object result, int line, int col)
        {
            List<shiversoft.Declaration> members = new List<shiversoft.Declaration>();

            return members;
        }

        public string FindQuickInfo(object result, int line, int col)
        {
            return "unknown";
        }

        public IList<shiversoft.Method> FindMethods(object result, int line, int col, string name)
        {
            return new List<shiversoft.Method>();
        }

        #endregion
    }
}
