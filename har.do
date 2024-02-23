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
*allows for functioning of time series commands
tsset t
*Generating category by year (can also be by month, day, quarter, etc)
//gen year = year(date)
*Data checking for duplicates
//duplicates report date
//duplicates list date

*******************************************************************************

*Summarise returns series
sum rets
local n = r(N)
scalar mean = r(mean)

*generating ewma
gen r2 = rets^2
scalar lambda = 0.95
su r2
gen ewma = r(mean) in 1
replace ewma = (1-lambda)*L.r2 + lambda*(L.ewma) in 2/l
lab var ewma "ewma smoother on sq. rets."
reg rv ewma

*generating garch(1,1) model
arch rets, arch(1) tarch(1) garch(1) noconstant //nolog
predict gjr, variance
tsline gjr ewma har

*Generating HAR-RV model
gen rvDay = L.rv
tssmooth ma rvWeek = rv, window(5)
tssmooth ma rvMonth = rv, window(22)
reg rv rvDay rvWeek rvMonth
predict har, xb
lab var har "HAR-RV Model"

save "working.dta", replace
*rolling forecasts
//rolling _b[] _se[], window(250) saving(harRolling.dta, replace): reg rv rvDay rvWeek rvMonth

use working.dta, replace
drop in 1/249
merge 1:1 _n using harRolling.dta
drop _merge
save "working2",replace

gen harRolling = _b_cons + rvDay*_b_rvDay + rvWeek*_b_rvWeek + rvMonth*_b_rvMonth
tsline har harRolling
reg rv har 
reg rv harRolling

rolling, window(250) clear: cor rv harRolling
gen n = _n
tsset n 
tsline rho
sum rho
corr rv harRolling

