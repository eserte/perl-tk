#include <tk.h>
#include <tix.h>

#ifdef PATCH_MENU
extern TIX_DECLARE_CMD(Tk_MenuCmd		);
#endif

extern TIX_DECLARE_CMD(glw_CspaceRender );
extern TIX_DECLARE_CMD(glw_CspacePick	);
extern TIX_DECLARE_CMD(glw_CspaceInit   );
extern TIX_DECLARE_CMD(glw_RgbToHsv     );
extern TIX_DECLARE_CMD(glw_HsvToRgb     );
extern TIX_DECLARE_CMD(glw_CblockRender );
extern TIX_DECLARE_CMD(glw_CblockInit   );
extern TIX_DECLARE_CMD(glw_Flush	);
extern TIX_DECLARE_CMD(glw_MatRender	);
extern TIX_DECLARE_CMD(glw_MatInit	);
extern TIX_DECLARE_CMD(Tk_MenuCmd	);



static Tix_TclCmd commands[] = {
    /*
     * Extended TK 3.6 widgets:
     */
    {"menu",		Tk_MenuCmd},

    /*
     * Tix GL Widgets
     */
    {"glwCspaceRender",	glw_CspaceRender},
    {"glwCspacePick",	glw_CspacePick},
    {"glwCspaceInit",	glw_CspaceInit},
    {"glwRgbToHsv",	glw_RgbToHsv},
    {"glwHsvToRgb",	glw_HsvToRgb},
    {"glwCblockRender",	glw_CblockRender},
    {"glwCblockInit",	glw_CblockInit},
    {"glwFlush",	glw_Flush},
    {"glwMatInit",	glw_MatInit},
    {"glwMatRender",	glw_MatRender},

    {(char*)NULL,	NULL},
};

#ifndef TIX_LIBRARY
#define TIX_LIBRARY "/usr/local/lib/tix"
#endif

#ifndef TIX_VERSION
#define TIX_VERSION	"4.0"
#endif

#ifndef TIX_PATCHLEVEL
#define TIX_PATCHLEVEL	"4.0b2"
#endif

int TixGLW_Init(interp)
    Tcl_Interp * interp;
{
    Tk_Window topLevel;
    char * appName;

    topLevel = Tk_MainWindow(interp);

    Tcl_SetVar(interp, "glw_version",    TIX_VERSION,    TCL_GLOBAL_ONLY);
    Tcl_SetVar(interp, "glw_patchlevel", TIX_PATCHLEVEL, TCL_GLOBAL_ONLY);

    /* Initialize the commands in the GLW package*/
    Tix_CreateCommands(interp, commands, (ClientData) topLevel,
	(void (*)()) NULL);

    if ((appName = Tcl_GetVar(interp, "argv0", TCL_GLOBAL_ONLY))== NULL) {
	appName = "tgwish";
    }

    /* Load the Tix library */
    if (Tix_LoadTclLibrary(interp, "TIX_LIBRARY", "tix_library", "GlwInit.tcl",
	TIX_LIBRARY, appName) != TCL_OK) {
	return TCL_ERROR;
    } else {
	return TCL_OK;
    }

    return TCL_OK;
}
