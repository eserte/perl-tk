/*
  Copyright (c) 1997-1998 Nick Ing-Simmons. All rights reserved.
  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.
*/

#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#include "tkGlue.def"

#include "pTk/tkPort.h"
#include "pTk/tkInt.h"
#include "tkGlue.h"

#ifndef newSVpvn
static SV *
newSVpvn(char *s,STRLEN len)
{
 SV *sv = newSVpv("",0);
 sv_setpvn(sv,s,len);
 return sv;
}
#endif


static int
Expire(int code)
{
 return code;
}

#define EXPIRE(args) \
  ( Tcl_SprintfResult args, Expire(TCL_ERROR) )

/*
 * This file maps Tcl_Obj * onto perl's SV *
 * They are very similar.
 * One area of worry is that Tcl_Obj are created with refCount = 0,
 * while SV's have SvREFCNT == 1
 * None the less normal idiom is
 *
 *   Tcl_Obj *obj = Tcl_NewFooObj(...)
 *   ...
 *   Tcl_DecrRefCount(obj)
 *
 * So difference should be transparent.
 *
 * Also :
 *
 *   Tcl_Obj *obj = Tcl_NewFooObj(...)
 *   Tcl_ListAppendElement(list,obj);
 *
 * Again this is consistent with perl's assumption that refcount is 1
 * and that av_push() does not increment it.
 *
 */

void
Tcl_IncrRefCount(Tcl_Obj *objPtr)
{
 SvREFCNT_inc(objPtr);
}

void
Tcl_DecrRefCount(Tcl_Obj *objPtr)
{
 SvREFCNT_dec(objPtr);
}

static SV *ForceScalar(SV *sv);

static SV *ForceScalarLvalue(SV *sv);

static void
Scalarize(SV *sv, AV *av)
{
 int n    = av_len(av)+1;
 if (n == 0)
  sv_setpvn(sv,"",0);
 else
  {
   SV **svp;
   if (n == 1 && (svp = av_fetch(av, 0, 0)))
    {
     sv_setsv(sv,*svp);
    }
   else
    {
     Tcl_DString ds;
     int i;
     Tcl_DStringInit(&ds);
     for (i=0; i < n; i++)
      {
       if ((svp = av_fetch(av, i, 0)))
        {
         SV *el = *svp;
         int temp = 0;
         if (SvROK(el) && SvTYPE(SvRV(el)) == SVt_PVAV)
          {
           el = newSVpv("",0);
           temp = 1;
           Scalarize(el,(AV *) SvRV(*svp));
          }
         Tcl_DStringAppendElement(&ds,LangString(el));
         if (temp)
          SvREFCNT_dec(el);
        }
      }
     sv_setpvn(sv,Tcl_DStringValue(&ds), Tcl_DStringLength(&ds));
     Tcl_DStringFree(&ds);
    }
  }
}

static SV *
ForceScalar(SV *sv)
{
 if (SvGMAGICAL(sv))
  mg_get(sv);
 if (SvTYPE(sv) == SVt_PVAV)
  {
   AV *av = (AV *) sv;
   SV *nsv = newSVpv("",0);
   Scalarize(nsv, (AV *) av);
   av_clear(av);
   av_store(av,0,nsv);
   return nsv;
  }
 else
  {
   if (SvROK(sv) && SvTYPE(SvRV(sv)) == SVt_PVAV)
    {
     /* Callbacks and lists often get stringified by mistake due to
        Tcl/Tk's string fixation - don't change the real value
      */
     SV *nsv = newSVpv("",0);
     Scalarize(nsv, (AV *) SvRV(sv));
     return sv_2mortal(nsv);
    }
   else if (!SvOK(sv))
    {
     /* Map undef to null string */
     sv_setpvn(sv,"",0);
    }
   return sv;
  }
}

static SV *
ForceScalarLvalue(SV *sv)
{
 if (SvTYPE(sv) == SVt_PVAV)
  {
   AV *av = (AV *) sv;
   SV *nsv = newSVpv("",0);
   av_clear(av);
   av_store(av,0,nsv);
   return nsv;
  }
 else
  {
   return sv;
  }
}

