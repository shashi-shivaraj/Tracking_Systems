% FILE NAME     : EKF.m
%
% DESCRIPTION   : Code to implement extended Kalman filter for sinusoidal Model. 
%
% PLATFORM		: Matlab
%
% DATE	        	NAME
% 22nd-Oct-2018     Shashi Shivaraju

clc; %clear all the varaibles
clear; %clear the screeen

%Read data from file
Data = dlmread("sin-data.txt");
ActualPos = Data(:,1); %Actual position of data for reference
SensorData = Data(:,2); %Sensor measurement data
n = length(SensorData); %Length of data

%Initialize
t = 1; %time
measure_noise = 0.1;%Measurement noise
dynamic_noise = 0.001;%Dynamic nosie
%Jacobians
Dfda = [0 0 0; 0 1 0; 0 0 0];
Dgdx = [0 0 1];
Dgdn = [1];

Q = [0 0 0; 0 dynamic_noise 0; 0 0 0]; %CoVariance of Dynamic noise
R = [measure_noise]; %CoVariance of Measurement noise
deltaTime = 0.001; %variation in time interval

X_t1_t1 = [deltaTime;0.01; SensorData(1,1)]; %State matrix
I = eye(3) ; %Identity matrix (3x3)
S_t1_t1 = I; %State Co-variance

Filter_Output = zeros(1, n); %EKF output

%loop through the data set
while(t <  length(Data))
   
   %Predict the next state
   X_t_t1 = [ X_t1_t1(1,1) + (deltaTime*(t-1) * X_t1_t1(2,1));
                X_t1_t1(2,1);
                sin(0.1*X_t1_t1(1,1))];
   
   %Calculate jacobain for each loop 
   Dfx = [1 deltaTime*t 0; 0 1 0; 0.1*cos(0.1 * X_t_t1(1,1)) 0 0];
    
   %Predicting next state co-variance
   S_t_t1 = (Dfx * S_t1_t1 * Dfx') + (Dfda * Q * Dfda');
    
   %Measurement data
   Y_t = SensorData(t);
     
   %Calculating kalman gain
   K_t = S_t_t1 * Dgdx'/((Dgdx * S_t_t1 * Dgdx') + (Dgdn * R * Dgdn'));
    
   %Update state
   X_t_t = X_t_t1 + K_t * (Y_t - X_t_t1(3,1));
    
   %Store filter output for plotting
   Filter_Output(1,t) = X_t_t(3,1);
     
   %Update state co-variance
   S_t_t = (I - (K_t * Dgdx)) * S_t_t1;
    
   %Incriment loop counter
   t = t  + 1;
    
   %Update prev variables
   S_t1_t1 = S_t_t;
   X_t1_t1 = X_t_t;
         
end

%plot the actual,measured and filtered data
x = 1:length(Data);
figure (1)
plot(x,SensorData, "ks",'MarkerSize',4);
hold on;
plot(x, Filter_Output,'k-.','LineWidth',2.5);
plot(x, ActualPos,'k','LineWidth',1);
hold off;
xlabel("time samples");
ylabel("position");
set(gca,"FontSize",14);
legend('Sensor Data', 'EKF Output', 'Actual Position');

% %Ratios
% dynNoise = 0.001 mesNoise = 0.10
% dynNoise = 0.001 mesNoise = 0.01
% dynNoise = 0.001 mesNoise = 0.5
