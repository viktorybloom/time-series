function main();

clc
clear all

%constructing matrix
load returns
ret = [bhpr rior wowr];
sigma = cov(ret);

%calculating w (findnig global min variance portfolio)
w = [0.25; 0.25; 0.25];

options = optimset('Display', 'iter','TolFun', 1e-007,'MaxIter',10000,'MaxFunEvals ',100000);

a = [eye(3);-eye(3)];
b = [1;1;1;0;0;0];
aeq = [1 1 1];
beq = 1;

optw = fmincon(@minportfolio,w,a,b,aeq,beq,[],[],[],options,sigma);


test = minportfolio(w,sigma);
ii = 0;

function[pvar] = minportfolio(w,sigma);

pvar = w'*sigma*w;







