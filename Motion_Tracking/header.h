#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<string.h>

#define DEBUG_MODE

#define SAMPLE_TIME		 0.05
#define G				 9.8
#define DATA_WINDOW_SIZE 50/*50x0.05 = 2.5s*/
#define	ACCEL_THRESHOLD	 0.003
#define	GYRO_THRESHOLD	 0.009 /*0.005*/	
#define SQR(x)	(x)*(x)
#define CONV_DEGREE(x) (x*180)/3.14159265358979323846 

typedef struct __sensor_data
{
    float			 time;
	float			 x_acc;
	float			 smoothx_acc;
	float			 x_acc_var;
	float			 y_acc;
	float			 smoothy_acc;
	float			 y_acc_var;
	float			 z_acc;
	float			 smoothz_acc;
	float			 z_acc_var;
	float			 pitch;
	float			 smooth_pitch;
	float			 pitch_var;
	float			 roll;
	float			 smooth_roll;
	float			 roll_var;
	float			 yaw;
	float			 smooth_yaw;
	float			 yaw_var;
	struct sensor_data *next;
	struct sensor_data *prev;
}sensor_data;

void smooth_sensordata(sensor_data* list_head);
void calculate_variance(sensor_data* list_head,int win_size);
void motion_estimation(sensor_data* list_head,int win_size);
void destroy_list(sensor_data* list_head);
