/*****************************************************************************/
/*  PROGRAMA PRINCIPAL                                                       */
/*                       Jose Miguel Benedi, 2010-2011 <jbenedi@dsic.upv.es> */
/*****************************************************************************/
#include <stdio.h>
#include <string.h>
#include "header.h"
#include "asin.h"
/************************************* Variables externas definidas en el AL */
extern FILE *yyin;
extern int  yylineno;
extern int  yydebug;
/********************************** Variables globales de uso en el "main.c" */
int verbosidad     = FALSE;     /* Flag para indicar si debe haber traza     */
int ver_tds        = FALSE;     /* Flag para indicar si debe mostrar la TDS  */
int salida_binario = FALSE;     /* Flag para indicar si la salida es binaria */
int num_errores    = 0;	        /* Contador del numero de errores            */
char *nom_fich;                 /* Nombre del fichero de salida              */
/*****************************************************************************/

void yyerror (char *msg) 

/*  Funcion que gestiona el tratamiento de errores.                          */
{
  num_errores++;  
  fprintf(stderr, "\nLinea %d. %s\n", yylineno , msg);
}

/*****************************************************************************/
main (int argc, char **argv) 

/*  Programa principal. Gestiona la linea de comandos y llama al Analizador  */
/*  Sintactico.                                                              */
{ int i, n = 0;

  for (i=0; i<argc; ++i) { 
    if (strcmp(argv[i], "-v")==0) { verbosidad =     TRUE; n++; }
    if (strcmp(argv[i], "-t")==0) { ver_tds =        TRUE; n++; }
  }
  --argc; n++;
  if (argc == n) {
    if ((yyin = fopen (argv[argc], "r")) == NULL)
      fprintf (stderr, "Fichero no valido %s\n", argv[argc]);      
    else {	  
      if (verbosidad == TRUE) printf("%3d.- ", yylineno);
      nom_fich = argv[argc];
      yyparse ();
      if (num_errores == 0) vuelca_codigo_ascii ();
      else printf ("\nNumero de errores: %d\n", num_errores);
    }	
  }
  else fprintf (stderr, "Uso: cmc [-v] [-t] fichero\n");
} 
/*****************************************************************************/
/*****************************************************************************/
