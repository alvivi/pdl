// Programa con errores semanticos
int n;
int a;
int n;                        // **** Variable ya declarada
bool b[10] ;

int f(int m)
{ bool x;

  m = 1;
  a = 2;
  b[a] = true;
  q = 4;                      //**** Identificador no declarado
}

int g()  { }
 
int f3(bool a, int a)         //**** Parametro duplicado
{ int a; }                    //**** Variable duplicada

int main ()
{ 
  read(p);                    //**** Identificador no declarado
  n=1;
  while (n = 5) {             //**** La  expresion debe ser booleana
    print (f(n)); 
    n++;
  }
}
