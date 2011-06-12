// Programa con errores semanticos

int  a;
bool b;
int  c[10];
bool d[10];

int suma (int a, int b)
{ int c; bool aux;

  aux = (a > b) || ( a >= b);
  if ( aux )
    aux = c ;                 //**** Tipos incompatibles (permitido)
  else { 
    a = d + b;                //**** Tipos incompatibles
    aux = aux && ( ! d[a]);
  }
  suma = aux;                 //**** Tipos incompatibles
}

int main()
{
  read (a);
  read (c);                   //**** Error de tipos El argumento de read
  print (a);
  print (c[c[a]]);

  c[a] = ( a * 2 ) / 5 ;
  d[a] = b || d[a];
  d[b] = true;                //**** El indice del array debe ser entero
}
