/*
 * tixMethod.c --
 *
 *	Handle the calling of class methods.
 *
 * ToDo:
 *
 * 1) Tix_CallMethod() needs to be re-written
 *
 */
#include <tkPort.h>
#include <tk.h>
#include <tix.h>

Tcl_HashTable methodTable;

/*
 *
 * argv[1] = widget record 
 * argv[2] = method
 * argv[3+] = args
 *
 */
TIX_DEFINE_CMD(Tix_CallMethodCmd)
{
    char * context;
    char * newContext;
    char * widRec = argv[1];
    char * method = argv[2];
    int    result;

    if (argc<3) {
	return Tix_ArgcError(interp, argc, argv, 1, "w method ...");
    }
 
    if ((context = GET_RECORD(interp, widRec, "className")) == NULL) {
	Tcl_AppendResult(interp, "invalid object reference \"", widRec,
	    "\"", (char*)NULL);
	return TCL_ERROR;
    }

    newContext = Tix_FindMethod(interp, context, method);

    if (newContext) {
	result = Tix_CallMethodByContext(interp, newContext, widRec, method,
	    argc-3, argv+3);
    } else {
	Tcl_ResetResult(interp);
	Tcl_AppendResult(interp, "cannot call method \"", method,
	    "\" for context \"", context, "\".", (char*)NULL);
	result = TCL_ERROR;
    }

    return result;
}

/*
 *
 * argv[1] = widget record 
 * argv[2] = method
 * argv[3+] = args
 *
 */
TIX_DEFINE_CMD(Tix_ChainMethodCmd)
{
    char * context;
    char * superClassContext;
    char * newContext;
    char * widRec = argv[1];
    char * method = argv[2];
    int    result;

    if (argc<3) {
	return Tix_ArgcError(interp, argc, argv, 1, "w method ...");
    }

    if ((context = Tix_GetContext(interp, widRec)) == NULL) {
	return TCL_ERROR;
    }

    if (Tix_SuperClass(interp, context, &superClassContext) != TCL_OK) {
	return TCL_ERROR;
    }

    if (superClassContext == NULL) {
	Tcl_ResetResult(interp);
	Tcl_AppendResult(interp, "no superclass exists for context \"",
	    context, "\".", (char*)NULL);
	result = TCL_ERROR;
	goto done;
    }

    newContext = Tix_FindMethod(interp, superClassContext, method);

    if (newContext) {
	result = Tix_CallMethodByContext(interp, newContext, widRec,
					 method, argc-3, argv+3);
    } else {
	Tcl_ResetResult(interp);
	Tcl_AppendResult(interp, "cannot chain method \"", method,
			 "\" for context \"", context, "\".", (char*)NULL);
	result = TCL_ERROR;
	goto done;
    }

  done:
    return result;
}

/*
 *
 * argv[1] = widget record 
 * argv[2] = class (context)
 * argv[3] = method
 *
 */
TIX_DEFINE_CMD(Tix_GetMethodCmd)
{
    char * newContext;
    char * context= argv[2];
    char * method = argv[3];
    char * cmdName;

    if (argc!=4) {
	return Tix_ArgcError(interp, argc, argv, 1, "w class method");
    }

    newContext = Tix_FindMethod(interp, context, method);

    if (newContext) {
	cmdName = Tix_GetMethodFullName(newContext, method);
	Tcl_AppendResult(interp, cmdName, NULL);
	ckfree(cmdName);
    } else {
	Tcl_SetResult(interp, "", TCL_STATIC);
    }

    return TCL_OK;
}

/*----------------------------------------------------------------------
 * Tix_FindMethod
 *
 *	Starting with class "context", find the first class that defines
 * the method. This class must be the same as the class "context" or
 * a superclass of the class "context".
 */
