using Irony.Interpreter.Ast;
using Irony.Parsing;
using Microsoft.VisualStudio;
using Microsoft.VisualStudio.Package;
using Microsoft.VisualStudio.TextManager.Interop;
using System;
using System.Collections.Generic;
using System.Diagnostics;

namespace shiversoft
{
    public class IronyLanguageService : Microsoft.VisualStudio.Package.LanguageService
    {
        private Grammar grammar;
        private Parser parser;
        private ParsingContext context;

        public IronyLanguageService()
        {
            grammar = new Grammar();
            parser = new Parser(Configuration.Grammar);
            context = new ParsingContext(parser);
        }


        #region Custom Colors
        public override int GetColorableItem(int index, out IVsColorableItem item)
        {
            if (index <= Configuration.ColorableItems.Count)
            {
                item = Configuration.ColorableItems[index - 1];
                return Microsoft.VisualStudio.VSConstants.S_OK;
            }
            else
            {
                throw new ArgumentNullException("index");
            }
        }

        public override int GetItemCount(out int count)
        {
            count = Configuration.ColorableItems.Count;
            return Microsoft.VisualStudio.VSConstants.S_OK;
        }
        #endregion

        #region MPF Accessor and Factory specialisation
        private LanguagePreferences preferences;
        public override LanguagePreferences GetLanguagePreferences()
        {
            if (this.preferences == null)
            {
                this.preferences = new LanguagePreferences(this.Site,
                                                        typeof(IronyLanguageService).GUID,
                                                        this.Name);
                this.preferences.Init();
            }

            return this.preferences;
        }

        public override Microsoft.VisualStudio.Package.Source CreateSource(IVsTextLines buffer)
        {
            return new Source(this, buffer, this.GetColorizer(buffer));
        }

        private IScanner scanner;
        public override IScanner GetScanner(IVsTextLines buffer)
        {
            if (scanner == null)
                this.scanner = new LineScanner(grammar);

            return this.scanner;
        }
        #endregion

        public override void OnIdle(bool periodic)
        {
            // from IronPythonLanguage sample
            // this appears to be necessary to get a parse request with ParseReason = Check?
            Source src = (Source)GetSource(this.LastActiveTextView);
            if (src != null && src.LastParseTime >= Int32.MaxValue >> 12)
            {
                src.LastParseTime = 0;
            }
            base.OnIdle(periodic);
        }

        public override Microsoft.VisualStudio.Package.AuthoringScope ParseSource(ParseRequest req)
        {
            // Debug.Print("ParseSource at ({0}:{1}), reason {2}", req.Line, req.Col, req.Reason);
            Source source = (Source)GetSource(req.View);
            switch (req.Reason)
            {
                case ParseReason.Check:
                    // This is where you perform your syntax highlighting.
                    // Parse entire source as given in req.Text.
                    // Store results in the AuthoringScope object.
                    AstNode node = (AstNode)parser.Parse(req.Text, req.FileName).Root?.AstNode;
                    source.ParseResult = node;

                    // Used for brace matching.
                    TokenStack braces = parser.Context.OpenBraces;
                    foreach (Token brace in braces)
                    {
                        TextSpan openBrace = new TextSpan();
                        openBrace.iStartLine = brace.Location.Line;
                        openBrace.iStartIndex = brace.Location.Column;
                        openBrace.iEndLine = brace.Location.Line;
                        openBrace.iEndIndex = openBrace.iStartIndex + brace.Length;

                        if(brace.OtherBrace is null)
                        {
                            continue;
                        }

                        TextSpan closeBrace = new TextSpan();
                        closeBrace.iStartLine = brace.OtherBrace.Location.Line;
                        closeBrace.iStartIndex = brace.OtherBrace.Location.Column;
                        closeBrace.iEndLine = brace.OtherBrace.Location.Line;
                        closeBrace.iEndIndex = closeBrace.iStartIndex + brace.OtherBrace.Length;

                        if (source.Braces == null)
                        {
                            source.Braces = new List<TextSpan[]>();
                        }
                        source.Braces.Add(new TextSpan[2] { openBrace, closeBrace });
                    }
                    
                    if (parser.Context.CurrentParseTree.ParserMessages.Count > 0)
                    {
                        foreach (var error in parser.Context.CurrentParseTree.ParserMessages)
                        {
                            TextSpan span = new TextSpan();
                            span.iStartLine = span.iEndLine = error.Location.Line;
                            span.iStartIndex = error.Location.Column;
                            span.iEndIndex = error.Location.Position;
                            req.Sink.AddError(req.FileName, error.Message, span, Severity.Error);
                        }
                    }

                    // TODO: intellisense errors: parser.Context.CurrentParseTree.Root
                    break;

                case ParseReason.DisplayMemberList:
                    // Parse the line specified in req.Line for the two
                    // tokens just before req.Col to obtain the identifier
                    // and the member connector symbol.
                    // Examine existing parse tree for members of the identifer
                    // and return a list of members in your version of the
                    // Declarations class as stored in the AuthoringScope
                    // object.
                    break;

                case ParseReason.MethodTip:
                    // Parse the line specified in req.Line for the token
                    // just before req.Col to obtain the name of the method
                    // being entered.
                    // Examine the existing parse tree for all method signatures
                    // with the same name and return a list of those signatures
                    // in your version of the Methods class as stored in the
                    // AuthoringScope object.
                    break;

                case ParseReason.HighlightBraces:
                case ParseReason.MemberSelectAndHighlightBraces:
                    if (source.Braces != null)
                    {
                        foreach (TextSpan[] brace in source.Braces)
                        {
                            if (brace.Length == 2)
                                req.Sink.MatchPair(brace[0], brace[1], 1);
                            else if (brace.Length >= 3)
                                req.Sink.MatchTriple(brace[0], brace[1], brace[2], 1);
                        }
                    }
                    break;
            }

            return new AuthoringScope(source.ParseResult);
        }

