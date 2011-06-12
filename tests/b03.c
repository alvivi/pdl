// Programa con errores semanticos

int  a;
int  b[20];
bool c;
bool d[10];                               
int  a1;
int  b1[20];
bool e[0];                    //**** Indice de array debe ser positivo

int main()
{
  b1 = b;                     //**** Asignacion no valida
  
    a1=a=1;
    while ((a < 10 ) && (a1 > 7)) {
      a = a + 1 ;
      a1 = a1-1;
    }
  
    c[a] = 1 ;                  //**** La variable no es un array
  b = c[a];                   //**** La variable no es un array
  b1[b[a1]] = a + b[5] * b1[a + b1[a1]] ;
  
    if (!d[a+1] && c) a = 1;
    else a = 2 ;
  
    if (a || a1 )  a = a1 ;     //**** La expresion no es booleana
    else d[3 + 5] = false;
  }

