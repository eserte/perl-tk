/*
 *
 * Todo:
 * (1) 	Problems: now a class shares some configspecs with the parent class.
 *    	If an option is declared as -static in the child class but not
 *	in the parent class, the parent class will still see this
 *	option as static.
 *
 * (2)	Modify ParseClassOptions so that it can ignore all # commented
 *	newlines. This means a departure from TCL's normal parsing, but I
 *	think the result is more desirable.
 */

#include <tkPort.h>
#include <tk.h>
#include <tix.h>

typedef struct {
    char * alias;
    char * ClassName;
    char * configSpec;
    char * def;
    char * flag;
    char * forceCall;
    char * method;
    char * readOnly;
    char * isStatic;
    char * superClass;

    int     optArgc;
    char ** optArgv;
} ClassParseStruct;

static TixConfigSpec *	CopySpec _ANSI_ARGS_((TixConfigSpec *spec));
static Tcl_CmdInfo *	GetVerifyCmd  _ANSI_ARGS_((
			    Tcl_Interp *interp, char * name));
static TixConfigSpec *	InitAlias _ANSI_ARGS_((Tcl_Interp *interp,
			    TixClassRecord * cPtr, char *s));
static int		InitHashEntries _ANSI_ARGS_((
			    Tcl_Interp *interp,TixClassRecord * cPtr));
static void		InitHashTables _ANSI_ARGS_((void));
static TixConfigSpec *	InitSpec _ANSI_ARGS_((Tcl_Interp * interp,
			    char * s, int isWidget));
static int 		ParseClassOptions _ANSI_ARGS_((
			    Tcl_Interp * interp, char * opts,
			    ClassParseStruct * rec));
static int		ParseOptions _ANSI_ARGS_((
			    Tcl_Interp * interp,TixClassRecord * cPtr,
			    char *widRec, int argc, char** argv));
static int 		SetupAlias _ANSI_ARGS_((Tcl_Interp *interp,
			    TixClassRecord * cPtr, char *s));
static int		SetupAttribute _ANSI_ARGS_((Tcl_Interp *interp,
			    TixClassRecord * cPtr, char *s,
			    int which));
static int 		SetupMethod _ANSI_ARGS_((Tcl_Interp *interp,
			    TixClassRecord * cPtr, char *s));
static int 		SetupDefault _ANSI_ARGS_((Tcl_Interp *interp,
			    TixClassRecord * cPtr, char *s));
static int 		SetupSpec _ANSI_ARGS_((Tcl_Interp *interp,
			    TixClassRecord * cPtr, char *s,
			    int isWidget));
static TixClassRecord * Tix_CreateClassRecord _ANSI_ARGS_((
			    Tcl_Interp *interp, char * classRec,
			    Tk_Window mainWindow));

Tcl_HashTable classTable;
Tcl_HashTable specTable;

TixClassRecord * Tix_GetClassByName(interp, classRec)
    Tcl_Interp * interp;
    char * classRec;
{
    Tcl_HashEntry *hashPtr;
    int    	isNew;

    hashPtr = Tcl_CreateHashEntry(&classTable, classRec, &isNew);
    if (!isNew) {
	return (TixClassRecord *)Tcl_GetHashValue(hashPtr);
    }
    else {
	Tcl_SetHashValue(hashPtr, (char*)NULL);
	return NULL;
    }
}


TixClassRecord * Tix_CreateClassByName(interp, classRec)
    Tcl_Interp * interp;
    char * classRec;
{
    if (Tcl_VarEval(interp, classRec, "::AutoLoad", (char*)NULL) == TCL_ERROR){
	return NULL;
    } else {
	return Tix_GetClassByName(interp, classRec);
    }
}

TIX_DECLARE_CMD(Tix_CreateWidgetCmd);
TIX_DECLARE_CMD(Tix_CreateInstanceCmd);
TIX_DECLARE_CMD(Tix_InstanceCmd);

/*----------------------------------------------------------------------
 * Tix_ClassCmd
 *
 * 	Create a class record for a Tix class.
 *
 * argv[0] = "tixClass" or "tixWidgetClass"
 * argv[1] = class
 * argv[2] = arglist
 */
