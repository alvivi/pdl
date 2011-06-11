
#ifndef PDL_ERROR
#define PDL_ERROR

void error(char *msg, ...);
int get_error_count();
void yyerror(char *msg);

#endif