void
Tcl_SetBooleanObj (Tcl_Obj *objPtr, int value)
{
 sv_setiv(ForceScalarLvalue(objPtr),value != 0);
}

void
Tcl_SetDoubleObj (Tcl_Obj *objPtr, double value)
{
 sv_setnv(ForceScalarLvalue(objPtr),value);
}

void
Tcl_SetIntObj (Tcl_Obj *objPtr, int value)
{
 sv_setiv(ForceScalarLvalue(objPtr),value);
}

void
Tcl_SetLongObj (Tcl_Obj *objPtr, long value)
{
 sv_setiv(ForceScalarLvalue(objPtr),value);
}

void
Tcl_SetStringObj (Tcl_Obj *objPtr, char *bytes, int length)
{
 if (length < 0)
  length = strlen(bytes);
 sv_setpvn(ForceScalarLvalue(objPtr), bytes, length);
}

int
Tcl_GetLongFromObj (Tcl_Interp *interp, Tcl_Obj *obj, long *longPtr)
{
 SV *sv = ForceScalar(obj);
 if (SvIOK(sv) || looks_like_number(sv))
  *longPtr = SvIV(sv);
 else
  {
   *longPtr = 0;
   return EXPIRE((interp, "'%s' isn't numeric", SvPVX(sv)));
  }
 return TCL_OK;
}

int
Tcl_GetBooleanFromObj (Tcl_Interp *interp, Tcl_Obj *obj, int *boolPtr)
{
 SV *sv = ForceScalar(obj);
 static char *yes[] = {"y", "yes", "true", "on", NULL};
 static char *no[] =  {"n", "no", "false", "off", NULL};
 if (SvPOK(sv))
  {
   STRLEN na;
   char *s = SvPV(sv, na);
   char **p = yes;
   while (*p)
    {
     if (!strcasecmp(s, *p++))
      {
       *boolPtr = 1;
       return TCL_OK;
      }
    }
   p = no;
   while (*p)
    {
     if (!strcasecmp(s, *p++))
      {
       *boolPtr = 0;
       return TCL_OK;
      }
    }
  }
 *boolPtr = SvTRUE(sv);
 return TCL_OK;
}

int
Tcl_GetIntFromObj (Tcl_Interp *interp, Tcl_Obj *obj, int *intPtr)
{
 SV *sv = ForceScalar(obj);
 if (SvIOK(sv) || looks_like_number(sv))
  *intPtr = SvIV(sv);
 else
  {
   *intPtr = 0;
   return EXPIRE((interp, "'%s' isn't numeric", SvPVX(sv)));
  }
 return TCL_OK;
}

int
Tcl_GetDoubleFromObj (Tcl_Interp *interp, Tcl_Obj *obj, double *doublePtr)
{
 SV *sv = ForceScalar(obj);
 if (SvNOK(sv) || looks_like_number(sv))
  *doublePtr = SvNV(sv);
 else
  {
   *doublePtr = 0;
   return EXPIRE((interp, "'%s' isn't numeric", SvPVX(sv)));
  }
 return TCL_OK;
}

Tcl_Obj *
Tcl_NewIntObj (int value)
{
 return newSViv(value);
}

Tcl_Obj *
Tcl_NewBooleanObj (int value)
{
 return newSViv(value);
}

Tcl_Obj *
Tcl_NewObj(void)
{
 return newSVpvn("",0);
}

Tcl_Obj *
Tcl_NewLongObj(long value)
{
 return newSViv(value);
}

Tcl_Obj *
Tcl_NewDoubleObj(double value)
{
 return newSVnv(value);
}

Tcl_Obj *
Tcl_NewStringObj (char *bytes, int length)
{
 if (bytes)
  {
   if (length < 0)
    length = strlen(bytes);
   return newSVpvn(bytes,length);
  }
 else
  return &PL_sv_undef;
}