TIX_DEFINE_CMD(Tix_ClassCmd)
{
    int	isWidget, i, code, flag;
    ClassParseStruct rec;
    TixClassRecord * cPtr, * scPtr;
    char * classRec = argv[1];
    static int inited = 0;

    if (!inited) {
	InitHashTables();
	inited = 1;
    }

    if (strcmp(argv[0], "tixClass")==0) {
	isWidget = 0;
    } else {
	isWidget = 1;
    }

    if (argc != 3) {
	return Tix_ArgcError(interp, argc, argv, 1, "className {...}");
    }

    if (ParseClassOptions(interp, argv[2], &rec) != TCL_OK) {
	code = TCL_ERROR;
	goto done;
    }

    cPtr = Tix_CreateClassRecord(interp, classRec, (Tk_Window)clientData);

    /* (1) Set up the basic stuff */

    cPtr->className = (char*)strdup(classRec);
    cPtr->ClassName = (char*)strdup(rec.ClassName);
    cPtr->isWidget  = isWidget;

    /* (2) Set up the superclass */

    if (!rec.superClass || strlen(rec.superClass) == 0) {
	scPtr = NULL;
    }
    else {
	/* Create the superclass's record if it does not exist yet */
	if ((scPtr = Tix_GetClassByName(interp, rec.superClass)) == NULL) {
#ifdef TIX_DEBUG
	    if (getenv("TIX_ET_DEBUG")) {
		fprintf(stderr, "%s loaded before the superclass %s\n",
		    cPtr->className, rec.superClass);
	    }
#endif
	    scPtr = Tix_CreateClassByName(interp, rec.superClass);
	}
    }
    cPtr->superClass = scPtr;

    /* (3) Set up the methods */
    if (SetupMethod(interp, cPtr, rec.method) != TCL_OK) {
	code = TCL_ERROR;
	goto done;
    }

    /* (4) Set up the major configspecs */
    if (SetupSpec(interp, cPtr, rec.configSpec, isWidget) != TCL_OK) {
	code = TCL_ERROR;
	goto done;
    }

    /* (5) Set up the aliases */

    /* (5.1)Create the alias configSpec's */
    if (rec.alias && *rec.alias) {
	if (SetupAlias(interp, cPtr, rec.alias) != TCL_OK) {
	    code = TCL_ERROR;
	    goto done;
	}
    }

    /* We are done with the class record. Now let's put the flags into
     * a hash table so then they can be retrived quickly whenever we call
     * the "$widget config" method
     */
    if (InitHashEntries(interp, cPtr)!=TCL_OK) {
	code = TCL_ERROR;
	goto done;
    }

    /* (5.2) Initialize the alias configSpec's */
    for (i=0; i<cPtr->nSpecs; i++) {
	if (cPtr->specs[i]->isAlias) {
	    cPtr->specs[i]->realPtr = 
	      Tix_FindConfigSpecByName(interp, cPtr, cPtr->specs[i]->dbName);
	} 
    }

    /* (6) Set up the attributes of the specs */
    if (rec.isStatic  && *rec.isStatic) {
	if (SetupAttribute(interp, cPtr, rec.isStatic, FLAG_STATIC)!= TCL_OK) {
	    code = TCL_ERROR;
	    goto done;
	}
    }
    if (rec.readOnly  && *rec.readOnly) {
	if (SetupAttribute(interp,cPtr,rec.readOnly, FLAG_READONLY)!=TCL_OK) {
	    code = TCL_ERROR;
	    goto done;
	}
    }
    if (rec.forceCall  && *rec.forceCall) {
	if (SetupAttribute(interp,cPtr,rec.forceCall,FLAG_FORCECALL)!=TCL_OK) {
	    code = TCL_ERROR;
	    goto done;
	}
    }

    /* (7) Record the default options */
    if (SetupDefault(interp, cPtr, rec.def) != TCL_OK) {
	code = TCL_ERROR;
	goto done;
    }

    /* Set up the TCL array variable to store some information about the
     * class. This is compatible with the old Tix and it also speeds up
     * some operations because the look-up of these variables are done
     * by hash tables.
     */
    flag = TCL_GLOBAL_ONLY;
    if (rec.superClass) {
	Tcl_SetVar2(interp, classRec, "superClass", rec.superClass, flag);
    } else {
	Tcl_SetVar2(interp, classRec, "superClass", "", flag);
    }

    Tcl_SetVar2(interp, classRec, "className",     classRec,      flag);
    Tcl_SetVar2(interp, classRec, "ClassName",     rec.ClassName, flag);
    Tcl_SetVar2(interp, classRec, "options",       rec.flag,      flag);
    Tcl_SetVar2(interp, classRec, "forceCall",     rec.forceCall, flag);
    Tcl_SetVar2(interp, classRec, "defaults",      rec.def   ,    flag);
    Tcl_SetVar2(interp, classRec, "methods",       rec.method,    flag);
    Tcl_SetVar2(interp, classRec, "staticOptions", rec.isStatic,  flag);

    /* Now create the instantiation command. */
    if (isWidget) {
	Tcl_CreateCommand(interp, cPtr->className, Tix_CreateWidgetCmd,
		(ClientData)cPtr, (void (*)()) NULL);
    } else {
	Tcl_CreateCommand(interp, cPtr->className, Tix_CreateInstanceCmd,
		(ClientData)cPtr, (void (*)()) NULL);
    }

    /* Create an "autoload" command. This is needed so that class
     * definitions can be auto-loaded properly
     */
    if (Tcl_VarEval(interp, "proc ", cPtr->className, "::AutoLoad {} {}",
	    (char *) NULL) != TCL_OK) {
	code = TCL_ERROR;
	goto done;
    }


    code = TCL_OK;

  done:
    if (rec.optArgv) {
	ckfree((char*)rec.optArgv);
    }

    return code;
}


