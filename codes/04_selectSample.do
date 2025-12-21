/*

04_selectSample.do:

selects sample and generates categorical variables for income groups (based on sample)
modified from script by Rozyspal and Schlafmann (2023)
by Taeuk Seo 2025-12-15

*/


clear all
capture log close

set maxvar 32767
set mem 200m
set more off


use ./files/work/data_SOC_withError.dta, replace


**************************************************************************************************************
** DROP OBSERVATIONS


*-----------------------------------------
*drop observations before 1986Q3 (according to Rebecca McBee of Survey of Consumers income was only asked in brackets before)
drop if month<ym(1986,7)

*-----------------------------------------
*drop observations if annual income is implausibly low (quarter of poverty guideline)
*source: U.S. Department of Health and Human Services, https://aspe.hhs.gov/topics/poverty-economic-mobility/poverty-guidelines/prior-hhs-poverty-guidelines-federal-register-references
merge m:1 year n_fam using ./files/downloaded/data_povertyguide_1982_2024
drop if _merge==2
drop _merge

drop if inc_hh<povguide/4 & povguide<.
drop povguide


*-----------------------------------------
*drop retirees (ie age>65)
drop if age>65


*-----------------------------------------
*drop if income information is missing
drop if inc==.
drop if inc_hh==.


**************************************************************************************************************
** SAMPLE SELECTION

gen d_a = 1		// all observations
gen d_p = 1 	// only obs with second interview
gen d_e = 1  	// exclude obs with income below average unemployment benefits
gen d_pe = 1 	// exclude obs with income below average unemployment benefits from panel sample


*-----------------------------------------
*only select obs with second interview
replace d_p = 0 if fe2_inc==.
replace d_pe = 0 if fe2_inc==.


*-----------------------------------------
*exclude obs which change household size between interviews
replace d_p = 0 if n_adults!=m6_n_adults & m6_n_adults<.
replace d_pe = 0 if n_adults!=m6_n_adults & m6_n_adults<.
replace d_a = 0 if n_adults!=m6_n_adults & m6_n_adults<.
replace d_e = 0 if n_adults!=m6_n_adults & m6_n_adults<.


*-----------------------------------------
*exclude obs where respondent changed (race, gender, marriage status, region & age different)
global varlist i_race d_male d_maritalStat i_region
foreach v in $varlist {
	replace d_p = 0 if `v'!=m6_`v' & m6_`v'<.
	replace d_pe = 0 if `v'!=m6_`v' & m6_`v'<.
	replace d_a = 0 if `v'!=m6_`v' & m6_`v'<.
	replace d_e = 0 if `v'!=m6_`v' & m6_`v'<.
}
replace d_p = 0 if (age<m6_age-1 | age>m6_age) & m6_age<.
replace d_pe = 0 if (age<m6_age-1 | age>m6_age) & m6_age<.
replace d_e = 0 if (age<m6_age-1 | age>m6_age) & m6_age<.
replace d_a = 0 if (age<m6_age-1 | age>m6_age) & m6_age<.





*-----------------------------------------
*exclude observations if annual income is below average unemployment benefits
merge m:1 year using ./files/work/avgUnempBen_annual
drop if _merge==2
drop _merge

replace d_e = 0 if inc<avgben & avgben<. & n_adults<. 
replace d_pe = 0 if d_p==1 & inc<avgben & avgben<. & n_adults<. 

drop avgben avgben_r





**************************************************************************************************************
** GENERATE INCOME QUARTILE INDICATORS

gen d_inc1 = 0
gen d_inc2 = 0
gen d_inc3 = 0
gen d_inc4 = 0

gen d_inc51 = 0
gen d_inc52 = 0
gen d_inc53 = 0
gen d_inc54 = 0
gen d_inc55 = 0

gen d_inc101 = 0
gen d_inc102 = 0
gen d_inc103 = 0
gen d_inc104 = 0
gen d_inc105 = 0
gen d_inc106 = 0
gen d_inc107 = 0
gen d_inc108 = 0
gen d_inc109 = 0
gen d_inc1010 = 0

gen d_incpc1 = 0
gen d_incpc2 = 0
gen d_incpc3 = 0
gen d_incpc4 = 0

gen d_incpc51 = 0
gen d_incpc52 = 0
gen d_incpc53 = 0
gen d_incpc54 = 0
gen d_incpc55 = 0

gen d_incpc101 = 0
gen d_incpc102 = 0
gen d_incpc103 = 0
gen d_incpc104 = 0
gen d_incpc105 = 0
gen d_incpc106 = 0
gen d_incpc107 = 0
gen d_incpc108 = 0
gen d_incpc109 = 0
gen d_incpc1010 = 0



gen d_inc1_p = 0
gen d_inc2_p = 0
gen d_inc3_p = 0
gen d_inc4_p = 0

gen d_inc51_p = 0
gen d_inc52_p = 0
gen d_inc53_p = 0
gen d_inc54_p = 0
gen d_inc55_p = 0

gen d_inc101_p = 0
gen d_inc102_p = 0
gen d_inc103_p = 0
gen d_inc104_p = 0
gen d_inc105_p = 0
gen d_inc106_p = 0
gen d_inc107_p = 0
gen d_inc108_p = 0
gen d_inc109_p = 0
gen d_inc1010_p = 0