Tcl_Obj *
Tcl_NewListObj (int objc, Tcl_Obj *CONST objv[])
{
 AV *av = newAV();
 if (objc)
  {
   while (objc-- > 0)
    {
     SV *sv = objv[objc];
     if (sv)
      {
       /* tkConfig.c passes Tcl_NewStringObj() or LangSetDefault()
          so REFCNT should be ok as-is
        */
       if (SvREFCNT(sv) <= 0 || SvTEMP(sv))
        {
         LangDebug("%s %d:\n",__FUNCTION__, objc);
         sv_dump(sv);
        }
       av_store(av,objc,sv);
      }
    }
  }
 return MakeReference((SV *) av);
}

char *
Tcl_GetStringFromObj (Tcl_Obj *objPtr, int *lengthPtr)
{
 char *s;
 if ((SvROK(objPtr) && SvTYPE(SvRV(objPtr)) == SVt_PVAV) ||
      (SvTYPE(objPtr) == SVt_PVAV))
  objPtr = ForceScalar(objPtr);
 if (SvPOK(objPtr))
  {
   STRLEN len;
   s = SvPV(objPtr, len);
   if (lengthPtr)
    *lengthPtr = len;
  }
 else
  {
   s = LangString(objPtr);
   if (lengthPtr)
    *lengthPtr = strlen(s);
  }
 return s;
}

AV *
ForceList(Tcl_Interp *interp, Tcl_Obj *sv)
{
 if (SvTYPE(sv) == SVt_PVAV)
  {
   return (AV *) sv;
  }
 else
  {
   int object = sv_isobject(sv);
   if (!object && SvROK(sv) && SvTYPE(SvRV(sv)) == SVt_PVAV)
    {
     return (AV *) SvRV(sv);
    }
   else
    {
     AV *av = newAV();
     if (!object && (SvIOK(sv) || SvNOK(sv)))
      {
       /* Simple case of single number */
       av_store(av,0,SvREFCNT_inc(sv));
      }
     else
      {
       /* Parse TCL like strings
          {} are quotes - and can be nested
          \ quotes \ itself and whitespace

          Older Tk used this perl code ...
          local $_ = shift;
          my (@arr, $tmp);
          while (/\{([^{}]*)\}|((?:[^\s\\]|\\.)+)/gs) {
            if (defined $1) { push @arr, $1 }
            else { $tmp = $2 ; $tmp =~ s/\\([\s\\])/$1/g; push @arr, $tmp }
          }
       */
       unsigned char *s = (unsigned char *) LangString(sv);
       int i = 0;
       while (*s)
        {
         unsigned char *base;
         /* Skip leading whitespace */
         while (isspace(*s))
          s++;
         if (!*s)
          break;
         base = s;
         if (*s == '{')
          {
           /* Slurp chars till we find matching '}' */
           int count = 1;  /* number of open '{' */
           base = ++s;
           while (*s)
            {
             if (*s == '{')
              count++;
             else if (*s == '}' && (--count <= 0))
              break;
             s++;
            }
           if (*s != '}')
            {
             /* Found end of string before closing '}'
                TCL would set an error, we will just include the
                un-matched opening '{' in the string.
              */
             base--;
            }
          }
         else if (*s)
          {
           /* Find a "word" */
           while (*s && !isspace(*s))
            {
             if (*s == '\\' && s[1]) /* \ quotes anything except end of string */
              s++;
             s++;
            }
          }
         av_store(av,i++,newSVpvn(base,(s-base)));
         if (*s == '}')
          s++;
        }
      }
     /* Now have an AV populated decide how to return */
     if (SvREADONLY(sv))
      {
       sv_2mortal((SV *) av);
       return av;
      }
     else
      {
       SV *ref = MakeReference((SV *) av);
       sv_setsv(sv,ref);
       SvREFCNT_dec(ref);
      }
     return (AV *) SvRV(sv);
    }
  }
}

int
Tcl_ListObjAppendElement (Tcl_Interp *interp, Tcl_Obj *listPtr,
			    Tcl_Obj *objPtr)
{
 AV *av = ForceList(interp,listPtr);
 if (!objPtr)
  objPtr = &PL_sv_undef;
 if (av)
  {
   av_push(av, objPtr);
   return TCL_OK;
  }
 return TCL_ERROR;
}

