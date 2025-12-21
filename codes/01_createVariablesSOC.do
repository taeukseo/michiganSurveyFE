/*

01_createVariablesSOC.do:

creates variables for analysis for Survey of Consumers data
modified from script by Rozyspal and Schlafmann (2023)
by Taeuk Seo 2025-12-15

*/

clear all
capture log close

set maxvar 32767
set more off

use ./files/downloaded/data_MichSurvey, clear
*source of the data: Michigan Surveys of Consumers, University of Michigan, retrieved from https://data.sca.isr.umich.edu/.

gen hhid = CASEID
gen intid = ID
gen month = YYYYMM
gen intid_prev = IDPREV
gen month_prev = DATEPR
gen weight = WT

gen year = YYYY
gen season = YYYYQ - YYYY*10
gen quarter = yq(year,season)
format quarter %tq

gen month_help = mod(month,year*100)
replace month = ym(year, month_help)
format month %tm

gen monthOfYear = month(dofm(month))
gen halfOfYear = .
replace halfOfYear = 1 if monthOfYear<=6
replace halfOfYear = 2 if monthOfYear>6

drop if hhid==.

**************************************************************************************************************
** CONSTRUCT VARIABLES

*-----------------------------------------
*DEMOGRAPHICS
gen n_adults = NUMADT
gen n_child = NUMKID
gen n_fam = n_adult + n_child

*gen d_all = 1

gen d_college = 0
replace d_college = 1 if EDUC==5 | EDUC==6
gen d_high = 0
replace d_high = 1 if EDUC==3 | EDUC==4
gen d_nohigh = 0
replace d_nohigh = 1 if EDUC==1 | EDUC==2
gen educ = .
replace educ = 1 if d_nohigh==1
replace educ = 2 if d_high==1
replace educ = 3 if d_college==1

gen age = AGE
gen d_age35 = 0
replace d_age35 = 1 if age<35
gen d_age50 = 0
replace d_age50 = 1 if age>=35 & age<50
gen d_age65 = 0
replace d_age65 = 1 if age>=50 & age<65
gen agegroup = .
replace agegroup = 35 if d_age35==1
replace agegroup = 50 if d_age50==1
replace agegroup = 65 if d_age65==1

gen d_maritalStat = MARRY

gen d_male = .
replace d_male = 1 if SEX==1
replace d_male = 0 if SEX==2

gen i_region = REGION

gen i_race = RACE
gen d_black = 0
replace d_black = 1 if RACE==2
gen d_hisp = 0
replace d_hisp = 1 if RACE==3

*-----------------------------------------
*INCOME
gen inc_hh = INCOME
replace inc_hh=. if inc_hh==1		//INCOME = 1 implausibe since it is total hh income (all sources)

gen inc_format = INCQFM
label variable inc_format "1:open, 2:asked open, answered bracket, 3:bracket"

gen income_percapita = inc_hh / n_adults


*-----------------------------------------
*INFLATION EXPECTATIONS
gen inflation_exp1y = .
replace inflation_exp1y = 0 if PX1Q1==3
replace inflation_exp1y = PX1Q2/100 if PX1Q1==1 | PX1Q1==2
replace inflation_exp1y = -PX1Q2/100 if PX1Q1==5

gen inflation_exp5y = .
replace inflation_exp5y = 0 if PX5Q1==3
replace inflation_exp5y = PX5Q2/100 if PX5Q1==1 | PX5Q1==2
replace inflation_exp5y = -PX5Q2/100 if PX5Q1==5


*-----------------------------------------
*INCOME EXPECTATIONS
gen income_exp1y_dpct = .
replace income_exp1y_dpct = 0 if INEXQ1==3
replace income_exp1y_dpct = INEXQ2/100 if INEXQ1==1
replace income_exp1y_dpct = -INEXQ2/100 if INEXQ1==5

gen income_exp1y_real_dpct = (1+income_exp1y_dpct)/(1+inflation_exp1y) - 1
label variable income_exp1y_real_dpct "expected percentage change in real income"


*-----------------------------------------
*UNEMPLOYMENT EXPECTATIONS
gen unemp_e1 = .
replace unemp_e1 = 1 if UNEMP==1
replace unemp_e1 = 0 if UNEMP==3
replace unemp_e1 = -1 if UNEMP==5
label variable unemp_e1 "Unemployment more/less/same next year"

gen unemp_e1_up = .
replace unemp_e1_up = 1 if unemp_e1==1
replace unemp_e1_up = 0 if (unemp_e1==0 | unemp_e1==-1)

gen unemp_e1_same = .
replace unemp_e1_same = 1 if unemp_e1==0
replace unemp_e1_same = 0 if (unemp_e1==1 | unemp_e1==-1)

gen unemp_e1_down = .
replace unemp_e1_down = 1 if unemp_e1==-1
replace unemp_e1_down = 0 if (unemp_e1==0 | unemp_e1==1)



*-----------------------------------------
*GENERATE CATEGORICAL VARIABLES
gen i_nadult = .
replace i_nadult = 1 if n_adults==1
replace i_nadult = 2 if n_adults==2
replace i_nadult = 3 if n_adults>2 & n_adults<.
label define nadultgroup 1 "\hspace{0.2cm} 1" 2 "\hspace{0.2cm} 2" 3 "\hspace{0.2cm} 3 or more"
label values i_nadult nadultgroup

gen d_female = 1-d_male
label variable d_female "\hspace{0.2cm} female"

gen d_unmarried = .
replace d_unmarried = 0 if d_maritalStat==1
replace d_unmarried = 1 if (d_maritalStat>1 & d_maritalStat<.)
label variable d_unmarried "\hspace{0.2cm} not married"

gen i_age = .
replace i_age = 1 if age<=25 
replace i_age = 2 if age>25 & age<=30 
replace i_age = 3 if age>30 & age<=35 
replace i_age = 4 if age>35 & age<=40 
replace i_age = 5 if age>40 & age<=45 
replace i_age = 6 if age>45 & age<=50 
replace i_age = 7 if age>50 & age<=55 
replace i_age = 8 if age>55 & age<=60 
replace i_age = 9 if age>60 & age<=65 
label variable i_age "age group"
label define agegroup9 1 "<=25" 2 "25-30" 3 "30-35" 4 "35-40" 5 "40-45" 6 "45-50" 7 "50-55" 8 "55-60" 9 "60-65"
label values i_age agegroup9

**************************************************************************************************************
** SAVE

sort year hhid
save ./files/work/data_SOC_allvars, replace

capture log close
