*************************************************************
* SubPopulation Elasticity Analysis							*
* Natalia Emanuel   									   	*
* Written: 16 Feb 2017									   	*
* Last Edited: 26 April 2017							   	*
*               										   	*
* NOTES: 										   			*
*************************************************************

* Paths for finding and saving data
local build_output "${DATA_PATH}/ACS/Build_IPUMS_Elasticity/Output"
local analysis_output "${PROJECTS}/MFElasticity/Output"
local analysis_input "${PROJECTS}/MFElasticity/Input"
local analysis_code "${PROJECTS}/MFElasticity/Code"

* Log the Analysis
cap log close
log using `analysis_output'/Subgroup_log.txt, replace text

* Clear matrices
mat drop _all

********************** Run Analysis 2005+, year by year ************************************
forval yr=2005(1)2015{
	use `analysis_input'/ACS`yr'.dta, clear
	disp "`yr' Loaded"
	include `analysis_code'/4-SubPopReg-Mini.do
}

include `analysis_code'/4-MakePopTables.do




* Log Close
log close
