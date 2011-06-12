// Ejemplo de sintaxis con variables globales y locales;
// la mayoria de las variables no son necesarias;
// comprobar con la funcion "mostrar_tds"    (2X + 2Y)

int a;
bool b;

int A(int x, bool y, int z)
{
  int a; bool b;

  return x+z;
}

int c[27];
int d;
bool e;

int B(int x, int y, bool z)
{
  int a; bool b;

  return x+y;
}

int f[27];
int g;
bool h;

int C(int x, bool y, int z)
{
  int a; bool b;

  return A(B(x,z,y), y ,B(x,z,y));
}

int i[27];
int j;
bool k;

int main()
{
  int x;
  int y;

  read(x);
  read(y);
  if (x < y) print(C(x,true,y));
  else print(C(y,true,x));
}