/*----------------------------------------------------------------------
 * Tix_CreateInstanceCmd
 *
 * 	Create an instance object of a normal Tix class.
 *
 * argv[0]  = object name.
 * argv[1+] = args 
 */

TIX_DEFINE_CMD(Tix_CreateInstanceCmd)
{
    TixClassRecord * cPtr;
    char * widRec;
    int i, code = TCL_OK;
    TixConfigSpec * spec;
    char * value;

    if (argc <= 1) {
	return Tix_ArgcError(interp, argc, argv, 1, "name ?arg? ...");
    }

    cPtr = (TixClassRecord *)clientData;
    widRec = argv[1];

    Tcl_SetVar2(interp, widRec, "className", cPtr->className, TCL_GLOBAL_ONLY);
    Tcl_SetVar2(interp, widRec, "ClassName", cPtr->ClassName, TCL_GLOBAL_ONLY);
    Tcl_SetVar2(interp, widRec, "context",   cPtr->className, TCL_GLOBAL_ONLY);

    /* This is the command that access the widget */
    Tcl_CreateCommand(interp, widRec, Tix_InstanceCmd,
	(ClientData)cPtr, (void (*)()) NULL);

    /* Set up the widget record according to defaults and arguments */
    ParseOptions(interp, cPtr, widRec, argc-2, argv+2);

    /* Call the constructor method */
    if (Tix_CallMethod(interp, cPtr->className, widRec, "Constructor",
		0, 0) != TCL_OK) {
	code = TCL_ERROR;
	goto done;
    }

    /* %% todo: call the configuration methods of the forceCall flags */
    /* %% warning. configuration methods for -forcecall options must *not*
     * assume that the value in the widget record has been validated!
     *
     * todo: please explain the above in the programming guide.
     */
    for (i=0; i<cPtr->nSpecs; i++) {
	spec = cPtr->specs[i];
	if (spec->forceCall) {
	  value = Tcl_GetVar2(interp, widRec, spec->argvName,
			      TCL_GLOBAL_ONLY);
	  if (Tix_CallConfigMethod(interp, cPtr, widRec, spec, value)!=TCL_OK){
	      code = TCL_ERROR;
	      goto done;
	  }
	}
    }

    Tcl_SetResult(interp, widRec, TCL_VOLATILE);

  done:
    return code;
}

/*----------------------------------------------------------------------
 * Tix_InstanceCmd
 *
 * 	Redirect the method calls to the class methods
 *
 * argv[0]  = widget name
 * argv[1]  = method name
 * argv[2+] = arglist
 */
