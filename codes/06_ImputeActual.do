/*

06_ImputeActual.do:

imputes actual income changes using information from interviews in the next year (2nd half)
modified from script by Rozyspal and Schlafmann (2023)
by Taeuk Seo 2025-12-15


*/


clear all
capture log close

set maxvar 32767
set more off
version 17

local n_imps = 25

****************************************************************************************************************
** GENERATE DATA SET ONLY WITH RELEVANT VARIABLES AND RELEVANT OBS

use ./files/work/data_SOC_winsorized.dta, clear


*select variables to keep
keep age d_maritalStat d_male d_black d_hisp educ i_region n_adult n_child ///
	 month year halfOfYear monthOfYear hhid intid m6_intid weight ///
	 inc m6_inc  ///
	 infl_e1 ///
	 inc_e1_d inc_e1_r_d m6_inc_e1_d m6_inc_e1_r_d  ///
	 d_p d_pe d_e d_inc* d_m6_inc* d_a ///
	 ac2_inc* fe2_inc* ///
	 i_inc* d_unmarried d_female i_age i_nadult agegroup

*select obs to keep
keep if d_a==1

*drop obs with missing information in relevant variables
drop if n_child==. | educ==. | d_maritalStat==. | inc ==. | ///m6_inc ==. | ///
		d_male==. | d_black ==. | d_hisp==. | i_region==. | n_adult==. | age==. | ///n_child==. 
		infl_e1==. | inc_e1_d==.
		
*drop obs with only one interview in 2nd half (neither useful for imputation nor good timing for expectation vs realization if imputed)
drop if halfOfYear==2 & m6_inc==.

save ./files/tmp/temp_data.dta, replace


****************************************************************************************************************
** FOR EACH YEAR: IMPUTE 3RD OBSERVATION FOR INCOME FOR SECOND HALF INTERVIEWS


set seed 100683

forvalues y = 1986/2019 {

	use ./files/tmp/temp_data.dta, clear
		
	keep if year==`y' | year==`y'+1

	*comparison group: select only interviews in 2nd half of year (only those report for two different years)
	drop if year==`y'+1 & halfOfYear==1
	drop if year==`y'+1 & m6_inc==.

	*group to be imputed: select only interviews in 2nd half of year (only for those 2nd income info reflects 2nd year)
	drop if year==`y' & halfOfYear==1
	drop if year==`y' & m6_inc==.

	
	*prepare variables for imputation
	gen ac_inc = .
	replace ac_inc = ac2_inc if year==`y'+1
	
	gen ln_inc = .
	replace ln_inc = ln(inc) if year==`y'+1
	replace ln_inc = ln(m6_inc) if year==`y' //using the income information that hh's give us in 2nd interview

	*impute actual income change
	mi set wide
	mi register imputed ac_inc
	mi register regular ln_inc age d_maritalStat d_male d_black d_hisp educ i_region n_adult weight inc_e1_d infl_e1


	mi impute pmm ac_inc c.ln_inc##c.ln_inc c.age##c.age i.educ i.d_maritalStat i.d_male ///
								i.d_black i.d_hisp i.i_region i.n_adult weight ///
								inc_e1_d infl_e1, ///
								add(`n_imps') knn(5) noisily

	*drop obs from comparison group
	drop if year==`y'+1

	save ./files/tmp/temp_data`y'_2nd, replace
	
	clear

}


****************************************************************************************************************
** FOR EACH YEAR: IMPUTE 2ND INCOME FOR INTERVIEWS IN 1ST HALF OF YEAR
*  income changes from obs of 2nd half of year are used to impute income for the 2nd year when interview 
*  was in 1st half of year (then they reported twice the same year); 
*  also: for first half of year we do not need a reinterview at all!!!

set seed 090383
set more off
forvalues y = 1986/2020 {

	use ./files/tmp/temp_data.dta, clear
	keep if year==`y'

	*prepare variables for imputation
	gen ac_inc = .
	replace ac_inc = ac2_inc if halfOfYear==2
	
	gen ln_inc = ln(inc) 
	
	
	*impute 2nd year income
	mi set wide
	mi register imputed ac_inc
	mi register regular ln_inc age d_maritalStat d_male d_black d_hisp educ i_region n_adult weight inc_e1_d infl_e1
	
	mi impute pmm ac_inc c.ln_inc##c.ln_inc c.age##c.age i.educ i.d_maritalStat i.d_male ///
								i.d_black i.d_hisp i.i_region i.n_adult weight ///
								inc_e1_d infl_e1, ///
								add(`n_imps') knn(5)  noisily

	*drop obs from comparison group
	drop if halfOfYear==2

	save ./files/tmp/temp_data`y'_1st, replace
	clear

}

****************************************************************************************************************
** APPEND ALL YEARS 
use ./files/tmp/temp_data1986_1st, clear
forvalues y = 1987/2020 {
	mi append using ./files/tmp/temp_data`y'_1st
	save ./files/tmp/temp_data_imputed_1st_after`y', replace
}
save ./files/tmp/temp_data_imputed_1st, replace

use ./files/tmp/temp_data1986_2nd, clear
forvalues y = 1987/2019 {
	mi append using ./files/tmp/temp_data`y'_2nd
	save ./files/tmp/temp_data_imputed_2nd_after`y', replace
}
save ./files/tmp/temp_data_imputed_2nd, replace

mi append using ./files/tmp/temp_data_imputed_1st

save ./files/work/data_imputed, replace

** CONSTRUCT FORECAST ERRORS
use ./files/work/data_imputed, replace
mi passive: gen fe_inc = inc_e1_d - ac_inc
save ./files/work/data_imputed_fe, replace


capture log close
