/*

000_installPackages.do:

install the required STATA packages

*/


clear all
set more off

sysdir set PLUS "./files/ssc_plus"

* *** Add required packages from SSC to this list ***
local ssc_packages "distinct estout outtable grstyle bgshade egenmore schemepack"

if !missing("`ssc_packages'") {
    foreach pkg of local ssc_packages {
        * install using ssc, but avoid re-installing if already present
        
        disp "`pkg'"
        
        capture which `pkg'
        disp _rc
        if _rc == 111 {                 
            dis "Installing `pkg'"
            ssc install `pkg', replace
            }
    }
}

grstyle init
grstyle color major_grid gs12
grstyle linewidth major_grid thin
grstyle linepattern major_grid solid
grstyle set grid

set scheme white_tableau