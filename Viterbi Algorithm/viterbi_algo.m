% FILE NAME     : viterbi_algo.m
%
% DESCRIPTION   : Code to implement Viterbi Algorithm. 
%
% PLATFORM		: Matlab
%
% DATE	        	NAME
% 27th-Nov-2018     Shashi Shivaraju

clc; %clear all the varaibles
close all;%close all windows
clear; %clear the screeen

%Given State Sequence Order in HMM = [A C G T] = [1 2 3 4]

%Given State Sequence   
%State_Seq = ['G', 'G', 'C', 'A', 'C', 'T', 'G', 'A', 'A' ];
%State_Seq_Index = [3 3 2 1 2 4 3 1 1];

State_Seq = ['T', 'C', 'A', 'G', 'C', 'G', 'G', 'C', 'T' ];
State_Seq_Index = [4 2 1 3 2 3 3 2 4];
size = length(State_Seq); %Length of the given sequence

%Probabilities of the HMM states
Prob_iH = -1; %initial to High 
Prob_iL = -1; %initial to Low
Prob_HH = -1; %High to High
Prob_HL = -1; %High to Low
Prob_LL = log2(0.6); %Low to Low
Prob_LH = log2(0.4); %Low to High
Prob_H = [log2(0.2), log2(0.3), log2(0.3), log2(0.2)]; % State = [A C G T] = [1 2 3 4]
Prob_L = [log2(0.3), log2(0.2), log2(0.2), log2(0.3)]; % State = [A C G T] = [1 2 3 4]
    
    
%Matrix to store the result
%row 1 = prob. at H state
%row 2 = prob. at L state
%row 3 = max(row1,row2) at each index
%row 4 = 0/1 (1 = H state;0 = L state)
Result = zeros(4, size);
 
%Loop through the given sequence to calulate the max. prob. at High and Low States
for i = 1:size
    
	%Transition from intial State
	if( i == 1)
		Result(1,i) = Prob_iH + Prob_H(State_Seq_Index(i)); %initial -> H ->State(i)
        Result(2,i) = Prob_iL + Prob_L(State_Seq_Index(i)); %initial -> L ->State(i)
		
		%select the state with highest prob.
		if(Result(1,i) > Result(2,i))
			Result(3,i) = Result(1,i);
            Result(4,i) = 1;
        else
            Result(3,i) = Result(2,i);
            Result(4,i) = 0;
        end
        
    else % Transition from State(i-1) -> State(i)
            Result(1,i) = Prob_H(State_Seq_Index(i)) + max ( (Result(1, i-1) + Prob_HH), (Result(2, i-1) + Prob_LH));
            Result(2,i) = Prob_L(State_Seq_Index(i)) + max ( (Result(1, i-1) + Prob_HL), (Result(2, i-1) + Prob_LL));
          
			%select the state with highest prob.
            if(Result(1,i) == Result(2,i)) %if both states have equal prob,stay with the previous state
                Result(3,i) = Result(1,i);
                Result(4,i) = 2;
            elseif( Result(1,i) < Result(2,i))
                Result(3,i) = Result(2,i);
                Result(4,i) = 0;
            else
                Result(3,i) = Result(1,i);
                 Result(4,i) = 1;
            end
     end
end

%back tracking  to find  the  path  which  corresponds  to  the  highest probability
for i = size:-1:1
   if(Result(4,i) == 2 && i ~= size)
        Result(4,i) = Result(4,i+1);
   elseif(Result(4,i) == 2 && i == size)
        Result(4,i) = Result(4,i-1);
   end
end

    
 disp("Most  probable state path  is ");
    for i = 1:size
       if(Result(4,i) == 1)
           disp('H');
       elseif(Result(4,i) == 0)
            disp('L');
       end
    end

  disp("Result Matrix = ");
  disp(Result);