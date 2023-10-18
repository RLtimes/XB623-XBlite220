/*
 Program      : sphere2.cpp
 Date         : 4.23.1995
 Author       : Hans Kopp
 EMail        : hskopp@cip.informatik.uni-erlangen.de
 Description  : This Programm draws a textured, diffuse shaded,
  specular shaded or bumpmapped sphere, that can be
  rotated interactively around an arbitrary axis
 Compiler     : Watcom C++ 10.0 / Turbo C++ 2.0
 Command Line : wcl386 /l=dos4g sphere2.cpp (Watcom + extender)
 Notes        : to compile it with Turbo C++, use the 'large'-
  memory-model
*/

#include <conio.h>
#include <math.h>
#ifdef __WATCOMC__
#include <i86.h>
#else
#include <dos.h>
#endif
#include <stdlib.h>
#include <iostream.h>

 /* Size of the Texture and the Lookuptable
    (Only Powers of 2 below or equal to 256 are allowed,
     for Turbo C++ below or equal to 128) */
const int SIZEOFTEX = 128;

 /* Properties of the Video-Screen */ 
const int WIDTHOFSCREEN = 320;
const int HEIGHTOFSCREEN = 200;
const double ASPECT_RATIO = 1.15;
 /* Pointer to the Start of the Video-Memory 
    (The Video-Memory must be linear with 256 Colors, 
    so that the Pixel (x,y) can be accessed by
    SCREEN[x+y*WIDTHOFSCREEN])
 */
#ifdef __WATCOMC__
unsigned char *SCREEN = (unsigned char*)(0xa0000);
#else
unsigned char *SCREEN = (unsigned char*)(0xa0000000);
#endif


#ifndef M_PI
#define M_PI  3.14159265
#endif

#define EPSILON .0000001


 /* 2D-Lookuptable to change the Coordinate-System */
unsigned short *LOOKUPTABLE;

unsigned short *BUMPMAP;

unsigned char *TEXTURE;

 /* Another 1D-Lookup-table (see below) */
unsigned int *SCR_TO_SPHERE;



/* Function sphere_to_kart
   This funktion converts the (integer-) spherical coordinates (alpha,beta)
   into kartesian koordiantes (x,y,z) on the unit-sphere
   The polar axis of the SCS is the y-axis 
*/
void sphere_to_kart(int alpha,int beta ,double *x,double *y,double *z)
{
 /* convert to double */
 double alpha1 = (double)alpha * M_PI*2/SIZEOFTEX;
 double beta1 = (double)(beta - SIZEOFTEX/2) * M_PI/SIZEOFTEX;
 /* convert to kartesian coordinates */
 *x = cos(alpha1) * cos(beta1);
 *y = sin(beta1);
 *z = sin(alpha1) * cos(beta1);
}

/* Function kart_to_sphere
   This function converts a point (x,y,z) on the unit-sphere into
   (integer-) spherical coordinates (alpha,beta)
   It is exactly the inverse of the function above.
*/
void kart_to_sphere(double x,double y,double z,int *alpha,int *beta)
{
 double beta1,alpha1,w;
 /* convert to spherical Coordinates */ 
 beta1 = asin(y);
 if (fabs(cos(beta1)) > EPSILON)
  {
   w = x / cos(beta1);
   if (w > 1) w = 1; if (w < -1) w = -1;
   alpha1 = acos(w);
   if (z/cos(beta1) < 0) alpha1 = M_PI*2 - alpha1;
  }
 else
  {
   alpha1 = 0;
  }
 /* convert to Integer */ 
 *alpha = alpha1 / (M_PI*2)*SIZEOFTEX;
 *beta = beta1 / M_PI*SIZEOFTEX + SIZEOFTEX/2;
 /* truncate Integers */
 if (*alpha < 0) *alpha = 0;
 if (*alpha >= SIZEOFTEX) *alpha = SIZEOFTEX-1;
 if (*beta < 0) *beta = 0;
 if (*beta >= SIZEOFTEX) *beta = SIZEOFTEX-1;
}

