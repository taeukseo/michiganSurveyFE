
/*

05_winsorizeData.do:

winsorizes expectations and forecast errors
modified from script by Rozyspal and Schlafmann (2023)
by Taeuk Seo 2025-12-15

*/


clear all
capture log close

set maxvar 32767
set more off



use ./files/work/data_SOC_sample.dta, clear


**************************************************************************************************************
** WINSORIZE EXPECTATIONS, FORECAST ERRORS AND ACTUAL CHANGES

	   
global varlist_monthly infl_e1 inc_e1_d inc_e1_r_d ///
			   fe_infl ///
			   fe2_inc fe2_inc_r 
	
global varlist_annually ac2_inc ac2_inc_r ///


foreach v in $varlist_monthly {
	gen `v'_w5 = `v'
}
quietly {
	forvalues year = 1986/2021 {
		forvalues season = 1/12 {
			if (`year'<2021 | `season'<=2) {
				foreach v in $varlist_monthly {				
					qui sum `v' if month==ym(`year',`season'), det
					scalar min1 = r(p5)
					scalar max1 = r(p95)
					replace `v'_w5 = min1 if `v'_w5<min1 & month==ym(`year',`season')
					replace `v'_w5 = max1 if `v'_w5>max1 & month==ym(`year',`season') & `v'_w5<.

				}
			}
		}
	}
}

foreach v in $varlist_annually {
	gen `v'_w5 = `v'
}
quietly {
	forvalues y = 1986/2021 {
				foreach v in $varlist_annually {				
					qui sum `v' if year==`y', det
					scalar min1 = r(p5)
					scalar max1 = r(p95)
					replace `v'_w5 = min1 if `v'_w5<min1 & year==`y'
					replace `v'_w5 = max1 if `v'_w5>max1 & year==`y' & `v'_w5<.

		}
	}
}




*************************************************************************************************************
** SAVE
sort month hhid

save ./files/work/data_SOC_winsorized.dta, replace
clear

capture log close
