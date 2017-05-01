*************************************************************
* Cleaning ACS Dataset for Elasticity Analysis				*
* Natalia Emanuel   									   	*
* Written: 16 Feb 2017									   	*
* Last Edited: 13 April 2017							   	*
*               										   	*
* NOTES: Takes each year's data, cleans it and saves		*
* as a separate file for easier analysis in R later			*
*************************************************************
clear all

* Paths for finding and saving data
local build_output "${DATA_PATH}/ACS/Build_IPUMS_Elasticity/Output"
local analysis_output "${PROJECTS}/MFElasticity/Output"
local analysis_input "${PROJECTS}/MFElasticity/Input"
local analysis_code "${PROJECTS}/MFElasticity/Code"

* Log the progress
cap log close
log using `analysis_input'/Clean_log.txt, replace

********************** Grab price index data for calc'ing real wages ************************************
import delimited `analysis_input'/PCEPI.csv, clear

gen date1=date(date, "YMD")
format date1 %td
gen year=year(date1)

collapse (mean) pcepi, by(year)

tempfile priceindex
save `priceindex'

********************** Load Data for 2003+, year by year ************************************
*use year serial if mod(serial, 1000)==0 using "`build_output'/mfelasticity.dta", clear
*levelsof year, local(yearlevels)

*foreach yr of local yearlevels{
forval yr = 2005(1)2015{
	use `build_output'/mfelasticity.dta if year==`yr', clear
	disp "`yr' Loaded"
	qui: include `analysis_code'/1-CleanACS.do
	qui: include `analysis_code'/1-ImputeAndInstrument.do
	disp "Saving `yr'"
	save `analysis_input'/ACS`yr'.dta, replace
}

* Log Close
log close

