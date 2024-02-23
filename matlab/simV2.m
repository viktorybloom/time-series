clc 
clear all
%% Calculating option payoff, through simulation method.
%% Parameters
% Set up parameters for the option. European option price will depend on
% the current price of the underlying asset _s_, the strike price _x_, the
% risk free interest rate _r_, the time to maturity of the option _bigt_ 
% and the volatility _vol_.
% The number of simulations to run, to increase accuracy will be _nsims_.
s = 20;                 % Stock price
x = 20;                 % Exercise price
r = 0.05;               % Interest rate
bigt = 0.5;             % Time to expiry
vol = 0.3;              % Expected volatility
nsims = 1000;           % Number of simulations to run
%% Setting up time grid 
bign = 1000;            % Number of time steps to calculate
deltat = bigt/bign;     % Size of time steps
%% Setting up price grid
% Store price paths
psims = zeros(nsims,bign+1);% Allowing for _nsims_ simulations to be run.
psims(:,1) = s;             % stores initial stock price    
%% Simulate price paths
% Simulating geometric brownian motion drift
drift = (r - 0.5*vol.^2)*deltat;  

% Looping to include no. of _nsims_ simulations
for i = 1:nsims;         
  
    % Simulating stochastic price movement from 
    % previous time period to next period, until time bigt.
    for t = 2:bign+1;   
   
        psims(i,t) = psims(i,t-1)*exp(drift + vol*randn(1,1)*sqrt(deltat));
  
    end
    
end
%% Calculating option payoff.
% Pulling the final prices, from the last column at time bigt. 
endsp = psims(:,end);    
% Finding values of the option payoffs.
payoff = max(x-endsp,0);   
% Finding average value of the option payoffs.
avepayoff = (sum(payoff))/nsims; 
% Calculate the present value of the average simulated option payoffs.
discpayoff = avepayoff*exp(-r*bigt) 
%% Graphing simulated price movements
plot(0:bign,psims,'Linewidth',.3)
set(gca,'FontWeight','bold','Fontsize',10);
xlabel('Periods to Expiry','FontWeight','bold','Fontsize',12);
ylabel('Asset Price','FontWeight','bold','Fontsize',12);
title('Simulated Paths','FontWeight','bold','Fontsize',18);
grid on
set(gcf,'Color','w');
%% Histogram of prices at time bigt.
figure 
hist (endsp)
set(gca,'FontWeight','bold','Fontsize',10);
xlabel('Price','FontWeight','bold','Fontsize',12);
ylabel('Occurances','FontWeight','bold','Fontsize',12);
title('Simulated Prices Paths','FontWeight','bold','Fontsize',18);
grid on
set(gcf,'Color','w');

