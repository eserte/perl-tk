/* 
 * glwCspace.c
 *
 *	Implement the Color Space widget in the TixGLW package.
 */

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <tk.h>
#include <gl.h>

#ifndef M_PI
#define M_PI 3.141592627
#endif


/* aux functions */
#define RAD(t)  ((t / 180.0) * M_PI)

static void  _rgb_to_hsv(float*, float*, float*, float,  float,  float);
static void  _hsv_to_rgb(float , float , float , float*, float*, float*);
static void  vert2f(float x, float y);
static float max3(float a1, float a2, float a3);

/* rendering */
static void DrawColorSpace(float _h, float _s, float _v);
static void cspace_render (float h, float s, float v);
static void cspace_pick   (int x, int y, float *h, float *s);
static void cspace_init   (void);

static void cblock_init();
static void cblock_render(float r, float g, float b);

/* high level -- Tk/C interface */
int  glw_CspaceRender (ClientData, Tcl_Interp *interp, int argc, char **argv);
int  glw_CspacePick   (ClientData, Tcl_Interp *interp, int argc, char **argv);
int  glw_CspaceInit   (ClientData, Tcl_Interp *interp, int argc, char **argv);
int  glw_RgbToHsv     (ClientData, Tcl_Interp *interp, int argc, char **argv);
int  glw_HsvToRgb     (ClientData, Tcl_Interp *interp, int argc, char **argv);
int  glw_CblockRender (ClientData, Tcl_Interp *interp, int argc, char **argv);
int  glw_CblockInit   (ClientData, Tcl_Interp *interp, int argc, char **argv);

/**********************************************************************
 * THE COLOR SPACE
 **********************************************************************/
int
glw_CspaceRender(ClientData clientData, Tcl_Interp *interp,
		 int argc, char **argv)
{
    float h, s, v;

    if(argc != 3+1){
	Tcl_AppendResult(interp, "wrong # args: should be ", argv[0],
			 "h s v", NULL);
	return(TCL_ERROR);
    }

    h = atof(argv[1]);
    s = atof(argv[2]);
    v = atof(argv[3]);
    cspace_render(h, s, v);
    return(TCL_OK);
}

int
glw_CspaceInit(ClientData  clientData, Tcl_Interp* interp, 
	       int argc, char **argv)
{
    cspace_init();
    return(TCL_OK);
}

/*********************************************************************
 * return the color picked on the color space
 ********************************************************************/
int
glw_CspacePick(ClientData clientData, Tcl_Interp *interp,
	       int argc, char **argv)
{
    int    x, y;
    float  h, s;
    static char result[100];

    if(argc != 1+2){
	Tcl_AppendResult(interp, "wrong # args: should be \"", argv[0],
			 "x y", (char *) NULL);
	return(TCL_ERROR);
    }

    x = atoi(argv[1]);
    y = atoi(argv[2]);
    cspace_pick(x, y,  &h, &s);

    sprintf(result, "%f %f", h, s);
    interp->result = result;

    return TCL_OK;
}


/***********************************************************************
 *
 * LOW LEVEL RENDERING
 *
 ***********************************************************************/
#define RADIUS 1
#define RSTEP  0.2
#define TSTEP  12

static void cspace_init()
{
#if 0
    doublebuffer();
    RGBmode();
#endif
    ortho(-1,1,-1,1,-200,400);
}

static void cspace_pick(int x, int y, float *h, float *s)
{
    long width, height;
    float fx, fy, theta, arc;
    getsize(&width,&height);

    fx    = (float)( x - width/2)  / (float)(width / 2 );
    fy    = (float)( y - height/2) / (float)(height / 2);
    theta = atan2f(-fy,fx);
    arc   = sqrt(fx*fx + fy*fy);

    *h = theta / (2*M_PI);
    *s = arc;
    if (*h < 1) *h+=1;
    if (*h > 1) *h-=1;
    if (*s > 1) *s=1;
}

static void cspace_render(float h, float s, float v)
{
    reshapeviewport();
    ortho(-1.05, 1.05, -1.05, 1.05, -200, 400);
    cpack(0x404040);
    clear();
    DrawColorSpace(h,s,v);
    swapbuffers(); 
}

static void
DrawColorSpace(float _h, float _s, float _v)
{
    float v = _v;
    float h,s;
    float rgb[3];
    float r;
    float t;
    float x,y;

    shademodel(GOURAUD);
    subpixel(1);
    blendfunction(BF_SA, BF_MSA);
    for (r=RADIUS; r>RSTEP; r-=RSTEP) {
	bgnqstrip();
	for (t=0; t<=360; t+=TSTEP) {

	    /*
	     * Outer color and pixel
	     */
	    h = (float)(t) / 360.0;
            s = (float)(r) / RADIUS; 
	    _hsv_to_rgb(h,s,v, &rgb[0], &rgb[1], &rgb[2]);
	    c3f(rgb);
	    x = r * cos(RAD(t));
	    y = r * sin(RAD(t));
	    vert2f(x,y);

	    /*
	     * Inner color and pixel
	     */
            s = (float)(r-RSTEP) / RADIUS; 
	    _hsv_to_rgb(h,s,v, &rgb[0], &rgb[1], &rgb[2]);
	    c3f(rgb);
	    x = (r-RSTEP) * cos(RAD(t));
	    y = (r-RSTEP) * sin(RAD(t));
	    vert2f(x,y);
	}
	endqstrip();
    }

    t = _h * 360.0;
    r = _s * RADIUS; 

    x = r * cos(RAD(t));
    y = r * sin(RAD(t));

    /* draw a black rectangular selected point */
    RGBcolor(0,0,0);
#if 0
    bgnline();
    vert2f(x-0.1, y-0.1);
    vert2f(x+0.1, y-0.1);
    vert2f(x+0.1, y+0.1);
    vert2f(x-0.1, y+0.1);
    vert2f(x-0.1, y-0.1);
    endline();
#else
    circ(x, y, 0.06);
#endif
}

