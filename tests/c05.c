// Cálculo de los números primos menores que el dato introducido
bool a[150];
int max;

bool divisor (int d, int n)
{
  if (n < d) return false;
  else {
    while ( n >= d) n-=d ;
    if (n == 0) return true;
    else return false;
    }
}

int main()
{ int n; int m;

  read(max);
  while ((max <= 1)||(max >=150)) read(max); 
  
  n=2;
  while (n <= max) { a[n]=true; n++; }

  n=4;
  while (n <= max) { 
    if (divisor(2,n)) a[n]=false; 
    else {  
      m=3;
      while ((m*m) <= n) 
	if (divisor(m,n)) {
	  a[n]=false; m=n;
	  }
	else m=m+2;
      }
    n++;
    }

  n=2;
  while (n <= max ){
    if (a[n]) print(n);
    else ;
    n++;
  }
}
