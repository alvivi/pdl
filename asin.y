
%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "header.h"

int contexto; /* Indica el contexto actual (GLOBAL o LOCAL) */
int dvar; /* Desplazamiento del segmento de variables del contexto actual
             (puede ser el global o el local) */
int dpar; /* Deplazamiento del segmento de parámetros */
int si; /* Desplazamiento del segmento de código */
int dvartmp; /* Utilizado para guardar el desplazamiento del segmento de
                variables del contexto global mientras se utiliza un
                contexto local. */

TINFO terror = {T_ERROR, 0};
TINFO tlogico = {T_LOGICO, TALLA_LOGICO};
TINFO tentero = {T_ENTERO, TALLA_ENTERO};


%}


%union {
    char *id;
    int  cte;
    int  ref; /* Referencia a tablas auxiliares (Arrays y listas de
                 parámetros) o referencia del tipo de operador */
    SIMB simb;
    TINFO tinfo; /* Informacion para la comprobación de tipos */
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

%token <cte> TK_CTE       /* cte. entera */
%token <id> TK_ID         /* id */

%type <tinfo> tipoSimple
%type <ref> listaParametrosFormales
%type <ref> parametrosFormales

%type <tinfo> expresion
%type <tinfo> expresionSufija
%type <tinfo> expresionUnaria
%type <tinfo> expresionMultiplicativa;
%type <tinfo> expresionAditiva
%type <tinfo> expresionRelacional
%type <tinfo> expresionCondicional
%type <tinfo> expresionIgualdad

%type <ref> operadorUnario

%%


programa : 
{
    dvar = si = 0;
    carga_contexto(GLOBAL);
}
  secuenciaDeclaraciones
{
    if (ver_tds) mostrar_tds();
    descarga_contexto(GLOBAL);
}
;

secuenciaDeclaraciones : declaracion
                       | secuenciaDeclaraciones declaracion
                       ;

declaracion :
  declaracionVariable
| declaracionFuncion
;

declaracionVariable :
  tipoSimple TK_ID TK_COLON
{
    if (!inserta_simbolo($2, VARIABLE, $1.tipo, dvar, contexto, -1))
        yyerror("Identificador ya definido");
    dvar += $1.talla;
}
| tipoSimple TK_ID TK_OBCK TK_CTE TK_CBCK TK_COLON
{
    int ref = inserta_info_array($1.tipo, $4);
    if (!inserta_simbolo($2, VARIABLE, T_ARRAY, dvar, contexto, ref))
        yyerror("Identificador ya definido");
    dvar += $4 * $1.talla;
}
;

tipoSimple :
  TK_INT
{
    $$.tipo = T_ENTERO;
    $$.talla = TALLA_ENTERO;
}
| TK_BOOL
{
    $$.tipo = T_LOGICO;
    $$.talla = TALLA_LOGICO;
}
| error
{
    $$.tipo = T_ERROR
}
;

declaracionFuncion : 
  cabeceraFuncion bloque
{
    if (ver_tds) mostrar_tds();
    descarga_contexto(LOCAL);
    dvar = dvartmp;
}
;

cabeceraFuncion :
  tipoSimple TK_ID
{
    carga_contexto(LOCAL);
    dvartmp = dvar;
    dvar = 0;
    dpar = TALLA_SEGENLACES;
}
  TK_OPAR parametrosFormales TK_CPAR
{
    if(!inserta_simbolo($2, FUNCION, $1.tipo, si, GLOBAL, $5))
        yyerror("Identificador ya definido");
    else
        dvar += $1.talla;
}
;

parametrosFormales :
  listaParametrosFormales
{
    $$ = $1; /* redundante */
}
|
{
    $$ = inserta_info_dominio(-1, T_VACIO);
}
;

listaParametrosFormales :
  tipoSimple TK_ID
{
    if(!inserta_simbolo($2, PARAMETRO, $1.tipo, -dpar, LOCAL, -1))
        yyerror("Identificador ya definido");
    else {
        $$ = inserta_info_dominio(-1, $1.tipo);
        dpar += $1.talla;
    }
}
| tipoSimple TK_ID TK_COMMA
{
    if(!inserta_simbolo($2, PARAMETRO, $1.tipo, -dpar, LOCAL, -1))
        yyerror("Identificador ya definido");
    else
        dpar += $1.talla;
}
  listaParametrosFormales
{
    $$ = $5;
    inserta_info_dominio($$, $1.tipo);
}
;

bloque : TK_OCLY declaracionVariableLocal listaInstrucciones TK_CCLY
       ;

declaracionVariableLocal :
| declaracionVariableLocal declaracionVariable
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

expresion :
  expresionCondicional
{
    $$ = $1; /* redundante */
}
| TK_ID operadorAsignacion expresion
{
    SIMB simb = obtener_simbolo($1);
    
    if (simb.categoria != NULO)
        switch (simb.tipo) {
            case T_LOGICO:
                switch ($3.tipo) {
                    case T_LOGICO:
                        $$ = tlogico;
                        break;
                    case T_ENTERO:
                        $$ = tlogico;
                        break;
                    default:
                        yyerror("Valor lógico asignado a un valor no válido");
                        printf("*** %d\n", $3.tipo);
                        $$ = terror;
                }
                break;
            case T_ENTERO:
                switch ($3.tipo) {
                    case T_LOGICO:
                        $$ = tentero;
                        break;
                    case T_ENTERO:
                        $$ = tentero;
                        break;
                    default:
                        yyerror("Entero asignado a un valor no válido");
                        printf("*** %d\n", $3.tipo);
                        $$ = terror;
                }            
                break;
            case T_ARRAY:
                if ($3.tipo == T_ARRAY)
                    $$ = $3;
                else
                    yyerror("Array asignado a un valor no válido");
                    $$ = terror;
                break;
            default:
                $$ = terror;
        }
    else
        $$ = terror;
}
| TK_ID TK_OBCK expresion TK_CBCK operadorAsignacion expresion
{
    SIMB simb = obtener_simbolo($1);
    
    if (simb.categoria != NULO) {
        if ($3.tipo == T_ENTERO)
            /* TODO: Conversion y reconocimiento de tipos */
            $$ = $6;
        else {
            yyerror("Asignacion con desplazamiento de array no entero");
            $$ = terror;
        }
    }
    else
        $$ = terror;
}
;

expresionCondicional :
  expresionIgualdad
{
    $$ = $1; /* redundante */
}
| expresionCondicional operadorLogico expresionIgualdad
{
    /* TODO: Conversion de tipos*/
    $$ = tlogico;
}
;

expresionIgualdad :
  expresionRelacional
{
    $$ = $1; /* redundante */
}
| expresionIgualdad operadorIgualdad expresionRelacional
{
    /* TODO: Conversion de tipos*/
    $$ = tlogico;
}
;

expresionRelacional :
  expresionAditiva
{
    $$ = $1; /* redundante */
}
| expresionRelacional operadorRelacional expresionAditiva
{
    /* TODO: Conversion de tipos*/
    $$ = tlogico;
}
;

expresionAditiva :
  expresionMultiplicativa
{
    $$ = $1; /* redundante */
}
| expresionAditiva operadorAditivo expresionMultiplicativa
{
    if ($1.tipo == T_ENTERO && $3.tipo == T_ENTERO)
        $$ = $1;
    else {
        yyerror("Operación aditiva con un argumento no entero");
        $$ = terror;
    }
}
;

expresionMultiplicativa :
  expresionUnaria
{
    $$ = $1; /* redundante */
}
| expresionMultiplicativa operadorMultiplicativo expresionUnaria
{
    if ($1.tipo == T_ENTERO && $3.tipo == T_ENTERO)
        $$ = $1;
    else {
        yyerror("Operación multiplicativa con un argumento no entero");
        $$ = terror;
    }
}
;

expresionUnaria :
  expresionSufija
{
    $$ = $1; /* redundante */
}
| operadorUnario expresionUnaria
{
    if ($1 == TK_NOT)
        if ($2.tipo == T_LOGICO)
            $$ = $2;
        else {
            yyerror("Operador lógico aplicado a un valor no booleano");
            $$ = terror;
        }
    else 
        if ($2.tipo == T_ENTERO)
            $$ = $2;
        else {
            yyerror("Op. unario aritmetico aplicado a un valor no valido");
            $$ = terror;
        }

}
| operadorIncremento TK_ID
{
    SIMB simb = obtener_simbolo($2);
    if (simb.categoria != NULO) {
        TINFO tinfo = obtener_tipo(simb);
        if (tinfo.tipo == T_ENTERO)
            $$ = tinfo;
        else {
            yyerror("Op. de incremento no válido");
            $$ = terror;
        }
    }
    else
        $$ = terror;
}
;

expresionSufija :
  TK_ID TK_OBCK expresion TK_CBCK
{
    DIM dim; TINFO tinfo;
    SIMB simb = obtener_simbolo($1);
    
    if (simb.categoria != NULO)
        if (simb.tipo == T_ARRAY) {
            if ($3.tipo == T_ENTERO) {
                dim = obtener_array(simb.ref);
                tinfo.tipo = simb.tipo = dim.tipo;
                tinfo.talla = obtener_talla(simb);
                $$ = tinfo;
            }
            else {
                yyerror("El desplazamiento del array no es un entero");
                $$ = terror;
            }
        }
        else {
            yyerror("El valor no puede ser referenciado como un array");
            $$ = terror;
        }
    else
        $$ = terror;
}
| TK_ID TK_OPAR parametrosActuales TK_CPAR
{
    $$ = tentero; /* temp */
    /* TODO */
}
| TK_ID operadorIncremento
{
    SIMB simb = obtener_simbolo($1);
    if (simb.categoria != NULO) {
        TINFO tinfo = obtener_tipo(simb);
        if (tinfo.tipo == T_ENTERO)
            $$ = tinfo;
        else {
            yyerror("Op. de incremento no válido");
            $$ = terror;
        }
    }
    else
        $$ = terror;
}
| TK_OPAR expresion TK_CPAR
{
    $$ = $2;
}
| TK_ID
{
    SIMB simb = obtener_simbolo($1);
    if (simb.categoria != NULO)
        $$ = obtener_tipo(simb);
    else
        $$ = terror;
}
| TK_CTE
{
    $$ = tentero;
}
| TK_TRUE
{
    $$ = tlogico;
}
| TK_FALSE
{
    $$ = tlogico;
}
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

operadorUnario :
  TK_PLUS
{
    $$ = TK_PLUS;
}
| TK_MINUS
{
    $$ = TK_MINUS;
}
| TK_NOT
{
    $$ = TK_NOT
}
;


%%


TINFO obtener_tipo (SIMB simb)
{
    TINFO ret;
    
    ret.tipo = simb.tipo;
    ret.talla = obtener_talla(simb);
    
    return ret;
}

int obtener_talla (SIMB simb)
{
    DIM info; SIMB tin;
    
    switch (simb.tipo) {
        case T_ENTERO:
            return TALLA_ENTERO;
        case T_LOGICO:
            return TALLA_LOGICO;
        case T_ARRAY:
            info = obtener_array(simb.ref);
            tin.tipo = info.tipo;
            return info.lsup * obtener_talla(tin);
        default:
            return 0;
    }
}
