function[logl] = garchlogl(theta,rets)

alfa = theta(1);
beta = theta(2);
gamma = theta(3);
phi = theta(4);

bigt = length(rets);

cvar = zeros(bigt,1);
logl = zeros(bigt,1);

cvar(1) = alfa/(1-beta-gamma - 0.5*phi);
logl(1) = normpdf(rets(1),0,sqrt(cvar(1)));

for t = 2:bigt
    cvar(t) = alfa + beta*cvar(t-1) + gamma*rets(t-1)^2 + phi*(rets(t-1) < 0)*rets(t-1)^2;
    logl(t) = normpdf(rets(t),0,sqrt(cvar(t)));
end

logl = -sum(log(logl));

