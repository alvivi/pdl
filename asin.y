
%{

#include <stdio.h>
#include "header.h"
#include "error.h"

%}


%union {
    char *id;
    int  cte;
    SIMB simb;
}


%right TK_ASIG TK_SUMASIG TK_SUBASIG /* = += -= */

%right TK_EQUAL TK_NEQUAL /* == != */

%nonassoc TK_NOT    /* ! */
%right TK_AND TK_OR /* && || */

%right TK_LESS TK_GREAT TK_LESSEQ TK_GREATEQ /* < > <= >=*/

%right TK_PLUS TK_MINUS /* + - */

%right TK_MULT /* * */
%left  TK_DIV  /* / */

%nonassoc TK_INC TK_DEC /* ++  -- */


%token TK_BOOL  /* bool  */
%token TK_INT   /* int   */
%token TK_PRINT /* print */
%token TK_READ  /* read  */

%token TK_TRUE TK_FALSE  /* true, false */
%token TK_IF TK_ELSE     /* if, else    */
%token TK_WHILE          /* while       */
%token TK_RETURN         /* return      */

%token TK_OPAR TK_CPAR /* ( ) */
%token TK_OBCK TK_CBCK /* [ ] */
%token TK_OCLY TK_CCLY /* { } */

%token TK_COMMA TK_COLON /* , ; */

%token <ent> TK_CTE       /* cte. entera */
%token <ident> TK_ID        /* id */


%%


programa : secuenciaDeclaraciones
         ;

secuenciaDeclaraciones : declaracion
                       | secuenciaDeclaraciones declaracion
                       ;

declaracion : declaracionVariable
            | declaracionFuncion
            ;

declaracionVariable : tipoSimple TK_ID TK_COLON
                    | tipoSimple TK_ID TK_OBCK TK_CTE TK_CBCK TK_COLON
                    ;

tipoSimple : TK_INT
           | TK_BOOL
           ;

declaracionFuncion : cabeceraFuncion bloque
                   ;

cabeceraFuncion : tipoSimple TK_ID TK_OPAR parametrosFormales TK_CPAR
                ;

parametrosFormales : listaParametrosFormales 
                   |
                   ;

listaParametrosFormales : tipoSimple TK_ID
                        | tipoSimple TK_ID TK_COMMA listaParametrosFormales
                        ;

bloque : TK_OCLY declaracionVariableLocal listaInstrucciones TK_CCLY
       ;

declaracionVariableLocal : declaracionVariableLocal declaracionVariable
                         |
                         ;

listaInstrucciones : listaInstrucciones instruccion
                   |
                   ;

instruccion : TK_OCLY listaInstrucciones TK_CCLY
            | instruccionExpresion
            | instruccionEntradaSalida
            | instruccionSeleccion
            | instruccionIteracion
            | instruccionSalto
            ;

instruccionExpresion : TK_COLON
                     | expresion TK_COLON
                     ;

instruccionEntradaSalida : TK_READ TK_OPAR TK_ID TK_CPAR TK_COLON
                         | TK_PRINT TK_OPAR expresion TK_CPAR TK_COLON
                         ;

instruccionSeleccion : TK_IF TK_OPAR expresion TK_CPAR instruccion TK_ELSE instruccion
                     ;

instruccionIteracion : TK_WHILE TK_OPAR expresion TK_CPAR instruccion
                     ;

instruccionSalto : TK_RETURN expresion TK_COLON
                 ;

expresion : expresionCondicional
          | TK_ID operadorAsignacion expresion
          | TK_ID TK_OBCK expresion TK_CBCK operadorAsignacion expresion
          ;

expresionCondicional : expresionIgualdad
                     | expresionCondicional operadorLogico expresionIgualdad
                     ;

expresionIgualdad : expresionRelacional
                  | expresionIgualdad operadorIgualdad expresionRelacional
                  ;

expresionRelacional : expresionAditiva
                    | expresionRelacional operadorRelacional expresionAditiva
                    ;

expresionAditiva : expresionMultiplicativa
                 | expresionAditiva operadorAditivo expresionMultiplicativa
                 ;

expresionMultiplicativa : expresionUnaria
                        | expresionMultiplicativa operadorMultiplicativo expresionUnaria
                        ;

expresionUnaria : expresionSufija
                | operadorUnario expresionUnaria
                | operadorIncremento TK_ID
                ;

expresionSufija : TK_ID TK_OBCK expresion TK_CBCK
                | TK_ID TK_OPAR parametrosActuales TK_CPAR
                | TK_ID operadorIncremento
                | TK_OPAR expresion TK_CPAR
                | TK_ID | TK_CTE | TK_TRUE | TK_FALSE
                ;

parametrosActuales : listaParametrosActuales
                   |
                   ;

listaParametrosActuales : expresion
                        | expresion TK_COMMA listaParametrosActuales
                        ;

operadorAsignacion : TK_ASIG
                   | TK_SUMASIG
                   | TK_SUBASIG
                   ;

operadorLogico : TK_AND
               | TK_OR 
               ;

operadorIgualdad : TK_EQUAL
                 | TK_NEQUAL
                 ;

operadorRelacional : TK_LESS
                   | TK_GREAT
                   | TK_LESSEQ
                   | TK_GREATEQ
                   ;

operadorAditivo : TK_PLUS
                | TK_MINUS
                ;

operadorMultiplicativo : TK_MULT
                       | TK_DIV
                       ;

operadorIncremento : TK_INC
                   | TK_DEC
                   ;

operadorUnario : TK_PLUS
               | TK_MINUS
               | TK_NOT
               ;


%%