char * Tix_FindMethod(interp, context, method)
    Tcl_Interp * interp;
    char * context;
    char * method;
{
    char      * theContext;
    int    	isNew;
    char      * key;
    Tcl_HashEntry *hashPtr;
    static inited = 0;

    if (!inited) {
	Tcl_InitHashTable(&methodTable, TCL_STRING_KEYS);
	inited = 1;
    }

    key = Tix_GetMethodFullName(context, method);
    hashPtr = Tcl_CreateHashEntry(&methodTable, key, &isNew);
    ckfree(key);

    if (!isNew) {
	theContext = (char *) Tcl_GetHashValue(hashPtr);
    } else {
	for (theContext = context; theContext;) {
	    if (Tix_ExistMethod(interp, theContext, method)) {
		break;
	    }
	    /* Go to its superclass and see if it has the method */
	    if (Tix_SuperClass(interp, theContext, &theContext) != TCL_OK) {
		return NULL;
	    }
	    if (theContext == NULL) {
		return NULL;
	    }
	}

	if (theContext != NULL) {
	    /* theContext may point to the stack. We have to put it
	     * in some more permanent place 
	     */
	    theContext = (char*)strdup(theContext);
	}
	Tcl_SetHashValue(hashPtr, (char*)theContext);
    }

    return theContext;
}

/*----------------------------------------------------------------------
 * Tix_CallMethod
 *
 *	Starting with class "context", find the first class that defines
 * the method. Call this method.
 */
int Tix_CallMethod(interp, context, widRec, method, argc, argv)
    Tcl_Interp * interp;
    char * context;
    char * widRec;
    char * method;
    int argc;
    char ** argv;
{
    if (context =  Tix_FindMethod(interp, context, method)) {
	return Tix_CallMethodByContext(interp, context, widRec, method,
				       argc, argv);
    }
    else {
	Tcl_AppendResult(interp, "cannot call method \"", method,
		"\" for context \"", context, "\".", (char*)NULL);
	return TCL_ERROR;
    }
}

/*----------------------------------------------------------------------
 * Tix_FindConfigSpec
 *
 *	Starting with class "classRec", find the first class that defines
 * the option flag. This class must be the same as the class "classRec" or
 * a superclass of the class "classRec".
 */

/* save the old context: calling a method of a superclass will
 * change the context of a widget.
 */
char * Tix_SaveContext(interp, widRec)
    Tcl_Interp * interp;
    char * widRec;
{
    char * context;

    if ((context = GET_RECORD(interp, widRec, "context")) == NULL) {
	Tcl_AppendResult(interp, "invalid object reference \"", widRec,
	    "\"", (char*)NULL);
	return NULL;
    }
    else {
	return (char*)strdup(context);
    }
}

void Tix_RestoreContext(interp, widRec, oldContext)
    Tcl_Interp * interp;
    char * widRec;
    char * oldContext;
{
    SET_RECORD(interp, widRec, "context", oldContext);
    ckfree(oldContext);
}

void Tix_SetContext(interp, widRec, newContext)
    Tcl_Interp * interp;
    char * widRec;
    char * newContext;
{
    SET_RECORD(interp, widRec, "context", newContext);
}


char * Tix_GetContext(interp, widRec)
    Tcl_Interp * interp;
    char * widRec;
{
    char * context;

    if ((context = GET_RECORD(interp, widRec, "context")) == NULL) {
	Tcl_AppendResult(interp, "invalid object reference \"", widRec,
	    "\"", (char*)NULL);
	return NULL;
    } else {
	return context;
    }
}

int Tix_SuperClass(interp, class, superClass_ret)
    Tcl_Interp * interp;
    char * class;
    char ** superClass_ret;
{
    char * superclass;

    if ((superclass = GET_RECORD(interp, class, "superClass")) == NULL) {
	Tcl_AppendResult(interp, "invalid class \"", class,
	    "\"", (char*)NULL);
	return TCL_ERROR;
    }

    if (strlen(superclass) == 0) {
	*superClass_ret = (char*) NULL;
    } else {
	*superClass_ret =  superclass;
    }

    return TCL_OK;
}