gen d_incpc1_p = 0
gen d_incpc2_p = 0
gen d_incpc3_p = 0
gen d_incpc4_p = 0

gen d_incpc51_p = 0
gen d_incpc52_p = 0
gen d_incpc53_p = 0
gen d_incpc54_p = 0
gen d_incpc55_p = 0

gen d_incpc101_p = 0
gen d_incpc102_p = 0
gen d_incpc103_p = 0
gen d_incpc104_p = 0
gen d_incpc105_p = 0
gen d_incpc106_p = 0
gen d_incpc107_p = 0
gen d_incpc108_p = 0
gen d_incpc109_p = 0
gen d_incpc1010_p = 0

gen d_m6_incpc51_p = 0
gen d_m6_incpc52_p = 0
gen d_m6_incpc53_p = 0
gen d_m6_incpc54_p = 0
gen d_m6_incpc55_p = 0

gen d_m6_incpc101_p = 0
gen d_m6_incpc102_p = 0
gen d_m6_incpc103_p = 0
gen d_m6_incpc104_p = 0
gen d_m6_incpc105_p = 0
gen d_m6_incpc106_p = 0
gen d_m6_incpc107_p = 0
gen d_m6_incpc108_p = 0
gen d_m6_incpc109_p = 0
gen d_m6_incpc1010_p = 0

gen d_inc1_e = 0
gen d_inc2_e = 0
gen d_inc3_e = 0
gen d_inc4_e = 0

gen d_inc51_e = 0
gen d_inc52_e = 0
gen d_inc53_e = 0
gen d_inc54_e = 0
gen d_inc55_e = 0

gen d_inc101_e = 0
gen d_inc102_e = 0
gen d_inc103_e = 0
gen d_inc104_e = 0
gen d_inc105_e = 0
gen d_inc106_e = 0
gen d_inc107_e = 0
gen d_inc108_e = 0
gen d_inc109_e = 0
gen d_inc1010_e = 0

gen d_incpc1_e = 0
gen d_incpc2_e = 0
gen d_incpc3_e = 0
gen d_incpc4_e = 0

gen d_incpc51_e = 0
gen d_incpc52_e = 0
gen d_incpc53_e = 0
gen d_incpc54_e = 0
gen d_incpc55_e = 0

gen d_incpc101_e = 0
gen d_incpc102_e = 0
gen d_incpc103_e = 0
gen d_incpc104_e = 0
gen d_incpc105_e = 0
gen d_incpc106_e = 0
gen d_incpc107_e = 0
gen d_incpc108_e = 0
gen d_incpc109_e = 0
gen d_incpc1010_e = 0



gen d_inc1_pe = 0
gen d_inc2_pe = 0
gen d_inc3_pe = 0
gen d_inc4_pe = 0

gen d_inc51_pe = 0
gen d_inc52_pe = 0
gen d_inc53_pe = 0
gen d_inc54_pe = 0
gen d_inc55_pe = 0

gen d_inc101_pe = 0
gen d_inc102_pe = 0
gen d_inc103_pe = 0
gen d_inc104_pe = 0
gen d_inc105_pe = 0
gen d_inc106_pe = 0
gen d_inc107_pe = 0
gen d_inc108_pe = 0
gen d_inc109_pe = 0
gen d_inc1010_pe = 0

gen d_incpc1_pe = 0
gen d_incpc2_pe = 0
gen d_incpc3_pe = 0
gen d_incpc4_pe = 0

gen d_incpc51_pe = 0
gen d_incpc52_pe = 0
gen d_incpc53_pe = 0
gen d_incpc54_pe = 0
gen d_incpc55_pe = 0

gen d_incpc101_pe = 0
gen d_incpc102_pe = 0
gen d_incpc103_pe = 0
gen d_incpc104_pe = 0
gen d_incpc105_pe = 0
gen d_incpc106_pe = 0
gen d_incpc107_pe = 0
gen d_incpc108_pe = 0
gen d_incpc109_pe = 0
gen d_incpc1010_pe = 0

gen d_m6_incpc51_pe = 0
gen d_m6_incpc52_pe = 0
gen d_m6_incpc53_pe = 0
gen d_m6_incpc54_pe = 0
gen d_m6_incpc55_pe = 0

gen d_m6_incpc101_pe = 0
gen d_m6_incpc102_pe = 0
gen d_m6_incpc103_pe = 0
gen d_m6_incpc104_pe = 0
gen d_m6_incpc105_pe = 0
gen d_m6_incpc106_pe = 0
gen d_m6_incpc107_pe = 0
gen d_m6_incpc108_pe = 0
gen d_m6_incpc109_pe = 0
gen d_m6_incpc1010_pe = 0


