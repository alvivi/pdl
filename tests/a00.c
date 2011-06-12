// Con errores lexicos
int abcdefghijklmnopqrstuwxyz;                 // identificador excesivo
int b;
int c#;                                    // error caracter desconocido

int doble(int x, int y, int z) 
{ int a; int b; int c;
  print(a=x++);
  print(b=++y);
  print(c=z);
  return a+b*c;
}

int main() 
{
  abcdefghijklmnopqrstuwxyzzzzzz=b=c=3.56;     // identificador excesivo
                                               // y contante real
  print(doble(abcdefghijklmnopqrstuwxy,b,c));  // identificador excesivo
}