char * Tix_GetMethodFullName(context, method)
    char * context;
    char * method;
{
    char * buff;
    int    max;
    int    conLen;

    conLen = strlen(context);
    max = conLen + strlen(method) + 3;
    buff = (char*)ckalloc(max * sizeof(char));

    strcpy(buff, context);
    strcpy(buff+conLen, "::");
    strcpy(buff+conLen+2, method);

    return buff;
}


int Tix_ExistMethod(interp, context, method)
    Tcl_Interp * interp;
    char * context;
    char * method;
{
    char * cmdName;
    Tcl_CmdInfo dummy;
    int exist;

    cmdName = Tix_GetMethodFullName(context, method);
    exist = Tcl_GetCommandInfo(interp, cmdName, &dummy);

    if (!exist) {
	if (Tcl_VarEval(interp, "auto_load ", cmdName, (char*)NULL)!= TCL_OK) {
	    goto done;
	}
	if (strcmp(interp->result, "1") == 0) {
	    exist = 1;
	}
    }

  done:
    ckfree(cmdName);
    Tcl_SetResult(interp, NULL, TCL_STATIC);
    return exist;
}

/* %% There is a dirty version that uses the old argv, without having to
 * malloc a new argv.
 */
int Tix_CallMethodByContext(interp, context, widRec, method, argc, argv)
    Tcl_Interp * interp;
    char * context;
    char * widRec;
    char * method;
    int    argc;
    char ** argv;
{
    char  * cmdName;
    int     i, result;
    char  * oldContext;
    char ** newArgv;

    if ((oldContext = Tix_SaveContext(interp, widRec)) == NULL) {
	return TCL_ERROR;
    }
    Tix_SetContext(interp, widRec, context);

    cmdName = Tix_GetMethodFullName(context, method);

    /* Create a new argv list */
    newArgv = (char**)ckalloc((argc+2)*sizeof(char*));
    newArgv[0] = cmdName;
    newArgv[1] = widRec;
    for (i=0; i< argc; i++) {
	newArgv[i+2] = argv[i];
    }
    result = Tix_EvalArgv(interp, argc+2, newArgv);

    Tix_RestoreContext(interp, widRec, oldContext);
    ckfree((char*)newArgv);
    ckfree(cmdName);

    return result;
}


int Tix_EvalArgv(interp, argc, argv)
    Tcl_Interp * interp;
    int argc;
    char ** argv;
{
    Tcl_CmdInfo cmdInfo;

    if (!Tcl_GetCommandInfo(interp, argv[0], &cmdInfo)) {
	char * cmdArgv[2];

	/*
	 * This comand is not defined yet -- looks like we have to auto-load it
	 */
	if (!Tcl_GetCommandInfo(interp, "auto_load", &cmdInfo)) {
	    Tcl_AppendResult(interp, "cannot execute command \"auto_load\"",
		NULL);
	    return TCL_ERROR;
	}

	cmdArgv[0] = "auto_load";
	cmdArgv[1] = argv[0];

	if ((*cmdInfo.proc)(cmdInfo.clientData, interp, 2, cmdArgv)!= TCL_OK){ 
	    return TCL_ERROR;
	}

	if (!Tcl_GetCommandInfo(interp, argv[0], &cmdInfo)) {
	    Tcl_AppendResult(interp, "cannot auto-load command \"",
		argv[0], "\"",NULL);
	    return TCL_ERROR;
	}
    }

    return (*cmdInfo.proc)(cmdInfo.clientData, interp, argc, argv);
}

char * Tix_FindPublicMethod(interp, cPtr, method)
    Tcl_Interp * interp;
    TixClassRecord * cPtr;
    char * method;
{
    int i;
    int len = strlen(method);

    for (i=0; i<cPtr->nMethods; i++) {
	if (cPtr->methods[i][0] == method[0] &&
	    strncmp(cPtr->methods[i], method, len)==0) {
	    return cPtr->methods[i];
	}
    }
    return 0;
}


