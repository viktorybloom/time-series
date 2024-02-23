clear all
cd"path/to/directory"
*removes "more" prompt
set more off
*graphing colour scheme
//set scheme s2manual

*using sp500 and vix return and volatility information
use SPVIX.dta

*Date series setup. 
{
*Using businesss calander 
bcal create dataBCAL, from(date) gen(t) replace
*allows for functioning of time series commands
tsset t
*Generating category by year (can also be by month, day, quarter, etc)
//gen year = year(date)
*Data checking for duplicates
//duplicates report date
//duplicates list date
}
*******************************************************************************
*EWMA model estimation
{
*generating ewma
gen r2 = rets^2
scalar lambda = 0.95
qui su r2
gen ewma = r(mean) in 1
replace ewma = (1-lambda)*L.r2 + lambda*(L.ewma) in 2/l
lab var ewma "ewma smoother on sq. rets."
}
*******************************************************************************
*HAR-RV model estimation
{
gen rvDay = L.rv
tssmooth ma rvWeek = rv, window(5)
tssmooth ma rvMonth = rv, window(22)
/*
rolling _b[] _se[], window(250) saving(harRolling.dta, replace): ///
	reg rv rvDay rvWeek rvMonth, noconstant
*/ 
}
*******************************************************************************
*Realised Garch model estimation
{ /*
rolling _b[] _se[], window(250) saving(garchRolling.dta, replace): /// 
	arch rv, arch(1) garch(1) noconstant
*/
}
*******************************************************************************
*Data estimation cleanup and filling 
{
*merge model parameter estimation
drop in 1/249
merge 1:1 _n using garchRolling.dta
drop _merge start end
merge 1:1 _n using harRolling.dta
drop _merge start end

*Force non-negative parametre estimation 
*RGarch Varlist is _stat_* ARCH_*
*HAR-RV Varlist is _b_* _se_*
foreach var of varlist _stat_* ARCH_* _b_* _se_*{
    replace `var' = `var'[_n-1] if `var' == . 
	replace `var' = `var'[_n-1] if `var' < 0
}
save RollingFilled.dta, replace
}
*******************************************************************************
*Model creation
*Realised Garch model creation
{
*If for GJR model************************ 
*Create dummy for assymetric factor
gen d = 1 if rets <= 0
replace d = 0 if rets > 0
*****************************************
sort t
gen garchRolling = rv in 1
replace garchRolling = ARCH_b_cons + _stat_1*(rv) ///
	+ _stat_2*(L.garchRolling) in 2/l
}
*******************************************************************************
*HAR-RV model creation
{
gen harRolling = rvDay*_b_rvDay + rvWeek*_b_rvWeek ///
	+ rvMonth*_b_rvMonth
}
*******************************************************************************
*model diagnostics
{
/*
rolling _b[] _se[] e(r2) e(rmse), window(250) saving(multiRollingRegression.dta, replace): /// 
	reg rv garchRolling harRolling, noconstant	
*/
drop in 1/249
merge 1:1 _n using multiRollingRegression.dta
drop _merge start end

foreach var of varlist _*_garchRolling _*_harRolling{
    replace `var' = `var'[_n-1] if `var' == . 
	replace `var' = `var'[_n-1] if `var' < 0
	replace `var' = 0 if `var' == .
}

gen multiVarModel = _b_garchRolling*garchRolling + _b_harRolling*harRolling
tsline rv multiVarModel in 4150/4400
reg rv multiVarModel, noconstant



rolling, window(250) clear: cor rv multiVarModel
gen n = _n
tsset n 
tsline rho
sum rho

}
