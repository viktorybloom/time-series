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

*Generating HAR-RV model and variables
gen rvDay = L.rv
tssmooth ma rvWeek = rv, window(5)
tssmooth ma rvMonth = rv, window(22)
//reg rv rvDay rvWeek rvMonth
//predict har, xb
//lab var har "HAR-RV Model"
save working.dta, replace
*rolling forecasts
rolling _b[] _se[], window(250) saving(harRolling.dta, replace): ///
	reg rv rvDay rvWeek rvMonth

use harRolling.dta, replace
foreach var of varlist _b_* _se_* {
    replace `var' = `var'[_n-1] if `var' == . 
	replace `var' = `var'[_n-1] if `var' < 0
}

save harRollingFilled.dta, replace

use working.dta, replace
drop in 1/249
merge 1:1 _n using harRollingFilled.dta
drop _merge start end
save "working.dta",replace

gen harRolling = _b_cons + rvDay*_b_rvDay + rvWeek*_b_rvWeek + rvMonth*_b_rvMonth
tsline rv harRolling 
reg rv harRolling

rolling, window(250) clear: cor rv harRolling
gen n = _n
tsset n 
tsline rho
sum rho


