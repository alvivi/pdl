
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

#include "error.h"
#include "header.h"

int error_count = 0;

int strfch (char *str, char c)
{
    int r = 0;
    if (str)
        for (; *str; str++)
            if (*str == c) r++;
    return r;
}

void error (char *msg, ...)
{
    va_list ap;

    if (msg) {
        fprintf(stderr, "ERROR (%d): ", yylineno);
        if (strfch(msg, '%')) {
            va_start(ap, msg);
            vfprintf(stderr, msg, ap); 
            va_end(ap);
        } else
            fprintf(stderr, "%s", msg);
        fprintf(stderr, "\n");
    }
    
    error_count++;
}

int get_error_count ()
{
    return error_count;
}

void yyerror (char *msg)
{
    error(msg);
}
