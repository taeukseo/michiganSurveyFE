/*

00_createVariablesAggregate.do:

creates aggregate time series from FRED
modified from script by Rozyspal and Schlafmann
by Taeuk Seo 2025-12-15

*/


clear all
capture log close

set maxvar 32767
set more off

*-------------------------
* INFLATION (based on CPI all urban consumers), MONTHLY
* source: U.S. Bureau of Labor Statistics, Consumer Price Index for All Urban Consumers: All Items in U.S. City Average [CPIAUCSL], retrieved from FRED, Federal Reserve Bank of St. Louis; https://fred.stlouisfed.org/series/CPIAUCSL, May 19, 2016.

*load data

use "./files/downloaded/data_cpi_monthly", clear
tsset month, monthly
gen inflation = (cpi-l12.cpi)/l12.cpi
drop if inflation==.
qui sum cpi if month==ym(2022,1)		//change base quarter to 2007m1
scalar base = r(mean)
replace cpi = cpi / base
save ./files/work/data_inflation_monthly, replace

use "./files/downloaded/data_cpi_monthly", clear
tsset month, monthly
gen inflation = (cpi-l12.cpi)/l12.cpi
gen year = year(dofm(month))
gen season = month(dofm(month))
keep if season == 12
qui sum cpi if year == 2022
scalar base = r(mean)
replace cpi = cpi / base
keep year cpi inflation
save "./files/work/data_inflation_annual", replace

*-------------------------
** UNEMPLOYMENT RATE (MONTHLY)
* source: U.S. Bureau of Labor Statistics, Unemployment Rate [UNRATE], retrieved from FRED, Federal Reserve Bank of St. Louis; https://fred.stlouisfed.org/series/UNRATE, May 25, 2016.

*load data

use "./files/downloaded/data_urate_monthly", clear
tsset month
save ./files/work/data_urate_monthly.dta, replace

*-------------------------
* AVERAGE UNEMPLOYMENT BENEFIT - MONTHLY, ANNUAL, AND QUARTERLY 
* source: US Department of Labor, http://oui.doleta.gov/unemploy/claimssum.asp

*load data

use "./files/downloaded/data_avgUnempBenefit", clear

rename weeklyBenefitAmount avgben_week
label variable avgben_week "weekly benefit amount (12 month average) - US Dep of Labor (http://oui.doleta.gov/unemploy/claimssum.asp)"
gen avgben_month = 4*avgben_week
gen avgben = 52*avgben_week
gen year = year(date)
gen season = month(date)
gen month = ym(year,season)
format month %tm

sort month
merge 1:1 month using ./files/work/data_inflation_monthly
drop if _merge!=3
drop _merge

gen avgben_r = avgben / cpi

drop inflation cpi

keep avgben avgben_r year
collapse (mean) avgben avgben_r, by(year)

save ./files/work/avgUnempBen_annual, replace

capture log close