/* Function inittex_circles
   This Function initializes the Texture for the texture-mapped Sphere.
   (of course, you can change this Texture)
*/
void inittex_circles(unsigned char *tex)
{int x,y,x1,y1;
  for(x=0; x<SIZEOFTEX; x++)
   for(y=0; y<SIZEOFTEX+1; y++)
    {
     x1 = x - SIZEOFTEX/2;
     y1 = y - SIZEOFTEX/2;
     tex[x + y*SIZEOFTEX] = (unsigned char)sqrt(x1*x1 + y1*y1);
    }
}

/* Function inittex_diffuse
   This Function initializes the Texture for the diffuse
   shaded Sphere
*/
void inittex_diffuse(unsigned char *tex)
{
 int alpha,beta;
 double x,y,z;
 double dot;
 double lx=1,ly=0,lz=0;         /* Direction of the incident light */
 double lr;
 double nx,ny,nz;               /* Normal of a point on the Sphere */ 
 /* Normalize Direction of Light */
 lr = sqrt(lx*lx+ly*ly+lz*lz);
 lx = lx / lr;
 ly = ly / lr;
 lz = lz / lr;
 /* For all Pixels in the Intensity-Texture ... */ 
 for(alpha = 0; alpha < SIZEOFTEX; alpha++)
  for(beta = 0; beta < SIZEOFTEX; beta++)
   {
 /* convert to kartesian Coordinates */
     sphere_to_kart(alpha,beta,&nx,&ny,&nz);
 /* compute the intensity using the dot-product*/
     dot = nx*lx + ny*ly + nz*lz;
     if (dot < 0) dot = 0;
 /* set Pixel of the Texture */
     tex[alpha+beta*SIZEOFTEX] = int((dot + .2) / 1.2*255);
   }
}

       
/* Function inittex_specular
   This Function initializes the Texture for the specular shaded sphere
*/
void inittex_specular(unsigned char *tex)
{
 int alpha,beta;
 double rx,ry,rz;            /* Direction of a ray after it has been
    reflected on the spheres surface */ 
 int n=2;                    /* Number of Lightsources */
 int i;
 double lx[10],ly[10],lz[10];
 double li[10],lr;
 double exponent = 6;        /* specular Exponent */
 double intensity;
 double dot;
 /* Directions and Brightnesses of the lightsources */
 lx[0] = 12; ly[0] = 12;lz[0] = 12;li[0] = 1;
 lx[1] = -5; ly[1] = 4;lz[1] = -4;li[1] = .6;
 /* normalize Directions of the lightsources */  
 for(i=0;i<n;i++)
 {
 lr = sqrt(lx[i]*lx[i]+ly[i]*ly[i]+lz[i]*lz[i]);
 lx[i] = lx[i]/lr;
 ly[i] = ly[i]/lr;
 lz[i] = lz[i]/lr;
 }
 /* For all pixels of the Intensity-Texture ... */ 
 for(alpha = 0; alpha<SIZEOFTEX; alpha++)
  for(beta = 0; beta<SIZEOFTEX+1; beta++)
    {intensity = 0;
     sphere_to_kart(alpha,beta,&rx,&ry,&rz);
 /* Sum up the Intensities of the lightsources ... */
     for(i=0;i<n;i++)
     {
 /* compute the Intensity-Contribution of a single
    lightsource */
     dot = rx*lx[i] + ry*ly[i] + rz*lz[i]; if (dot < 0) dot =0;
     dot = pow(dot, exponent);
 /* Scale with the Brightness of the Lightsource */
     intensity += dot*li[i];
     }
 /* Store this Pixel */ 
     tex[alpha + beta*SIZEOFTEX] = int(255*(intensity+.3)/1.3);
    }
}

/* Function bump_fkt
   The gradients of this (mathematical) Function on the
   Unit-Sphere are used as normals for the Bump-Map.
   You can modify it, to achieve other effects.
*/
double bump_fkt(double x,double y,double z)
{
 return sqrt(x*x + y*y + z*z) * (1+.01*sin(x*23)) * (1+.01*cos(z*30));
}

