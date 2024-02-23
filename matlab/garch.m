function [ll,fvec,res]=garch11_l(garchpar,rets,opt)

T=length(rets);
ll=0;
if isreal(garchpar) & all(garchpar(1:3)>0) & sum(garchpar(2:3))<1
    sig0=garchpar(1)/(1-sum(garchpar(2:end)));
    for t=1:T
        if t==1
            ht=sig0;
        else
            ht=garchpar(1)+garchpar(2)*rets(t-1)^2+garchpar(3)*ht;
        end
        hvec(t,1)=ht;
            if ht>0
                f=normpdf(rets(t),0,sqrt(ht));
            else
                f=0;
            end
            if f>0;
                ll=ll+log(f);
            else
                ll=ll-50;
            end
            fvec=[fvec;f];
            res.stdres(t,1)= rets(t)/sqrt(ht);
    end
else
    ll=-50*T;
    hvec=zeros(T,1);
end
res.ll=ll;
res.hvec=hvec;