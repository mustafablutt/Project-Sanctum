%{

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "Sanctum.h"
#include "y.tab.h"

    nodeType *islt(int process, int opsNum, ...);
    nodeType *ID(int i);
    nodeType *constant(int value);
    void Node(nodeType *point);
    void yyerror(char *s);
    int EXP(nodeType *point);
    int yylex(void);int sym[26];                    
%}

%union {int iVal;char sIndex;nodeType *nPointer;};

%token <iVal> INTEGER
%token <sIndex> VARIABLE
%token WHILE IF PRINT FOR
%nonassoc IFX
%nonassoc ELSE

%left BIGEQUAL SMALLEQUAL EQUAL NOTEQUAL '>' '<' '+' '-' '*' '/'
%nonassoc UMINUS

%type <nPointer> stmt expr stmt_list

%%

program:
        function                { exit(0); }
        ;
function:
          function stmt         { EXP($2); Node($2); }
        |
        ;
stmt:
          ';'                            { $$ = islt(';', 2, NULL, NULL); } | expr ';'  { $$ = $1; }
        | PRINT expr ';'                 { $$ = islt(PRINT, 1, $2); } | VARIABLE '=' expr ';'   { $$ = islt('=', 2, ID($1), $3); } | WHILE '(' expr ')' stmt  { $$ = islt(WHILE, 2, $3, $5); } 
        | IF '(' expr ')' stmt %prec IFX { $$ = islt(IF, 2, $3, $5); } | IF '(' expr ')' stmt ELSE stmt { $$ = islt(IF, 3, $3, $5, $7); } | '{' stmt_list '}'              { $$ = $2; }
        ;
stmt_list:
          stmt                  { $$ = $1; }| stmt_list stmt        { $$ = islt(';', 2, $1, $2); }
        ;
expr:
          INTEGER               { $$ = constant($1); }| VARIABLE { $$ = ID($1); }
        | '-' expr %prec UMINUS { $$ = islt(UMINUS, 1, $2); }
        | expr '+' expr         { $$ = islt('+', 2, $1, $3); } | expr '-' expr { $$ = islt('-', 2, $1, $3); }
        | expr '*' expr         { $$ = islt('*', 2, $1, $3); } | expr '/' expr { $$ = islt('/', 2, $1, $3); }
        | expr '%' expr         { $$ = islt('%', 2, $1, $3); } 
        | expr '<' expr         { $$ = islt('<', 2, $1, $3); } | expr '>' expr { $$ = islt('>', 2, $1, $3); }
        | expr BIGEQUAL expr    { $$ = islt(BIGEQUAL, 2, $1, $3); } | expr SMALLEQUAL expr { $$ = islt(SMALLEQUAL, 2, $1, $3); }
        | expr NOTEQUAL expr    { $$ = islt(NOTEQUAL, 2, $1, $3); } | expr EQUAL expr { $$ = islt(EQUAL, 2, $1, $3); }
        | '(' expr ')'          { $$ = $2; }
        ;

%%

nodeType *constant(int value) {nodeType *point;
    if ((point = malloc(sizeof(nodeType))) == NULL)yyerror("out of memory");
    point->tip = typeConstant;point->constant.value = value;
    return point;}

nodeType *ID(int i) {nodeType *point;
    if ((point = malloc(sizeof(nodeType))) == NULL) yyerror("out of memory");
    point->tip = typeID;point->ID.i = i;
    return point;}

nodeType *islt(int process, int opsNum, ...) {va_list ap;nodeType *point;int i;
    if ((point = malloc(sizeof(nodeType) + (opsNum-1) * sizeof(nodeType *))) == NULL) yyerror("out of memory");
    point->tip = tipIslt;point->islt.process = process;point->islt.opsNum = opsNum;
    va_start(ap, opsNum);
    for (i = 0; i < opsNum; i++)point->islt.islenen[i] = va_arg(ap, nodeType*);va_end(ap);return point;}

void Node(nodeType *point) { int i;if (!point) return;
    if (point->tip == tipIslt) {for (i = 0; i < point->islt.opsNum; i++)Node(point->islt.islenen[i]);}
    free (point);}

void yyerror(char *s) {fprintf(stdout, "%s\n", s);}

int main(void) {yyparse();return 0;}

int EXP(nodeType *point) {if (!point) return 0;
    switch(point->tip) {case typeConstant:return point->constant.value;case typeID:return sym[point->ID.i];
    case tipIslt:
        switch(point->islt.process) {
        case WHILE: while(EXP(point->islt.islenen[0])) EXP(point->islt.islenen[1]); return 0;

        case IF:    if (EXP(point->islt.islenen[0])) EXP(point->islt.islenen[1]);else if (point->islt.opsNum > 2) EXP(point->islt.islenen[2]);return 0;

        case PRINT: printf("%d\n", EXP(point->islt.islenen[0])); return 0;

        case ';':  EXP(point->islt.islenen[0]); return EXP(point->islt.islenen[1]);case '=':  return sym[point->islt.islenen[0]->ID.i] = EXP(point->islt.islenen[1]);

        case UMINUS:return -EXP(point->islt.islenen[0]);
        case '+':   return EXP(point->islt.islenen[0]) + EXP(point->islt.islenen[1]);
        case '-': return EXP(point->islt.islenen[0]) - EXP(point->islt.islenen[1]);
        case '*':   return EXP(point->islt.islenen[0]) * EXP(point->islt.islenen[1]);
        case '/': return EXP(point->islt.islenen[0]) / EXP(point->islt.islenen[1]);
        case '<':   return EXP(point->islt.islenen[0]) < EXP(point->islt.islenen[1]);
        case '>': return EXP(point->islt.islenen[0]) > EXP(point->islt.islenen[1]);
        case '%': return EXP(point->islt.islenen[0]) - (EXP(point->islt.islenen[0]) / EXP(point->islt.islenen[1])) * EXP(point->islt.islenen[1]) ;

        case BIGEQUAL:  return EXP(point->islt.islenen[0]) >= EXP(point->islt.islenen[1]);
        case SMALLEQUAL: return EXP(point->islt.islenen[0]) <= EXP(point->islt.islenen[1]);
        case NOTEQUAL:  return EXP(point->islt.islenen[0]) != EXP(point->islt.islenen[1]);
        case EQUAL:   return EXP(point->islt.islenen[0]) == EXP(point->islt.islenen[1]);
        }
    }
    return 0;
}