/* Function init_bumpmap
   This function initializes the bump-map
*/
void init_bumpmap(unsigned short *bump)
{
 int alpha,beta,alpha1,beta1;
 double px,py,pz;             /* Point on the Unit-Sphere */ 
 double gx,gy,gz;             /* Gradient at this Point */ 
 double base,gr,nr; 

 /* For all Entries of the Bump-Map ... */
 for(alpha = 0; alpha < SIZEOFTEX; alpha++)
  for(beta = 0; beta < SIZEOFTEX; beta++)
    {
 /* Konvert to kartesian Coordiantes */ 
     sphere_to_kart(alpha,beta,&px,&py,&pz);
 /* Compute the gradient of the Function above at this point */
     base = bump_fkt(px,py,pz);
     gx = (bump_fkt(px+EPSILON, py, pz) - base)/EPSILON;
     gy = (bump_fkt(px, py+EPSILON, pz) - base)/EPSILON;
     gz = (bump_fkt(px, py, pz+EPSILON) - base)/EPSILON;
 /* Normalize ... */ 
     gr = sqrt(gx*gx + gy*gy + gz*gz);
     gx = gx/gr;gy = gy/gr; gz = gz/gr;
 /* store this Vector in the Bump-Map */
     kart_to_sphere(gx,gy,gz,&alpha1,&beta1);
     bump[alpha + beta*SIZEOFTEX] = alpha1 + beta1*SIZEOFTEX;
    }
}


/* Function initialize
   Description : This function initializes all the lookuptables.
   It expects the memory already to be allocated.
*/
void initialize(void)
{
 int alpha,beta;
 int x,y;
 double x_kart,y_kart,z_kart;     /* kartesian coordinates */

 /* Compute the Lookup-Table for the Switching between the
    Coordinate-Systems */
 for(x = 0; x < SIZEOFTEX; x++)
   for(y = 0; y < SIZEOFTEX + 1; y++)
    {
 /* sperical Coordinates to kartesian Coordinates */
     sphere_to_kart(x,y,&x_kart,&y_kart,&z_kart);
 /* kartesian Coordiantes to spherical Coordinates
    (compared to the line above, y_kart and z_kart
     are toggled.!!!) */
     kart_to_sphere(x_kart,z_kart,y_kart,&alpha,&beta);
     LOOKUPTABLE[x + y*SIZEOFTEX] = alpha + beta*SIZEOFTEX;
   }

 /* Compute the Lookuptable, that is used to
    convert the 2D-Screen-Coordinates to the initial
    spherical Coordinates (this is somewhat different
    from the pseudocode in the article) */
 for(x = 0; x < SIZEOFTEX; x++)
   {
    SCR_TO_SPHERE[x] =
      (int)(acos((double)(x-SIZEOFTEX/2+1) * 2/SIZEOFTEX) * SIZEOFTEX/M_PI);
    SCR_TO_SPHERE[x] = SCR_TO_SPHERE[x]%SIZEOFTEX;
    SCR_TO_SPHERE[x+SIZEOFTEX] = SCR_TO_SPHERE[x];
   }
}


