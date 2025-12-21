/*

03_constructErrors.do:

constructs:
	- errors in inflation expectations 
	- actual changes in real and nominal income (for 2nd half hh)
	- forecast errors in real and nominal income growth (for 2nd half hh)
*/


clear all
capture log close

set maxvar 32767
set more off


**-----------------------------------------------
** CONSTRUCT FORECAST ERRORS IN INFLATION

*get inflation 12 months ahead (not calendar year!)
use ./files/work/data_inflation_monthly, replace
tsset month, monthly
gen ac_infl = f12.inflation
drop cpi inflation
drop if ac_infl==.
save ./files/tmp/temp_inflation_realized, replace
clear

*merge to main data set
use ./files/work/data_SOC_allvarsWithPanel_ren.dta, replace
merge m:1 month using ./files/tmp/temp_inflation_realized
drop if _merge==2
drop _merge

*generate forecast error
gen fe_infl = infl_e1 - ac_infl


**-----------------------------------------------
** CONSTRUCT ACTUAL CHANGES AND FORECAST ERRORS IN INCOME GROWTH
gen y_1 = year-1 //year of first income obs (base year for change)
gen y_2 = year   //year of second income obs 

*get inflation in base year
gen year_temp = year
replace year = y_1
merge m:1 year using ./files/work/data_inflation_annual //, keepusing(cpi)
drop if _merge==2
drop _merge inflation
ren cpi cpi_1

*get inflation in second year
replace year = y_2
merge m:1 year using ./files/work/data_inflation_annual //, keepusing(cpi)
drop if _merge==2
drop _merge inflation
ren cpi cpi_2 

replace year = year_temp
drop year_temp

*generate real income and income changes
gen ac2_inc = .
replace ac2_inc = m6_inc / inc - 1 if halfOfYear==2

gen inc_r = inc/cpi_1

gen ac2_inc_r = .
replace ac2_inc_r = (ac2_inc + 1) * cpi_1 / cpi_2  - 1 if halfOfYear==2

*generate forecast errors
gen fe2_inc = inc_e1_d - ac2_inc
gen fe2_inc_r = inc_e1_r_d - ac2_inc_r


**-----------------------------------------------
** SAVE
save ./files/work/data_SOC_withError.dta, replace



capture log close
