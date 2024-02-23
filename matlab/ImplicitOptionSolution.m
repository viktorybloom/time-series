clc
clear all 
%% Parameters
% Set up parameters for the option. European option price will depend on
% the current price of the underlying asset _s_, the strike price _x_, the
% risk free interest rate _r_, the time to maturity of the option _bigt_ 
% and the volatility _vol_
s = 20;         % Stock price
x = 20;         % Exercise price
r = 0.05;       % Interest rate
bigt = 0.5;     % Time to expiry (years)
vol = 0.3;      % Expected volatility
%% Finite Difference Parameters 
% To price the option via finite differences, we need to specify some 
% extra parameters. These are the the maximum share price, being _smax_, 
% that will be concidered in the algorithm. This should be set large 
% enough that the option has effectively zero value at this price 
% throughout the lifetime of the option. 
% Other parameters are the matricies required for the finite difference
% operation, being in _n_ number of timesteps, and _m_ number of share 
% prices.
smax = 40;      
n = 200;
m = 75;
% _dels_ is the difference in share prices possible per price jump,
% while, _delt_ is the finite difference, or size of steps, 
% in time in the matrix. 
dels = smax/m;
delt = bigt/n;
% Grid conditions are set to ensure that finite steps are within 
% implicit solution conditions.
jgrid = (0:dels:smax)';
j_count = (0:1:m)';
t_count = (0:1:n);
tgrid = (0:delt:bigt);
grid = zeros(m+1,n+1);

%% Set up boundary conditions 
    %PUT OPTION
    % Boundary conditions ensure that finite difference solver stays 
    % within set put conditions. These conditions are:
    % ##  P(t_count,smax) = 0
    % ##  P(bigt,S) = max(x-s,0) 
    % ##  P(t_count,0) = X    
grid(:,end) = max(x-jgrid,0);     % Pricing option payoff ar final column.
grid(1,:) = x*exp(-r.*delt*(n-t_count)); % Discounting at risk-free rate
                                         % per period

    %CALL OPTION
    %If we were to price a call boundary condition codes are as follows:
% grid(:,end) = max(jgrid-x,0);
% grid(end,1:end) = smax - x*exp(-r.*delt*(n-t_count));
%% Implicit solution.
% Setting up coefficients matrix. Calculating the BSM PDE, solving 
% for interior points in the grid, stepping back through time to 
% reach t = 0, from where the final option price can be read.
phi = zeros(m-1,m-1);
cj = -0.5*r*j_count*delt - 0.5*vol^2*j_count.^2*delt;   
bj = r*delt + 1 + vol^2*j_count.^2*delt;
aj = 0.5*r*j_count*delt - 0.5*vol^2*j_count.^2*delt;   
% Set up phi
for k = 1:m-2;
    phi(k,k+1) = cj(k+1);
end
for k = 1:m-1;
    phi(k,k) = bj(k+1);
end
for k = 2:m-1;
    phi(k,k-1) = aj(k+1);
end
i_phi = inv(phi);
for t = n:-1:1;
   tmp = grid(2:end-1,t+1);
   tmp(1) = tmp(1) - aj(1)*grid(1,t);
   tmp(end) = tmp(end) - cj(end-1)*grid(end,t);
   grid(2:end-1,t) = i_phi*tmp;
end
%% OPTION PRICE
% Once all paths have been calculated, the approximated final option 
% price is calculated. Because the price may come between points, a
% linear estimate can be found through linear interpolation, which 
% finds the approximated price at time zero.
price = interp1(jgrid,grid(:,1),s,'linear')