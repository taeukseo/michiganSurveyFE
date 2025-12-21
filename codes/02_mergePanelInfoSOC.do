/*

02_mergePanelInfoSOC.do:

creates a data set containing current variables, same variables 6 months later
modified from script by Rozyspal and Schlafmann (2023)
by Taeuk Seo 2025-12-15

*/


clear all
capture log close

set maxvar 32767
set more off



**************************************************************************************************************
** CREATE DATA WITH FUTURE ACTUAL REALIZATION


**-----------------------------------------------
** CREATE CURRENT DATA SET

use ./files/work/data_SOC_allvars, replace
keep hhid intid* month* quarter weight d_* educ age* inflation* n_* income*  ///
	 inc_hh* unemp* i_*

sort month intid
save ./files/tmp/temp_current.dta, replace
clear


**-----------------------------------------------
** CREATE 6 MONTHS LATER DATA SET
use ./files/work/data_SOC_allvars, replace
keep hhid intid* month* quarter weight d_* educ age* inflation* n_* income* ///
	 inc_hh* unemp* i_*

*drop observations without previous intertiew
drop if (intid_prev==. | month_prev==.)

*rename variables
global varlist 	inflation_exp1y  inflation_exp5y income_percapita ///
				income_exp1y_dpct income_exp1y_real_dpct ///
				 ///
				weight hhid ///
				n_adults n_child n_fam d_male d_maritalStat i_region i_race educ age ///
				inc_hh   ///
				unemp_e1 
foreach v in $varlist {
	ren `v' m6_`v'
}


*get month information (original and reinterview)
ren intid m6_intid
ren month m6_month
ren intid_prev intid
ren month_prev month1
gen year1 = int(month1/100)
gen help1 = mod(month1,100)
gen month = ym(year1,help1)
format month %tm
drop year1 help1 month1 


*drop hh with more than one interview in follow up (one case)
by month intid, sort: egen test = count(m6_hhid)
drop if test>1
drop test

*drop hh if reinterview is not after 6 months (doesn't seem to be the case)
drop if m6_month-month!=6


*sort and save
sort month intid
save ./files/tmp/temp_6months.dta, replace
clear



**-----------------------------------------------
** MERGE OBSERVATIONS
use ./files/tmp/temp_current.dta, clear
drop if month == ym(2018,5)
merge 1:1 month intid using ./files/tmp/temp_6months.dta
drop if _merge!=3
drop _merge


**-----------------------------------------------
** SELECT VARIABLES AND SAVE

keep hhid intid month weight m6_* 
save ./files/tmp/temp_panel.dta, replace
clear




**************************************************************************************************************
** MERGE TO MAIN DATA SET

use ./files/work/data_SOC_allvars, replace
sort month intid
* Exclude May 2018 sample, no ID included
drop if month == ym(2018,5)
merge 1:1 month intid using ./files/tmp/temp_panel.dta
drop _merge

**************************************************************************************************************
*RENAME VARIABLES

ren income_percapita inc
ren income_exp1y_dpct inc_e1_d
ren income_exp1y_real_dpct inc_e1_r_d

ren inflation_exp1y infl_e1
ren inflation_exp5y infl_e5

ren m6_income_percapita m6_inc
ren m6_income_exp1y_dpct m6_inc_e1_d
ren m6_income_exp1y_real_dpct m6_inc_e1_r_d


save ./files/work/data_SOC_allvarsWithPanel_ren.dta, replace
clear











capture log close


