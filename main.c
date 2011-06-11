
#include <stdio.h>
#include <string.h>
#include "header.h"
#include "asin.h"
#include "error.h"


int verbosidad     = FALSE;
int ver_tds        = FALSE;
int salida_binario = FALSE;

char *nom_fich;



main (int argc, char **argv) 
{
    int i, n = 0;
    
    for (i = 0; i < argc; i++) { 
        if (strcmp(argv[i], "-v") == 0) { verbosidad = TRUE; n++; }
        if (strcmp(argv[i], "-t") == 0) { ver_tds = TRUE; n++; }
    }
    
    argc--; n++;
    
    if (argc == n) {
        if ((yyin = fopen (argv[argc], "r")) == NULL)
            error("fichero \"%s\" no valido", argv[argc]);
        else {
            if (verbosidad == TRUE) printf("%3d.- ", yylineno);
            nom_fich = argv[argc];
            yyparse();
            
            if (get_error_count() == 0)
                vuelca_codigo_ascii();
            else
                printf("\nNumero de errores: %d\n", get_error_count());
        }
    }
    else
        fprintf(stderr, "Uso: cmc [-v] [-t] fichero\n");
} 