/***********************************************************************
 *                   The color block
 ***********************************************************************/
int
glw_CblockRender(ClientData clientData, Tcl_Interp *interp,
		 int argc, char **argv)
{
    float r, g, b;

    if(argc != 1+3){
	Tcl_AppendResult(interp, "wrong # args: should be \"", argv[0],
			 "r g b width height", NULL);
	return(TCL_ERROR);
    }

    r = atof(argv[1]);
    g = atof(argv[2]);
    b = atof(argv[3]);

    cblock_render(r, g, b);
    return(TCL_OK);
}

int
glw_CblockInit(ClientData clientData, Tcl_Interp *interp,
	       int argc, char **argv)
{
    cblock_init();
    return(TCL_OK);
}

static void cblock_init()
{
#if 0
    RGBmode();
#endif
    ortho2(-1,1,-1,1);
}

static void cblock_render(float r, float g, float b)
{
    long width, height;
    float rgb[3];

    rgb[0] = r;
    rgb[1] = g;
    rgb[2] = b;

    reshapeviewport();
    c3f(rgb);
    clear();
}

/**********************************************************************
 * Here are two routines that converts between rgb and hsv. I tried
 * to implemente it in TCL but it somehow failed me.
 **********************************************************************/
int
glw_HsvToRgb(ClientData clientData, Tcl_Interp *interp,
	     int argc, char **argv)
{
    float h, s, v, r, g, b;
    char tmp[100];
    if(argc != 4){
	Tcl_AppendResult(interp, "wrong # args: should be \"", argv[0],
			 "h s v", NULL);
	return(TCL_ERROR);
    }

    h = atof(argv[1]);
    s = atof(argv[2]);
    v = atof(argv[3]);
    r,g,b;

    _hsv_to_rgb(h,s,v, &r, &g, &b);
    sprintf(tmp, "%f %f %f", r, g, b);
    Tcl_AppendResult(interp,tmp, NULL);

    return(TCL_OK);
}

int
glw_RgbToHsv(ClientData clientData, Tcl_Interp *interp,
	     int argc, char **argv)
{
    float h, s, v, r, g, b;
    char tmp[100];
    if(argc != 4){
	Tcl_AppendResult(interp, "wrong # args: should be \"", argv[0],
			 "r g b", NULL);
	return(TCL_ERROR);
    }

    r = atof(argv[1]);
    g = atof(argv[2]);
    b = atof(argv[3]);
    h,s,v;

    _rgb_to_hsv(&h,&s,&v, r, g, b);
    sprintf(tmp, "%f %f %f", h, s, v);
    Tcl_AppendResult(interp,tmp, NULL);

    return(TCL_OK);
}

/***********************************************************************
 *
 *                           Aux functions
 *
 **********************************************************************/
#define ZERO 0.00000001

static void
vert2f(float x, float y)
{
    float v[2];
    v[0] = x; v[1] = y;
    v2f(v);
}


static float
max3(float a1, float a2, float a3)
{
    if (a1 > a2) {
	a2 = a1;
    }
    if (a2 > a3) {
        return a2;
    } else {
        return a3;
    }
}

static 
float min3(float a1, float a2, float a3)
{
    if (a1 < a2) {
	a2 = a1;
    }
    if (a2 < a3) {
        return a2;
    } else {
        return a3;
    }
}

static void 
_hsv_to_rgb(float h, float s, float v, float *r,float *g, float *b)
{
    int i;
    float f,p,q,t;

    if (s <= ZERO) {
	*r = v;
	*g = v;
	*b = v;
    } else {
	if (h == 1.0) h = 0;
	h *= 6.0;
        i = (int)h;
	f = h - floorf(h);
	p = v * (1.0-s);
	q = v * (1.0-(s*f));
	t = v * (1.0-s*(1-f));

	switch (i) {
	  case 0 :	
	    *r = v;
	    *g = t;
	    *b = p;
	    break;
	  case 1 :
	    *r = q;
	    *g = v;
	    *b = p;
	    break;
	  case 2 :	
	    *r = p;
	    *g = v;
	    *b = t;
	    break;
	  case 3 :	
	    *r = p;
	    *g = q;
	    *b = v;
	    break;
	  case 4 :	
	    *r = t;
	    *g = p;
	    *b = v;
	    break;
	  case 5 :	
	    *r = v;
	    *g = p;
	    *b = q;
	}
    }
}

static void 
_rgb_to_hsv(float *h, float *s, float *v, float r, float g, float b)
{
    float delta;
    float max = max3(r,g,b);
    float min = min3(r,g,b);
    *v = max;

    if (max >= ZERO) {
        *s = (max-min)/max;
    } else {
        *s = 0;
    }

    if (*s <= ZERO) {
	*h = 0; 			/* *h = UNDEFINED; */
    } else {
	delta = max - min;
	if (r == max) {
	    *h = (g - b) / delta;
        }
	else if (g == max) {
	    *h = 2 + (b - r) / delta;
        } else {
	    *h = 4 + (r - g) / delta;
        }
	    /* convert to [0..1] */	
        *h /= 6.0;
	if (*h<0.0) {
	    *h += 1.0;
	}
    }
}
