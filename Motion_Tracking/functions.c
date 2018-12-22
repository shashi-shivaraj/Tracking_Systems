#include "header.h"


void smooth_sensordata(sensor_data* list_head)
{
	sensor_data *curr = NULL;
	sensor_data *temp1 = NULL,*temp2 = NULL,
		*temp3 = NULL,*temp4 = NULL;
	int count = 0;

	curr = list_head;
	while(curr)
	{
		temp2 = curr->prev;
		temp3 = curr->next;

		count ++;
		if(curr == list_head || curr->next == NULL)
		{
			curr->smoothx_acc = curr->x_acc;
			curr->smoothy_acc = curr->y_acc;
			curr->smoothz_acc = curr->z_acc;

			curr->smooth_pitch = curr->pitch;
			curr->smooth_roll  = curr->roll;
			curr->smooth_yaw   = curr->yaw;

		}
		else if(temp2->prev == NULL ||
			temp3->next == NULL)
		{

			curr->smoothx_acc = (temp2->x_acc + curr->x_acc + temp3->x_acc)/3;
			curr->smoothy_acc = (temp2->y_acc + curr->y_acc + temp3->y_acc)/3;
			curr->smoothz_acc = (temp2->z_acc + curr->z_acc + temp3->z_acc)/3;

			curr->smooth_pitch = (temp2->pitch + curr->pitch + temp3->pitch)/3;
			curr->smooth_roll  = (temp2->roll + curr->roll + temp3->roll)/3;
			curr->smooth_yaw   = (temp2->yaw + curr->yaw + temp3->yaw)/3;
		}
		else
		{
			temp2 = curr->prev;
			temp1 = temp2->prev;
			temp3 = curr->next;
			temp4 = temp3->next;

			curr->smoothx_acc = (temp1->x_acc + temp2->x_acc + curr->x_acc + temp3->x_acc + temp4->x_acc)/5;
			curr->smoothy_acc = (temp1->y_acc + temp2->y_acc + curr->y_acc + temp3->y_acc + temp4->y_acc)/5;
			curr->smoothz_acc = (temp1->z_acc + temp2->z_acc + curr->z_acc + temp3->z_acc + temp4->z_acc)/5;

			curr->smooth_pitch = (temp1->pitch + temp2->pitch + curr->pitch + temp3->pitch + temp4->pitch)/5;
			curr->smooth_roll  = (temp1->roll + temp2->roll + curr->roll + temp3->roll + temp4->roll)/5;
			curr->smooth_yaw   = (temp1->yaw + temp2->yaw + curr->yaw + temp3->yaw + temp4->yaw)/5;
		}

		curr = curr->next;
	}
}

