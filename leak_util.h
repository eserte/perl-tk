typedef long used_proc _((void *,SV *,long));
typedef struct hash_s *hash_ptr;
extern long int sv_apply_to_used _((void *p, used_proc (*proc), long int n));
extern long int  check_used _((hash_ptr **save));
extern long int  note_used _((hash_ptr **save));
extern void Dump_vec _((char *who,int count,SV **data));