TIX_DEFINE_CMD(Tix_InstanceCmd)
{
    TixClassRecord * cPtr;
    char * widRec = argv[0];
    char * method = argv[1];
    char * classRec;
    char * methodName;		/* full name of the method -- method may be
				 * abbreviated */
    int len;

    cPtr = (TixClassRecord *)clientData;
    classRec = cPtr->className;
    
    if (argc <= 1) {
	return Tix_ArgcError(interp, argc, argv, 1, "option ...");
    }

    len = strlen(method);

    if ((methodName = Tix_FindPublicMethod(interp, cPtr, method)) == NULL) {
	return Tix_UnknownPublicMethodError(interp, cPtr, widRec, method);
    }

    if (Tix_CallMethod(interp, classRec, widRec, methodName,
	argc-2, argv+2) == TCL_OK) {
	return TCL_OK;
    }
    /* We will have an "unknown error" return value here, now
     * try to execute the command as a "Intrinsics" command
     *		configure, cget, subwidget or subwidgets
     */
    else if (strncmp(method, "configure", len) == 0) {
	Tcl_ResetResult(interp);

	if (argc==2) {
	    return Tix_QueryAllOptions(interp, cPtr, widRec);
	}
	else if (argc == 3) {
	    return Tix_QueryOneOption(interp, cPtr, widRec, argv[2]);
	} else {
	    return Tix_ChangeOptions(interp, cPtr, widRec, argc-2, argv+2);
	}
    }
    else if (strncmp(method, "cget", len) == 0) {
	Tcl_ResetResult(interp);

	if (argc == 3) {
	    return Tix_GetVar(interp, cPtr, widRec, argv[2]);
	} else {
	    return Tix_ArgcError(interp, argc, argv, 2, "-flag");
	}
    }
    else if (cPtr->isWidget && strncmp(method, "subwidget", len) == 0) {
	char * swName, buff[40];

	Tcl_ResetResult(interp);
	if (argc >= 3) {
	    sprintf(buff, "w:%s", argv[2]);
	    swName = Tcl_GetVar2(interp, widRec, buff, TCL_GLOBAL_ONLY);

	    if (swName) {
		if (argc == 3) {
		    Tcl_SetResult(interp, swName, TCL_VOLATILE);
		    return TCL_OK;
		} else {
		    argv[2] = swName;
		    return Tix_EvalArgv(interp, argc-2, argv+2);
		}
	    }
	    Tcl_AppendResult(interp, "unknown subwidget \"", argv[2],
		"\"", NULL);
	    return TCL_ERROR;
	} else {
	    return Tix_ArgcError(interp, argc, argv, 2, "-flag");
	}
    }
    else if (cPtr->isWidget && strncmp(method, "subwidgets", len) == 0) {
	Tcl_ResetResult(interp);

	return Tix_CallMethod(interp, classRec, widRec, "subwidgets",
	    argc-2, argv+2);
    } else {
	/* error message already append by Tix_CallMethod() */
	return TCL_ERROR;
    }
}

/*----------------------------------------------------------------------
 * Subroutines for Class definition
 *
 *
 *----------------------------------------------------------------------
 */
static int SetupMethod(interp, cPtr, s)
    Tcl_Interp * interp;
    TixClassRecord * cPtr;
    char * s;
{
    TixClassRecord * scPtr = cPtr->superClass;
    char ** listArgv;
    int listArgc, i;
    int nMethods;


    if (s && *s) {
	if (Tcl_SplitList(interp, s, &listArgc, &listArgv) != TCL_OK) {
	    return TCL_ERROR;
	}
    } else {
	listArgc = 0;
	listArgv = 0;
    }

    nMethods = listArgc;

    if (scPtr) {
	nMethods += scPtr->nMethods;
    }
    cPtr->nMethods = nMethods;
    cPtr->methods  = (char**)ckalloc(nMethods*sizeof(char*));
    /* Copy the methods of this class */
    for (i=0; i<listArgc; i++) {
	cPtr->methods[i] = (char*)strdup(listArgv[i]);
    }
    /* Copy the methods of the super class */
    for (; i<nMethods; i++) {
	cPtr->methods[i] = scPtr->methods[i-listArgc];
    }

    if (listArgv) {
	ckfree((char*)listArgv);
    }

    return TCL_OK;
}

