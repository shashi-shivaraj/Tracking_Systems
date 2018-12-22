
% FILE NAME     : TwoD_Constant_Velocity.m
%
% DESCRIPTION   : Code to implement Kalman filter for 2D Constant Velocity Model. 
%
% PLATFORM		: Matlab
%
% DATE	        	NAME
% 9th-Oct-2018      Shashi Shivaraju

clear; %clear all the varaibles
clc; %clear the screeen

%Read data from file
Data = dlmread("2D-UWB-data.txt");

%Initialize the matrices
time = 1; %current time instant
measure_noise1 = 0.0001; %Measurement noise
measure_noise2 = 0.001; %Measurement noise
dynamic_noise1 = 0.0001; %Dynamic nosie
dynamic_noise2 = 0.0001; %Dynamic nosie
Yt = Data';  %Sensor measurements
Filter_Output = zeros(2, length(Data(:,1))); %Filter Output
I = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1]; %Identity matrix
STrans_Mat = [1 0 time 0 ; 0 1 0 time; 0 0 1 0; 0 0 0 1]; %State transition matrix
M = [1 0 0 0 ; 0 1 0 0]; %Observation matrix
X_t1_t1 = [Data(1,1) ; Data(1,2) ; 0 ; 0]; %State matrix
R = [measure_noise1 0.00001; 0.00001 measure_noise2 ]; %CoVariance of Measurement noise
Q = [0 0 0 0; 0 0 0 0; 0 0 dynamic_noise1 0.00001; 0 0 0.00001 dynamic_noise2]; %Covariance of Dynamic noise
S_t1_t1 = [1 0.1 0.1 0.1; 0.1 1 0.1 0.1; 0.1 0.1 1 0.1; 0.1 0.1 0.1 1]; %State Covariance
K_G = zeros(4,2); %Kalman gain

%loop through the data set
while(time < length(Data(:,1) ))
    
     %Predict the next state
     X_t_t1 = STrans_Mat * X_t1_t1;
     %Predict the next state covariance 
     S_t_t1 = (STrans_Mat * S_t1_t1 * STrans_Mat') + Q;  
     %Calculate the Kalman Gain
     K_G = (S_t_t1 * M') / ( M * S_t_t1 * M' + R ); % (S_t_t1 * M') * inv( M * S_t_t1 * M' + R)
     
     %Update the state
     X_t_t = X_t_t1 + (K_G * (Yt(:,time) - (M * X_t_t1) ));
     %Update state covariance
     S_t_t = (I - (K_G * M) ) * S_t_t1 ;
     
     %Store the filter output for plotting
     Filter_Output(1,time) = X_t_t(1,1);
     Filter_Output(2,time) = X_t_t(2,1);

	 %loop (now t becomes t+1)
	 time = time + 1 ;
     X_t1_t1 = X_t_t;
     S_t1_t1 = S_t_t;
     
 end %end of while
 
%Plot the sensor data and the filter output
x = 1:length(Data(:,1)); 
figure(1)
plot(x,Data(:,1),"k.","markersize",3) ;
hold on
plot(x,Filter_Output(1,:), "k-","linewidth",1);
hold off
legend('Sensor Data','Kalman Output');
xlabel('Samples');
ylabel('x-position');
axis([0 132 150 600])


figure(2)
plot(x,Data(:,2),"k.","markersize",3) ;
hold on
plot(x,Filter_Output(2,:), "k-","linewidth",2);
hold off
legend('Sensor Data','Kalman Output');
xlabel('Samples');
ylabel('x-position');
axis([0 132 300 800])