/* Funktion draw_sphere
   Description : This funktion aktually draws the textured sphere
   Arguments : * phi,theta and psi : angles describing the orientation
   of the sphere
   (angle_in_degree = phi/SIZEOFTEX*360)
        * radius : radius of the sphere in pixel
  Note : the speed of this function can still be improved
  (for example the shifts in the interior loop can be removed)
*/
void draw_sphere(int phi,int theta,int psi,int radius)
 {
  int x,y;             /* current Pixel-Position */
  int xr;              /* Width of Sphere in current scanline */
  int screenpos;       /* auxiliary variable */
  int beta1,alpha1;      /* initial spherical coordinates */
  long xinc,xscaled;    /* auxiliary variables */
  int alpha_beta2,alpha_beta3;  /* spherical coordinates of the
       2. and 3. system (the 2 coordinates
       are stored in a single integer) */

 /* For all Scanlines ... */
  for(y = -radius+1;y < radius; y++)
    {
 /* compute the Width of the Sphere in this Scanline */
     xr = sqrt(radius*radius - y*y) * ASPECT_RATIO;
     if (xr==0) xr = 1;
 /* computer the first spherical Coordinate beta */
     beta1 = SCR_TO_SPHERE[(y+radius) * SIZEOFTEX/(2*radius)] * SIZEOFTEX;
     screenpos = (y+HEIGHTOFSCREEN/2) * WIDTHOFSCREEN + WIDTHOFSCREEN/2;
     xinc = (long)SIZEOFTEX * 0x10000 / (2*xr);
     xscaled = 0;
 /* For all Pixels in this Scanline ... */
     for(x = -xr;x < xr;x++)
       {
    /* compute the second spherical Coordinate alpha */
 alpha1 = SCR_TO_SPHERE[xscaled >> 16] / 2;
 xscaled += xinc;
 alpha1 = alpha1 + phi;
    /* rotate Texture in the first Coordinate-System (alpha,beta),
       switch to the next Coordinate-System and rotate there */
 alpha_beta2 = LOOKUPTABLE[beta1 + alpha1] + theta;
    /* the same Procedure again ... */
 alpha_beta3 = LOOKUPTABLE[alpha_beta2] + psi;
    /* draw the Pixel */
 SCREEN[screenpos + x] = TEXTURE[alpha_beta3];
       }
  }
}

/* Funktion draw_sphere_specular
   Description : This funktion aktually draws a specular shaded sphere
   Arguments : * phi,theta and psi : angles describing the orientation
   of the lights
   (angle_in_degree = phi/SIZEOFTEX*360)
        * radius : radius of the sphere in pixel
*/
void draw_sphere_specular(int phi,int theta,int psi,int radius)
 {
  int x,y;             /* current Pixel-Position */
  int xr;              /* Width of Sphere in current Scanline */
  int screenpos;       /* auxiliary Variable */
  int beta1,alpha1;      /* initial spherical Coordinates */
 /* other spherical Coordinates (positions and directions) */
  int alpha_beta2, alpha_beta3, alpha_beta4, alpha_beta5;
  long xinc,xscaled;    /* auxiliary variables */

 /* For all Scanlines ... */
  for(y = -radius+1; y < radius; y++)
    {
 /* compute the Width of the Sphere in this Scanline */
     xr = sqrt(radius*radius - y*y) * ASPECT_RATIO;
     if (xr==0) xr = 1;
 /* computer the first spherical Coordinate beta */
     beta1 = SCR_TO_SPHERE[(y+radius) * SIZEOFTEX/(2*radius)] * SIZEOFTEX;
     screenpos = (y+HEIGHTOFSCREEN/2) * WIDTHOFSCREEN + WIDTHOFSCREEN/2;
     xinc = (long)SIZEOFTEX * 0x10000 / (2*xr);
     xscaled = 0;
 /* For all Pixels in this Scanline ... */
     for(x = -xr;x < xr;x++)
       {
    /* compute the second spherical Coordinate alpha */
 alpha1 = SCR_TO_SPHERE[xscaled >> 16] / 2;
 xscaled += xinc;
 alpha1 = alpha1 + SIZEOFTEX/2;
   /* Go into a SCS with the z-axis as polar Axis */
 alpha_beta2 = LOOKUPTABLE[beta1 + alpha1];
   /* Multiply only the Beta-Coordinate by 2 */
 alpha_beta3 = ((alpha_beta2*2) & ((SIZEOFTEX-2)*SIZEOFTEX)) |
        (alpha_beta2&(SIZEOFTEX-1));
   /* rotate the directional Vector */ 
 alpha_beta4 = LOOKUPTABLE[alpha_beta3+phi] + theta;
 alpha_beta5 = LOOKUPTABLE[alpha_beta4] + psi;
    /* draw the Pixel */
 SCREEN[screenpos + x] = TEXTURE[alpha_beta5];
       }
  }
}


