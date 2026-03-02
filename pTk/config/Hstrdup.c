#include <string.h>

#define STRING "Whatever"

int main()
{char *e;
 char *p = strdup(STRING);
 if (!p || strcmp(p,STRING))
  return 1;
 return 0;
}