        /// <summary>
        /// Called to determine if the given location can have a breakpoint applied to it. 
        /// </summary>
        /// <param name="buffer">The IVsTextBuffer object containing the source file.</param>
        /// <param name="line">The line number where the breakpoint is to be set.</param>
        /// <param name="col">The offset into the line where the breakpoint is to be set.</param>
        /// <param name="pCodeSpan">
        /// Returns the TextSpan giving the extent of the code affected by the breakpoint if the 
        /// breakpoint can be set.
        /// </param>
        /// <returns>
        /// If successful, returns S_OK; otherwise returns S_FALSE if there is no code at the given 
        /// position or returns an error code (the validation is deferred until the debug engine is loaded). 
        /// </returns>
        /// <remarks>
        /// <para>
        /// CAUTION: Even if you do not intend to support the ValidateBreakpointLocation but your language 
        /// does support breakpoints, you must override the ValidateBreakpointLocation method and return a 
        /// span that contains the specified line and column; otherwise, breakpoints cannot be set anywhere 
        /// except line 1. You can return E_NOTIMPL to indicate that you do not otherwise support this 
        /// method but the span must always be set. The example shows how this can be done.
        /// </para>
        /// <para>
        /// Since the language service parses the code, it generally knows what is considered code and what 
        /// is not. Normally, the debug engine is loaded and the pending breakpoints are bound to the source. It is at this time the breakpoint location is validated. This method is a fast way to determine if a breakpoint can be set at a particular location without loading the debug engine.
        /// </para>
        /// <para>
        /// You can implement this method to call the ParseSource method with the parse reason of CodeSpan. 
        /// The parser examines the specified location and returns a span identifying the code at that 
        /// location. If there is code at the location, the span identifying that code should be passed to 
        /// your implementation of the CodeSpan method in your version of the AuthoringSink class. Then your 
        /// implementation of the ValidateBreakpointLocation method retrieves that span from your version of 
        /// the AuthoringSink class and returns that span in the pCodeSpan argument.
        /// </para>
        /// <para>
        /// The base method returns E_NOTIMPL.
        /// </para>
        /// </remarks>
        public override int ValidateBreakpointLocation(IVsTextBuffer buffer, int line, int col, TextSpan[] pCodeSpan)
        {
            // TODO: Add code to not allow breakpoints to be placed on non-code lines.
            // TODO: Refactor to allow breakpoint locations to span multiple lines.
            if (pCodeSpan != null)
            {
                pCodeSpan[0].iStartLine = line;
                pCodeSpan[0].iStartIndex = col;
                pCodeSpan[0].iEndLine = line;
                pCodeSpan[0].iEndIndex = col;
                if (buffer != null)
                {
                    int length;
                    buffer.GetLengthOfLine(line, out length);
                    pCodeSpan[0].iStartIndex = 0;
                    pCodeSpan[0].iEndIndex = length;
                }
                return VSConstants.S_OK;
            }
            else
            {
                return VSConstants.S_FALSE;
            }
        }

        public override ViewFilter CreateViewFilter(CodeWindowManager mgr, IVsTextView newView)
        {
            return new IronyViewFilter(mgr, newView);
        }

        public override string Name
        {
            get { return Configuration.Name; }
        }

        public override string GetFormatFilterList()
        {
            return Configuration.FormatList;
        }
    }
}