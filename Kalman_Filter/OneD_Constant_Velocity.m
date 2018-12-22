
% FILE NAME     : OneD_Constant_Velocity.m
%
% DESCRIPTION   : Code to implement Kalman filter for 1D Constant Velocity Model. 
%
% PLATFORM		: Matlab
%
% DATE	        	NAME
% 9th-Oct-2018      Shashi Shivaraju

clear; %clear all the varaibles
clc; %clear the screeen

%Read data from file
Data = dlmread("1D-data.txt");

%Initialize the matrices
time = 1; %current time instant
measure_noise = 1; %Measurement noise
dynamic_noise = 0.000001; %Dynamic nosie
Yt = [Data' ; zeros(1, length(Data)) ]; %Sensor measurements
Filter_Output = zeros(1, length(Data)); %Filter Output
I = [1 0; 0 1]; %Identity matrix
STrans_Mat = [1 time ; 0 1]; %State Transition Matrix
M = [1 0; 0 0]; %Observation Matrix
X_t1_t1 = [0 ; 0]; %State matrix
R = [measure_noise 0.1; 0.1 0.1 ]; %CoVariance of Measurement noise
Q = [0 0 ; 0 dynamic_noise]; %CoVariance of Dynamic noise
S_t1_t1 = I; %State Covariance
K_G = [0 0; 0 0]; %Kalman Gain


%loop through the data set
while(time < length(Data))
    
     %Predict the next state
     X_t_t1 = STrans_Mat * X_t1_t1;
     %Predict the next state covariance 
     S_t_t1 = (STrans_Mat * S_t1_t1 * STrans_Mat') + Q ; 
     %Calculate the Kalman Gain
     K_G = (S_t_t1 * M') / ( M * S_t_t1 * M' + R); % (S_t_t1 * M') * inv( M * S_t_t1 * M' + R)
     
     %Update the state
     X_t_t = X_t_t1 + (K_G * (Yt(:,time) - (M * X_t_t1) ));
     %Update state covariance
     S_t_t = (I - (K_G * M) ) * S_t_t1; 
     
     %Store the filter output for plotting
     Filter_Output(time) = X_t_t(1,1); 
     
     %loop (now t becomes t+1)
     time = time + 1 ;
     X_t1_t1 = X_t_t;
     S_t1_t1 = S_t_t;
     
 end %end of while
 

%Plot the sensor data and the filter output
x = 0:length(Data)-1;
figure(1)
plot(x,Data,"k.","markersize",3) ;
hold on
plot(x, Filter_Output, "k-","Linewidth",1);
hold off
set(gca,"FontSize",14);
xlabel('Samples');
ylabel('x-position');
legend('Sensor Data','Kalman Output');
axis([0 640 -3 4]);


