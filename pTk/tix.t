#ifdef _TIX
VFUNC(void,Tix_GetScrollFractions,V_Tix_GetScrollFractions,_ANSI_ARGS_((int total,
			    int window, int first,
			    double * first_ret, double * last_ret)))
VFUNC(int,Tix_HandleSubCmds,V_Tix_HandleSubCmds,_ANSI_ARGS_((
			    Tix_CmdInfo * cmdInfo,
			    Tix_SubCmdInfo * subCmdInfo,
			    ClientData clientData, Tcl_Interp *interp,
			    int argc, Arg *args)))
VFUNC(void,Tix_LinkListAppend,V_Tix_LinkListAppend,_ANSI_ARGS_((Tix_ListInfo * infoPtr,
			    Tix_LinkList * lPtr, char * itemPtr, int flags)))
VFUNC(void,Tix_LinkListDelete,V_Tix_LinkListDelete,_ANSI_ARGS_((Tix_ListInfo * infoPtr,
			    Tix_LinkList * lPtr, Tix_ListIterator * liPtr)))
VFUNC(int,Tix_LinkListDeleteRange,V_Tix_LinkListDeleteRange,_ANSI_ARGS_((
			    Tix_ListInfo * infoPtr,
			    Tix_LinkList * lPtr, char * fromPtr,
			    char * toPtr, Tix_ListIterator * liPtr)))
VFUNC(int,Tix_LinkListFind,V_Tix_LinkListFind,_ANSI_ARGS_((
			    Tix_ListInfo * infoPtr, Tix_LinkList * lPtr,
			    char * itemPtr, Tix_ListIterator * liPtr)))
VFUNC(void,Tix_LinkListInit,V_Tix_LinkListInit,_ANSI_ARGS_((Tix_LinkList * lPtr)))
VFUNC(void,Tix_LinkListInsert,V_Tix_LinkListInsert,_ANSI_ARGS_((
			    Tix_ListInfo * infoPtr,
			    Tix_LinkList * lPtr, char * itemPtr,
			    Tix_ListIterator * liPtr)))
VFUNC(void,Tix_LinkListIteratorInit,V_Tix_LinkListIteratorInit,_ANSI_ARGS_((Tix_ListIterator *liPtr)))
VFUNC(void,Tix_LinkListNext,V_Tix_LinkListNext,_ANSI_ARGS_((Tix_ListInfo * infoPtr,
			    Tix_LinkList * lPtr, Tix_ListIterator * liPtr)))
VFUNC(void,Tix_LinkListStart,V_Tix_LinkListStart,_ANSI_ARGS_((Tix_ListInfo * infoPtr,
			    Tix_LinkList * lPtr, Tix_ListIterator * liPtr)))
#endif /* _TIX */
