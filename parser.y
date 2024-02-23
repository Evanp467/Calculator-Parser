%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

extern int yylex();
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

#define MAX_VARS 100
struct var {
    char* name;
    float value;
} vars[MAX_VARS];
int var_count = 0;

int find_var_index(const char* var_name);
void set_var_value(const char* var_name, float value);
float get_var_value(const char* var_name);

%}

%union {
    int ival;
    float fval;
    char* sval;
}

%token <ival> INT
%token <fval> FLOAT
%token ADD SUBTRACT MULTIPLY DIVIDE MODULO EQUAL UNKNOWN
%token <sval> ID
%type <fval> expression term factor

%left ADD SUBTRACT
%left MULTIPLY DIVIDE MODULO
%right EQUAL

%%

program:
    | program statement
    ;

statement:
      ID EQUAL expression { set_var_value($1, $3); printf("%s = %.1f\n", $1, $3); }
    | expression          { printf("Result = %.1f\n", $1); }
    | error               { yyerror("INVALID SYNTAX"); }
    ;

expression:
      expression ADD term         { $$ = $1 + $3; }
    | expression SUBTRACT term    { $$ = $1 - $3; }
    | term
    ;

term:
      term MULTIPLY factor        { $$ = $1 * $3; }
    | term DIVIDE factor          { $$ = $1 / $3; }
    | term MODULO factor          { $$ = fmod($1, $3); }
    | factor
    ;

factor:
      INT                         { $$ = $1; }
    | FLOAT                       { $$ = $1; }
    | ID                          { $$ = get_var_value($1); }
    | '(' expression ')'          { $$ = $2; }
    ;

%%

int main() {
    printf("Enter your expression:\n");
    yyparse();
    return 0;
}

int find_var_index(const char* var_name) {
    for (int i = 0; i < var_count; i++) {
        if (strcmp(vars[i].name, var_name) == 0)
            return i;
    }
    return -1;
}

void set_var_value(const char* var_name, float value) {
    int index = find_var_index(var_name);
    if (index == -1) {
        // Variable not found, create new
        index = var_count++;
        vars[index].name = strdup(var_name);
    }
    vars[index].value = value;
}

float get_var_value(const char* var_name) {
    int index = find_var_index(var_name);
    if (index == -1) {
        yyerror("Variable not found");
        return 0.0;
    }
    return vars[index].value;
}