AV *
MaybeForceList(Tcl_Interp *interp, Tcl_Obj *sv)
{
 AV *av;
 int object = sv_isobject(sv);
 if (!object && SvROK(sv) && SvTYPE(SvRV(sv)) == SVt_PVAV)
  {
   return (AV *) SvRV(sv);
  }
 else if (!object && (SvIOK(sv) || SvNOK(sv)))
  {
   av = newAV();
   av_store(av,0,SvREFCNT_inc(sv));
   sv_2mortal((SV *) av);
   return av;
  }
 else if (SvREADONLY(sv))
  {
   /* returns mortal list anyway */
   return ForceList(interp,sv);
  }
 else
  {
   SvREADONLY_on(sv);
   av = ForceList(interp,sv);
   SvREADONLY_off(sv);
   /* If there was more than one element set the SV */
   if (av && av_len(av) > 0)
    {
     /* AV is mortal - so we want newRV not MakeReference as we need extra REFCNT */
     sv_setsv(sv,newRV((SV *) av));
    }
   return av;
  }
}

int
Tcl_ListObjGetElements (Tcl_Interp *interp, Tcl_Obj *listPtr,
			    int *objcPtr, Tcl_Obj ***objvPtr)
{
 if (listPtr)
  {
   AV *av = MaybeForceList(interp,listPtr);
   if (av)
    {
     *objcPtr = av_len(av)+1;
     *objvPtr = AvARRAY(av);
     return TCL_OK;
    }
  }
 *objcPtr = 0;
 *objvPtr = NULL;
 return TCL_OK;
}

int
Tcl_ListObjIndex (Tcl_Interp *interp,  Tcl_Obj *listPtr, int index,
			    Tcl_Obj **objPtrPtr)
{
 AV *av = ForceList(interp,listPtr);
 if (av)
  {
   SV **svp = av_fetch(av, index, 0);
   if (svp)
    {
     *objPtrPtr = *svp;
     return TCL_OK;
    }
   return EXPIRE((interp, "No element %d",index));
  }
 return TCL_ERROR;
}

int
Tcl_ListObjLength (Tcl_Interp *interp, Tcl_Obj *listPtr, int *intPtr)
{
 AV *av = ForceList(interp,listPtr);
 if (av)
  {
   *intPtr = av_len(av)+1;
   return TCL_OK;
  }
 return TCL_ERROR;
}

int
Tcl_ListObjReplace (Tcl_Interp *interp, Tcl_Obj *listPtr, int first, int count,
			    int objc, Tcl_Obj *CONST objv[])
{
 AV *av = ForceList(interp,listPtr);
 if (av)
  {
   int len = av_len(av)+1;
   int newlen = len-count+objc;
   int i;
   if (newlen > len)
    {
     /* Move entries beyond old range up to make room for new */
     av_extend(av,newlen-1);
     for (i=len-1; i >= (first+count); i--)
      {
       SV **svp = av_fetch(av,i,0);
       av_store(av,i+newlen-len,SvREFCNT_inc(*svp));
      }
    }
   else if (newlen < len)
    {
     /* Move entries beyond old range down to new location */
     for (i=first+count; i < len; i++)
      {
       SV **svp = av_fetch(av,i,0);
       av_store(av,i+newlen-len,SvREFCNT_inc(*svp));
      }
#ifdef AvFILLp
     AvFILLp(av) = newlen-1;
#else
     AvFILL(av) = newlen-1;
#endif
    }
   /* Store new values */
   for (i=0; i < objc; i++)
    {
     av_store(av,first+i,objv[i]);
    }
   return TCL_OK;
  }
 return TCL_ERROR;
}

Tcl_Obj *
Tcl_ConcatObj (int objc, Tcl_Obj *CONST objv[])
{
 /* This is very like Tcl_NewListObj() - but is typically
    called on a command's objv - which will not have REFCNT
    set way Tcl_NewListObj() is expecting. So correct that
    then call Tcl_NewListObj().
  */
 int i;
 for (i=0; i < objc; i++)
  {
   SV *sv = (SV *)objv[i];
   if (sv)
    {
     SvREFCNT_inc(sv);
    }
  }
 return Tcl_NewListObj (objc, objv);
}


