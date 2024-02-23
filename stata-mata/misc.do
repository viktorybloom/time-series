/*
** Using MATA Optimize
** Estimating GARCH(1,1) Model of DM/BP Exchange Rate
** Bollerslerv and Ghysels [1996], JBES, 307-327.
*/
clear
set more off
infile xrate dday using "path/to/directory/file"
keep in 1/1974
generate one=1
describe
summarize
regress xrate

mata        //invoking MATA
mata clear  //clear MATA without disturbing Stata

//b=parameters, f=function value, g=gradient vector, H=hessian matrix
//data is the extra argument to be analyzed
void garchllf(todo,b,data,f,g,H) //concentrated log-likelihood
{
real matrix x
real colvector y,e,u,v
real scalar n,k
n=rows(data)
k=cols(data)
y=data[.,1]
x=data[.,2..k]
k=cols(x)
e=y-x*b[1..k]'
//GARCH(1,1) variance equation
v=J(n,1,(e'e/n))  //variance initialization
for (i=2;i<=n;i++)  {
    v[i]=b[k+3]+b[k+1]*v[i-1]+b[k+2]*e[i-1]^2
}
u=e:/sqrt(v)
f=-0.5*(ln(2*pi()):+ln(v):+(u:^2))  //component log-likelihood
}
void garchmllf(todo,b,data,f,g,H) //concentrated log-likelihood
{
real matrix x
real colvector y,e,u,v
real scalar n,k
n=rows(data)
k=cols(data)
y=data[.,1]
x=data[.,2..k]
k=cols(x)
e=y-x*b[1..k]'
//GARCH-M(1,1) variance equation with updated e
v=J(n,1,(e'e/n))  //variance initialization
for (i=2;i<=n;i++)  {
    v[i]=b[k+3]+b[k+1]*v[i-1]+b[k+2]*e[i-1]^2
	e[i]=y[i]-x[i,.]*b[1..k]'-b[k+4]*v[i]
}
u=e:/sqrt(v)
f=-0.5*(ln(2*pi()):+ln(v):+(u:^2))  //component log-likelihood
}
st_view(data=.,.,("xrate","one"))

//GARCH(1,1) Model
S1=optimize_init()
optimize_init_evaluator(S1,&garchllf())
optimize_init_evaluatortype(S1,"v0")
optimize_init_argument(S1,1,data)
optimize_init_params(S1,(0,0,0,0.1))

b=optimize(S1)
vb=optimize_result_V_robust(S1)  //using robust var-cov and s.e.
seb=sqrt(diagonal(vb))
tb=b':/seb
ll=optimize_result_value(S1)
printf("Log-Likeliohood = %12.0g",ll)
b',seb,tb

//GARCH-M(1,1) Model
optimize_init_evaluator(S1,&garchmllf())
optimize_init_params(S1,(b,0))   //previous results b as initial values

b=optimize(S1)
vb=optimize_result_V_robust(S1)  //using robust var-cov and s.e.
seb=sqrt(diagonal(vb))
tb=b':/seb
ll=optimize_result_value(S1)
printf("Log-Likeliohood = %12.0g",ll)
b',seb,tb

mata describe //show MATA enviornment

end
