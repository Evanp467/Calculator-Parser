%{
#include "parser.tab.h"  // Include Bison-generated header file
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

%}

DIGIT       [0-9]
OCTAL_DIGIT [0-7]
HEX_DIGIT   [0-9a-fA-F]
EXPONENT    [eE][-+]?{DIGIT}+

%%

"0x"{HEX_DIGIT}+               { yylval.ival = strtol(yytext, NULL, 16); return INT; } /* Hexadecimal */
"0"{OCTAL_DIGIT}+              { yylval.ival = strtol(yytext, NULL, 8); return INT; } /* Octal */
{DIGIT}+                       { yylval.ival = strtol(yytext, NULL, 10); return INT; } /* Decimal */

{DIGIT}*"."{DIGIT}+({EXPONENT})? { yylval.fval = strtod(yytext, NULL); return FLOAT; } /* Floating Point, optional leading 0s */
{DIGIT}+"."{DIGIT}*({EXPONENT})? { yylval.fval = strtod(yytext, NULL); return FLOAT; } /* Floating Point, mandatory leading 0s */

[a-zA-Z_][a-zA-Z_0-9]*         { yylval.sval = strdup(yytext); return ID; } /* Identifier */

"+"                             { return ADD; } /* Add */
"-"                             { return SUBTRACT; } /* Subtract */
"*"                             { return MULTIPLY; } /* Multiply */
"/"                             { return DIVIDE; } /* Divide */
"%"                             { return MODULO; } /* Modulo */
"="                             { return EQUAL; } /* Equal */

"("                             { return '('; } /* Open Parenthesis */
")"                             { return ')'; } /* Close Parenthesis */

[ \t\n]+                         ; /* Ignore whitespace */

.                               { return UNKNOWN; } /* Unknown Character */

%%

int yywrap() {
    return 1;
}
