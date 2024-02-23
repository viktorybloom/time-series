clear all
cd"path/to/directory"
*removes "more" prompt
set more off
*graphing colour scheme
//set scheme s2manual

*using sp500 and vix return and volatility information
use SPVIX.dta

*Date series setup. Using businesss calander 
bcal create dataBCAL, from(date) gen(t) replace
tsset t
*Data checking for duplicates
//duplicates report date
//duplicates list date

*Summarise returns series
sum rets
local n = r(N)
scalar mean = r(mean)

*parametric VaR on returns, normal distribution
gmm (rets - {mu})((rets - {mu})^2 - (`n'-1)/(`n')*{v}), ///
	onestep winitial(identity) vce(robust)

nlcom (VaR95: _b[mu:_cons] + sqrt(_b[v:_cons])*invnormal(0.05))  ///
	(VaR97: _b[mu:_cons] + sqrt(_b[v:_cons])*invnormal(0.03))  ///
	(VaR99: _b[mu:_cons] + sqrt(_b[v:_cons])*invnormal(0.01)), noheader
	
*parametric VaR on returns, students t distribution
nlcom (VaR95: _b[mu:_cons] + sqrt(_b[v:_cons])*invt(5,0.05))  ///
	(VaR97: _b[mu:_cons] + sqrt(_b[v:_cons])*invt(5,0.03))  ///
	(VaR99: _b[mu:_cons] + sqrt(_b[v:_cons])*invt(5,0.01)), noheader

*VaR on ewma 
*ewma generation
gen r2 = rets^2
scalar lambda = 0.95
su r2 //in 1/2528
gen ewma = r(mean) in 1
replace ewma = (1-lambda)*L.r2 + lambda*(L.ewma) in 2/6690
lab var ewma "ewma smoother on sq. rets."
*VaR with ewma model
generate VaRewma95 = mean+ewma^0.5*invnormal(0.05)
generate VaRewma97 = mean+ewma^0.5*invnormal(0.03)
generate VaRewma99 = mean+ewma^0.5*invnormal(0.01)
tsline rets VaRewma95 VaRewma97 VaRewma99, lcolor(black gs5 gs10 gs15)

********************************************************************************
*Generating an garch(1,1) volatility model for use in VaR analysis
arch rets, arch(1) garch(1) noconstant  nolog
predict variance, variance
generate VaRgarch95 = mean+variance^0.5*invnormal(0.05)
generate VaRgarch97 = mean+variance^0.5*invnormal(0.03)
generate VaRgarch99 = mean+variance^0.5*invnormal(0.01)
tsline rets VaRgarch95 VaRgarch97 VaRgarch99, lcolor(black gs5 gs10 gs15)

*computing VaR standard errors
predict residuals, residuals
predictnl VaR = mean+([ARCH]_b[_cons]+ [ARCH]_b[L.arch]*L.residuals^2+[ARCH]_b[L.garch]*L.variance)^0.5*invnormal(0.05), se(VaR_SE)
generate VaRplusSE = VaR+VaR_SE
generate VaRminusSE = VaR-VaR_SE
*plot VaR standard errors
tsline rets VaR VaRplusSE VaRminusSE, lcolor(black gs5 gs10 gs15)

*expected shortfall simply calculates the expected loss in the tail of the distribution.
*What is the expected loss if our confidence level is exceeded.
scalar ES95 = normalden(invnormal(1-0.95))/(1-0.95)
scalar ES97 = normalden(invnormal(1-0.97))/(1-0.97)
scalar ES99 = normalden(invnormal(1-0.99))/(1-0.99)
dis ES95, ES97, ES99


