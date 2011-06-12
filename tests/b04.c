// Programa con errores semanticos

int  a;
int  b[20];
bool c;
int  d;

int f11(int p1, bool p11)
{ 
  int a11;

  p11 = p1;                   // **** Tipos incompatibles 
  return p11;                 // **** El resultado debe ser "int"
}

bool f1(bool p1, bool p2, int p3)
{
  int a1;
  int a2[10];
  int a;
  
  p11 = p2;                   // **** Parametro no visible
  p2 = f1( c, c);             // **** Error en el numero de parametros
  return f11( a1, c);         // **** El resultado debe ser "bool"
  a2[d] = b[p3];
}

bool f2(int q1)
{ 
  return (q1 < 2);
  f1 = true;                  // **** Asignacion incorrecta
  return f1( q1, c, q1);      // **** Error de tipo en los parametros
}

int main()
{
  a = f5(a, d, c) + 3;        // **** Funcion no definida
  c = f1(c, a, d) + c;        // **** Tipos parametros incompatibles
  a = f2;                     // **** La funcion tiene parametros
  c = f1(c, f2(a), d) || c; 
  c = d = 5 ;                 // **** Tipos incompatibles en asignacion
  a = 1;
  while (a < 12 ) { print (a); a++; }
}
