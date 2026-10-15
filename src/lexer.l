/* lexer.l: Flex lexer for Anka (spec: docs/LANGUAGE.md §2).
 *
 * How Flex picks a rule (lecture 2, "Ambiguity"):
 *   1. maximal munch: the rule that matches the LONGEST text wins
 *   2. rule priority: on a tie in length, the rule listed FIRST wins
 * That is why the keywords come before IDENT, and the catch-all "." is last.
 */

%option noyywrap nounput noinput yylineno

%{
#include <stdio.h>
#include <ctype.h>
#include "tokens.h"

int lex_errors = 0;             /* read by main.c to choose the exit status */

static int comment_depth = 0;       /* how many open comments we are inside */
static int comment_start_line = 0;  /* line of the outermost open comment */

/* Print one error line in the format of docs/LANGUAGE.md §2.8 and count it. */
static void lex_error(int line, const char *what, const char *text)
{
    printf("LINE %d: %-12s %s '%s'\n", line, "ERROR", what, text);
    lex_errors++;
}

/* A string token may contain any escape (\\. in its regex); only
 * \n \t \" \\ are legal. Report each bad one; the string is still returned. */
static void check_escapes(const char *s, int line)
{
    for (int i = 1; s[i] != '\0'; i++) {
        if (s[i] == '\\') {
            char c = s[i + 1];
            if (c != 'n' && c != 't' && c != '"' && c != '\\') {
                char bad[3] = { '\\', c, '\0' };
                lex_error(line, "invalid escape", bad);
            }
            i++;                /* skip the escaped character */
        }
    }
}
%}

DIGIT       [0-9]
LETTER      [a-zA-Z_]
EXPONENT    [eE][+-]?{DIGIT}+

    /* COMMENT: inside a block comment. %x = exclusive: only <COMMENT> rules run. */
%x COMMENT

%%

    /* ---- whitespace and comments ---- */
[ \t\r\n]+              { /* skip; yylineno counts the \n for us */ }
"//"[^\n]*              { /* line comment: skip to the end of the line */ }

"/*"                    { comment_depth = 1;
                          comment_start_line = yylineno;
                          BEGIN(COMMENT); }
<COMMENT>"/*"           { comment_depth++;      /* comments nest */ }
<COMMENT>"*/"           { comment_depth--;
                          if (comment_depth == 0) BEGIN(INITIAL); }
<COMMENT>[^/*\n]+       { /* comment text: skip */ }
<COMMENT>\n             { /* skip; yylineno still counts it */ }
<COMMENT>.              { /* a lone '/' or '*' inside a comment */ }
<COMMENT><<EOF>>        { lex_error(comment_start_line, "unterminated comment", "/*");
                          BEGIN(INITIAL);
                          return END; }

    /* ---- keywords: BEFORE IDENT, so "if" is IF and not IDENT ---- */
"fn"                    { return FN; }
"let"                   { return LET; }
"if"                    { return IF; }
"else"                  { return ELSE; }
"while"                 { return WHILE; }
"for"                   { return FOR; }
"in"                    { return IN; }
"return"                { return RETURN; }
"break"                 { return BREAK; }
"continue"              { return CONTINUE; }
"print"                 { return PRINT; }
"int"                   { return TYPE_INT; }
"float"                 { return TYPE_FLOAT; }
"bool"                  { return TYPE_BOOL; }
"true"                  { return TRUE; }
"false"                 { return FALSE; }

    /* ---- identifiers: "ifx" is 3 chars, the keyword "if" only 2, so munch picks IDENT ---- */
{LETTER}({LETTER}|{DIGIT})*     { return IDENT; }

    /* ---- numbers ---- */
    /* Float: digits on BOTH sides of '.', or an exponent. Rejects "1." and ".5",
       so "0..5" can only be INT DOTDOT INT. Leading zeros are allowed: "007.5". */
{DIGIT}+"."{DIGIT}+{EXPONENT}?  { return FLOAT_LIT; }
{DIGIT}+{EXPONENT}              { return FLOAT_LIT; }
    /* Int: "0" alone, or no leading zero. */
0|[1-9]{DIGIT}*                 { return INT_LIT; }
    /* "007": longer than INT's "0", so munch picks this error rule. */
0{DIGIT}+                       { lex_error(yylineno, "integer with leading zeros", yytext); }

    /* ---- strings: no newline inside; \\. accepts any escape, checked in C ---- */
\"([^"\\\n]|\\.)*\"             { check_escapes(yytext, yylineno);
                                  return STRING_LIT; }
    /* Same without the closing quote: stops before the \n, so the next line lexes normally. */
\"([^"\\\n]|\\.)*               { lex_error(yylineno, "unterminated string", yytext); }

    /* ---- operators: munch makes "==" one EQ, never two ASSIGNs ---- */
"+"                     { return PLUS; }
"-"                     { return MINUS; }
"*"                     { return STAR; }
"/"                     { return SLASH; }
"%"                     { return PERCENT; }
"**"                    { return POW; }
"="                     { return ASSIGN; }
"+="                    { return PLUS_ASSIGN; }
"-="                    { return MINUS_ASSIGN; }
"*="                    { return STAR_ASSIGN; }
"/="                    { return SLASH_ASSIGN; }
"=="                    { return EQ; }
"!="                    { return NEQ; }
"<"                     { return LT; }
"<="                    { return LE; }
">"                     { return GT; }
">="                    { return GE; }
"&&"                    { return AND; }
"||"                    { return OR; }
"!"                     { return NOT; }
"->"                    { return ARROW; }
".."                    { return DOTDOT; }

    /* ---- punctuation ---- */
"("                     { return LPAREN; }
")"                     { return RPAREN; }
"{"                     { return LBRACE; }
"}"                     { return RBRACE; }
";"                     { return SEMI; }
","                     { return COMMA; }
":"                     { return COLON; }

<<EOF>>                 { return END; }

    /* ---- catch-all, LAST: any other single byte is an error; skip it and go on ---- */
.                       { unsigned char c = (unsigned char)yytext[0];
                          if (c >= 128 || !isprint(c)) {     /* not printable ASCII */
                              char hex[5];
                              snprintf(hex, sizeof hex, "\\x%02X", c);
                              lex_error(yylineno, "unexpected byte", hex);
                          } else {
                              lex_error(yylineno, "unexpected character", yytext);
                          } }

%%
