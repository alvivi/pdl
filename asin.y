
/*
 * Domínguez Cartagena, Luis (luidoca@fiv.upv.es)
 * Lanza Duarte, Gustavo (guslandu@fiv.upv.es)
 * Vilanova Vidal, Álvaro (alvivi@fiv.upv.es)
 */

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
int fail; /* Se utiliza en algunas definiciones para comprobar errores */
int finfunc = -1; /* LANS que apunta al fin de la función actual */

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
    TPROG tprog;
    TINSIF tinsif;
    TINSWHILE tinswhile;
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
%type <ref> listaParametrosActuales
%type <ref> parametrosActuales

%type <tinfo> expresion
%type <tinfo> expresionSufija
%type <tinfo> expresionUnaria
%type <tinfo> expresionMultiplicativa;
%type <tinfo> expresionAditiva
%type <tinfo> expresionRelacional
%type <tinfo> expresionCondicional
%type <tinfo> expresionIgualdad

%type <ref> operadorAsignacion
%type <ref> operadorLogico
%type <ref> operadorIgualdad
%type <ref> operadorRelacional
%type <ref> operadorAditivo
%type <ref> operadorMultiplicativo
%type <ref> operadorUnario
%type <ref> operadorIncremento


%%


programa : 
{
    dvar = si = 0;
    carga_contexto(GLOBAL);
    
    /* Reservamos espacio para las variables globales */
    $<tprog>$.lans_globales = crea_lans(si);
    emite(INCTOP, cr_arg_nulo(), cr_arg_nulo(), cr_arg_entero(-1));
    
    /* Saltamos a la función main */
    $<tprog>$.lans_main = crea_lans(si);
    emite(GOTOS, cr_arg_nulo(), cr_arg_nulo(), cr_arg_entero(-1));
}
  secuenciaDeclaraciones
{
    /* Completamos la instrucción de salto a main */
    SIMB simb = obtener_simbolo("main");
    if (simb.categoria == FUNCION)
        completa_lans($<tprog>1.lans_main, cr_arg_etiqueta(simb.desp));
    else
        yyerror("Función main no declarada");
    
    /* Completamos la instrucción de reseva de especio para las v. globales */
    completa_lans($<tprog>1.lans_globales, cr_arg_entero(dvar));
    
    if (ver_tds) mostrar_tds();
    descarga_contexto(GLOBAL);
}
;

secuenciaDeclaraciones :
  declaracion
| secuenciaDeclaraciones declaracion
;

declaracion :
  declaracionVariable
| declaracionFuncion
;