static int SetupDefault(interp, cPtr, s)
    Tcl_Interp * interp;
    TixClassRecord * cPtr;
    char * s;
{
    char ** listArgv;
    int listArgc, i;

    if (s && *s) {
	if (Tcl_SplitList(interp, s, &listArgc, &listArgv) != TCL_OK) {
	    return TCL_ERROR;
	}
    } else {
	return TCL_OK;
    }

    for (i=0; i<listArgc; i++) {
	if (Tcl_VarEval(interp, "option add *", cPtr->ClassName,
	    listArgv[i],
	    " widgetDefault", NULL) != TCL_OK) {
	    goto error;
	}
    }

    if (listArgv) {
	ckfree((char*)listArgv);
    }
    return TCL_OK;

  error:
   if (listArgv) {
	ckfree((char*)listArgv);
    }
    return TCL_ERROR;
}

static int SetupSpec(interp, cPtr, s, isWidget)
    Tcl_Interp * interp;
    TixClassRecord * cPtr;
    char * s;
    int isWidget;
{
    TixClassRecord * scPtr = cPtr->superClass;
    char ** listArgv;
    int listArgc, i;
    TixConfigSpec * dupSpec;
    int nSpecs;
    int j;
    int nAlloc;
    int code = TCL_OK;

    if (s && *s) {
	if (Tcl_SplitList(interp, s, &listArgc, &listArgv) != TCL_OK) {
	    return TCL_ERROR;
	}
    } else {
	listArgc = 0;
	listArgv = 0;
    }

    nSpecs = listArgc;

    nAlloc = (scPtr) ? (nSpecs+scPtr->nSpecs) : (nSpecs);

    cPtr->nSpecs = nSpecs;
    cPtr->specs  = (TixConfigSpec**)ckalloc(nAlloc*sizeof(TixConfigSpec*));

    /* Initialize the specs of this class */
    for (i=0; i<listArgc; i++) {
	if ((cPtr->specs[i] = InitSpec(interp, listArgv[i], isWidget))==NULL){
	    code = TCL_ERROR;
	    goto done;
	}
    }
    /* Copy the specs of the super class */
    if (!scPtr) {
	goto done;
    }

    for (i=0; i<scPtr->nSpecs; i++) {
	/* See if we have re-defined this configspec */
	for (dupSpec = 0, j=0; j<listArgc; j++) {
	    char * pName = scPtr->specs[i]->argvName;
	    if (strcmp(cPtr->specs[j]->argvName, pName)==0) {
		dupSpec = cPtr->specs[j];
		break;
	    }
	}

	if (dupSpec) {
	    /* if we have not redefined the dbclass or dbname of
	     * this duplicated configSpec, then simply
	     * copy the parent's attributed to the new configSpec
	     *
	     * Otherwise we don't copy the parent's attributes (do nothing)
	     */
	    if ((strcmp(dupSpec->dbClass, scPtr->specs[i]->dbClass) == 0)
		&&(strcmp(dupSpec->dbName, scPtr->specs[i]->dbName) == 0)){
		dupSpec->readOnly  = scPtr->specs[i]->readOnly;
		dupSpec->isStatic  = scPtr->specs[i]->isStatic;
		dupSpec->forceCall = scPtr->specs[i]->forceCall;
	    }
	} else {
	    /* Let's copy the parent's configSpec */
	    cPtr->specs[cPtr->nSpecs] = CopySpec(scPtr->specs[i]);
	    cPtr->nSpecs ++;
	}
    }

    if (cPtr->nSpecs != nAlloc) {
	cPtr->specs = (TixConfigSpec**)
	  realloc((char*)cPtr->specs, cPtr->nSpecs*sizeof(TixConfigSpec*));
    }

  done:
    if (listArgv) {
	ckfree((char*)listArgv);
    }
    return code;
}

static int SetupAlias(interp, cPtr, s)
    Tcl_Interp * interp;
    TixClassRecord * cPtr;
    char * s;
{
    char ** listArgv;
    int listArgc, i;

    if (Tcl_SplitList(interp, s, &listArgc, &listArgv) != TCL_OK) {
	return TCL_ERROR;
    } else {
	int nAliases = listArgc;
	int nAlloc = cPtr->nSpecs + nAliases;

	cPtr->specs = (TixConfigSpec**)
	    realloc((char*)cPtr->specs, nAlloc*sizeof(TixConfigSpec*));

	/* Initialize the aliases of this class */
	for (i=cPtr->nSpecs; i<nAlloc; i++) {
	    cPtr->specs[i] = InitAlias(interp, cPtr, listArgv[i-cPtr->nSpecs]);
	    if (cPtr->specs[i] == NULL) {
		ckfree((char*)listArgv);
		return TCL_ERROR;
	    }
	}

	cPtr->nSpecs = nAlloc;
    }
    ckfree((char*)listArgv);
    return TCL_OK;
}

