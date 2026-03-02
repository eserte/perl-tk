#include <stdio.h>
int main()
{
 char x[] = "\377";
 if (x[0] > 0)
  {
   printf("char is unsigned type\n");
   return 0;
  }
 else
  {
   printf("char is signed type\n");
   return 1;
  }
}

