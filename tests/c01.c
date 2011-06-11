// Comprueba si un numero es >= que otro  */
bool f1(int x, int y)
{
  if (x >= y) return true;
  else   return false;
}

int f2(bool c, bool d)
{
  if (c && d) return 1;
  else return 0;
}

int main()
{
  int a; int b; bool c;

  read(a); read (b); c = true;
  if (f1(a,b)) print(f2(c,f1(a,b)));
  else print(0);
}
