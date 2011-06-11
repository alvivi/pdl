int  x;
bool y;

int main ()
{
  x = 27;    print(y = x + 2); 
  y = x = 0; print(y);

  y = true;  print(x = y || false);
  x = y = x > 27; print(x);
}
