/**********************************************************************
*  FILE NAME	: non_linearfitting.c
*
*  DESCRIPTION  : Program to calculate a nonlinear regression fit by 
* 				  implementing a root finding method.
*
*  PLATFORM		: Linux
*
*  DATE	               	NAME	        	  	REASON
*  8th Sep,2018         Shashi Shivaraju        ECE_8540_lab_02
*                       [C88650674]
***********************************************************************/
/*Header file inclusions*/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/*MACRO decalrations*/
#define DATA_LEN 	110 /*total number of (xi,yi) points in data file*/
#define DATA_FILE_NUM 	3 /*Total number of data file*/

#define MAX_ITERATIONS  500000

/*Main function of the program*/
int main()
{
	FILE *fp = NULL;		/*File pointer to open and read data from file*/
	int ret = 0;			/*Variable to check return value*/
	int count = 0,i = 0,j = 0;			/*variable for loop*/
	double an = 0,an1 = 0,fan = 0,fpan1 = 0; /*variable for calculations*/
	double x_data[DATA_LEN] = {0};	/*Array to store the x coordinates*/
	double y_data[DATA_LEN] = {0};   /*Array to store the y coordinates*/
	double initial_guess[DATA_FILE_NUM] = {6,15,0.2}; /*Initial guess value of 'a'*/
	/*file name of the data file*/
	char* filenames[DATA_FILE_NUM] = {"log-data-A.txt","log-data-B.txt","log-data-C.txt"}; 
	
	/*Calculate the unknown 'a' in the model y = ln(ax) for the three data files*/
	for(count = 0;count < DATA_FILE_NUM;count++)
	{
		fp = fopen(filenames[count],"r"); /*open the data for reading*/
		if(!fp)
		{
			printf("fopen failed for %s",filenames[count]);
			break;
		}
		
		printf("Current file : %s\n",filenames[count]);
		
		/*read the data from the file*/
		for(i = 0;i < DATA_LEN;i++)
		{
			fscanf(fp,"%lf %lf",&x_data[i],&y_data[i]);
			//printf("%lf %lf\n",x_data[i],y_data[i]);
		}
		
		an = initial_guess[count];/*initial guess near to true value*/
		for(i = 0;i < MAX_ITERATIONS;i++) /*iterate until zero crossing is determined*/
		{
			fan = 0;
			fpan1 = 0;
			
			for(j = 0;j < DATA_LEN;j++)
			{
			   fan = fan + (y_data[j] - log(an*x_data[j]))/an;
			   fpan1 = fpan1 +(log(an*x_data[j])-y_data[j]-1)/(an*an);
			}
			
			an1 = an - (fan/fpan1);
			
			printf("iteration = %d an = %lf an1=%lf\n",i,an,an1);
			if(fabs(an1 -an) < 0.0000001)
			{
				break; /*value found*/
			}
			
			an = an1;
		}
		
		/*close the file*/	
		if(fp)
		{
			fclose(fp);
		}
		fp = NULL;
	} 
	
	return 0;
}