declaracionVariable :
  tipoSimple TK_ID TK_COLON
{
    if (inserta_simbolo($2, VARIABLE, $1.tipo, dvar, contexto, -1))
        dvar += $1.talla;
    else
        yyerror("Identificador ya definido");
}
| tipoSimple TK_ID TK_OBCK TK_CTE TK_CBCK TK_COLON
{
    int ref;
    
    if ($4 <= 0)
        yyerror("El tamaño de un array debe ser mayor o igual que 1");
    else {
        ref = inserta_info_array($1.tipo, $4);
        if (inserta_simbolo($2, VARIABLE, T_ARRAY, dvar, contexto, ref))
            dvar += $4 * $1.talla;
        else
            yyerror("Identificador ya definido");
    }
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
  cabeceraFuncion
{
    /* Apilamos el frame pointer */
    emite(PUSHFP, cr_arg_nulo(), cr_arg_nulo(), cr_arg_nulo());
    /* Actualizamos el frame pointer a la posición actual de la pila */
    emite(FPTOP, cr_arg_nulo(), cr_arg_nulo(), cr_arg_nulo());
    /* Reservamos espacio para las variables locales y temporales*/
    $<ref>$ = crea_lans(si);
    emite(INCTOP, cr_arg_nulo(), cr_arg_nulo(), cr_arg_entero(-1));
}
  bloque
{
    /* Completamos la instrucción de reseva de memoria local */
    completa_lans($<ref>2, cr_arg_entero(dvar));
    
    completa_lans(finfunc, cr_arg_etiqueta(si));
    finfunc = -1;
    
    /* Actualizamos el tope de la pila al frame pointer  */
    emite(TOPFP, cr_arg_nulo(), cr_arg_nulo(), cr_arg_nulo());
    /* Actualizamos la pila */
    emite(FPPOP, cr_arg_nulo(), cr_arg_nulo(), cr_arg_nulo());
    
    /* Devolvemos el flujo de ejucución */
    if (es_main())
        emite(FIN, cr_arg_nulo(), cr_arg_nulo (), cr_arg_nulo ());
    else
        emite(RET, cr_arg_nulo(), cr_arg_nulo (), cr_arg_nulo ());
        
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
    fail = 0;
}
  TK_OPAR parametrosFormales TK_CPAR
{
    /* Insertamos la función en la TDS */
    if(!inserta_simbolo($2, FUNCION, $1.tipo, si, GLOBAL, $5)) {
        yyerror("Identificador ya definido");
        fail = 1;
    }
}
;

parametrosFormales :
{
    if (!fail)
        $$ = inserta_info_dominio(-1, T_VACIO);
}
| listaParametrosFormales
{
    $$ = $1; /* redundante */
}
;

listaParametrosFormales :
  tipoSimple TK_ID
{
    dpar += $1.talla;
    if(!inserta_simbolo($2, PARAMETRO, $1.tipo, -dpar, LOCAL, -1)) {
        yyerror("Parámetro ya definido");
        fail = 1;
    }
    else if (!fail) {
        $$ = inserta_info_dominio(-1, $1.tipo);
        
    }
}
| tipoSimple TK_ID TK_COMMA 
{
    dpar += $1.talla;
    if(!inserta_simbolo($2, PARAMETRO, $1.tipo, -dpar, LOCAL, -1)) {
        yyerror("Parámetro ya definido");
        fail = 1;
    }
}
  listaParametrosFormales
{    
    if (!fail) {        
        $$ = $5;
        inserta_info_dominio($$, $1.tipo);
    }
}
;

bloque :
  TK_OCLY declaracionVariableLocal listaInstrucciones TK_CCLY
;

declaracionVariableLocal :
declaracionVariableLocal declaracionVariable
|
;

listaInstrucciones :
  listaInstrucciones instruccion
|
;

instruccion :
  TK_OCLY listaInstrucciones TK_CCLY
| instruccionExpresion
| instruccionEntradaSalida
| instruccionSeleccion
| instruccionIteracion
| instruccionSalto
;

instruccionExpresion :
  TK_COLON
| expresion TK_COLON
;

instruccionEntradaSalida :
  TK_READ TK_OPAR TK_ID TK_CPAR TK_COLON
{
    SIMB simb = obtener_simbolo($3);
    if (simb.categoria != NULO) {
        if (simb.tipo == T_ENTERO) {
            emite(EREAD, cr_arg_nulo(), cr_arg_nulo(),
                  cr_arg_posicion(simb.nivel, simb.desp));
        }
        else
            yyerror("La instrucción read solo acepta parámetros de tipo "
                    "entero");
    }
}
| TK_PRINT TK_OPAR expresion TK_CPAR TK_COLON
{
    switch ($3.tipo) {
        case T_LOGICO:
        case T_ENTERO:
            emite(EWRITE, cr_arg_nulo(), cr_arg_nulo(), $3.pos);
            break;
        default:
            yyerror("La instrucción print solo acepta parámetros de tipos "
                    "simples");
    }
}
;

instruccionSeleccion :
  TK_IF TK_OPAR expresion TK_CPAR
{
    if ($3.tipo == T_LOGICO) {
        $<tinsif>$.lans_falso = crea_lans(si);
        emite(EIGUAL, $3.pos, cr_arg_entero(0), cr_arg_entero(-1));
    }
    else
        yyerror("La expresión condicional de la instrucción if no es "
                "del tipo lógico");
}
  instruccion TK_ELSE
{
    $<tinsif>5.lans_fin = crea_lans(si);
    emite(GOTOS, cr_arg_nulo(), cr_arg_nulo(), cr_arg_entero(-1));
    completa_lans($<tinsif>5.lans_falso, cr_arg_etiqueta(si));
}
  instruccion
{
    completa_lans($<tinsif>5.lans_fin, cr_arg_etiqueta(si));
}
;

instruccionIteracion :
  TK_WHILE 
{
    $<tinswhile>$.cond = cr_arg_etiqueta(si);
}
  TK_OPAR expresion TK_CPAR
{
    if ($4.tipo == T_LOGICO) {
        $<tinswhile>2.lans_fin = crea_lans(si);
        emite(EIGUAL, $4.pos, cr_arg_entero(0), cr_arg_entero(-1));
    }
    else
        yyerror("La expresión condicional de la instrucción while no es "
                "del tipo lógico");
}
  instruccion
{
    emite(GOTOS, cr_arg_nulo(), cr_arg_nulo(), $<tinswhile>2.cond);
    completa_lans($<tinswhile>2.lans_fin, cr_arg_etiqueta(si));
}
;

instruccionSalto :
  TK_RETURN expresion TK_COLON
{
    int lans;
    INF inf = obtener_info_funcion(-1); /* Info de la función actual */
    if (inf.tipo == $2.tipo) {
        emite(EASIG, $2.pos, cr_arg_nulo(),
            cr_arg_posicion(contexto, -(dpar + 1)));
        lans = crea_lans(si);
        emite(GOTOS, cr_arg_nulo(), cr_arg_nulo(), cr_arg_entero(-1));
        finfunc = fusiona_lans(finfunc, lans);        
    } else if ($2.tipo != T_ERROR) 
        yyerror("El tipo del valor devuelto no coincide con el de "
                "la función");
}
;

expresion :
  expresionCondicional
{
    $$ = $1; /* redundante */
}
| TK_ID operadorAsignacion expresion
{
    SIMB simb = obtener_simbolo($1);
    TIPO_ARG pos = $3.pos;
    if (simb.categoria == VARIABLE || simb.categoria == PARAMETRO) {
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
                        if ($3.tipo != T_ERROR)
                        yyerror("Variable de tipo lógico asignado a un valor "
                                "de tipo no lógico");
                        $$ = terror;
                }   
                break;
            case T_ENTERO:
                switch ($3.tipo) {
                    case T_LOGICO:
                        $$ = tentero;
                        pos = emite_entero_a_bool($3.pos);
                        break;
                    case T_ENTERO:
                        $$ = tentero;
                        break;
                    default:
                        if ($3.tipo != T_ERROR)
                            yyerror("Asignación no válida");
                        $$ = terror;
                }            
                break;
            default:
                if (simb.tipo != T_ERROR && $3.tipo != T_ERROR)
                    yyerror("Asignación no válida");
                $$ = terror;
        }
        
        $$.pos = cr_arg_posicion(simb.nivel, simb.desp);
        
        switch ($2) {            
            case TK_ASIG:
            default:             
                emite(EASIG, pos, cr_arg_nulo(), $$.pos);
                break;
            case TK_SUMASIG:
                emite(ESUM, $$.pos, pos, $$.pos);
                break;
            case TK_SUBASIG:
                emite(EDIF, $$.pos, pos, $$.pos);
                break;
        }
    }
    else {
        if (simb.categoria == FUNCION)
            yyerror("Asignación no válida");
        $$ = terror;
    }
        
}
| TK_ID TK_OBCK expresion TK_CBCK operadorAsignacion expresion
{
    DIM dim;
    SIMB simb = obtener_simbolo($1);
    TIPO_ARG base, tmp;
    base = cr_arg_posicion(simb.nivel, simb.desp);
    
    if (simb.categoria != NULO)
        if (simb.tipo == T_ARRAY) {
            if ($3.tipo == T_ENTERO) {
                dim = obtener_array (simb.ref);
                switch (dim.tipo) {
                    case T_ENTERO:
                        $$ = tentero;
                        $$.pos = $6.pos;               
                        switch ($5) {            
                            case TK_ASIG:
                            default:             
                                emite(EVA, base, $3.pos, $6.pos);
                                break;
                            case TK_SUMASIG:
                                tmp = cr_arg_posicion(contexto,crea_var_temp());
                                emite(EAV, base, $3.pos, tmp);                                
                                emite(ESUM, tmp, $6.pos, tmp);
                                emite(EVA, base, $3.pos, tmp);
                                break;
                            case TK_SUBASIG:
                                tmp = cr_arg_posicion(contexto,crea_var_temp());
                                emite(EAV, base, $3.pos, tmp);                                
                                emite(EDIF, tmp, $6.pos, tmp);
                                emite(EVA, base, $3.pos, tmp);                            
                                break;
                        }                     
                        break;
                        
                    case T_LOGICO:
                        if ($5 == TK_ASIG) {
                            $$ = tlogico;
                            $$.pos = ($6.tipo == T_ENTERO) ?
                                     emite_entero_a_bool($6.pos) : $6.pos;
                            emite(EVA, base, $3.pos, $6.pos);
                            break;                       
                        }
                        else {
                            $$ = terror;
                            yyerror("Operación escalar sobre un vector "
                                    "booleano");
                        }                        
                        break;
                    default:
                        $$ = terror;
                }
            }
            else {
                yyerror("El indice del array no es del tipo entero");
                $$ = terror;
            }
        }
        else {
            yyerror("La variable no es un array");
            $$ = terror;
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
    TIPO_ARG lhs, rhs, res;
    
    if (($1.tipo == T_LOGICO || $1.tipo == T_ENTERO) &&
       ($3.tipo == T_LOGICO || $3.tipo == T_ENTERO)) {
        $$ = tlogico;
        lhs = ($1.tipo == T_ENTERO) ? emite_entero_a_bool($1.pos) : $1.pos;
        rhs = ($3.tipo == T_ENTERO) ? emite_entero_a_bool($3.pos) : $3.pos;
        res = cr_arg_posicion(contexto, crea_var_temp());
        emite($2, lhs, rhs, res);
        emite(ETOB, res, cr_arg_nulo(), res);
        $$.pos = res;    
    }
    else
        $$ = terror;
}
;

expresionIgualdad :
  expresionRelacional
{
    $$ = $1; /* redundante */
}
| expresionIgualdad operadorIgualdad expresionRelacional
{
    TIPO_ARG lhs, rhs;
    
    /* Si alguno de los dos valores a comparar son del tipo lógico, hay que
       que realizar una conversión de tipo entero a bool en los valores
       enteros */
    if ($1.tipo == T_LOGICO || $3.tipo == T_LOGICO) {
        lhs = ($1.tipo == T_ENTERO) ? emite_entero_a_bool($1.pos) : $1.pos;
        rhs = ($3.tipo == T_ENTERO) ? emite_entero_a_bool($3.pos) : $3.pos;        
    }
    else {
        lhs = $1.pos;
        rhs = $3.pos;
    }
    
    $$ = tlogico;
    $$.pos = cr_arg_posicion(contexto, crea_var_temp());
    emite(EASIG, cr_arg_entero(1), cr_arg_nulo(), $$.pos);
    emite($2, $1.pos, $3.pos, cr_arg_etiqueta(si + 2));
    emite(EASIG, cr_arg_entero(0), cr_arg_nulo(), $$.pos);
}
;

expresionRelacional :
  expresionAditiva
{
    $$ = $1; /* redundante */
}
| expresionRelacional operadorRelacional expresionAditiva
{
    $$ = tlogico;
    $$.pos = cr_arg_posicion(contexto, crea_var_temp());
    emite(EASIG, cr_arg_entero(1), cr_arg_nulo(), $$.pos);
    emite($2, $1.pos, $3.pos, cr_arg_etiqueta(si + 2));
    emite(EASIG, cr_arg_entero(0), cr_arg_nulo(), $$.pos);
}
;

expresionAditiva :
  expresionMultiplicativa
{
    $$ = $1; /* redundante */
}
| expresionAditiva operadorAditivo expresionMultiplicativa
{
    if ($1.tipo == T_ENTERO && $3.tipo == T_ENTERO) {
        $$ = tentero;
        $$.pos = cr_arg_posicion(contexto, crea_var_temp());
        emite($2, $1.pos, $3.pos, $$.pos);
    }
    else {
        if ($1.tipo != T_ERROR && $3.tipo != T_ERROR)
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
    if ($1.tipo == T_ENTERO && $3.tipo == T_ENTERO) {
        $$ = tentero;
        $$.pos = cr_arg_posicion(contexto, crea_var_temp());
        emite($2, $1.pos, $3.pos, $$.pos);
    }
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
        if ($2.tipo == T_LOGICO) {
            $$ = $2;
            $$.pos = cr_arg_posicion(contexto, crea_var_temp());
            emite(EASIG, cr_arg_entero(1), cr_arg_nulo(), $$.pos);
            emite(EIGUAL, $2.pos, cr_arg_entero(0), cr_arg_etiqueta(si + 2));
            emite(EASIG, cr_arg_entero(0), cr_arg_nulo(), $$.pos);
        }
        else {
            yyerror("Operador lógico aplicado a un valor no booleano");
            $$ = terror;
        }
    else 
        if ($2.tipo == T_ENTERO) {
            $$ = $2;
            $$.pos = cr_arg_posicion(contexto, crea_var_temp());
            emite(EMULT, cr_arg_entero(-1), $2.pos, $$.pos);            
        }
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
        if (tinfo.tipo == T_ENTERO) {
            $$ = tinfo;
            $$.pos = cr_arg_posicion(simb.nivel, simb.desp);
            emite($1, $$.pos, cr_arg_entero(1), $$.pos);
        }
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
                $$.pos = cr_arg_posicion(contexto, crea_var_temp());
                emite(EAV, cr_arg_posicion(simb.nivel, simb.desp),
                      $3.pos, $$.pos);
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
| 
  TK_ID 
{
    emite(EPUSH, cr_arg_nulo(), cr_arg_nulo(), cr_arg_entero(0));
}
  TK_OPAR parametrosActuales TK_CPAR
{
    int cmp;
    SIMB simb = obtener_simbolo($1);
    
    if (simb.categoria != NULO)
        if (simb.categoria == FUNCION) {
            cmp = compara_dominio(simb.ref, $4);
            if (cmp) {
                $$ = obtener_tipo(simb);
                $$.pos = cr_arg_posicion(contexto, crea_var_temp());
                emite(CALL, cr_arg_nulo(), cr_arg_nulo(),
                      cr_arg_etiqueta(simb.desp));
                emite(DECTOP, cr_arg_nulo(), cr_arg_nulo(),
                      cr_arg_entero(obtener_info_funcion(simb.ref).tparam));
                emite(EPOP, cr_arg_nulo(), cr_arg_nulo(), $$.pos);                 
            }
            else
                $$ = terror;
        }
        else {
            yyerror("Llamada a función con un identificador no válido");
            $$ = terror;            
        }
    else
        $$ = terror;
}
| TK_ID operadorIncremento
{
    SIMB simb = obtener_simbolo($1);
    TIPO_ARG tmp;
    
    if (simb.categoria != NULO) {
        TINFO tinfo = obtener_tipo(simb);
        if (tinfo.tipo == T_ENTERO) {
            $$ = tinfo;
            tmp = cr_arg_posicion(simb.nivel, simb.desp);
            $$.pos = cr_arg_posicion(contexto, crea_var_temp());
            emite(EASIG, tmp, cr_arg_nulo(), $$.pos);
            emite($2, tmp, cr_arg_entero(1), tmp);
        }
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
        if (simb.categoria != FUNCION)
            $$ = obtener_tipo(simb);            
        else {
            yyerror("Referencia a función no válida");
            $$ = terror;
        }
    else
        $$ = terror;
}
| TK_CTE
{
    $$ = tentero;
    $$.pos = cr_arg_entero(yylval.cte);
}
| TK_TRUE
{
    $$ = tlogico;
    $$.pos = cr_arg_entero(1);
}
| TK_FALSE
{
    $$ = tlogico;
    $$.pos = cr_arg_entero(0);
}
;

parametrosActuales :
{
    $$ = inserta_info_dominio(-1, T_VACIO);
}
| listaParametrosActuales
{
    $$ = $1; /* redundante */
}
;

listaParametrosActuales :
  expresion
{
    $$ = inserta_info_dominio(-1, $1.tipo);
    emite(EPUSH, cr_arg_nulo(), cr_arg_nulo(), $1.pos);
}
| expresion TK_COMMA listaParametrosActuales  
{
    inserta_info_dominio($3, $1.tipo);
    $$ = $3;
    emite(EPUSH, cr_arg_nulo(), cr_arg_nulo(), $1.pos);
}
;

operadorAsignacion :
  TK_ASIG
{
    $$ = TK_ASIG;
}
| TK_SUMASIG
{
    $$ = TK_SUMASIG;
}
| TK_SUBASIG
{
    $$ = TK_SUBASIG
}
;

operadorLogico :
  TK_AND
{
    $$ = EMULT;
}
| TK_OR
{
    $$ = ESUM;
}
;

operadorIgualdad :
  TK_EQUAL
{
    $$ = EIGUAL;
}
| TK_NEQUAL
{
    $$ = EDIST;
}
;

operadorRelacional :
  TK_LESS
{
    $$ = EMEN;
}
| TK_GREAT
{
    $$ = EMAY;
}
| TK_LESSEQ
{
    $$ = EMENEQ;
}
| TK_GREATEQ
{
    $$ = EMAYEQ;
}
;

operadorAditivo :
  TK_PLUS
{
    $$ = ESUM;
}
| TK_MINUS
{
    $$ = EDIF;
}
;

operadorMultiplicativo :
  TK_MULT
{
    $$ = EMULT;
}
| TK_DIV
{
    $$ = EDIVI;
}
;

operadorIncremento :
  TK_INC
{
    $$ = ESUM;
}
| TK_DEC
{
    $$ = EDIF;
}
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


TIPO_ARG emite_entero_a_bool (TIPO_ARG entero)
{
    TIPO_ARG res = cr_arg_posicion(contexto, crea_var_temp());
    emite(ETOB, entero, cr_arg_nulo(), res);
    
    return res;
};

TINFO obtener_tipo (SIMB simb)
{
    TINFO ret;
    
    ret.tipo = simb.tipo;
    ret.talla = obtener_talla(simb);
    ret.pos = cr_arg_posicion(simb.nivel, simb.desp);
    
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
