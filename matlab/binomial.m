clc
clear all

t = 0.5;
sigma = 0.3;
% no of time intervals
m = 50;
delt = t/m;
u = exp(sigma*sqrt(delt));
d = 1/u;
s0 = 5;
x = 4.5;
r = 0.05;   %annual

p = (exp(r*delt)-d)/(u-d);


% price grid
sgrid = zeros(m+1);
sgrid(1,1) = s0;

%payoff grid
payoffs = zeros(m+1);

% first loop through time
for i = 1:m;
   
    for j = 1:i;
       
        sgrid(j,i+1) = sgrid(j,i)*u;
        sgrid(j+1,i+1) = sgrid(j,i)*d;
        
    end
        
    
end

%compute payoffs
payoffs(:,end) = max(sgrid(:,end)-x,0);
for i = m:-1:1;
   
    for j = 1:i;
       
       payoffs(j,i) = exp(-r*delt)*(p*payoffs(j,i+1) + (1-p)*payoffs(j+1,i+1)); 
        
    end
        
    
end