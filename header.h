/*****************************************************************************/
/*****************************************************************************/
/**  Definiciones de variables y estructuras globales, asi como el perfil   **/
/**  de las operaciones auxiliares para el desarrollo del compilador de     **/
/**  MenosC.11.                                                             **/
/**                     Jose Miguel Benedi, 2010-2011 <jbenedi@dsic.upv.es> **/
/*****************************************************************************/
/*****************************************************************************/
#ifndef _DEF_H_
#define _DEF_H_
/*****************************************************************************/
/****************** Constantes de uso en todo el compilador ******************/
/*****************************************************************************/
#define FALSE 0
#define TRUE  1
/******************************************* Tallas de los tipos y segmentos */
#define TALLA_ENTERO     1
#define TALLA_LOGICO     1
#define TALLA_SEGENLACES 2       /* Talla del segmento de Enlaces de Control */
/******************************************* Tipos para la Tabla de Simbolos */
#define T_VACIO       0
#define T_ENTERO      1
#define T_LOGICO      2
#define T_ARRAY       3
#define T_ERROR       4
/************************************** Categorias para la Tabla de Simbolos */
#define NULO          0
#define VARIABLE      1
#define FUNCION       2
#define PARAMETRO     3
/*************************************************** Ambito de las variables */
#define GLOBAL        0
#define LOCAL         1
/********************************* Instrucciones del Codigo Tres Direcciones */
#define ESUM          0
#define EDIF          1
#define EMULT         2
#define EDIVI         3
#define RESTO         4
#define ESIG          5
#define EASIG         6
#define GOTOS         7
#define EIGUAL        8
#define EDIST         9
#define EMEN         10
#define EMAY         11
#define EMAYEQ       12
#define EMENEQ       13
#define EAV          14
#define EVA          15
#define EREAD        16
#define EWRITE       17
#define FIN          18
#define RET          19
#define CALL         20
#define EPUSH        21
#define EPOP         22
#define PUSHFP       23
#define FPPOP        24
#define FPTOP        25
#define TOPFP        26
#define INCTOP       27
#define DECTOP       28
#define ETOB         29
#define BTOE         30
/*****************************************************************************/
/************** Variables globales de uso en todo el compilador **************/
/*****************************************************************************/

extern FILE *yyin;
extern int  yylineno;
extern int  yydebug;

extern int verbosidad;                /* Para decidir si se desea una traza  */
extern int ver_tds;                   /* para indicar si debe mostrar la TDS */

extern char *nom_fich;                 /* Nombre del de salida               */

extern int contexto;          /* Contexto: ambito local o global             */
extern int dvar;              /* Desplazamiento en el Segmento de Variables  */
extern int dpar;              /* Desplazamiento en el Segmento de Parametros */
extern int si;                /* Desplazamiento en el Segmento de Codigo     */

/*****************************************************************************/
/******* Estructuras Generales asociadas a las funciones de la librería ******/
/*****************************************************************************/

typedef struct tipo_arg      /* Estructura para los argumentos del codigo 3D */
{              
  int tipo;                  /* Tipo del argumento                           */
  union {
    int i;                   /* Variable para argumento entero               */
    struct                   /* Estructura para una posición de memoria      */
    {               
      int pos, niv;          /*     Posicion relativa y nivel del contexto   */
    } p;                     /* Variable para argumento posicion de memoria  */
    int e;                   /* Variable para argumento direccion de memoria */
  } val;
} TIPO_ARG;

typedef struct simb     /* Estructura para la informacion obtenida de la TDS */
{
  int   categoria;                /* Categoria del objeto                    */
  int   tipo;                     /* Tipo del objeto                         */
  int   desp;                     /* Desplazamiento relativo en el segmento  */
  int   nivel;                    /* Ambito de las variables: global o local */
  int   ref;                      /* Campo de referencia de usos multiples   */
} SIMB;

typedef struct dim  /* Estructura para la informacion obtenida de la TDArray */
{
  int   tipo;                                       /* Tipo de los elementos */
  int   lsup;                                       /* Numero de elementos   */
} DIM;

typedef struct inf      /* Estructura para las funciones                     */
{
  int   tipo;                            /* Tipo del rango de la funcion     */
  int   tparam;                          /* Talla del segmento de parametros */
}INF;

/*****************************************************************************/
/**** Macros, constantes, variables y estructuras propias (Alumnos) **********/
/*****************************************************************************/

/* Información del tipo de un no terminal, útil pata la comprobación de
   tipos
 */
typedef struct tinfo 
{
    int tipo;
    int talla;
} TINFO;


TINFO obtener_tipo (SIMB simb);
int obtener_talla (SIMB simb);


/*****************************************************************************/
/******************* Perfil de las funciones de la libreria ******************/
/*****************************************************************************/

/************************************* Operaciones para la gestion de la TDB */
void carga_contexto (int cont);

/* Crea el contexto necesario asi como las inicializalizaciones de la TDS y 
   la TDB para un nuevo bloque con contexto (GLOBAL o LOCAL) definido en 
   "cont". Además, actualiza la variable global "contexto" a su nuevo valor. */

void descarga_contexto (int cont);

