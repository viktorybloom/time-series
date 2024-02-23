function Estimate_DCC();

clear all
clc

load rets

nassets = size(rets,2);
bigt = size(rets,1);

% matrix to store cond volatilities
cstd = zeros(bigt,nassets);

options = optimset('Display', 'iter', 'largescale', 'off','TolFun', 1e-007,'MaxIter',10000,'MaxFunEvals ',100000);

% Estimate univariate GARCH models and obtain cond vols
for i = 1:nassets;
    
    initial = [var(rets(:,i))*(1-0.85-0.05-0.5*0.05);0.85;0.05;0.05];       
    sumA =  [-eye(4); 0 1 1 0.5];   %introduces positivity and  constraint
    sumB =  [-1e-9;-0.3;-0.001;-0.001;0.9999];
    par = fmincon(@garchlogl,initial,sumA,sumB,[],[],[],[],[],options,rets(:,i),1);
    cstd(:,i) = sqrt(garchlogl(par,rets(:,i),2));
    
end

% standardised returns
stdret = rets./cstd;

% tmp = DCClogl([0.05;0.85],stdret);
initial = [0.05;0.85];
sumA =  [-eye(2); 1 1];
sumB = [-0.01;-0.5;0.999];
dcc_par = fmincon(@DCClogl,initial,sumA,sumB,[],[],[],[],[],options,stdret,1);
corrmat = DCClogl(dcc_par,stdret,2);

aa = 0;

%==============================================
function[logl] = DCClogl(theta,stdrets,flag);

a = theta(1);
b = theta(2);

bigt = length(stdrets);
nassets = size(stdrets,2);

Qt = zeros(nassets,nassets,bigt);
Rt = zeros(nassets,nassets,bigt);

intercept = corrcoef(stdrets)*(1-a-b);
Qt(:,:,1) = intercept;
q = sqrt(diag(Qt(:,:,1)));
Rt(:,:,1) = Qt(:,:,1)./ (q*q');

logl = zeros(length(stdrets),1);
logl(1) = -(log(det(Rt(:,:,1))) + stdrets(1,:)*inv(Rt(:,:,1))*stdrets(1,:)');

for i = 2:bigt;
    
    
    
    tmp = sqrt(diag(Qt(:,:,i-1)));
    Qt(:,:,i) = intercept + a.*stdrets(i-1,:)'*stdrets(i-1,:)./(tmp*tmp')...
        + b.*Qt(:,:,i-1);
    q = sqrt(diag(Qt(:,:,i)));
    Rt(:,:,i) = Qt(:,:,i)./ (q*q');
    logl(i) = -(log(det(Rt(:,:,i))) + stdrets(i,:)*inv(Rt(:,:,i))*stdrets(i,:)');
    
end

if flag == 1;
    logl = -sum(logl);
elseif flag == 2;
    logl = Rt;
end



%==============================================
function[logl] = garchlogl(theta,rets,flag);

alfa = theta(1);
beta = theta(2);
gamma = theta(3);
phi = theta(4);

bigt = length(rets);

cvar = zeros(bigt,1);
logl = zeros(bigt,1);

cvar(1) = alfa/(1-beta-gamma - 0.5*phi);
logl(1) = normpdf(rets(1),0,sqrt(cvar(1)));

for t = 2:bigt;
    
    cvar(t) = alfa + beta*cvar(t-1) + gamma*rets(t-1)^2 + phi*(rets(t-1) < 0)*rets(t-1)^2;
    logl(t) = normpdf(rets(t),0,sqrt(cvar(t)));
end

if flag == 1;
    logl = -sum(log(logl));
elseif flag == 2;
    logl = cvar;
end