static int SetupAttribute(interp, cPtr, s, which)
    Tcl_Interp * interp;
    TixClassRecord * cPtr;
    char * s;
    int which;
{
    char ** listArgv;
    int listArgc, i;
    TixConfigSpec  * spec;

    if (Tcl_SplitList(interp, s, &listArgc, &listArgv) != TCL_OK) {
	return TCL_ERROR;
    } else {
	for (i=0; i<listArgc; i++) {
	    spec = Tix_FindConfigSpecByName(interp, cPtr, listArgv[i]);
	    if (spec == NULL) {
		ckfree((char*)listArgv);
		return TCL_ERROR;
	    }
	    switch(which) {
	      case FLAG_READONLY:
		spec->readOnly = 1;
		break;
	      case FLAG_STATIC:
		spec->isStatic = 1;
		break;
	      case FLAG_FORCECALL:
		spec->forceCall = 1;
		break;
	    }
	}
    }

    ckfree((char*)listArgv);
    return TCL_OK;
}

static TixClassRecord * Tix_CreateClassRecord(interp, classRec, mainWindow)
    Tcl_Interp * interp;
    char * classRec;
    Tk_Window mainWindow;
{
    Tcl_HashEntry *hashPtr;
    int    	isNew;
    TixClassRecord * cPtr;

    cPtr = (TixClassRecord *)ckalloc(sizeof(TixClassRecord));
    cPtr->superClass = NULL;
    cPtr->isWidget   = 0;
    cPtr->className  = "";
    cPtr->ClassName  = "";
    cPtr->nSpecs     = 0;
    cPtr->specs      = 0;
    cPtr->nMethods   = 0;
    cPtr->methods    = 0;
    cPtr->defaults   = 0;
    cPtr->mainWindow = mainWindow;

    hashPtr = Tcl_CreateHashEntry(&classTable, classRec, &isNew);
    Tcl_SetHashValue(hashPtr, (char*)cPtr);

    return cPtr;
}

static int ParseClassOptions(interp, opts, rec)
    Tcl_Interp * interp;
    char * opts;
    ClassParseStruct * rec;
{
    int	   i;
    char * buff, *s, *p;
    int code = TCL_OK;

    rec->alias		= "";
    rec->configSpec	= "";
    rec->ClassName	= "";
    rec->flag		= "";
    rec->forceCall	= "";
    rec->method		= "";
    rec->def		= "";
    rec->readOnly	= "";
    rec->isStatic	= "";
    rec->superClass	= "";

    /* Get rid of the comments */
    buff = ckalloc((strlen(opts)+1) * sizeof(char));
    for (s=opts,p=buff; *s;) {
	/* Skip starting spaces */
	while (isspace(*s)) {
	    s++;
	}
	if (*s == '#') {
	    while (*s && *s != '\n') {
		s++;
	    }
	    if (*s) {
		s++;
	    }
	    continue;
	}
	while (*s && *s != '\n') {
	    *p++ = *s++;
	}
	if (*s) {
	    *p++ = *s++;
	}
    }
    *p = '\0';

    if (Tcl_SplitList(interp, buff, &rec->optArgc, &rec->optArgv) != TCL_OK) {
	code = TCL_ERROR;
	goto done;
    }

    if ((rec->optArgc %2) == 1) {
	Tcl_AppendResult(interp, "value for \"", rec->optArgv[rec->optArgc-1],
	    "\" missing", (char*)NULL);
	code = TCL_ERROR;
	goto done;
    }
    for (i=0; i<rec->optArgc; i+=2) {
	if (strcmp(rec->optArgv[i], "-alias") == 0) {
	    rec->alias = rec->optArgv[i+1];
	}
	else if (strcmp(rec->optArgv[i], "-configspec") == 0) {
	    rec->configSpec = rec->optArgv[i+1];
	}
	else if (strcmp(rec->optArgv[i], "-classname") == 0) {
	    rec->ClassName = rec->optArgv[i+1];
	}
	else if (strcmp(rec->optArgv[i], "-default") == 0) {
	    rec->def = rec->optArgv[i+1];
	}
	else if (strcmp(rec->optArgv[i], "-flag") == 0) {
	    rec->flag = rec->optArgv[i+1];
	}
	else if (strcmp(rec->optArgv[i], "-forcecall") == 0) {
	    rec->forceCall = rec->optArgv[i+1];
	}
	else if (strcmp(rec->optArgv[i], "-method") == 0) {
	    rec->method = rec->optArgv[i+1];
	}
	else if (strcmp(rec->optArgv[i], "-readonly") == 0) {
	    rec->readOnly = rec->optArgv[i+1];
	}
	else if (strcmp(rec->optArgv[i], "-static") == 0) {
	    rec->isStatic = rec->optArgv[i+1];
	}
	else if (strcmp(rec->optArgv[i], "-superclass") == 0) {
	    rec->superClass = rec->optArgv[i+1];
	}
	else {
	    Tcl_AppendResult(interp, "unknown rec->option \"", rec->optArgv[i],
		"\"", (char*)NULL);
	    code = TCL_ERROR;
	    goto done;
	}
    }

  done:
    free((char*)buff);
    return code;
}

