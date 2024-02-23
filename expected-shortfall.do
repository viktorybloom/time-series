clear all
cd"path/to/directory"
set more off

import excel using "^GSPC.xlsx", firstrow clear
drop Open High Low Close Volume
bcal create dataBCAL, from(Date) gen(t) replace
tsset t
gen rets = log(AdjClose/L.AdjClose)

//drop in 1/1510
*Summarise returns series
sum rets
local n = r(N)
scalar mean = r(mean)
*Set confidence level
scalar confidenceLevel = 1 - 0.99

sort rets
gen n=_n
scalar VaRposition = ceil(confidenceLevel*`n')
di VaRposition, `n'
g VaRsearch = rets if VaRposition == n
sum VaRsearch

sca VaR = r(mean) 
di VaR

sum rets in 1/VaRposition
scalar CVaR = (1/VaRposition)*sum(rets, in 1/VaRposition)


scalar expectedShortfall = normalden(invnormal(1-confidenceLevel))/(1-confidenceLevel)
di expectedShortfall
