%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FILE NAME     : non_linearfit.m
%
% DESCRIPTION   : To plot the graphs to fit a 
%                 function of the form y = ln(ax) to given set of data.
%
% PLATFORM		: Matlab
%
% DATE	        NAME				  REFERENCE		REASON
% 11-Sep-2018   Shashi Shivaraju      Initial code	ECE 8540 lab2
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; %clear all the varaibles
clc; %clear the screeen

%Read the data from file and store it in matrices
A = dlmread('log-data-A.txt'); 
B = dlmread('log-data-B.txt'); 
C = dlmread('log-data-C.txt');

%plot the data points and the fitted line for log-data-A.txt
YA = A(:,2);
XA = A(:,1);
a1 = 6.711359; %value of a found using root finding method
figure(1)
plot(XA, YA,'b.'); %plot original data points
grid on;
hold on;
y1 = log(a1.*XA);  %plot the fitted line
plot(XA,y1,'r','LineWidth',2);
legend('Original Data','Fitted Model')
hold off;
title('Part 1: Non Linear Fitting for log-data-A');
xlabel('x axis');
ylabel('y axis');


%plot the data points and the fitted line for log-data-B.txt
YB = B(:,2);
XB = B(:,1);
a2 = 18.996116; %value of a found using root finding method
figure(2)
plot(XB, YB,'b.'); %plot original data points
grid on;
hold on;
y2 = log(a2.*XB);  %plot the fitted line
plot(XB,y2,'r','LineWidth',2);
legend('Original Data','Fitted Model')
hold off;
title('Part 2: Non Linear Fitting for log-data-B');
xlabel('x axis');
ylabel('y axis');


%plot the data points and the fitted line for log-data-C.txt
YC = C(:,2);
XC = C(:,1);
a3 = 0.289998; %value of a found using root finding method
figure(3)
plot(XC, YC,'b.'); %plot original data points
grid on;
hold on;
y3 = log(a3.*XC);  %plot the fitted line
plot(XC,y3,'r','LineWidth',2);
legend('Original Data','Fitted Model')
hold off;
title('Part 3: Non Linear Fitting for log-data-C');
xlabel('x axis');
ylabel('y axis');
