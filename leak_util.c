/*
  Copyright (c) 1995,1996-1998 Nick Ing-Simmons. All rights reserved.
  This program is free software; you can redistribute it and/or
  modify it under the same terms as Perl itself.
*/

#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>
#include "leak_util.h"


#define MAX_HASH 1009

static hash_ptr pile = NULL;

static long int note_sv _((void *p,SV * sv, long int n));
static long int check_sv _((void *p,SV * sv, long n));

struct hash_s 
{struct hash_s *link;
 SV *sv;
 char *tag;
};

static char *
lookup(hash_ptr *ht, SV *sv, void *tag)
{unsigned hash = ((unsigned) sv) % MAX_HASH;
 hash_ptr p = ht[hash];
 while (p)
  {
   if (p->sv == sv)
    {char *old = p->tag;
     p->tag = tag;
     return old;
    }
   p = p->link;
  }
 if ((p = pile))
  pile = p->link;
 else
  p = (hash_ptr) malloc(sizeof(struct hash_s));
 p->link  = ht[hash];
 p->sv    = sv;
 p->tag   = tag;
 ht[hash] = p;
 return NULL;
}

void
check_arenas()
{
 SV *sva;
 for (sva = sv_arenaroot; sva; sva = (SV *) SvANY(sva))
  {
   SV *sv = sva + 1;
   SV *svend = &sva[SvREFCNT(sva)];
   while (sv < svend)
    {
     if (SvROK(sv) && ((IV) SvANY(sv)) & 1)
      {
       warn("Odd SvANY for %p @ %p[%d]",sv,sva,(sv-sva));
       abort();
      }
     ++sv;
    }
  }
}

long int
sv_apply_to_used(p, proc,n)
void *p;
used_proc *proc;
long int n;
{
 SV *sva;
 for (sva = sv_arenaroot; sva; sva = (SV *) SvANY(sva))
  {
   SV *sv = sva + 1;
   SV *svend = &sva[SvREFCNT(sva)];

   while (sv < svend)
    {
     if (SvTYPE(sv) != SVTYPEMASK)
      {
       n = (*proc) (p, sv, n);
      }
     ++sv;
    }
  }
 return n;
}

static char old[] = "old";
static char new[] = "new";

static long 
note_sv(p,sv, n)
void *p;
SV *sv;
long int n;
{
 lookup(p,sv,old);
 return n+1;
}

long 
note_used(x)
hash_ptr **x;
{
 hash_ptr *ht;
 Newz(603, ht, MAX_HASH, hash_ptr);
 *x = ht;
 return sv_apply_to_used(ht, note_sv, 0);
}

static long 
check_sv(p, sv, hwm)
void *p;
SV *sv;
long int hwm;
{
 char *state = lookup(p,sv,new);
 if (state != old)
  {                           
   fprintf(stderr,"%s %p : ", state ? state : new, sv);
   sv_dump(sv);
  }
 return hwm+1;
}

long 
check_used(x)
hash_ptr **x;
{hash_ptr *ht = *x;
 long count = sv_apply_to_used(ht, check_sv, 0);
 long i;
 for (i = 0; i < MAX_HASH; i++)
  {hash_ptr p = ht[i];
   while (p)
    {
     hash_ptr t = p;
     p = t->link;
     if (t->tag != new)
      {
       LangDumpVec(t->tag ? t->tag : "NUL",1,&t->sv);
      }
     t->link = pile;
     pile = t;
    }
  }
 free(ht);
 *x = NULL;
 return count;
}