char *
Tcl_DStringAppendElement(dsPtr, string)
    Tcl_DString *dsPtr;		/* Structure describing dynamic string. */
    char *string;		/* String to append.  Must be
				 * null-terminated. */
{
    char *s = string;
    int ch;
    while ((ch = *s))
     {
      if (isspace(ch))
       break;
      s++;
     }
    if (Tcl_DStringLength(dsPtr)) {
	Tcl_DStringAppend(dsPtr, " ", 1);
    }
    if (*s) {
	Tcl_DStringAppend(dsPtr, "{", 1);
    }
    Tcl_DStringAppend(dsPtr, string, -1);
    if (*s) {
	Tcl_DStringAppend(dsPtr, "}", 1);
    }
    return Tcl_DStringValue(dsPtr);
}

void
Tcl_AppendStringsToObj (Tcl_Obj *obj,...)
{
 va_list ap;
 char *s;
 SV *sv = ForceScalar(obj);
 va_start(ap,obj);
 while ((s = va_arg(ap,char *)))
  {
   sv_catpv(sv,s);
  }
 va_end(ap);
 if (sv != obj && SvROK(obj))
  sv_setsv(obj,sv);
}

/*
 *----------------------------------------------------------------------
 *
 * Tcl_GetIndexFromObj --
 *
 *	This procedure looks up an object's value in a table of strings
 *	and returns the index of the matching string, if any.
 *
 * Results:

 *	If the value of objPtr is identical to or a unique abbreviation
 *	for one of the entries in objPtr, then the return value is
 *	TCL_OK and the index of the matching entry is stored at
 *	*indexPtr.  If there isn't a proper match, then TCL_ERROR is
 *	returned and an error message is left in interp's result (unless
 *	interp is NULL).  The msg argument is used in the error
 *	message; for example, if msg has the value "option" then the
 *	error message will say something flag 'bad option "foo": must be
 *	...'
 *
 * Side effects:
 *	The result of the lookup is cached as the internal rep of
 *	objPtr, so that repeated lookups can be done quickly.
 *
 *----------------------------------------------------------------------
 */

int
Tcl_GetIndexFromObj(interp, objPtr, tablePtr, msg, flags, indexPtr)
    Tcl_Interp *interp; 	/* Used for error reporting if not NULL. */
    Tcl_Obj *objPtr;		/* Object containing the string to lookup. */
    char **tablePtr;		/* Array of strings to compare against the
				 * value of objPtr; last entry must be NULL
				 * and there must not be duplicate entries. */
    char *msg;			/* Identifying word to use in error messages. */
    int flags;			/* 0 or TCL_EXACT */
    int *indexPtr;		/* Place to store resulting integer index. */
{
    int index, length, i, numAbbrev;
    char *key, *p1, *p2, **entryPtr;
    Tcl_Obj *resultPtr;

    /*
     * Lookup the value of the object in the table.  Accept unique
     * abbreviations unless TCL_EXACT is set in flags.
     */

    key = Tcl_GetStringFromObj(objPtr, &length);
    index = -1;
    numAbbrev = 0;
    for (entryPtr = tablePtr, i = 0; *entryPtr != NULL; entryPtr++, i++) {
	for (p1 = key, p2 = *entryPtr; *p1 == *p2; p1++, p2++) {
	    if (*p1 == 0) {
		index = i;
		goto done;
	    }
	}
	if (*p1 == 0) {
	    /*
	     * The value is an abbreviation for this entry.  Continue
	     * checking other entries to make sure it's unique.  If we
	     * get more than one unique abbreviation, keep searching to
	     * see if there is an exact match, but remember the number
	     * of unique abbreviations and don't allow either.
	     */

	    numAbbrev++;
	    index = i;
	}
    }
    if ((flags & TCL_EXACT) || (numAbbrev != 1)) {
	goto error;
    }

    done:
    *indexPtr = index;
    return TCL_OK;

    error:
    if (interp != NULL) {
	resultPtr = Tcl_GetObjResult(interp);
	Tcl_AppendStringsToObj(resultPtr,
		(numAbbrev > 1) ? "ambiguous " : "bad ", msg, " \"",
		key, "\": must be ", *tablePtr, (char *) NULL);
	for (entryPtr = tablePtr+1; *entryPtr != NULL; entryPtr++) {
	    if (entryPtr[1] == NULL) {
		Tcl_AppendStringsToObj(resultPtr, ", or ", *entryPtr,
			(char *) NULL);
	    } else {
		Tcl_AppendStringsToObj(resultPtr, ", ", *entryPtr,
			(char *) NULL);
	    }
	}
    }
    return TCL_ERROR;
}

