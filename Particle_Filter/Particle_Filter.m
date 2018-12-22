% FILE NAME     : Particle_Filter.m
%
% DESCRIPTION   : Code to implement Particle filter. 
%
% PLATFORM		: Matlab
%
% DATE	        	NAME
% 19th-Nov-2018     Shashi Shivaraju

clc; %clear all the varaibles
close all;%close all windows
clear; %clear the screeen

%Read data from file
Data = dlmread("magnets-data.txt");
ActualPosition = Data(:,1);%Actual position of data for reference
ActualVelocity = Data(:,2);%Actual velocity of data for reference
SensorMeasurement = Data(:,3);%Sensor measurement data

%Positions of Magnets
xm1 = -10;
xm2 = 10;

%Number of Particles in Filter
M = 1000;

%Standard Deviations
SigmaA = 0.0625; %Dynamic noise
SigmaN = 0.003906; %Measurement noise
SigmaM = 4;

%State of each particle
XPos = zeros(1,M);
XVel = zeros(1,M);
XPrevPos = zeros(1,M);
XPrevVel = zeros(1,M);

%Weight of each particle
weight = ones(1,M) * 1/M;
weightPrev = ones(1,M) * 1/M;
weightUpdated = ones(1,M) * 1/M;

%Ideal measurement for each particle
Sensor_Ideal = zeros(1,M);

%Particle Filter Output
PF_Output = zeros(1,length(SensorMeasurement));
%Index of Weights
Weight_Index= 1 : M;

%Resampling
Q = zeros(1,M); %calculate the running totals
T = zeros(1,M+1);%Array of M+1 uniform random numbers 0 to 1
RSCount = 0;% Total number of resampling done during filtering
PlotWeights = 0;%Flag for plotting the weights between one resample cycle
Select_ResampleCount = 27; %Select the resample count after which weights have to be plotted

%loop through the each sensor reading
for t = 1:length(SensorMeasurement)
    
    %loop through each particle in filter
    for i = 1:M
            
            % Update each particle as per state transition equation
            XPos(i) = XPrevPos(i) + XPrevVel(i) ;
            if( XPrevPos(i) < -20)
                XVel(i) = 2;
            elseif (XPrevPos(i) > 20)
                XVel(i) = -2;
            elseif (XPrevPos(i) >= 0 && XPrevPos(i) <= 20 ) 
                XVel(i) = XPrevVel(i) - abs(randn * SigmaA);
            elseif (XPrevPos(i) >= -20 && XPrevPos(i) < 0)
                XVel(i) = XPrevVel(i) + abs(randn * SigmaA);
            end
   
            %Ideal measurement of the particle
            Sensor_Ideal(i) = (1 / (sqrt(2*pi) * SigmaM))  * exp( -((XPrevPos(i) - xm1  )^2) / (2 * (SigmaM^2) )) + (1 / (sqrt(2*pi) * SigmaM))  * exp( -((XPrevPos(i) - xm2  )^2) / (2 * (SigmaM^2) ));
            %Calculate Probability by comparing the ideal measurement against the actual measurement    
            Prob_Yt_Xtm = ((1 / (sqrt(2*pi) * SigmaN)) * exp ( - ((Sensor_Ideal(i) - SensorMeasurement(t) )^2) / (2 * (SigmaN^2) )));
            %Update weight of the particle
            weightUpdated(i) = weightPrev(i) * Prob_Yt_Xtm;
            
            %Store the previous values
            XPrevPos(i) = XPos(i);
            XPrevVel(i) = XVel(i);
            weightPrev(i) = weightUpdated(i);            
    end
    
    %Initialization
    Index = zeros(1,M);
    
    %Find the cumulative weight
    weightSum = 0;
    for k = 1:M
        weightSum = weightSum + weightUpdated(k) ;
    end
    
    %Normalize the weights so they add up to 1
    for k = 1:M
        weight(k) = weightUpdated(k) / weightSum ;  
    end
     
    %Calculate the Particle Filter Output and Coefficient of Variation
    Filter_Output = 0;
    CV = 0;
    for k = 1:M
        %Expected Filter Output
        Filter_Output = Filter_Output +  (weight(k) *  XPos(k));    
        %Coefficient of Variation
        CV = CV + (((M * weight(k)) - 1) ^ 2);
    end
    
    %Coefficient of Variation
    CV = 1/M * CV;
    %Particle Filter Output
    PF_Output(t) = Filter_Output;
    %Effective Sampling Size
    ESS = M / (1 + CV);
    
    %Plot weights if flag is on
    if(PlotWeights)
        figure(t)
        bar(Weight_Index, weight,'k')
        axis([0 M 0 0.0075])
        xlabel("Particle");
        ylabel("Weight");
        set(gca,'FontSize',14)
        disp(strcat('iteration = ',num2str(t),' ESS = ',num2str(ESS)));
    end
    
     %Resample the weights 
     if( ESS < 0.5 * M )
         
        %Calculate the running totals
        Q(1) = weight(1); 
        for k = 2:M
            Q(k) = Q(k-1) + weight(k); 
        end
        %T is an array of M+1 uniform random numbers 0 to 1
        T = rand(1,M);
        T(k+1) = 1; %Boundary condition for cumulative hist
        %Sort them smallest to largest
        T = sort(T);
        %Arrays start at 1
        i = 1;
        j = 1;
        while( i <= M ) 
            if( T(i) < Q(j) )
                Index(i) = j;
                i = i+1;
            else
                j = j+1;
            end
        end
        
        %Update the states and weights of the particles
        for i = 1:M
            XPos(i) = XPos(Index(i));
            XPrevPos(i) = XPrevPos(Index(i));
            XVel(i) = XVel(Index(i));
            XPrevVel(i) = XPrevVel(Index(i)) ; 
            weight(i) = 1/M;
            weightPrev(i) = 1/M;
            weightUpdated(i) = 1/M;
        end
        
        %Increase the resample count 
        RSCount = RSCount + 1;
        
        %Update the flag to plot the weights during resampling
        if(RSCount == Select_ResampleCount)
            PlotWeights = 1;
        end
        
        %Plot resampled weights
        if(PlotWeights)
            figure(t)
            bar(Weight_Index, weight,'k')
            axis([0 M 0 0.0075])
            xlabel("Particle");
            ylabel("Weight");
            set(gca,'FontSize',14)
        end
        
        %Reset the flag to plot weights
        if(RSCount == Select_ResampleCount + 1)
           PlotWeights = 0;
        end
        
     end
end

%Plot the actual position and position obtained from Particle filter  
PF_Index = 0 : length(ActualPosition)-1;   %Index of Particle Filter output
figure(1)
plot(PF_Index,ActualPosition,'k','LineWidth', 0.7);
hold on
plot(PF_Index,PF_Output,'k','LineWidth', 1,'Marker','.','MarkerSize',10);
hold off
xlabel("time samples");
ylabel("Position");
set (gca,"FontSize",14);
legend("Actual Position", "PF Output");