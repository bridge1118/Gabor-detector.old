/* SUM-MAX MAPS FOR TEMPLATE MATCHING INFERENCE */
# include <stdio.h>
# include <stdlib.h>
# include "mex.h"        
# include "math.h"
# define PI 3.1415926
# define ROUND(x) (floor((x)+.5))
# define NEGMAX -1e10
# define px(x, y, lengthx, lengthy) ((x) + ((y)-1)*(lengthx) - 1) 
/* Generating integer vector */
int *int_vector(int n)
{
    int *v; 
    v = (int*) mxCalloc (n, sizeof(int));
    return v; 
}
/* Generating integer matrix */
int **int_matrix(int m, int n)
{
    int **mat; 
    int i; 
    mat = (int**) mxCalloc(m, sizeof(int*)); 
    for (i=0; i<m; i++)
        mat[i] = int_vector(n); 
    return mat; 
}
/* Free matrix space */
void free_matrix(void **mat, int m, int n)
{
        int i;
        for (i=0; i<m; i++)
              mxFree(mat[i]);
        mxFree(mat);
}

 /* variables */
int numOrient; 
int numResolution, numElement; /* number of resolutions and number of Gabors */   
double *allSizex, *allSizey;  /* sizes of images at multiple resolutions */
float **MAX1map, **SUM2map, *MAX2score;
int halfFilterSize; /* filter size = 2*halfFilterSize + 1 */ 
double **allSymbol; /* symbols of Gabors */              
int sizex, sizey; /* MAX1 maps are smaller than SUM1 maps by subsample */ 
double *selectedOrient, *selectedx, *selectedy, *selectedlambda, *selectedLogZ; /* parameters of learned active basis */     
double *allFx, *allFy; /* detected location over multiple resolutions */

/* compute SUM2 maps for image img, the size of SUM2 is the same as that of MAX1 */
void ComputeSUM2map(int resolution)
{
   int t, x, y, here, x1, y1, besto, bestx, besty; 
   double bestlambda, bestLogZ; 
   
   for (x=1; x<=sizex; x++)
      for (y=1; y<=sizey; y++)
         {  
           here = px(x, y, sizex, sizey);            
           SUM2map[resolution][here] = 0.; 
         }  
   t = 0; 
   do  
   {
     besto = ROUND(selectedOrient[t]); bestx = ROUND(selectedx[t]); besty = ROUND(selectedy[t]);  
     bestlambda = selectedlambda[t]; bestLogZ = selectedLogZ[t]; 
     for (x=1; x<=sizex; x++)
         for (y=1; y<=sizey; y++)  
          {  
              x1 = x+bestx; y1 = y+besty; 
              if ((x1>=1)&&(x1<=sizex)&&(y1>=1)&&(y1<=sizey))
                 SUM2map[resolution][px(x, y, sizex, sizey)] +=  
                   (bestlambda*MAX1map[besto*numResolution+resolution][px(x1, y1, sizex, sizey)] - bestLogZ);  
              else 
                 SUM2map[resolution][px(x, y, sizex, sizey)] -= bestLogZ; 
         }
     t++; 
     }
  while (t<numElement);   
}
/* compute the MAX2 score for each resolution */
void ComputeMAX2score(int resolution)
{
   int x, y, Fx, Fy, t, besto, bestx, besty, shift, trace[2];  
   float F, r, maxResponse; 

   F = NEGMAX; 
   for (x=1; x<=sizex; x++)
         for (y=1; y<=sizey; y++)  
          {       
             r = SUM2map[resolution][px(x, y, sizex, sizey)]; 
             if (F<r) 
             {
                 F = r; Fx = x; Fy = y; 
             }
          }  
   MAX2score[resolution] = F; allFx[resolution] = Fx; allFy[resolution] = Fy; 
} 
/* read in the input and output variables */
void mexFunction(int nlhs, mxArray *plhs[], 
                 int nrhs, const mxArray *prhs[])                
{
 int resolution, orient, c; 
 mxArray *f;  
 
 c = 0; 
 numResolution = ROUND(mxGetScalar(prhs[c++]));
 allSizex = mxGetPr(prhs[c++]);
 allSizey = mxGetPr(prhs[c++]);
 numOrient = ROUND(mxGetScalar(prhs[c++]));     
 numElement = ROUND(mxGetScalar(prhs[c++])); 
 selectedOrient = mxGetPr(prhs[c++]);              
 selectedx = mxGetPr(prhs[c++]);         
 selectedy = mxGetPr(prhs[c++]);   
 selectedlambda = mxGetPr(prhs[c++]);  
 selectedLogZ = mxGetPr(prhs[c++]);  
 MAX1map = mxCalloc(numResolution*numOrient, sizeof(float*));   
 for (resolution=0; resolution<numResolution; resolution++)
     for (orient=0; orient<numOrient; orient++)
      {  
       f = mxGetCell(prhs[c], orient*numResolution+resolution); 
       MAX1map[orient*numResolution+resolution] = mxGetPr(f);         
      }
 c++;
 SUM2map = mxCalloc(numResolution, sizeof(float*)); 
 for (resolution=0; resolution<numResolution; resolution++)
   {
     f = mxGetCell(prhs[c], resolution); 
     SUM2map[resolution] = mxGetPr(f);  
  } 
 c++; 
 MAX2score = mxGetPr(prhs[c++]);
 allFx =  mxGetPr(prhs[c++]);
 allFy =  mxGetPr(prhs[c++]);

 for (resolution=0; resolution<numResolution; resolution++)
 {
 sizex = ROUND(allSizex[resolution]); 
 sizey = ROUND(allSizey[resolution]); 
 ComputeSUM2map(resolution);   
 ComputeMAX2score(resolution);  
 }
}

     



 

                    