void calculate_variance(sensor_data* list_head,int win_size)
{
	int i=0;
	sensor_data	*head = NULL,*cur = NULL,*temp = NULL/*,*win_head = NULL*/;
	float x_acc_sum=0,y_acc_sum=0,z_acc_sum=0;
	float pitch_sum=0,roll_sum=0,yaw_sum=0;
	float x_acc_avg=0,y_acc_avg=0,z_acc_avg=0;
	float pitch_avg=0,roll_avg=0,yaw_avg=0;
	float x_acc_var=0,y_acc_var=0,z_acc_var=0;
	float pitch_var=0,roll_var=0,yaw_var=0;

	head = list_head;
	cur = head;

	while(head)
	{
		temp = head;
		cur = head;
		/*calculate the mean for the window*/
		for(i=0;i<win_size && cur;i++)
		{
			x_acc_sum = x_acc_sum + cur->smoothx_acc;
			y_acc_sum = y_acc_sum + cur->smoothy_acc;
			z_acc_sum = z_acc_sum + cur->smoothz_acc;
			pitch_sum = pitch_sum + cur->smooth_pitch;
			roll_sum  = roll_sum  + cur->smooth_roll;
			yaw_sum   = yaw_sum   + cur->smooth_yaw;

			cur = cur->next;
		}
		x_acc_avg = x_acc_sum/win_size;
		y_acc_avg = y_acc_sum/win_size;
		z_acc_avg = z_acc_sum/win_size;
		pitch_avg = pitch_sum/win_size;
		roll_avg = roll_sum/win_size;
		yaw_avg = yaw_sum/win_size;

		cur = temp;
		/*calculate the variance for the window*/
		for(i=0;i<win_size && cur;i++)
		{
			x_acc_var = x_acc_var+SQR(cur->smoothx_acc-x_acc_avg);
			y_acc_var = y_acc_var+SQR(cur->smoothy_acc-y_acc_avg);
			z_acc_var = z_acc_var+SQR(cur->smoothz_acc-z_acc_avg);
			pitch_var = pitch_var+SQR(cur->smooth_pitch-pitch_avg);
			roll_var  = roll_var+SQR(cur->smooth_roll-roll_avg);
			yaw_var   = yaw_var+SQR(cur->smooth_yaw-yaw_avg);

			cur = cur->next;

		}
		/*Store the variance calculation of 
		window data at first data in window*/
		head->x_acc_var = x_acc_var/(win_size-1);
		head->y_acc_var = y_acc_var/(win_size-1);
		head->z_acc_var = z_acc_var/(win_size-1);
		head->pitch_var = pitch_var/(win_size-1);
		head->roll_var = roll_var/(win_size-1);
		head->yaw_var = yaw_var/(win_size-1);

		x_acc_sum=0;y_acc_sum=0;z_acc_sum=0;
		pitch_sum=0;roll_sum=0;yaw_sum=0;
		x_acc_avg=0;y_acc_avg=0;z_acc_avg=0;
		pitch_avg=0;roll_avg=0;yaw_avg=0;
		x_acc_var=0;y_acc_var=0;z_acc_var=0;
		pitch_var=0;roll_var=0;yaw_var=0;

		head = cur; 
	}
}

