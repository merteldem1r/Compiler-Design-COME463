/* main.c: driver for the Anka compiler `ankac`.
 *
 * Project 1 only has one mode:  ankac --tokens [file.anka]
 * It calls yylex() until END and prints one token per line
 * (format: docs/LANGUAGE.md §2.8). Without a file it reads standard input.
 */
#include <stdio.h>
#include <string.h>
#include "tokens.h"

/* Defined in the Flex-generated lexer (lexer.l). */
extern FILE *yyin;
extern char *yytext;
extern int yylineno;
extern int lex_errors;
int yylex(void);

/* The printable name of a token code, as used in the spec. */
static const char *token_name(int t)
{
    switch (t) {
    case FN:           return "FN";
    case LET:          return "LET";
    case IF:           return "IF";
    case ELSE:         return "ELSE";
    case WHILE:        return "WHILE";
    case FOR:          return "FOR";
    case IN:           return "IN";
    case RETURN:       return "RETURN";
    case BREAK:        return "BREAK";
    case CONTINUE:     return "CONTINUE";
    case PRINT:        return "PRINT";
    case TYPE_INT:     return "TYPE_INT";
    case TYPE_FLOAT:   return "TYPE_FLOAT";
    case TYPE_BOOL:    return "TYPE_BOOL";
    case TRUE:         return "TRUE";
    case FALSE:        return "FALSE";
    case IDENT:        return "IDENT";
    case INT_LIT:      return "INT_LIT";
    case FLOAT_LIT:    return "FLOAT_LIT";
    case STRING_LIT:   return "STRING_LIT";
    case PLUS:         return "PLUS";
    case MINUS:        return "MINUS";
    case STAR:         return "STAR";
    case SLASH:        return "SLASH";
    case PERCENT:      return "PERCENT";
    case POW:          return "POW";
    case ASSIGN:       return "ASSIGN";
    case PLUS_ASSIGN:  return "PLUS_ASSIGN";
    case MINUS_ASSIGN: return "MINUS_ASSIGN";
    case STAR_ASSIGN:  return "STAR_ASSIGN";
    case SLASH_ASSIGN: return "SLASH_ASSIGN";
    case EQ:           return "EQ";
    case NEQ:          return "NEQ";
    case LT:           return "LT";
    case LE:           return "LE";
    case GT:           return "GT";
    case GE:           return "GE";
    case AND:          return "AND";
    case OR:           return "OR";
    case NOT:          return "NOT";
    case ARROW:        return "ARROW";
    case DOTDOT:       return "DOTDOT";
    case LPAREN:       return "LPAREN";
    case RPAREN:       return "RPAREN";
    case LBRACE:       return "LBRACE";
    case RBRACE:       return "RBRACE";
    case SEMI:         return "SEMI";
    case COMMA:        return "COMMA";
    case COLON:        return "COLON";
    default:           return "UNKNOWN";
    }
}

int main(int argc, char *argv[])
{
    if (argc < 2 || argc > 3 || strcmp(argv[1], "--tokens") != 0) {
        fprintf(stderr, "usage: ankac --tokens [file.anka]\n");
        return 2;
    }

    FILE *in = NULL;
    if (argc == 3) {
        in = fopen(argv[2], "r");
        if (in == NULL) {
            perror(argv[2]);
            return 2;
        }
        yyin = in;
    }

    int t;
    while ((t = yylex()) != END) {
        printf("LINE %d: %-12s '%s'\n", yylineno, token_name(t), yytext);
    }
    printf("LINE %d: END\n", yylineno);

    if (in != NULL) {
        fclose(in);
    }
    return lex_errors > 0 ? 1 : 0;
}