void
Tcl_AppendToObj(objPtr, bytes, length)
    register Tcl_Obj *objPtr;	/* Points to the object to append to. */
    char *bytes;		/* Points to the bytes to append to the
				 * object. */
    register int length;	/* The number of bytes to append from
				 * "bytes". If < 0, then append all bytes
				 * up to NULL byte. */
{
 SV *sv = ForceScalar(objPtr);
 if (length < 0)
  length = strlen(bytes);
 sv_catpvn(sv, bytes, length);
 if (sv != objPtr && SvROK(objPtr))
  sv_setsv(objPtr,sv);
}

void
Tcl_WrongNumArgs(interp, objc, objv, message)
    Tcl_Interp *interp;			/* Current interpreter. */
    int objc;				/* Number of arguments to print
					 * from objv. */
    Tcl_Obj *CONST objv[];		/* Initial argument objects, which
					 * should be included in the error
					 * message. */
    char *message;			/* Error message to print after the
					 * leading objects in objv. The
					 * message may be NULL. */
{
    Tcl_Obj *objPtr;
    char **tablePtr;
    int i;

    objPtr = Tcl_GetObjResult(interp);
    Tcl_AppendToObj(objPtr, "wrong # args: should be \"", -1);
    for (i = 0; i < objc; i++) {
	Tcl_AppendStringsToObj(objPtr,
		    Tcl_GetStringFromObj(objv[i], (int *) NULL),
		    (char *) NULL);
	if (i < (objc - 1)) {
	    Tcl_AppendStringsToObj(objPtr, " ", (char *) NULL);
	}
    }
    if (message) {
      Tcl_AppendStringsToObj(objPtr, " ", message, (char *) NULL);
    }
    Tcl_AppendStringsToObj(objPtr, "\"", (char *) NULL);
}


#define DStringSV(svp) ((*svp) ? (*svp = ForceScalar(*svp)) : (*svp = newSVpv("",0), *svp))

#undef Tcl_DStringInit
void
Tcl_DStringInit(Tcl_DString *svp)
{
 *svp = NULL;
}

void
Tcl_DbDStringInit(Tcl_DString *svp,char *file,int line)
{
 Tcl_DStringInit(svp);
}

void
Tcl_DStringFree(Tcl_DString *svp)
{
 if (*svp)
  {
   SvREFCNT_dec(*svp);
   *svp = NULL;
  }
}

char *
Tcl_DStringAppend(Tcl_DString *svp, char *s, int len)
{
 SV *sv = DStringSV(svp);
 if (len < 0)
  len = strlen(s);
 sv_catpvn(sv,s,len);
 return SvPVX(sv);
}

int
Tcl_DStringLength(Tcl_DString *svp)
{
 return (int) ((*svp) ? SvCUR(DStringSV(svp)) : 0);
}

void
Tcl_DStringResult(Tcl_Interp *interp, Tcl_DString *svp)
{
 SV *sv = DStringSV(svp);
 Tcl_ArgResult(interp,sv);
 Tcl_DStringFree(svp);
}

void
Tcl_DStringSetLength(Tcl_DString *svp,int len)
{
 SV *sv = DStringSV(svp);
 char *s = SvGROW(sv,(Size_t)(len+1));
 s[len] = '\0';
 SvCUR(sv) = len;
}

char *
Tcl_DStringValue(Tcl_DString *svp)
{
 SV *sv = DStringSV(svp);
 STRLEN len;
 return SvPV(sv,len);
}

void
Tcl_DStringGetResult(Tcl_Interp *interp, Tcl_DString *svp)
{
 SV *sv = DStringSV(svp);
 sv_setsv(sv,LangScalarResult(interp));
}