quietly {
	forvalues y = 1986/2021 {
		
			
			
				*all obs
				_pctile inc if year==`y' & d_a==1 [pw=weight], p(25 50 75)
				scalar p25 = r(r1)
				scalar p50= r(r2)
				scalar p75 = r(r3)
				replace d_incpc1 = 1 if (inc<=p25) & year==`y' & d_a==1 
				replace d_incpc2 = 1 if (inc>p25 & inc<=p50) & year==`y' & d_a==1 
				replace d_incpc3 = 1 if (inc>p50 & inc<=p75) & year==`y' & d_a==1 
				replace d_incpc4 = 1 if (inc>p75 & inc<.) & year==`y' & d_a==1 

				_pctile inc if year==`y' & d_a==1 [pw=weight], p(20 40 60 80)
				scalar p20 = r(r1)
				scalar p40 = r(r2)
				scalar p60 = r(r3)
				scalar p80 = r(r4)
				replace d_incpc51 = 1 if (inc<=p20) & year==`y' & d_a==1 
				replace d_incpc52 = 1 if (inc>p20 & inc<=p40) & year==`y' & d_a==1 
				replace d_incpc53 = 1 if (inc>p40 & inc<=p60) & year==`y' & d_a==1 
				replace d_incpc54 = 1 if (inc>p60 & inc<=p80) & year==`y' & d_a==1 
				replace d_incpc55 = 1 if (inc>p80 & inc<.) & year==`y' & d_a==1 
				
				_pctile inc if year==`y' & d_a==1 [pw=weight], p(10 20 30 40 50 60 70 80 90)
				scalar p10 = r(r1)
				scalar p20 = r(r2)
				scalar p30 = r(r3)
				scalar p40 = r(r4)
				scalar p50 = r(r5)
				scalar p60 = r(r6)
				scalar p70 = r(r7)
				scalar p80 = r(r8)
				scalar p90 = r(r9)
				replace d_incpc101 = 1 if (inc<=p10) & year==`y' & d_a==1 
				replace d_incpc102 = 1 if (inc>p10 & inc<=p20) & year==`y' & d_a==1 
				replace d_incpc103 = 1 if (inc>p20 & inc<=p30) & year==`y' & d_a==1 
				replace d_incpc104 = 1 if (inc>p30 & inc<=p40) & year==`y' & d_a==1 
				replace d_incpc105 = 1 if (inc>p40 & inc<=p50) & year==`y' & d_a==1 
				replace d_incpc106 = 1 if (inc>p50 & inc<=p60) & year==`y' & d_a==1 
				replace d_incpc107 = 1 if (inc>p60 & inc<=p70) & year==`y' & d_a==1 
				replace d_incpc108 = 1 if (inc>p70 & inc<=p80) & year==`y' & d_a==1 
				replace d_incpc109 = 1 if (inc>p80 & inc<=p90) & year==`y' & d_a==1 
				replace d_incpc1010 = 1 if (inc>p90 & inc<.) & year==`y' & d_a==1 

				_pctile inc_hh if year==`y' & d_a==1 [pw=weight], p(25 50 75)
				scalar p25 = r(r1)
				scalar p50= r(r2)
				scalar p75 = r(r3)
				replace d_inc1 = 1 if (inc_hh<=p25) & year==`y' & d_a==1 
				replace d_inc2 = 1 if (inc_hh>p25 & inc_hh<=p50) & year==`y' & d_a==1 
				replace d_inc3 = 1 if (inc_hh>p50 & inc_hh<=p75) & year==`y' & d_a==1 
				replace d_inc4 = 1 if (inc_hh>p75 & inc_hh<.) & year==`y' & d_a==1 

				_pctile inc_hh if year==`y' & d_a==1 [pw=weight], p(20 40 60 80)
				scalar p20 = r(r1)
				scalar p40 = r(r2)
				scalar p60 = r(r3)
				scalar p80 = r(r4)
				replace d_inc51 = 1 if (inc_hh<=p20) & year==`y' & d_a==1 
				replace d_inc52 = 1 if (inc_hh>p20 & inc_hh<=p40) & year==`y' & d_a==1 
				replace d_inc53 = 1 if (inc_hh>p40 & inc_hh<=p60) & year==`y' & d_a==1 
				replace d_inc54 = 1 if (inc_hh>p60 & inc_hh<=p80) & year==`y' & d_a==1 
				replace d_inc55 = 1 if (inc_hh>p80 & inc_hh<.) & year==`y' & d_a==1 
					
				_pctile inc_hh if year==`y' & d_a==1 [pw=weight], p(10 20 30 40 50 60 70 80 90)
				scalar p10 = r(r1)
				scalar p20 = r(r2)
				scalar p30 = r(r3)
				scalar p40 = r(r4)
				scalar p50 = r(r5)
				scalar p60 = r(r6)
				scalar p70 = r(r7)
				scalar p80 = r(r8)
				scalar p90 = r(r9)
				replace d_inc101 = 1 if (inc_hh<=p10) & year==`y' & d_a==1 
				replace d_inc102 = 1 if (inc_hh>p10 & inc_hh<=p20) & year==`y' & d_a==1 
				replace d_inc103 = 1 if (inc_hh>p20 & inc_hh<=p30) & year==`y' & d_a==1 
				replace d_inc104 = 1 if (inc_hh>p30 & inc_hh<=p40) & year==`y' & d_a==1 
				replace d_inc105 = 1 if (inc_hh>p40 & inc_hh<=p50) & year==`y' & d_a==1 
				replace d_inc106 = 1 if (inc_hh>p50 & inc_hh<=p60) & year==`y' & d_a==1 
				replace d_inc107 = 1 if (inc_hh>p60 & inc_hh<=p70) & year==`y' & d_a==1 
				replace d_inc108 = 1 if (inc_hh>p70 & inc_hh<=p80) & year==`y' & d_a==1 
				replace d_inc109 = 1 if (inc_hh>p80 & inc_hh<=p90) & year==`y' & d_a==1 
				replace d_inc1010 = 1 if (inc_hh>p90 & inc_hh<.) & year==`y' & d_a==1 
				
				*panel only
				_pctile inc if year==`y' & d_p==1 [pw=weight], p(25 50 75)
				scalar p25 = r(r1)
				scalar p50= r(r2)
				scalar p75 = r(r3)
				replace d_incpc1_p = 1 if (inc<=p25) & year==`y' & d_p==1  
				replace d_incpc2_p = 1 if (inc>p25 & inc<=p50) & year==`y' & d_p==1 
				replace d_incpc3_p = 1 if (inc>p50 & inc<=p75) & year==`y' & d_p==1 
				replace d_incpc4_p = 1 if (inc>p75 & inc<.) & year==`y' & d_p==1 

				_pctile inc if year==`y' & d_p==1 [pw=weight], p(20 40 60 80)
				scalar p20 = r(r1)
				scalar p40 = r(r2)
				scalar p60 = r(r3)
				scalar p80 = r(r4)
				replace d_incpc51_p = 1 if (inc<=p20) & year==`y' & d_p==1
				replace d_incpc52_p = 1 if (inc>p20 & inc<=p40) & year==`y' & d_p==1
				replace d_incpc53_p = 1 if (inc>p40 & inc<=p60) & year==`y' & d_p==1
				replace d_incpc54_p = 1 if (inc>p60 & inc<=p80) & year==`y' & d_p==1
				replace d_incpc55_p = 1 if (inc>p80 & inc<.) & year==`y' & d_p==1

				_pctile inc if year==`y' & d_p==1 [pw=weight], p(10 20 30 40 50 60 70 80 90)
				scalar p10 = r(r1)
				scalar p20 = r(r2)
				scalar p30 = r(r3)
				scalar p40 = r(r4)
				scalar p50 = r(r5)
				scalar p60 = r(r6)
				scalar p70 = r(r7)
				scalar p80 = r(r8)
				scalar p90 = r(r9)
				replace d_incpc101_p = 1 if (inc<=p10) & year==`y' & d_p==1
				replace d_incpc102_p = 1 if (inc>p10 & inc<=p20) & year==`y' & d_p==1
				replace d_incpc103_p = 1 if (inc>p20 & inc<=p30) & year==`y' & d_p==1
				replace d_incpc104_p = 1 if (inc>p30 & inc<=p40) & year==`y' & d_p==1
				replace d_incpc105_p = 1 if (inc>p40 & inc<=p50) & year==`y' & d_p==1
				replace d_incpc106_p = 1 if (inc>p50 & inc<=p60) & year==`y' & d_p==1
				replace d_incpc107_p = 1 if (inc>p60 & inc<=p70) & year==`y' & d_p==1
				replace d_incpc108_p = 1 if (inc>p70 & inc<=p80) & year==`y' & d_p==1
				replace d_incpc109_p = 1 if (inc>p80 & inc<=p90) & year==`y' & d_p==1
				replace d_incpc1010_p = 1 if (inc>p90 & inc<.) & year==`y' & d_p==1

				_pctile m6_inc if year==`y' & d_p==1 [pw=weight], p(20 40 60 80)
				scalar p20 = r(r1)
				scalar p40 = r(r2)
				scalar p60 = r(r3)
				scalar p80 = r(r4)
				replace d_m6_incpc51_p = 1 if (m6_inc<=p20) & year==`y' & d_p==1
				replace d_m6_incpc52_p = 1 if (m6_inc>p20 & m6_inc<=p40) & year==`y' & d_p==1
				replace d_m6_incpc53_p = 1 if (m6_inc>p40 & m6_inc<=p60) & year==`y' & d_p==1
				replace d_m6_incpc54_p = 1 if (m6_inc>p60 & m6_inc<=p80) & year==`y' & d_p==1
				replace d_m6_incpc55_p = 1 if (m6_inc>p80 & m6_inc<.) & year==`y' & d_p==1

				_pctile m6_inc if year==`y' & d_p==1 [pw=weight], p(10 20 30 40 50 60 70 80 90)
				scalar p10 = r(r1)
				scalar p20 = r(r2)
				scalar p30 = r(r3)
				scalar p40 = r(r4)
				scalar p50 = r(r5)
				scalar p60 = r(r6)
				scalar p70 = r(r7)
				scalar p80 = r(r8)
				scalar p90 = r(r9)
				replace d_m6_incpc101_p = 1 if (m6_inc<=p10) & year==`y' & d_p==1
				replace d_m6_incpc102_p = 1 if (m6_inc>p10 & m6_inc<=p20) & year==`y' & d_p==1
				replace d_m6_incpc103_p = 1 if (m6_inc>p20 & m6_inc<=p30) & year==`y' & d_p==1
				replace d_m6_incpc104_p = 1 if (m6_inc>p30 & m6_inc<=p40) & year==`y' & d_p==1
				replace d_m6_incpc105_p = 1 if (m6_inc>p40 & m6_inc<=p50) & year==`y' & d_p==1
				replace d_m6_incpc106_p = 1 if (m6_inc>p50 & m6_inc<=p60) & year==`y' & d_p==1
				replace d_m6_incpc107_p = 1 if (m6_inc>p60 & m6_inc<=p70) & year==`y' & d_p==1
				replace d_m6_incpc108_p = 1 if (m6_inc>p70 & m6_inc<=p80) & year==`y' & d_p==1
				replace d_m6_incpc109_p = 1 if (m6_inc>p80 & m6_inc<=p90) & year==`y' & d_p==1
				replace d_m6_incpc1010_p = 1 if (m6_inc>p90 & m6_inc<.) & year==`y' & d_p==1
				
				_pctile inc_hh if year==`y' & d_p==1  [pw=weight], p(25 50 75)
				scalar p25 = r(r1)
				scalar p50= r(r2)
				scalar p75 = r(r3)
				replace d_inc1_p = 1 if (inc_hh<=p25) & year==`y' & d_p==1
				replace d_inc2_p = 1 if (inc_hh>p25 & inc_hh<=p50) & year==`y' & d_p==1
				replace d_inc3_p = 1 if (inc_hh>p50 & inc_hh<=p75) & year==`y' & d_p==1
				replace d_inc4_p = 1 if (inc_hh>p75 & inc_hh<.) & year==`y' & d_p==1

				_pctile inc_hh if year==`y' & d_p==1  [pw=weight], p(20 40 60 80)
				scalar p20 = r(r1)
				scalar p40 = r(r2)
				scalar p60 = r(r3)
				scalar p80 = r(r4)
				replace d_inc51_p = 1 if (inc_hh<=p20) & year==`y' & d_p==1
				replace d_inc52_p = 1 if (inc_hh>p20 & inc_hh<=p40) & year==`y' & d_p==1
				replace d_inc53_p = 1 if (inc_hh>p40 & inc_hh<=p60) & year==`y' & d_p==1
				replace d_inc54_p = 1 if (inc_hh>p60 & inc_hh<=p80) & year==`y' & d_p==1
				replace d_inc55_p = 1 if (inc_hh>p80 & inc_hh<.) & year==`y' & d_p==1
					
				_pctile inc_hh if year==`y' & d_p==1 [pw=weight], p(10 20 30 40 50 60 70 80 90)
				scalar p10 = r(r1)
				scalar p20 = r(r2)
				scalar p30 = r(r3)
				scalar p40 = r(r4)
				scalar p50 = r(r5)
				scalar p60 = r(r6)
				scalar p70 = r(r7)
				scalar p80 = r(r8)
				scalar p90 = r(r9)
				replace d_inc101_p = 1 if (inc_hh<=p10) & year==`y' & d_p==1
				replace d_inc102_p = 1 if (inc_hh>p10 & inc_hh<=p20) & year==`y' & d_p==1
				replace d_inc103_p = 1 if (inc_hh>p20 & inc_hh<=p30) & year==`y' & d_p==1
				replace d_inc104_p = 1 if (inc_hh>p30 & inc_hh<=p40) & year==`y' & d_p==1
				replace d_inc105_p = 1 if (inc_hh>p40 & inc_hh<=p50) & year==`y' & d_p==1
				replace d_inc106_p = 1 if (inc_hh>p50 & inc_hh<=p60) & year==`y' & d_p==1
				replace d_inc107_p = 1 if (inc_hh>p60 & inc_hh<=p70) & year==`y' & d_p==1
				replace d_inc108_p = 1 if (inc_hh>p70 & inc_hh<=p80) & year==`y' & d_p==1
				replace d_inc109_p = 1 if (inc_hh>p80 & inc_hh<=p90) & year==`y' & d_p==1
				replace d_inc1010_p = 1 if (inc_hh>p90 & inc_hh<.) & year==`y' & d_p==1
				
				
				*panel only, unemployed excluded
				_pctile inc if year==`y' & d_pe==1 [pw=weight], p(25 50 75)
				scalar p25 = r(r1)
				scalar p50= r(r2)
				scalar p75 = r(r3)
				replace d_incpc1_pe = 1 if (inc<=p25) & year==`y' & d_pe==1  
				replace d_incpc2_pe = 1 if (inc>p25 & inc<=p50) & year==`y' & d_pe==1 
				replace d_incpc3_pe = 1 if (inc>p50 & inc<=p75) & year==`y' & d_pe==1 
				replace d_incpc4_pe = 1 if (inc>p75 & inc<.) & year==`y' & d_pe==1 

				_pctile inc if year==`y' & d_pe==1 [pw=weight], p(20 40 60 80)
				scalar p20 = r(r1)
				scalar p40 = r(r2)
				scalar p60 = r(r3)
				scalar p80 = r(r4)
				replace d_incpc51_pe = 1 if (inc<=p20) & year==`y' & d_pe==1
				replace d_incpc52_pe = 1 if (inc>p20 & inc<=p40) & year==`y' & d_pe==1
				replace d_incpc53_pe = 1 if (inc>p40 & inc<=p60) & year==`y' & d_pe==1
				replace d_incpc54_pe = 1 if (inc>p60 & inc<=p80) & year==`y' & d_pe==1
				replace d_incpc55_pe = 1 if (inc>p80 & inc<.) & year==`y' & d_pe==1

				_pctile inc if year==`y' & d_pe==1 [pw=weight], p(10 20 30 40 50 60 70 80 90)
				scalar p10 = r(r1)
				scalar p20 = r(r2)
				scalar p30 = r(r3)
				scalar p40 = r(r4)
				scalar p50 = r(r5)
				scalar p60 = r(r6)
				scalar p70 = r(r7)
				scalar p80 = r(r8)
				scalar p90 = r(r9)
				replace d_incpc101_pe = 1 if (inc<=p10) & year==`y' & d_pe==1
				replace d_incpc102_pe = 1 if (inc>p10 & inc<=p20) & year==`y' & d_pe==1
				replace d_incpc103_pe = 1 if (inc>p20 & inc<=p30) & year==`y' & d_pe==1
				replace d_incpc104_pe = 1 if (inc>p30 & inc<=p40) & year==`y' & d_pe==1
				replace d_incpc105_pe = 1 if (inc>p40 & inc<=p50) & year==`y' & d_pe==1
				replace d_incpc106_pe = 1 if (inc>p50 & inc<=p60) & year==`y' & d_pe==1
				replace d_incpc107_pe = 1 if (inc>p60 & inc<=p70) & year==`y' & d_pe==1
				replace d_incpc108_pe = 1 if (inc>p70 & inc<=p80) & year==`y' & d_pe==1
				replace d_incpc109_pe = 1 if (inc>p80 & inc<=p90) & year==`y' & d_pe==1
				replace d_incpc1010_pe = 1 if (inc>p90 & inc<.) & year==`y' & d_pe==1
				
				_pctile m6_inc if year==`y' & d_pe==1 [pw=weight], p(20 40 60 80)
				scalar p20 = r(r1)
				scalar p40 = r(r2)
				scalar p60 = r(r3)
				scalar p80 = r(r4)
				replace d_m6_incpc51_pe = 1 if (m6_inc<=p20) & year==`y' & d_pe==1
				replace d_m6_incpc52_pe = 1 if (m6_inc>p20 & m6_inc<=p40) & year==`y' & d_pe==1
				replace d_m6_incpc53_pe = 1 if (m6_inc>p40 & m6_inc<=p60) & year==`y' & d_pe==1
				replace d_m6_incpc54_pe = 1 if (m6_inc>p60 & m6_inc<=p80) & year==`y' & d_pe==1
				replace d_m6_incpc55_pe = 1 if (m6_inc>p80 & m6_inc<.) & year==`y' & d_pe==1

				_pctile m6_inc if year==`y' & d_pe==1 [pw=weight], p(10 20 30 40 50 60 70 80 90)
				scalar p10 = r(r1)
				scalar p20 = r(r2)
				scalar p30 = r(r3)
				scalar p40 = r(r4)
				scalar p50 = r(r5)
				scalar p60 = r(r6)
				scalar p70 = r(r7)
				scalar p80 = r(r8)
				scalar p90 = r(r9)
				replace d_m6_incpc101_pe = 1 if (m6_inc<=p10) & year==`y' & d_pe==1
				replace d_m6_incpc102_pe = 1 if (m6_inc>p10 & m6_inc<=p20) & year==`y' & d_pe==1
				replace d_m6_incpc103_pe = 1 if (m6_inc>p20 & m6_inc<=p30) & year==`y' & d_pe==1
				replace d_m6_incpc104_pe = 1 if (m6_inc>p30 & m6_inc<=p40) & year==`y' & d_pe==1
				replace d_m6_incpc105_pe = 1 if (m6_inc>p40 & m6_inc<=p50) & year==`y' & d_pe==1
				replace d_m6_incpc106_pe = 1 if (m6_inc>p50 & m6_inc<=p60) & year==`y' & d_pe==1
				replace d_m6_incpc107_pe = 1 if (m6_inc>p60 & m6_inc<=p70) & year==`y' & d_pe==1
				replace d_m6_incpc108_pe = 1 if (m6_inc>p70 & m6_inc<=p80) & year==`y' & d_pe==1
				replace d_m6_incpc109_pe = 1 if (m6_inc>p80 & m6_inc<=p90) & year==`y' & d_pe==1
				replace d_m6_incpc1010_pe = 1 if (m6_inc>p90 & m6_inc<.) & year==`y' & d_pe==1				

				_pctile inc_hh if year==`y' & d_pe==1  [pw=weight], p(25 50 75)
				scalar p25 = r(r1)
				scalar p50= r(r2)
				scalar p75 = r(r3)
				replace d_inc1_pe = 1 if (inc_hh<=p25) & year==`y' & d_pe==1
				replace d_inc2_pe = 1 if (inc_hh>p25 & inc_hh<=p50) & year==`y' & d_pe==1
				replace d_inc3_pe = 1 if (inc_hh>p50 & inc_hh<=p75) & year==`y' & d_pe==1
				replace d_inc4_pe = 1 if (inc_hh>p75 & inc_hh<.) & year==`y' & d_pe==1

				_pctile inc_hh if year==`y' & d_pe==1  [pw=weight], p(20 40 60 80)
				scalar p20 = r(r1)
				scalar p40 = r(r2)
				scalar p60 = r(r3)
				scalar p80 = r(r4)
				replace d_inc51_pe = 1 if (inc_hh<=p20) & year==`y' & d_pe==1
				replace d_inc52_pe = 1 if (inc_hh>p20 & inc_hh<=p40) & year==`y' & d_pe==1
				replace d_inc53_pe = 1 if (inc_hh>p40 & inc_hh<=p60) & year==`y' & d_pe==1
				replace d_inc54_pe = 1 if (inc_hh>p60 & inc_hh<=p80) & year==`y' & d_pe==1
				replace d_inc55_pe = 1 if (inc_hh>p80 & inc_hh<.) & year==`y' & d_pe==1
					
				_pctile inc_hh if year==`y' & d_pe==1 [pw=weight], p(10 20 30 40 50 60 70 80 90)
				scalar p10 = r(r1)
				scalar p20 = r(r2)
				scalar p30 = r(r3)
				scalar p40 = r(r4)
				scalar p50 = r(r5)
				scalar p60 = r(r6)
				scalar p70 = r(r7)
				scalar p80 = r(r8)
				scalar p90 = r(r9)
				replace d_inc101_pe = 1 if (inc_hh<=p10) & year==`y' & d_pe==1
				replace d_inc102_pe = 1 if (inc_hh>p10 & inc_hh<=p20) & year==`y' & d_pe==1
				replace d_inc103_pe = 1 if (inc_hh>p20 & inc_hh<=p30) & year==`y' & d_pe==1
				replace d_inc104_pe = 1 if (inc_hh>p30 & inc_hh<=p40) & year==`y' & d_pe==1
				replace d_inc105_pe = 1 if (inc_hh>p40 & inc_hh<=p50) & year==`y' & d_pe==1
				replace d_inc106_pe = 1 if (inc_hh>p50 & inc_hh<=p60) & year==`y' & d_pe==1
				replace d_inc107_pe = 1 if (inc_hh>p60 & inc_hh<=p70) & year==`y' & d_pe==1
				replace d_inc108_pe = 1 if (inc_hh>p70 & inc_hh<=p80) & year==`y' & d_pe==1
				replace d_inc109_pe = 1 if (inc_hh>p80 & inc_hh<=p90) & year==`y' & d_pe==1
				replace d_inc1010_pe = 1 if (inc_hh>p90 & inc_hh<.) & year==`y' & d_pe==1

				
				
				*unemployed excluded
				_pctile inc if year==`y' & d_e==1 [pw=weight], p(25 50 75)
				scalar p25 = r(r1)
				scalar p50= r(r2)
				scalar p75 = r(r3)
				replace d_incpc1_e = 1 if (inc<=p25) & year==`y' & d_e==1  
				replace d_incpc2_e = 1 if (inc>p25 & inc<=p50) & year==`y' & d_e==1 
				replace d_incpc3_e = 1 if (inc>p50 & inc<=p75) & year==`y' & d_e==1 
				replace d_incpc4_e = 1 if (inc>p75 & inc<.) & year==`y' & d_e==1 

				_pctile inc if year==`y' & d_e==1 [pw=weight], p(20 40 60 80)
				scalar p20 = r(r1)
				scalar p40 = r(r2)
				scalar p60 = r(r3)
				scalar p80 = r(r4)
				replace d_incpc51_e = 1 if (inc<=p20) & year==`y' & d_e==1
				replace d_incpc52_e = 1 if (inc>p20 & inc<=p40) & year==`y' & d_e==1
				replace d_incpc53_e = 1 if (inc>p40 & inc<=p60) & year==`y' & d_e==1
				replace d_incpc54_e = 1 if (inc>p60 & inc<=p80) & year==`y' & d_e==1
				replace d_incpc55_e = 1 if (inc>p80 & inc<.) & year==`y' & d_e==1

				_pctile inc if year==`y' & d_e==1 [pw=weight], p(10 20 30 40 50 60 70 80 90)
				scalar p10 = r(r1)
				scalar p20 = r(r2)
				scalar p30 = r(r3)
				scalar p40 = r(r4)
				scalar p50 = r(r5)
				scalar p60 = r(r6)
				scalar p70 = r(r7)
				scalar p80 = r(r8)
				scalar p90 = r(r9)
				replace d_incpc101_e = 1 if (inc<=p10) & year==`y' & d_e==1
				replace d_incpc102_e = 1 if (inc>p10 & inc<=p20) & year==`y' & d_e==1
				replace d_incpc103_e = 1 if (inc>p20 & inc<=p30) & year==`y' & d_e==1
				replace d_incpc104_e = 1 if (inc>p30 & inc<=p40) & year==`y' & d_e==1
				replace d_incpc105_e = 1 if (inc>p40 & inc<=p50) & year==`y' & d_e==1
				replace d_incpc106_e = 1 if (inc>p50 & inc<=p60) & year==`y' & d_e==1
				replace d_incpc107_e = 1 if (inc>p60 & inc<=p70) & year==`y' & d_e==1
				replace d_incpc108_e = 1 if (inc>p70 & inc<=p80) & year==`y' & d_e==1
				replace d_incpc109_e = 1 if (inc>p80 & inc<=p90) & year==`y' & d_e==1
				replace d_incpc1010_e = 1 if (inc>p90 & inc<.) & year==`y' & d_e==1

				_pctile inc_hh if year==`y' & d_e==1  [pw=weight], p(25 50 75)
				scalar p25 = r(r1)
				scalar p50= r(r2)
				scalar p75 = r(r3)
				replace d_inc1_e = 1 if (inc_hh<=p25) & year==`y' & d_e==1
				replace d_inc2_e = 1 if (inc_hh>p25 & inc_hh<=p50) & year==`y' & d_e==1
				replace d_inc3_e = 1 if (inc_hh>p50 & inc_hh<=p75) & year==`y' & d_e==1
				replace d_inc4_e = 1 if (inc_hh>p75 & inc_hh<.) & year==`y' & d_e==1

				_pctile inc_hh if year==`y' & d_e==1  [pw=weight], p(20 40 60 80)
				scalar p20 = r(r1)
				scalar p40 = r(r2)
				scalar p60 = r(r3)
				scalar p80 = r(r4)
				replace d_inc51_e = 1 if (inc_hh<=p20) & year==`y' & d_e==1
				replace d_inc52_e = 1 if (inc_hh>p20 & inc_hh<=p40) & year==`y' & d_e==1
				replace d_inc53_e = 1 if (inc_hh>p40 & inc_hh<=p60) & year==`y' & d_e==1
				replace d_inc54_e = 1 if (inc_hh>p60 & inc_hh<=p80) & year==`y' & d_e==1
				replace d_inc55_e = 1 if (inc_hh>p80 & inc_hh<.) & year==`y' & d_e==1

				_pctile inc_hh if year==`y' & d_e==1 [pw=weight], p(10 20 30 40 50 60 70 80 90)
				scalar p10 = r(r1)
				scalar p20 = r(r2)
				scalar p30 = r(r3)
				scalar p40 = r(r4)
				scalar p50 = r(r5)
				scalar p60 = r(r6)
				scalar p70 = r(r7)
				scalar p80 = r(r8)
				scalar p90 = r(r9)
				replace d_inc101_e = 1 if (inc_hh<=p10) & year==`y' & d_e==1
				replace d_inc102_e = 1 if (inc_hh>p10 & inc_hh<=p20) & year==`y' & d_e==1
				replace d_inc103_e = 1 if (inc_hh>p20 & inc_hh<=p30) & year==`y' & d_e==1
				replace d_inc104_e = 1 if (inc_hh>p30 & inc_hh<=p40) & year==`y' & d_e==1
				replace d_inc105_e = 1 if (inc_hh>p40 & inc_hh<=p50) & year==`y' & d_e==1
				replace d_inc106_e = 1 if (inc_hh>p50 & inc_hh<=p60) & year==`y' & d_e==1
				replace d_inc107_e = 1 if (inc_hh>p60 & inc_hh<=p70) & year==`y' & d_e==1
				replace d_inc108_e = 1 if (inc_hh>p70 & inc_hh<=p80) & year==`y' & d_e==1
				replace d_inc109_e = 1 if (inc_hh>p80 & inc_hh<=p90) & year==`y' & d_e==1
				replace d_inc1010_e = 1 if (inc_hh>p90 & inc_hh<.) & year==`y' & d_e==1


	}
}


