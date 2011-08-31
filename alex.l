
/*
 * Domínguez Cartagena, Luis (luidoca@fiv.upv.es)
 * Lanza Duarte, Gustavo (guslandu@fiv.upv.es)
 * Vilanova Vidal, Álvaro (alvivi@fiv.upv.es)
 */

%{

#include <stdio.h>

#include "header.h"
#include "asin.h"

#define RETURN_TOKEN(x) { if (verbosidad) ECHO; return (x); }

void make_id();
void make_int();
void make_real();

%}


%option yylineno

ALPHA [a-zA-Z]

NLINE ("\n"|"\r\n"|"\n\r"|"\r")
DIGIT [0-9]

ID    {ALPHA}({ALPHA}|{DIGIT})*
CONST {DIGIT}+
REAL  {DIGIT}*"."{DIGIT}+


%%


{NLINE}       { if (verbosidad) { ECHO; printf("%3d-", yylineno); } }
"//".*{NLINE} /* Comentarios */


"bool"   RETURN_TOKEN (TK_BOOL);
"int"    RETURN_TOKEN (TK_INT);
"print"  RETURN_TOKEN (TK_PRINT);
"read"   RETURN_TOKEN (TK_READ);
         
"true"   RETURN_TOKEN (TK_TRUE);
"false"  RETURN_TOKEN (TK_FALSE);
"if"     RETURN_TOKEN (TK_IF); 
"else"   RETURN_TOKEN (TK_ELSE);
"while"  RETURN_TOKEN (TK_WHILE);
"return" RETURN_TOKEN (TK_RETURN);
"!"      RETURN_TOKEN (TK_NOT);

"&&"     RETURN_TOKEN (TK_AND);
"||"     RETURN_TOKEN (TK_OR);

"=="     RETURN_TOKEN (TK_EQUAL);
"!="     RETURN_TOKEN (TK_NEQUAL);

"="      RETURN_TOKEN (TK_ASIG);
";"      RETURN_TOKEN (TK_COLON);
"["      RETURN_TOKEN (TK_OBCK);
"]"      RETURN_TOKEN (TK_CBCK);
"{"      RETURN_TOKEN (TK_OCLY);
"}"      RETURN_TOKEN (TK_CCLY);
"("      RETURN_TOKEN (TK_OPAR);
")"      RETURN_TOKEN (TK_CPAR);

"+="     RETURN_TOKEN (TK_SUMASIG);
"-="     RETURN_TOKEN (TK_SUBASIG);

"<="     RETURN_TOKEN (TK_LESSEQ);
">="     RETURN_TOKEN (TK_GREATEQ);
"<"      RETURN_TOKEN (TK_LESS);
">"      RETURN_TOKEN (TK_GREAT);

"++"     RETURN_TOKEN (TK_INC);
"--"     RETURN_TOKEN (TK_DEC);

"+"      RETURN_TOKEN (TK_PLUS);
"-"      RETURN_TOKEN (TK_MINUS);
"*"      RETURN_TOKEN (TK_MULT);
"/"      RETURN_TOKEN (TK_DIV);

","	     RETURN_TOKEN (TK_COMMA);
";"	     RETURN_TOKEN (TK_COLON);

{REAL}  { make_real(); RETURN_TOKEN (TK_CTE) }
{CONST} { make_int();  RETURN_TOKEN (TK_CTE) }
{ID}    { make_id();   RETURN_TOKEN (TK_ID)  }

[[:space:]] /* Ignoramos los espacios */

.       { yyerror("Caracter no reconocido"); }


%%


void make_id()
{
    char *t;
    if (yyleng > 14) {
        printf("Linea %d. Aviso: identificador \"%s\" truncado\n", yylineno,
               yytext);
        yyleng = 14;
    }
    
    t = (char *) malloc(yyleng + 1);
    strncpy(t, yytext, yyleng);
    t[yyleng] = 0;
    yylval.id = t;
}


void make_int()
{
    yylval.cte = atoi(yytext);
}


void make_real()
{
    char *t;
    printf("Linea %d. Aviso: constante real truncada a entera\n", yylineno);
    yyleng = strcspn(yytext, ".");
    t = (char *) malloc(yyleng + 1);
    strncpy(t, yytext, yyleng);
    t[yyleng] = 0;
    yylval.cte = atoi(yytext);
}
