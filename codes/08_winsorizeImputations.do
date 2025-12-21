/*

08_winsorizeImputations.do:

winsorizes the imputed errors and changes
modified from script by Rozyspal and Schlafmann (2023)
by Taeuk Seo 2025-12-15

*/


clear all
capture log close

set maxvar 32767
set more off


******************************************************************************************************************
** WINSORIZE IMPUTED VALUES 
global varlist_annual ac_inc ac_inc_r
global varlist_monthly fe_inc fe_inc_r 

set more off

use ./files/work/data_imputed_r, replace

foreach v in $varlist_annual {
	mi passive: gen `v'_w1 = `v'
	mi passive: gen `v'_w5 = `v'
	mi passive: gen `v'_w10 = `v'
	mi passive: gen `v'_w25 = `v'
}
save ./files/tmp/data_imputed_temp, replace

foreach v in $varlist_monthly {
	mi passive: gen `v'_w1 = `v'
	mi passive: gen `v'_w5 = `v'
	mi passive: gen `v'_w10 = `v'
	mi passive: gen `v'_w25 = `v'
}
save ./files/tmp/data_imputed_temp, replace

mi convert mlong
save ./files/tmp/data_imputed_temp, replace

*annual winsorization (income changes, do not vary by month due to calendar year question)
*quietly {
	foreach v in $varlist_annual {
		forvalues y = 1986/2020 {
			disp `y'
			qui sum `v' if year==`y', det
			scalar min1 = r(p1)
			scalar max1 = r(p99)
			scalar min5 = r(p5)
			scalar max5 = r(p95)
			scalar min10 = r(p10)
			scalar max10 = r(p90)
			scalar min25 = r(p25)
			scalar max25 = r(p75)
			
			replace `v'_w1 = min1 if `v'_w1<min1 & year==`y'
			replace `v'_w1 = max1 if `v'_w1>max1 & year==`y' & `v'_w1<.
			
			replace `v'_w5 = min5 if `v'_w5<min5 & year==`y'
			replace `v'_w5 = max5 if `v'_w5>max5 & year==`y' & `v'_w5<.
			
			replace `v'_w10 = min10 if `v'_w10<min10 & year==`y'
			replace `v'_w10 = max10 if `v'_w10>max10 & year==`y' & `v'_w10<.
			
			replace `v'_w25 = min25 if `v'_w25<min25 & year==`y'
			replace `v'_w25 = max25 if `v'_w25>max25 & year==`y' & `v'_w25<.
			
		}
	}
*}
save ./files/tmp/data_imputed_temp, replace

*monthly winsorization (forecast errors: while realizations don't change monthly, forecasts do)
*quietly {
	forvalues y = 1986/2020 {
		disp `y'
		forvalues s = 1/12 {
			if (`y'<2021 | `s'<=2) {
				foreach v in $varlist_monthly {				
					qui sum `v' if month==ym(`y',`s'), det
					
					scalar min1 = r(p1)
					scalar max1 = r(p99)
					scalar min5 = r(p5)
					scalar max5 = r(p95)
					scalar min10 = r(p10)
					scalar max10 = r(p90)
					scalar min25 = r(p25)
					scalar max25 = r(p75)
					
					replace `v'_w1 = min1 if `v'_w1<min1 & month==ym(`y',`s')
					replace `v'_w1 = max1 if `v'_w1>max1 & month==ym(`y',`s') & `v'_w1<.
					
					replace `v'_w5 = min5 if `v'_w5<min5 & month==ym(`y',`s')
					replace `v'_w5 = max5 if `v'_w5>max5 & month==ym(`y',`s') & `v'_w5<.
					
					replace `v'_w10 = min10 if `v'_w10<min10 & month==ym(`y',`s')
					replace `v'_w10 = max10 if `v'_w10>max10 & month==ym(`y',`s') & `v'_w10<.
					
					replace `v'_w25 = min25 if `v'_w25<min25 & month==ym(`y',`s')
					replace `v'_w25 = max25 if `v'_w25>max25 & month==ym(`y',`s') & `v'_w25<.
			
				}
			}
		}
	}
*}

save ./files/tmp/data_imputed_temp, replace

use ./files/tmp/data_imputed_temp, clear
export delimited hhid month fe_inc_r_w5  ///
	using ./files/work/data_imputed_temp2.csv, replace

mi convert wide
save ./files/work/data_imputed_win, replace



capture log close