sort month hhid

save ./files/work/data_SOC_sample.dta, replace




**************************************************************************************************************
** GENERATING CATEGORICAL VARIABLES

global varlist inc incpc 
global grouplist p pe e

foreach v in $varlist {

	gen i_`v' = .
	forvalues n=1/4 {
		replace i_`v' = `n' if d_`v'`n'==1
	}

	gen i_`v'5 = .
	forvalues n=1/5 {
		replace i_`v'5 = `n' if d_`v'5`n'==1
	}

	gen i_`v'10 = .
	forvalues n=1/10 {
		replace i_`v'10 = `n' if d_`v'10`n'==1
	}
		
	foreach g in $grouplist {

		gen i_`v'_`g' = .
		forvalues n=1/4 {
			replace i_`v'_`g' = `n' if d_`v'`n'_`g'==1
		}

		gen i_`v'5_`g'= .
		forvalues n=1/5 {
			replace i_`v'5_`g' = `n' if d_`v'5`n'_`g'==1
		}

		gen i_`v'10_`g' = .
		forvalues n=1/10 {
			replace i_`v'10_`g' = `n' if d_`v'10`n'_`g'==1
		}
		
	}
}

**************************************************************************************************************
** SAVE
sort month hhid

save ./files/work/data_SOC_sample.dta, replace
clear

capture log close