void motion_estimation(sensor_data* list_head,int win_size)
{
	sensor_data	*head = NULL,*cur = NULL,*temp = NULL;
	int motion_detection_flag = 0;
	int i=0,count = 0;

	float  x_velocity=0,y_velocity=0,z_velocity=0;
	float  prev_x_vel=0,prev_y_vel=0,prev_z_vel=0;
	float  avg_x_vel=0,avg_y_vel=0,avg_z_vel=0;
	float total_x_dist=0,total_y_dist=0,total_z_dist=0;
	float total_pitch_rotation=0,total_roll_rotation=0,total_yaw_rotation=0;


#ifdef DEBUG_MODE
	FILE*fp = NULL;
	fp = fopen("motion_tracking_result.txt","w+");
#endif /*DEBUG_MODE*/

	head = list_head;
	cur = head;

	while(head)
	{
		temp = head;
		cur = head;

		if(cur->x_acc_var > ACCEL_THRESHOLD ||
		   cur->y_acc_var > ACCEL_THRESHOLD ||
		   cur->z_acc_var > ACCEL_THRESHOLD	||
		   cur->pitch_var > GYRO_THRESHOLD  ||
		   cur->roll_var  > GYRO_THRESHOLD  ||
		   cur->yaw_var   > GYRO_THRESHOLD)
		{
			motion_detection_flag = 1;
			count ++;
		}
 
		if(motion_detection_flag)
		{
			/*calculate total linear distance and total angular rotation in the window*/
			for(i=0;i<win_size && cur;i++)
			{
				total_pitch_rotation = total_pitch_rotation + cur->smooth_pitch * SAMPLE_TIME;
				total_roll_rotation = total_roll_rotation + cur->smooth_roll * SAMPLE_TIME;
				total_yaw_rotation = total_yaw_rotation + cur->smooth_yaw * SAMPLE_TIME;

				prev_x_vel = x_velocity;
				x_velocity = x_velocity+cur->smoothx_acc * SAMPLE_TIME;
				avg_x_vel  = (x_velocity + prev_x_vel)/2;
				total_x_dist = total_x_dist + avg_x_vel*SAMPLE_TIME;

				prev_y_vel = y_velocity;
				y_velocity = y_velocity+cur->smoothy_acc * SAMPLE_TIME;
				avg_y_vel  = (y_velocity + prev_y_vel)/2;
				total_y_dist = total_y_dist + avg_y_vel*SAMPLE_TIME;
				
				prev_z_vel = z_velocity;
				z_velocity = z_velocity+cur->smoothz_acc * SAMPLE_TIME;
				avg_z_vel  = (z_velocity + prev_z_vel)/2;
				total_z_dist = total_z_dist + avg_z_vel*SAMPLE_TIME;
				
				cur = cur->next;
			}
			motion_detection_flag = 0;
			printf("MOTION Detected from time %f to time %f\n\n",
				head->time,head->time+win_size*SAMPLE_TIME);
			fprintf(fp,"MOTION Detected from time %f to time %f with:\n",
				head->time,head->time+win_size*SAMPLE_TIME);
			fprintf(fp,"Total Angular Rotation along Pitch Axis %f degree :\n",CONV_DEGREE(total_pitch_rotation));
			fprintf(fp,"Total Angular Rotation along Roll Axis %f degree:\n",CONV_DEGREE(total_roll_rotation));
			fprintf(fp,"Total Angular Rotation along Yaw Axis %f degree:\n",CONV_DEGREE(total_yaw_rotation));

			fprintf(fp,"Total Linear Distance along X Axis %f meter :\n",total_x_dist*G);
			fprintf(fp,"Total Linear Distance along Y Axis %f meter:\n",total_y_dist*G);
			fprintf(fp,"Total Linear Distance along Z Axis %f meter:\n\n",total_z_dist*G);


			total_pitch_rotation=0;total_roll_rotation=0;
			total_yaw_rotation=0;
			x_velocity=0;y_velocity=0;z_velocity=0;
			prev_x_vel=0;prev_y_vel=0;prev_z_vel=0;
			avg_x_vel=0;avg_y_vel=0;avg_z_vel=0;
		}
		else
		{
			/*traverse to the next window*/
			for(i=0;i<win_size && cur;i++)
			{
				cur = cur->next;
			}
			printf("REST Detected from time %f to time %f\n\n",
				head->time,head->time+win_size*SAMPLE_TIME);
			fprintf(fp,"REST Detected from time %f to time %f\n\n",
				head->time,head->time+win_size*SAMPLE_TIME);
			fprintf(fp,"Total Angular Rotation along Pitch Axis %f degree :\n",0);
			fprintf(fp,"Total Angular Rotation along Roll Axis %f degree:\n",CONV_DEGREE(0));
			fprintf(fp,"Total Angular Rotation along Yaw Axis %f degree:\n",CONV_DEGREE(0));

			fprintf(fp,"Total Linear Distance along X Axis %f meter :\n",0*G);
			fprintf(fp,"Total Linear Distance along Y Axis %f meter:\n",0*G);
			fprintf(fp,"Total Linear Distance along Z Axis %f meter:\n\n",0*G);
		}

		head = cur;
	}
	fclose(fp);
	fp = NULL;
}


void destroy_list(sensor_data* list_head)
{

	sensor_data *curr = NULL;

#ifdef DEBUG_MODE
	FILE*fp = NULL;
	fp = fopen("smooth_data.txt","w+");
#endif /*DEBUG_MODE*/

	fprintf(fp,"time\t\taccX\t\ts_accX\t\taccX_var\taccY\t\ts_accY\t\taccY_var\taccZ\
			   \t\ts_accZ\t\taccZ_var\tpitch\t\ts_pitch\t\tpitch_var\troll\t\ts_roll\t\troll_var\tyaw\t\t\ts_yaw\t\tyaw_var\n");

	/*Deallocate the memory*/
	curr = list_head;
	while(list_head)
	{	
		curr = list_head;
		fprintf(fp,"%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n",\
			curr->time,curr->x_acc,curr->smoothx_acc,curr->x_acc_var,\
			curr->y_acc,curr->smoothy_acc,curr->y_acc_var,\
			curr->z_acc,curr->smoothz_acc,curr->z_acc_var,\
			curr->pitch,curr->smooth_pitch,curr->pitch_var,\
			curr->roll,curr->smooth_roll,curr->roll_var,\
			curr->yaw,curr->smooth_yaw,curr->yaw_var);
		list_head = curr->next;
		free (curr);
		curr = NULL;
	}

	fclose(fp);
	fp = NULL;
}