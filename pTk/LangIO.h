#ifdef NEED_REAL_STDIO
#include <stdio.h>
#else
#if !defined(_STDIO_INCLUDED) && \
    !defined(_stdio_h) && \
    !defined(__STDIO_H__) && \
    !defined(_h_stdio_) && \
    !defined(_included_stdio) && \
    !defined(_H_STDIO_) && \
    !defined(_STDIO_H) && \
    !defined(_FILEDEFED) && \
    !defined(_INCLUDED_STDIO) && \
    !defined(_STDIO_H_) && \
    !defined(__STDIO_H) && \
    !defined(__STDIO_LOADED) && \
    !defined(_H_STDIO) && \
    !defined(_INC_STDIO) && \
    !defined(__h_stdio__) && \
    !defined(STDIO_H) && \
    !defined(_stdio_h_) && \
    !defined(__stdio_h__) && \
    !defined(_stdio_included) && \
    !defined(_h_stdio) && \
    !defined(__H_STDIO__) && \
    !defined(FILE)
#define _STDIO_INCLUDED
#define _stdio_h
#define __STDIO_H__
#define _h_stdio_
#define _included_stdio
#define _H_STDIO_
#define _STDIO_H
#define _FILEDEFED
#define _INCLUDED_STDIO
#define _STDIO_H_
#define __STDIO_H
#define __STDIO_LOADED
#define _H_STDIO
#define _INC_STDIO
#define __h_stdio__
#define STDIO_H
#define _stdio_h_
#define __stdio_h__
#define _stdio_included
#define _h_stdio
#define __H_STDIO__
#define _FILEDEFED
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
