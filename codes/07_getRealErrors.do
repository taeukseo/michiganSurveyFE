/*

07_getRealErrors.do:

loads inflation and constructs real errors
modified from script by Rozyspal and Schlafmann (2023)
by Taeuk Seo 2025-12-15

*/


clear all
capture log close

set maxvar 32767
set more off

******************************************************************************************************************
** CREATE REAL INCOME CHANGES AND ERRORS

use ./files/work/data_imputed_fe, replace
set more off

gen y_inc = . //year of first income obs (base year for change)
replace y_inc = year-1 if halfOfYear==1
replace y_inc = year   if halfOfYear==2 //uses income from second interview as base

gen y_incimp = . //year of second income obs (imputed)
replace y_incimp = year   if halfOfYear==1
replace y_incimp = year+1 if halfOfYear==2 //uses income from second interview as base


*get inflation n base year
gen year_temp = year
replace year = y_inc
merge m:1 year using ./files/work/data_inflation_annual
drop if _merge==2
drop _merge inflation
ren cpi cpi_base

*get inflation in second year
replace year = y_incimp
merge m:1 year using ./files/work/data_inflation_annual
drop if _merge==2
drop _merge inflation
ren cpi cpi_imp

replace year = year_temp
drop year_temp

*compute real changes
mi passive: gen ac_inc_r = (ac_inc + 1) * cpi_base/cpi_imp - 1

mi passive: gen fe_inc_r = inc_e1_r_d - ac_inc_r

save ./files/work/data_imputed_r, replace

capture log close
