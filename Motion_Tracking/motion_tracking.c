#include"header.h"

int main(int argc,char*argv[])
{
	FILE* fp = NULL;                /*File pointer for file operations*/
	char header[10];				/*char pointer to read the header in the data file*/
	sensor_data *list_head = NULL,*new_data = NULL,*prev_data = NULL,*curr_data = NULL;
	float time = 0,x_acc = 0,y_acc = 0,z_acc = 0,pitch = 0,roll = 0,yaw = 0;
	int i =0,count = 0;
	
	if(argc != 2)
	{
		printf("[Usage]./exe raw_acc_gyro_data.txt\n");
		return -1;
	}

	fp = fopen(argv[1],"r");        /*open input image file provided as cmd line arg*/
	if(!fp)                         /*error handling*/
	{
		printf("fopen failed for %s\n",argv[1]);/*failure to open the input file*/
		return -1;              /*return error code*/	
	}

	for(i = 0;i<7;i++)
	{
		fscanf(fp,"%s",&header);
	}

	count = 0;
	while(0<fscanf(fp,"%f %f %f %f %f %f %f",\
		&time,&x_acc,&y_acc,&z_acc,&pitch,&roll,&yaw))/*will exit at EOF or fscanf error*/
	{

		new_data = (sensor_data*)malloc(sizeof(sensor_data));
		if(!new_data)
		{
			printf("memory allocation failed");
			return NULL;
		}
		memset(new_data,0,sizeof(sensor_data));

		count ++;
		new_data->time = time;
		new_data->x_acc = x_acc;
		new_data->y_acc = y_acc;
		new_data->z_acc = z_acc;
		new_data->pitch = pitch;
		new_data->roll  = roll;
		new_data->yaw   = yaw;

		if(!list_head)
		{
			list_head = new_data;
			list_head->prev = NULL;
		}

		if(prev_data)
		{
			prev_data->next = new_data;
			new_data->prev = prev_data;
		}

		new_data->next = NULL;
		prev_data = new_data;
	}

	smooth_sensordata(list_head);

	calculate_variance(list_head,DATA_WINDOW_SIZE);

	motion_estimation(list_head,DATA_WINDOW_SIZE);

	/*Free the memory allocated*/
	destroy_list(list_head);

	if(fp)
	{
		fclose(fp);
		fp = NULL;
	}

}
