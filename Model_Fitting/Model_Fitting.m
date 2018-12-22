
% FILE NAME     : Model_Fitting.m
%
% DESCRIPTION   : Code to fit a model to data 
%
% PLATFORM	: Matlab
%
% DATE	        NAME
% 29-Aug-2018   Shashi Shivaraju


clear; %clear all the varaibles
clc; %clear the screeen

%Part 1 of the lab
%data points
x1 = [5 6 7 8 9];
y1 = [1 1 2 3 5];

%declare  the matrices of the normal equation
A1 = [5 1;6 1;7 1;8 1;9 1];
b1 = [1;1;2;3;5];

X1 = (A1'*A1)\(A1'*b1);

%plot the data and the line 
figure(1);
plot(x1,y1,'k*');
hold on;
y1 = X1(1,1)*x1+X1(2,1);
plot(x1,y1);
hold off;
axis([4 10 0 6]);
set(gca,"FontSize",14);
xlabel('x-axis');
ylabel('y-axis');
legend('datapoints','linefit')

%Part 2 of the lab
%data points
x2 = [5 6 7 8 9 8];
y2 = [1 1 2 3 5 14];

%declare  the matrices of the normal equation
A2 = [5 1;6 1;7 1;8 1;9 1;8 1];
b2 = [1;1;2;3;5;14];
X2 = (A2'*A2)\(A2'*b2); %X = inv(A'*A)*A'*b

%plot the data and the line 
figure(2);
plot(x2,y2,'k*');
axis([4 10 0 16]);
hold on;
y2 = X2(1,1)*x2+X2(2,1);
plot(x2,y2);
hold off;
set(gca,"FontSize",14,"YTick",(0:2:16));
xlabel('x-axis');
ylabel('y-axis');
legend('datapoints','linefit')


%Part 3 of the lab
%read the data from the file
T = readtable('83people-all-meals.txt');
Data = table2array(T);
%y-axis data
KiloCal_Bite = (Data(:,4)./Data(:,3));
%x-axis data
bites = Data(:,3);

bites_down = zeros(length(bites),1) ;
KiloCal_Bite_down = zeros(length(bites),1);

%declare  the matrices of the normal equation
A3 = [log(bites) ones(length(bites),1)];
b3 = log(KiloCal_Bite);

%solve for the unknowns
X3 = (A3'*A3)\(A3'*b3); %X = inv(A'*A)*A'*b

a3 = exp(X3(2,1));
b3 = X3(1,1);

%plot the data and the line 
figure(3)
plot(bites_down, KiloCal_Bite_down,'k.');
hold on;
x3 = 0:max(bites);
y3 = a3 * x3.^b3;
plot(x3,y3,'k','LineWidth',3);
hold off;
axis([0 150 0 150]);
set(gca,"FontSize",14);
xlabel('Bites');
ylabel('kilo-calories/ bites');
legend('datapoints','linefit')
