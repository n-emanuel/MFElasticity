*************************************************************
* Cleaning ACS Dataset for Elasticity Analysis				*
* Natalia Emanuel   									   	*
* Written: 16 March 2017								   	*
* Last Edited: 13 April 2017							   	*
*               										   	*
* NOTES: Takes each year's data, cleans it and saves		*
* as a separate file for easier analysis in R later			*
*************************************************************

* Paths for finding and saving data
local build_output "${DATA_PATH}/ACS/Build_IPUMS_Elasticity/Output"
local analysis_output "${PROJECTS}/MFElasticity/Output"
local analysis_input "${PROJECTS}/MFElasticity/Input"
local analysis_code "${PROJECTS}/MFElasticity/Code"


********************** Grab price index data for calc'ing real wages ************************************
import delimited `analysis_input'/PCEPI.csv, clear

gen date1=date(date, "YMD")
format date1 %td
gen year=year(date1)

collapse (mean) pcepi, by(year)

tempfile priceindex
save `priceindex'

********************** Load Data for 2003+, year by year ************************************
*FIXME: Don't use the small dataset for real analyses -- just for local analyses
foreach yr in 2003(1)20015{
	use `build_output'/mfelasticity.dta if inlist(year, `yr'), clear
	do `analysis_code'/1-CleanACS.do
	save `analysis_input'/ACS`yr'.dta, replace
}

