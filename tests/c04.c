// Devuelve 1 si los dos numeros son positivos e iguales

bool distintos (int x, int y)
{
  if ( x != y) return true;
  else false;
}

int main()
{ 
  int i;
  int j;

  read(i); read(j);
  while (distintos(i,j) || (i != 0)) {    // uso del OR 
    if ( !(i == 0))                      // uso del NOT
      if ((i == j) && (i > 0)) print(1); // uso del AND
      else print(0);
    else {}
    read(i); read(j);
    }
}
