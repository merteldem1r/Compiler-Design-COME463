/* tokens.h: token codes for the Anka lexer (spec: docs/LANGUAGE.md §2.4).
 *
 * Codes start at 258, like Bison's: 0-255 are left for single characters
 * and 0 means "end of input". In Project 2 Bison generates this list for us
 * (parser.tab.h) and this file goes away.
 */
#ifndef TOKENS_H
#define TOKENS_H

typedef enum {
    END = 0,            /* end of input */

    /* keywords (16) */
    FN = 258, LET,
    IF, ELSE, WHILE, FOR, IN, RETURN, BREAK, CONTINUE,
    PRINT,
    TYPE_INT, TYPE_FLOAT, TYPE_BOOL,
    TRUE, FALSE,

    /* identifiers and literals */
    IDENT, INT_LIT, FLOAT_LIT, STRING_LIT,

    /* operators (22) */
    PLUS, MINUS, STAR, SLASH, PERCENT, POW,
    ASSIGN, PLUS_ASSIGN, MINUS_ASSIGN, STAR_ASSIGN, SLASH_ASSIGN,
    EQ, NEQ, LT, LE, GT, GE,
    AND, OR, NOT,
    ARROW, DOTDOT,

    /* punctuation (7) */
    LPAREN, RPAREN, LBRACE, RBRACE, SEMI, COMMA, COLON
} token_type;

#endif
