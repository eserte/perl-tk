/*
 * "The Road goes ever on and on, down from the door where it began."
 */

#ifdef OEMVS
#pragma runopts(HEAP(1M,32K,ANYWHERE,KEEP,8K,4K))
#endif


#include "EXTERN.h"
#include "perl.h"

static void xs_init _((void));
static PerlInterpreter *my_perl;

int
main(int argc, char **argv, char **env)
{
    int exitstatus;

#ifdef PERL_GLOBAL_STRUCT
#define PERLVAR(var,type) /**/
#define PERLVARI(var,type,init) Perl_Vars.var = init;
#define PERLVARIC(var,type,init) Perl_Vars.var = init;
#include "perlvars.h"
#undef PERLVAR
#undef PERLVARI
#undef PERLVARIC
#endif

    PERL_SYS_INIT(&argc,&argv);

    perl_init_i18nl10n(1);

    if (!do_undump) {
	my_perl = perl_alloc();
	if (!my_perl)
	    exit(1);
	perl_construct( my_perl );
	perl_destruct_level = 0;
    }

    exitstatus = perl_parse( my_perl, xs_init, argc, argv, (char **) NULL );
    if (!exitstatus) {
	exitstatus = perl_run( my_perl );
    }

    perl_destruct( my_perl );
    perl_free( my_perl );

    PERL_SYS_TERM();

    exit( exitstatus );
    return exitstatus;
}

/* Register any extra external extensions */

EXTERN_C void boot_Tk__Tkperl _((CV* cv));
EXTERN_C void boot_DynaLoader _((CV* cv));

static void
xs_init(void)
{
	char *file = __FILE__;
	dXSUB_SYS;
	{
	newXS("Tk::Tkperl::bootstrap", boot_Tk__Tkperl, file);
	}
	{
	/* DynaLoader is a special case */

	newXS("DynaLoader::boot_DynaLoader", boot_DynaLoader, file);
	}
}
