#ifdef NEED_REAL_STDIO
#include <stdio.h>
#else
#if !defined(_STDIO_H) && !defined(FILE) && \
    !defined(_STDIO_INCLUDED) && !defined(__STDIO_LOADED) && \
    !defined(_INC_STDIO)
#define _STDIO_H
#define _STDIO_INCLUDED
#define __STDIO_LOADED
#define _INC_STDIO
struct _FILE;
#define FILE struct _FILE
EXTERN int printf  _ANSI_ARGS_((CONST char *,...));
EXTERN int sscanf  _ANSI_ARGS_((CONST char *, CONST char *,...));
#ifdef SPRINTF_RETURN_CHAR
EXTERN char *sprintf _ANSI_ARGS_((char *, CONST char *,...));
#else
EXTERN int sprintf _ANSI_ARGS_((char *, CONST char *,...));
#endif
#endif
#endif /* NEED_REAL_STDIO */

#ifndef EOF
#define EOF (-1)
#endif

/* This is to catch case with no stdio */
#ifndef BUFSIZ
#define BUFSIZ 1024
#endif

#ifndef SEEK_SET
#define SEEK_SET 0
#endif

#ifndef SEEK_CUR
#define SEEK_CUR 1
#endif

#ifndef SEEK_END
#define SEEK_END 2
#endif
