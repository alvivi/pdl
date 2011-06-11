// Ejemplo expresiones de asignación
int a;
int b;
int c;

int doble(int x, int y, int z) 
{ 
  print(x);
  print(y);
  print(z);
  return x+y+z;
}

int main() 
{
  print(a=1); print(b=2); print(c=3);
  print(doble(a,b,c));
}
