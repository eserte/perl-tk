#ifdef NEED_REAL_STDIO
#include <stdio.h>
#else
#if !defined(__H_STDIO__) && \
    !defined(__STDIO_H__) && \
    !defined(__h_stdio__) && \
    !defined(__stdio_h__) && \
    !defined(_H_STDIO_) && \
    !defined(_stdio_h_) && \
    !defined(_h_stdio_) && \
    !defined(__STDIO_H) && \
    !defined(_STDIO_H_) && \
    !defined(_H_STDIO) && \
    !defined(_INCLUDED_STDIO) && \
    !defined(_stdio_included) && \
    !defined(_stdio_h) && \
    !defined(_included_stdio) && \
    !defined(_h_stdio) && \
    !defined(__STDIO_LOADED) && \
    !defined(_STDIO_INCLUDED) && \
    !defined(_STDIO_H) && \
    !defined(STDIO_H) && \
    !defined(_INC_STDIO) && \
    !defined(FILE)
#define __H_STDIO__
#define __STDIO_H__
#define __h_stdio__
#define __stdio_h__
#define _H_STDIO_
#define _stdio_h_
#define _h_stdio_
#define __STDIO_H
#define _STDIO_H_
#define _H_STDIO
#define _INCLUDED_STDIO
#define _stdio_included
#define _stdio_h
#define _included_stdio
#define _h_stdio
#define __STDIO_LOADED
#define _STDIO_INCLUDED
#define _STDIO_H
#define STDIO_H
#define _INC_STDIO
#undef FILE
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