static TixConfigSpec * InitSpec(interp, s, isWidget)
    Tcl_Interp * interp;
    char * s;
    int isWidget;
{
    char ** listArgv = NULL;
    int listArgc;
    TixConfigSpec * sPtr = NULL;
    char * specList = NULL;
    char * cmdArgv[2];
    /* KLUDGE
     *
     * The following call will try to substitute the contents inside
     * the string "s". Since s was originally in curly brackets,
     * setting s to {-bitmap bitmap Bitmap [tix getbitmap mybitmap]}
     * will cause the defValue to be "[tix" because the nested
     * expression is never evaluated.
     *
     * tixInt_Expand is in library/Utils.tcl. It will substitute all
     * nested evaluation inside the spec string "s".
     */
    cmdArgv[0] = "subst";
    cmdArgv[1] = s;
#if 1
    if (Tix_EvalArgv(interp, 2, cmdArgv)!= TCL_OK) {
#else
    if (Tcl_VarEval(interp, "tixInt_Expand ", s, (char*)NULL) != TCL_OK) {
#endif
	sPtr = NULL;
	goto done;
    }

    specList = strdup(interp->result);

    if (Tcl_SplitList(interp, specList, &listArgc, &listArgv)!= TCL_OK) {
	sPtr = NULL;
	goto done;
    }
    if (( isWidget && (listArgc < 4 || listArgc > 5)) ||
	(!isWidget && (listArgc < 2 || listArgc > 3))) {
	Tcl_AppendResult(interp, "Wrong number of elements in ",
	    "config spec list \"", specList, "\"", NULL);
	sPtr = NULL;
	goto done;
    }

    sPtr = (TixConfigSpec * )ckalloc(sizeof(TixConfigSpec));

    sPtr->isAlias   = 0;
    sPtr->readOnly  = 0;
    sPtr->isStatic  = 0;
    sPtr->forceCall = 0;
    sPtr->realPtr   = NULL;

    if (isWidget) {
	sPtr->argvName = (char*)strdup(listArgv[0]);
	sPtr->dbName   = (char*)strdup(listArgv[1]);
	sPtr->dbClass  = (char*)strdup(listArgv[2]);
	sPtr->defValue = (char*)strdup(listArgv[3]);
    }
    else {
	sPtr->argvName = (char*)strdup(listArgv[0]);
	sPtr->dbClass  = "";
	sPtr->dbName   = "";
	sPtr->defValue = (char*)strdup(listArgv[1]);
    }

    /* Set up the verifyCmd */
    if ((isWidget && listArgc == 5) || (!isWidget && listArgc == 3)) {
	int n;

	if (isWidget) {
	    n = 4;
	} else {
	    n = 2;
	}
#if 0
	/* don't want to use this because the verifyCmd may change ... or
	 * it may not be there yet (autoloaded later)
	 */
	if ((sPtr->verifyCmdInfo = GetVerifyCmd(interp, listArgv[n]))==NULL) {
	    goto done;
	}
#else
	sPtr->verifyCmd = strdup(listArgv[n]);
#endif
    } else {
	sPtr->verifyCmd = NULL;
    }

  done:
    if (listArgv) {
	ckfree((char *) listArgv);
    }
    if (specList) {
	ckfree(specList);
    }
    return sPtr;
}

static TixConfigSpec *InitAlias(interp, cPtr, s)
    Tcl_Interp * interp;
    TixClassRecord * cPtr;
    char * s;
{
    char ** listArgv;
    int listArgc;
    TixConfigSpec  * sPtr;

    if (Tcl_SplitList(interp, s, &listArgc, &listArgv) != TCL_OK) {
	return NULL;
    } else {
	sPtr = (TixConfigSpec*) ckalloc(sizeof(TixConfigSpec));
	sPtr->isAlias    = 1;
	sPtr->isStatic   = 0;
	sPtr->forceCall  = 0;
	sPtr->readOnly   = 0;
	sPtr->argvName   = (char*)strdup(listArgv[0]);
	sPtr->dbName     = (char*)strdup(listArgv[1]);
	sPtr->dbClass    = "";
	sPtr->defValue   = "";
	sPtr->verifyCmd  = NULL;
	sPtr->realPtr    = NULL;

	ckfree((char*)listArgv);
	return sPtr;
    }
}

static void InitHashTables()
{
    Tcl_InitHashTable(&classTable, TCL_STRING_KEYS);
    Tcl_InitHashTable(&specTable,  TCL_STRING_KEYS);
}


static int InitHashEntries(interp, cPtr)
    Tcl_Interp * interp;
    TixClassRecord *cPtr;
{
    Tcl_HashEntry * hashPtr;
    int    	    isNew;
    char	  * key;
    int		    i;
    TixConfigSpec * sPtr;

    for (i=0; i<cPtr->nSpecs; i++) {
	sPtr = cPtr->specs[i];
	key = Tix_GetConfigSpecFullName(cPtr->className, sPtr->argvName);

	hashPtr = Tcl_CreateHashEntry(&specTable, key, &isNew);
	Tcl_SetHashValue(hashPtr, (char*)sPtr);

	ckfree(key);
    }

    return TCL_OK;
}
/*----------------------------------------------------------------------
 * Subroutines for object instantiation.
 *
 *
 *----------------------------------------------------------------------
 */
static int  ParseOptions(interp, cPtr, widRec, argc, argv)
    Tcl_Interp * interp;
    TixClassRecord * cPtr;
    char *widRec;
    int argc;
    char** argv;
{
    int i;
    int flag = TCL_GLOBAL_ONLY;
    TixConfigSpec *spec;

    if ((argc %2) != 0) {
	Tcl_AppendResult(interp, "missing argument for \"", argv[argc-1],
	    "\"", NULL);
	return TCL_ERROR;
    }

    /* Set all specs by their default values */
    for (i=0; i<cPtr->nSpecs; i++) {
	spec = cPtr->specs[i];
	if (!spec->isAlias) {
	    if (Tix_ChangeOneOption(interp, cPtr, widRec, spec,
		spec->defValue, 1, 0)!=TCL_OK) {
		return TCL_ERROR;
	    }
	}
    }

    /* Set specs according to argument line values */
    for (i=0; i<argc; i+=2) {
	spec = Tix_FindConfigSpecByName(interp, cPtr, argv[i]);

	if (spec == NULL) {	/* this is an invalid flag */
	    return TCL_ERROR;
	}

	if (Tix_ChangeOneOption(interp, cPtr, widRec, spec,
		argv[i+1], 0, 1)!=TCL_OK) {
	    return TCL_ERROR;
	}
    }

    return TCL_OK;
}

static TixConfigSpec * CopySpec (sPtr)
    TixConfigSpec *sPtr;
{
    TixConfigSpec *nPtr = (TixConfigSpec *)ckalloc(sizeof(TixConfigSpec));

    *nPtr = *sPtr;

    return nPtr;
}

static Tcl_CmdInfo * GetVerifyCmd(interp, name)
    Tcl_Interp *interp;
    char * name;
{
    /* %% ToDo: to advoid malloc'ing a lot of cmdInfo structures, can
     * put things in a hash table ...
     */
    Tcl_CmdInfo *cmdInfoPtr = (Tcl_CmdInfo *)malloc(sizeof(Tcl_CmdInfo));

    if (Tcl_GetCommandInfo(interp, name, cmdInfoPtr) == 0) {
	ckfree((char*)cmdInfoPtr);
	return NULL;
    } else {
	return cmdInfoPtr;
    }
}