/* Funktion draw_sphere_bump
   Description : This funktion aktually draws a bump-mapped sphere
   Arguments : * phi,theta,psi,phi2,theta2 : angles describing the
   orientation of the bumpmap and the lights
   (angle_in_degree = phi/SIZEOFTEX*360)
        * radius : radius of the sphere in pixel
*/
void draw_sphere_bump(
  int phi,int theta,int psi,
  int phi2,int theta2,
  int radius)
 {
  int x,y;               /* current Pixel-Position */
  int xr;                /* Width of Sphere in current scanline */
  int screenpos;         /* auxiliary variable */
  int beta1,alpha1;      /* initial spherical coordinates */
  long xinc,xscaled;     /* auxiliary variables */
  int alpha_beta2,alpha_beta3;  /* spherical coordinates of the
     2. and 3. system (the 2 coordinates
     are stored in a single integer) */
  int normal1,normal2;
 /* For all Scanlines ... */
  for(y = -radius+1;y < radius; y++)
    {
 /* compute the Width of the Sphere in this Scanline */
     xr = sqrt(radius*radius - y*y) * ASPECT_RATIO;
     if (xr==0) xr = 1;
 /* computer the first spherical Coordinate beta */
     beta1 = SCR_TO_SPHERE[(y+radius) * SIZEOFTEX/(2*radius)] * SIZEOFTEX;
     screenpos = (y+HEIGHTOFSCREEN/2) * WIDTHOFSCREEN + WIDTHOFSCREEN/2;
     xinc = (long)SIZEOFTEX * 0x10000 / (2*xr);
     xscaled = 0;
 /* For all Pixels in this Scanline ... */
     for(x = -xr;x < xr;x++)
       {
    /* compute the second spherical Coordinate alpha */
 alpha1 = SCR_TO_SPHERE[xscaled >> 16] / 2;
 xscaled += xinc;
 alpha1 = alpha1+phi ;
    /* rotate Texture in the first Coordinate-System (alpha,beta),
       switch to the next Coordinate-System and rotate there */
 alpha_beta2 = LOOKUPTABLE[beta1 + alpha1] + theta;
    /* the same Procedure again ... */
 alpha_beta3 = LOOKUPTABLE[alpha_beta2] + psi;
    /* draw the Pixel */
 normal1 = BUMPMAP[alpha_beta3]+phi2;
 normal2 = LOOKUPTABLE[normal1]+theta2;
 SCREEN[screenpos + x] = TEXTURE[normal2];
       }
  }
}

/* Function setpalette 
   This Function sets the 'nr'-th table entry of the palette with
   the color (r,g,b). (0 <= r,g,b < 256)
*/
void setpalette(int nr,int r,int g,int b)
{
 union REGS re;
 re.h.al = 16; re.h.ah = 16;
 re.h.ch = g/4; re.h.cl = b/4; re.h.dh = r/4;
#ifdef __WATCOMC__
 re.w.bx = nr&255;
 int386(0x10,&re,&re);
#else
 re.x.bx = nr&255;
 int86(0x10,&re,&re);
#endif
}

/* Function set_grey_palette
   This Function initializes the whole palette
*/
void set_grey_palette(void)
{
 int rgb;
 for(rgb = 0;rgb<256;rgb++)
  {
   setpalette(rgb,rgb,rgb,rgb);
  }
}



