function[logl,wi,ai,bi,h] = garchl(param,rets,psi)

w = param(1);

alpha = param(2);

beta = param(3);

k = kurtosis(rets);

c=(psi.*(1-alpha-beta)-1+(alpha+beta).^psi)*(alpha*(1-(alpha+beta)^2)...
        +(alpha^2)*(alpha+beta));
    

a=psi.*(1-beta)^2+2*psi.*(psi-1)*((1-alpha-beta).^2).*(1-(alpha+beta)^2+alpha^2)...
    /((k-1)*(1-(alpha+beta).^2))+4*c./(1-(alpha+beta)^2);

b=(alpha*(1-(alpha+beta)^2)+(alpha^2)*(alpha+beta))*(1-(alpha+beta).^(2*psi))...
    /(1-(alpha+beta)^2);

wi=psi.*w.*(1+(alpha+beta).^psi)./(1-(alpha+beta));

x=(a.*((alpha+beta).^psi)-b)./(a.*(1+(alpha+beta).^(2*psi))-2*b);

bi=[(1-sqrt(1-4*x.^2))./(2*x) (1+sqrt(1-4*x.^2))./(2*x)];

bi=bi(:,1);

bi(bi<0)=0;         % Constraint positive 

ai=(alpha+beta).^psi-bi;

ai(ai<0)=0;         % Constraint positive 

T = length(rets);

h=NaN(T,1);

h(1)=var(rt);

for t=2:T
    
    h(t)=wi(t)+ai(t).*rt(t-1)^2+bi(t).*h(t-1);
    
end

f=normpdf(rets,0,sqrt(h));

logl=sum(log(f));

logl=-logl;



