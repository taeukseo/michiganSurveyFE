/*

09_plotFigures.do:

plots time series of average forecast errors and
      cross sectional distribution of individual forecast errors
by Taeuk Seo 2025-12-15

*/

import delimited ./files/work/data_imputed_temp2, clear
rename month modate2
gen year = substr(modate2,1,4)
gen month = substr(modate2,6,2)
destring year month, replace
gen modate = ym(year,month)
format %tm modate
save ./files/work/data_imputed_temp2, replace

	 
use ./files/work/data_imputed_temp2, clear

gsort modate fe_inc_r_w5
drop if missing(fe_inc_r_w5)
forvalues j = 1/99 {
by modate: egen pr`j' = pctile(fe_inc_r_w5), p(`j')
}
by modate: egen pr_mean = mean(fe_inc_r_w5)
by modate: egen pr_sd = sd(fe_inc_r_w5)
duplicates drop modate, force

su pr_mean
local pr_mean_avg `r(mean)'
su pr_sd
local pr_sd_avg `r(mean)'

collapse (mean) pr*

gen n = _n
reshape long pr, i(n) j(nn)
tsset nn

generate normalDist = `pr_mean_avg' + `pr_sd_avg'*invnorm(nn/100)

keep if nn >= 5 & nn <= 95

label var pr "Forecast error percentile (Michigan Survey)"
label var normalDist "Normal distribution"

save ./files/output/percentilesForecastError, replace


use ./files/downloaded/fred_nber, clear
merge 1:1 modate using ./files/output/forecastErrors
keep if _merge == 3

bgshade modate, shaders(usrec) sstyle(lcolor(gs10) lpattern(l)) ///
		twoway((tsline pr_mean_12, lcolor(blue) lwidth(1.0) ///
				yline(0, lcolor(red) lpattern(solid))), ///
		 ytitle("") ///
		 xtitle("Year", size(5))  ///
		 xscale(range(300 792)) ///
		 xlabel(300(120)792, labsize(medium)) ///
		 yscale(range(-0.15 0.05)) ///
		 ylabel(-0.15(0.05)0.05, labsize(medium)) ///
		 title("A. Avg. forecast error", size(6)) ///
		 legend(pos(6) row(1)) ///
		 plotregion(lcolor(grey) lwidth(thin)) ///
		 graphregion(color(white)) ///
		 tlabel(, format(%tmY)) plotregion(margin(zero)) ///
		 aspectratio(0.8) ysize(6) xsize(6) ///
		 )
graph export "./figures/figForecastErrorsMeanExtended.pdf", ///
	as(pdf) replace


mata: mata clear
mata:
real scalar lininterp_mata(real colvector x, real colvector y, real scalar xq)
{
    real scalar n, left, yq
    real colvector keep, p

    // Remove missings & basic check
    keep = (x != .) & (y != .)
    x = select(x, keep)
    y = select(y, keep)
    n = rows(x)
    if (n < 2 | xq == .) return(.)

    // Sort x and align y
    p = order(x, 1)
    x = x[p]
    y = y[p]

    // No extrapolation: outside range -> .
    if (xq < x[1] | xq > x[n]) return(.)

    // Endpoints
    if (xq == x[1]) return(y[1])
    if (xq == x[n]) return(y[n])

    // Find interval [x[left], x[left+1]] with x[left] <= xq < x[left+1]
    left = 1
    while (left < n & x[left+1] <= xq) left++

    // Exact match
    if (x[left] == xq) return(y[left])

    // Linear interpolation
    yq = y[left] + (y[left+1] - y[left]) * (xq - x[left]) / (x[left+1] - x[left])
    return(yq)
}
end


capture program drop lininterp_store
program define lininterp_store, rclass
    // Usage: lininterp_store x y, x0(<real scalar>)
    version 18.0
    syntax varlist(min=2 max=2 numeric) , x0(real)

    // Parse varlist (order: x y)
    local xvar : word 1 of `varlist'
    local yvar : word 2 of `varlist'

    // Basic checks
    confirm variable `xvar'
    confirm variable `yvar'

    // Pull columns into Mata and compute interpolation
    tempname y0scalar
    mata: st_numscalar("`y0scalar'", lininterp_mata( ///
            st_data(., "`xvar'"), ///
            st_data(., "`yvar'"), ///
            `x0'))

    // Move result to r()
    scalar y0 = `y0scalar'
    return scalar y0 = y0
end

use ./files/output/percentilesForecastError, clear

gsort pr nn

local model_pessimism = -0.264
local model_pessimism_disp : display %4.3f -1*`model_pessimism'

lininterp_store pr nn, x0(`model_pessimism')
local y0 : display %2.1f r(y0)

twoway ///
	(line  pr nn, lcolor(blue) lwidth(0.7) ///
	xline(18.78, lwidth(0.25)) yline(-0.267, lwidth(0.1))) ///
	(scatteri -0.267 18.78, msymbol(circle) mcolor(blue)) ///
	(pcarrowi 0.05 23  -0.23 19.5, ///
	  mcolor(black) lcolor(black) barbsize(1.5)) ///
	, ///
	xlabel(0(20)100, labsize(medium)) xscale(range(0 100)) ///
	ylabel(-1(0.5)0.5, labsize(medium)) yscale(range(-1 0.5)) ///
	xtitle("Percentile", size(5)) ///
	ytitle("") ///
	title("B. Cross section pct.", size(6)) ///
	text(0.25  20 "Model pessimism: −`model_pessimism_disp'", place(e)) ///
	text(0.15  20 "Percentile: `y0'", place(e)) /// 
	graphregion(margin(5 5 5 5)) plotregion(margin(0 0 0 0) ///
	lcolor(grey) lwidth(thin)) ///
	aspectratio(0.8) xsize(6) ysize(6) ///
	legend(off)
					
graph export "./figures/figForecastErrorsDistribution.pdf", ///
	as(pdf) replace