/* Libera en la TDB y la TDS el contexto asociado con el bloque actual con 
   contexto (GLOBAL o LOCAL) definido en "cont".  Además, actualiza la 
   variable global "contexto" a su nuevo valor.                              */

/************************************* Operaciones para la gestion de la TDS */
int inserta_info_array (int telem, int nelem);

/* Inserta en la Tabla de Arrays la informacion de un array cuyos elementos 
   son de tipo "telem" y el numero de elementos es "nelem". Devuelve su 
   referencia en la Tabla de Arrays.                                         */

int inserta_info_dominio (int refe, int tipo);

/* Para un dominio existente referenciado por "refe", inserta en la Tabla 
   de Dominios la informacion del "tipo" del parametro.  Si "ref= -1" 
   entonces crea una nueva entrada en la tabla de dominios para el tipo de 
   este parametro y devuelve su referencia.  Si la funcion no tiene 
   parametros, debe crearse un dominio vacio con: 
   "refe = -1" y "tipo = T_VACIO".                                           */

int inserta_simbolo(char *nom,int clase,int tipo,int desp,int cont,int ref);

/* Inserta en la TDS toda la informacion asociada con un simbolo de: nombre 
   "nom", clase "clase", tipo "tipo", desplazamiento relativo en el segmento 
   correspondiente (variables, parametros o instrucciones) "desp", nivel de 
   contexto "cont" y referencia a posibles subtablas "ref" (-1 si no 
   referencia a otras subtablas).  Si el identificador ya existe en el 
   contexto actual, devuelve el valor "FALSE" ("TRUE" en caso contrario).    */

SIMB obtener_simbolo (char *nom);

/* Obtiene toda la informacion asociada con un objeto de nombre "nom" y la
   devuelve en una estructura de tipo "SIMB". Si el objeto no está declarado,
   proporciona un mensaje de errror y en el campo "categoria" devuelve el 
   valor "NULO".                                                             */

INF obtener_info_funcion (int ref);

/* Devuelve la informacion del tipo del rango y el numero (talla) de 
   parametros de la funcion cuyo dominio esta referenciad por "ref" en 
   la TDS. Si "ref<0" entonces devuelve la informacion de la funcion 
   asociada al contexto actual.                                              */

int es_main ();

/* Si la funcion actual es "main" devuelve "TRUE" ("FALSE en caso contrario).*/

DIM obtener_array (int ref);

/* Devuelve toda la informacion asociada con un array referenciado por "ref" 
   en la Tabla de Arrays.                                                    */

int compara_dominio (int refx, int refy);

/* Si los dominios referenciados por "refx" y "refy" no coinciden muestra 
   un mensaje de error y devuelve "FALSE" ("TRUE" si son iguales).           */

void mostrar_tds ();

/* Muestra en pantalla toda la informacion de la TDS asociada con el
   contexto actual (GLOBAL o LOCAL)                                          */

/*********************** Operaciones para la generacion de codigo intermedio */
TIPO_ARG cr_arg_nulo ();

/* Crea un argumento de una instruccion tres direcciones de tipo nulo.       */


TIPO_ARG cr_arg_entero (int valor);

/* Crea un argumento de una instruccion tres direcciones de tipo
   entero con "valor".                                                       */

TIPO_ARG cr_arg_etiqueta (int valor);

/*  Crea el argumento de una instruccion tres direcciones de tipo
    etiqueta con la informacion de la direccion en "valor".                  */

TIPO_ARG cr_arg_posicion (int n, int valor);

/*  Crea el argumento de una instruccion tres direcciones de tipo
    posicion con el contexto "n" y el desplazamiento "valor".                */

void emite (int cop, TIPO_ARG arg1, TIPO_ARG arg2, TIPO_ARG res);

/* Crea una instruccion tres direcciones con el codigo de operacion
   "cod" y los argumentos "arg1", "arg2" y "res", y la pone en la
   siguiente posicion libre (indicada por "si") del Segmento de
   Codigo. A continuacion, incrementa "si".                                  */

int crea_var_temp ();

/*  Crea una variable temporal, de talla "1", en el segmento de
    variables del bloque actual y devuelve su desplazamiento
    relativo. A continuacón, incrementa "dvar = dvar + 1".                   */

void vuelca_codigo_ascii();

/* Vuelca el codigo generado, en modo texto, a un fichero cuyo nombre
   es el del fichero de entrada con la extension ".txt".                     */

void vuelca_codigo_binario();

/* Vuelca el codigo generado, en modo binario, a un fichero cuyo
   nombre es el del fichero de entrada con la extension ".obj".              */

/****************************** Operaciones para la manipulacion de las LANS */
int crea_lans (int d);

/* Crea una lista de argumentos no satisfechos para una instruccion
   incompleta cuya dirección es "d" y devuelve su referencia.                */

int fusiona_lans (int x, int y);

/* Fusiona dos listas de argumentos no satisfechos cuyas referencias
   son "x" e "y" y devuelve la referencia de la lista fusionada.             */

void completa_lans ( int x, TIPO_ARG arg);

/* Completa con el argumento "arg" el campo "res" de todas las
   instrucciones incompletas de la lista "x".                                */

/*****************************************************************************/
#endif  /* _TDN_H_ */
/*****************************************************************************/
/*****************************************************************************/
