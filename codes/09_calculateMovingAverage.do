/*

09_getMovingAverage.do:

- obtains moving average mean forecast errors 
  (overall and by income group)

*/


clear all
capture log close

set maxvar 32767
set more off


// Load the dataset
use ./files/work/data_imputed_win, clear

// Set the survey design
qui mi svyset _n [pw=weight]

// Define the range of dates
local firstmonth = ym(1986,7)
local lastmonth = ym(2020,12)
local Nmonths = `lastmonth' - `firstmonth' + 1

// Initialize matrices to store results
matrix define MONTH = J(`Nmonths', 1, .)
matrix define B_e = J(`Nmonths', 1, .)

local monthcount = 0

// Loop through each month
forvalues currmonth = `firstmonth'/`lastmonth' {
    
    local monthcount = `monthcount' + 1
    
    matrix MONTH[`monthcount', 1] = `currmonth'
    disp %tmCCYYNN `currmonth'
    
    // Filter data for the current month
    qui {
        preserve
        keep if month == `currmonth'
        // Calculate the mean if there are observations
        capture mi estimate: svy, subpop(d_e): mean fe_inc_r_w5
        if _rc == 0 {
            matrix observe = r(table)
            matrix B_e[`monthcount', 1] = observe[1, 1]
        }
		else {
            matrix B_e[`monthcount', 1] = .
            display "No observation for month `currmonth'"
        }
        
        restore
    }
}

// Save the results to a Stata file
clear
set obs `Nmonths'

svmat double MONTH, name(month)
ren month1 month

svmat double B_e, name(b_e)
ren b_e1 e_mean_fe_inc_r_w5

drop if month == .
format month %tmCCYYNN
rename month modate
tsset modate
tssmooth ma pr_mean_12 = e_mean_fe_inc_r_w5, window(6 1 6)
save ./files/output/forecastErrors, replace
