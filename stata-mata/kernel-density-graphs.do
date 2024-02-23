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
gen year = year(date)

*Data checking for duplicates
//duplicates report date
//duplicates list date

*******************************************************************************
/*
*Best to run over data an analyse for major structural breaks / periods of major interest.
gen period = 1 if year <= 1994
replace period = 2 if year>=1995
replace period = 3 if year>=2000
replace period = 4 if year>=2005
replace period = 5 if year>=2010

*Kernal density plot in 5 year periods
kdensity rets, kernel(gaussian) bwidth(0.0002) normal, if period==1, title(1990-1995) name(kden90_95,replace) nodraw
kdensity rets, kernel(gaussian) bwidth(0.0002) normal, if period==2, title(1996-2000) name(kden96_00,replace) nodraw
kdensity rets, kernel(gaussian) bwidth(0.0002) normal, if period==3, title(2001-2005) name(kden01_05,replace) nodraw
kdensity rets, kernel(gaussian) bwidth(0.0002) normal, if period==4, title(2006-2010) name(kden06_10,replace) nodraw
kdensity rets, kernel(gaussian) bwidth(0.0002) normal, if period==5, title(2011-2016) name(kden11_16,replace) nodraw
graph combine kden90_95 kden96_00 kden01_05 kden06_10 kden11_16 //, cols(6)

*OR this method
kdensity rets, gen(x fx) nodraw
kdensity rets if period==1, gen(fx0) at(x) nodraw
kdensity rets if period==2, gen(fx1) at(x) nodraw
kdensity rets if period==3, gen(fx2) at(x) nodraw
kdensity rets if period==4, gen(fx3) at(x) nodraw
kdensity rets if period==5, gen(fx4) at(x) nodraw

lab var fx0 "90-94"
lab var fx1 "95-99"
lab var fx2 "00-04"
lab var fx3 "05-09"
lab var fx4 "10-16"

line fx0 fx1 fx2 fx3 fx4 x, sort ytitle(Density)

*/

kdensity rets, kernel(biweight) bwidth(0.0001) normal title(Biweight) name(Biweight,replace) legend(off) nodraw
kdensity rets, kernel(cosine) bwidth(0.0001) normal title(Cosine) name(Cosine,replace) legend(off) nodraw
kdensity rets, kernel(epanechnikov) bwidth(0.0001) normal title(Epanechnikov) name(Epanechnikov,replace) legend(off) nodraw
kdensity rets, kernel(epan2) bwidth(0.0001) normal title(Epan2) name(Epan2,replace) legend(off) nodraw
kdensity rets, kernel(gaussian) bwidth(0.0001) normal title(Gaussian) name(Gaussian,replace) legend(off) nodraw
kdensity rets, kernel(parzen) bwidth(0.0001) normal title(Parzen) name(Parzen,replace) legend(off) nodraw
kdensity rets, kernel(rectangle) bwidth(0.0001) normal title(Rectangle) name(Rectangle,replace) legend(off) nodraw
kdensity rets, kernel(triangle) bwidth(0.0001) normal title(Triangle) name(Triangle,replace) legend(off) nodraw
graph combine Biweight Cosine Epanechnikov Epan2 Gaussian Parzen Rectangle Triangle

