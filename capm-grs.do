clear *
cd"path/to/directory"
use equalweighted.dta
//use valueweighted.dta

// decile portfolio excess returns CAPM
forvalues i = 1(1)10 {
gen z`i' = dcl`i' - rf
}
matrix tbl = J(10, 6, 0) 
matrix colnames tbl = Mean Stdev Alpha seAlpha Beta seBeta 
matrix rownames tbl = "Small = 1" 2 3 4 5 6 7 8 9 "Big = 10" 

forvalues i = 1(1)10 { 
quietly summ z`i'
matrix tbl[`i', 1] = round(r(mean), .001) 
matrix tbl[`i', 2] = round(r(sd), .01)
quietly reg z`i' mktrf 
matrix tbl[`i', 3] = round(_b[_cons], .001)
matrix tbl[`i', 4] = round(_se[_cons], .001)
matrix tbl[`i', 5] = round(_b[mktrf], .001)
matrix tbl[`i', 6] = round(_se[mktrf], .001)
predict res`i', resid
}
matrix list tbl

//Alpha
svmat tbl, names(col)
mkmat Alpha, matrix(alpha), in 1/10
matlist alpha 

//residual covariance matrix
qui sureg (z* = mktrf)
matrix sig = e(Sigma)
matlist sig


//GRS
matrix top = (alpha'*invsym(sig)*alpha)
matlist top

qui su mktrf
sca bottom = ((804-10-1)/10) / (1 + ( r(mean)^2 / r(Var) ))

sca J =  bottom * (.1598453) 
di J


grstest2 z*, flist(mktrf) alphas //nqui

/*
//CAPM estimated alphas are jointly statistically zero:
qui sureg (dcl1d - dcl10d = mktrf)
test _cons //reject null alpha = 0
clear
svmat tbl, names(col) // use col names as variable names
scatter Mean Beta, ytitle(Mean return) xtitle(Beta) xscale(range(0.8 1.2)) xlabel(0.8(0.1)1.2)
*/


