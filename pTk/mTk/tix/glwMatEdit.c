#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <tk.h>
#include <gl.h>

#ifndef M_PI
#define M_PI 3.141592627
#endif


int glw_MatRender(ClientData, Tcl_Interp *interp, int argc, char **argv);
int glw_MatInit  (ClientData, Tcl_Interp *interp, int argc, char **argv);

/***********************************************************************
 *
 *              Low level drawing/picking functions
 *
 *
 ***********************************************************************/

struct MatdStruct {
    float amb[3], dif[3], emi[3], spe[3];
    float alp, shi; 
};

/***********************************************************************
 *
 *             C L A S S    M a t E d i t o r :: D I A G R A M
 *
 ***********************************************************************/
static float lm[] = {
	AMBIENT, .1, .1, .1,
	LOCALVIEWER, 1,
	LMNULL
};

static float lt[] = {
	LCOLOR, 1, 1, 1,
	POSITION, 10, 20, 10.5, 2,
	LMNULL
};


static int materialIndex = 3;
static int lightIndex    = 3;
static int lmodelIndex   = 3;

static void 
matd_init()
{
    static int index_inited = 0;

    mmode(MVIEWING);
    translate(0,0,-4);
    ortho(-1.2, 1.2, -1.2, 1.2, -10, 10);

    if (index_inited == 0) {
	materialIndex = 3;
	lightIndex    = 3;
	lmodelIndex   = 3;

	index_inited = 0;
    }
    lmbind(MATERIAL, 0);
    lmbind(LIGHT1,   0);
    lmbind(LMODEL,   0);
}

static void
BindMaterial(struct MatdStruct *data)
{
    float defn[100], *def;
    def = defn;

    *def++ = AMBIENT;
    *def++ = data->amb[0];
    *def++ = data->amb[1];
    *def++ = data->amb[2];
    *def++ = DIFFUSE;
    *def++ = data->dif[0];
    *def++ = data->dif[1];
    *def++ = data->dif[2];
    *def++ = EMISSION;
    *def++ = data->emi[0];
    *def++ = data->emi[1];
    *def++ = data->emi[2];
    *def++ = SPECULAR;
    *def++ = data->spe[0];
    *def++ = data->spe[1];
    *def++ = data->spe[2];

    *def++ = ALPHA;
    *def++ = data->alp;
    *def++ = SHININESS;
    *def++ = data->shi;
    *def++ = LMNULL;

    lmdef(DEFMATERIAL, materialIndex, 0, defn);
    lmdef(DEFLIGHT,    lightIndex,    0, lt);
    lmdef(DEFLMODEL,   lmodelIndex,   0, lm);

    lmbind(MATERIAL, materialIndex);
    lmbind(LIGHT1,   lightIndex);
    lmbind(LMODEL,   lmodelIndex);
}

static void
DrawBBoard(void)
{
    short colors[2][3]= { 
	{0x00,0x00,0x3f},     /*white*/
	{0xbf,0xbf,0xbf}      /*black*/
    };
    int x,y;
    int v[2];

    for (x = -2;x<2;x++) {
	for(y = -2;y<2;y++) {
	    c3s(colors[ (x+y) & 1 ]);
	    bgnpolygon();
		v[0] = x;
		v[1] = y;
	        v2i((const long*)v);

		v[0] = x;
		v[1] = y+1;
	        v2i((const long*)v);

		v[0] = x+1;
		v[1] = y+1;
	        v2i((const long*)v);

		v[0] = x+1;
		v[1] = y;
	        v2i((const long*)v);
             endpolygon();
	}
    }
}


static void
DrawSphere()
{
    const TSTEP = 20;
    const PSTEP = 20;
    double theta, dtheta, phi, dphi;
    double x0, x1, y0, y1, z0, z1;
    float n[3], v[3];
    int i, j;

    theta, dtheta = 2*M_PI/TSTEP;
    phi, dphi = M_PI/(PSTEP*2);

    subpixel(TRUE);
    pntsmooth(SMP_ON);
    backface(FALSE);
    z1 = -1;
    for(i = -PSTEP, phi = -M_PI/2; i <PSTEP; i++, phi+=dphi) { 
	bgnqstrip();
	z0 = z1;
        z1 = sin(phi+dphi);
	for (j = 0, theta = 0;  j <= TSTEP;  j++, theta += dtheta)  {
		if (j == TSTEP)  theta = 0;
		x0 = cos(theta)*cos(phi);
		y0 = sin(theta)*cos(phi);
		x1 = cos(theta)*cos(phi+dphi);
		y1 = sin(theta)*cos(phi+dphi);
		v[0] = x1;  v[1] = y1;  v[2] = z1;
		n3f(v);
		v3f(v);
		v[0] = x0;  v[1] = y0;  v[2] = z0;
		n3f(v);
		v3f(v);
	    }
	endqstrip();
    }
}



static void
matd_render(struct MatdStruct *data)
{
    reshapeviewport();

    BindMaterial(data);
    czclear(0x404040, getgdesc(GD_ZMAX));

    DrawBBoard();
    DrawSphere();

    swapbuffers(); 
    gflush();
}


/***********************************************************************
 *
 *
 *
 *             High level Tk/C++ Interface
 *
 *
 ***********************************************************************/

int
glw_MatRender(ClientData clientData, Tcl_Interp *interp,
	      int argc, char **argv)
{
    struct MatdStruct data;

    if(argc != 15){
	Tcl_AppendResult(interp, "wrong # args: should be \"", argv[0],
			 "amb[3] dif[3] emi[3] spe[3] alp, shi", NULL);
	return(TCL_ERROR);
    }

    data.amb[0] = atof(argv[1]);
    data.amb[1] = atof(argv[2]);
    data.amb[2] = atof(argv[3]);
    data.dif[0] = atof(argv[4]);
    data.dif[1] = atof(argv[5]);
    data.dif[2] = atof(argv[6]);
    data.emi[0] = atof(argv[7]);
    data.emi[1] = atof(argv[8]);
    data.emi[2] = atof(argv[9]);
    data.spe[0] = atof(argv[10]);
    data.spe[1] = atof(argv[11]);
    data.spe[2] = atof(argv[12]);
    data.alp    = atof(argv[13]);
    data.shi    = atof(argv[14]);

    matd_render(&data);

    return(TCL_OK);
}

int
glw_MatInit(ClientData clientData, Tcl_Interp *interp,
	    int argc, char **argv)
{
    matd_init();
    return(TCL_OK);
}