void main(void)
{
 char c='*';
 char kind_of_sphere;
 int dir = 1,axis=0;
 /* this Variables describe the Orientation of the sphere */
 int phi=0,theta=0,psi=0,radius=80;
 int phi2 = 0, theta2 = 0;
 long i;
 int clearflag;
 union REGS inout;

 /* Allocate Memory */
 TEXTURE = new unsigned char[SIZEOFTEX*SIZEOFTEX+SIZEOFTEX];
 if (TEXTURE==NULL) {cout << "out of memory\n"; exit(1);}
 LOOKUPTABLE = new unsigned short[SIZEOFTEX*SIZEOFTEX+SIZEOFTEX];
 if (LOOKUPTABLE==NULL) {cout << "out of memory"; exit(1);}
 SCR_TO_SPHERE = new unsigned int[SIZEOFTEX*2];
 if (SCR_TO_SPHERE==NULL) {cout << "out of memory"; exit(1);}

 cout << "        ******************************* \n";
 cout << "        * Rotating Sphere (by H.Kopp) * \n";
 cout << "        ******************************* \n";
 cout << "Push 1,2 or 3 to choose axis of rotation \n";
 cout << "(for bumpmapping use buttons 4 and 6 too)\n";
 cout << "Push 5 to stop rotation \n";
 cout << "Push > or < to choose direction of rotation \n";
 cout << "Push + or - to change the size of the sphere \n";
 cout << "Push Space to exit \n";
 cout << "\nSelect kind of Sphere : \n";
 cout << " 1: Textured sphere \n";
 cout << " 2: Diffuse shaded sphere \n";
 cout << " 3: Specular shaded sphere \n";
 cout << " 4: Bump-mapped sphere \n";
 cout << " 5: Exit (no sphere :-( ) \n";
 cout << " Choose sphere : ";
 do
   kind_of_sphere = getch();
 while(!(kind_of_sphere >= '1' && kind_of_sphere <= '5'));

 if (kind_of_sphere == '5') exit(0);
 cout << kind_of_sphere << "\n";

 cout << "Initializing, please wait ... \n";

 switch (kind_of_sphere)
 {
  case '1':
   inittex_circles(TEXTURE); break;
  case '2':
   inittex_diffuse(TEXTURE); break;
  case '3':
   inittex_specular(TEXTURE); break;
  case '4':
   BUMPMAP = new unsigned short[SIZEOFTEX*SIZEOFTEX+SIZEOFTEX];
   if (BUMPMAP==NULL) {cout << "out of memory"; exit(1);}
   init_bumpmap(BUMPMAP);
   inittex_diffuse(TEXTURE); break;
 }
  /* Compute Lookuptables */
 initialize();

 /* Initialize Graphics-Mode 13h */
#ifdef __WATCOMC__
 inout.w.ax = 0x0013;
 int386(0x10,&inout,&inout);
#else
 inout.x.ax = 0x0013;
 int86(0x10,&inout,&inout);
#endif

if (kind_of_sphere != '1') set_grey_palette();
 /* Start Drawing Spheres */
while (c!=' ')
 {
  if (kbhit()) c=getch();
  clearflag = 0 ;
  switch (c)
  {
   case '1' : axis = 0; break;
   case '2' : axis = 1; break;
   case '3' : axis = 2; break;
   case '4' : axis = 3; break;
   case '5' : axis = 4; break;
   case '6' : axis = 5; break;
   case '<' : dir = -1; break;
   case '>' : dir = 1; break;
   case '+' :
      radius+=1; c='*';
      if (radius > HEIGHTOFSCREEN/2) radius = HEIGHTOFSCREEN/2;
      break;
   case '-' :
      radius-=1; c='*';
      clearflag = 1;
      if (radius < 10) radius = 10;
      break;
   default  :  break;
  }
  if (axis==0) phi=(phi+dir)&(SIZEOFTEX-1);
  if (axis==1) theta=(theta+dir)&(SIZEOFTEX-1);
  if (axis==2) psi=(psi+dir)&(SIZEOFTEX-1);
  if (axis==3) phi2 = (phi2+dir)&(SIZEOFTEX-1);
  if (axis==5) theta2 = (theta2+dir)&(SIZEOFTEX-1);
 /* Clear Screen only if Sphere became smaller */
  if (clearflag)
     for (i=0;i<(long)HEIGHTOFSCREEN*WIDTHOFSCREEN;i++) SCREEN[i] = 0;
 /* Draw Sphere */
  switch(kind_of_sphere)
  {
   case '1':
   case '2':
     draw_sphere(phi,theta,psi,radius); break;
   case '3':
     draw_sphere_specular(phi,theta,psi,radius); break;
   case '4':
     draw_sphere_bump(phi,theta,psi,phi2,theta2,radius); break;
  } 
}

 /* Back to Text-Mode */
#ifdef __WATCOMC__
 inout.w.ax = 0x0003;
 int386(0x10,&inout,&inout);
#else
 inout.x.ax = 0x0003;
 int86(0x10,&inout,&inout);
#endif

 /* Free Memory */
 delete(TEXTURE); delete(LOOKUPTABLE); delete(SCR_TO_SPHERE);
 if (kind_of_sphere == '4') delete(BUMPMAP);
};