*************************************************************
* Main Elasticity Analysis									*
* Natalia Emanuel   									   	*
* Written: 16 Feb 2017									   	*
* Last Edited: 16 March 2017							   	*
*               										   	*
* NOTES: 										   			*
*************************************************************

* Paths for finding and saving data
local build_output "${DATA_PATH}/ACS/Build_IPUMS_Elasticity/Output"
local analysis_output "${PROJECTS}/MFElasticity/Output"

******************** Setting survey weight options *************************
* If going Replicate weights svyset [pw=wgtp],  vce(brr) brrweight(repwtp1-repwtp80) fay(.5)mse
* Reference: https://usa.ipums.org/usa/complex_survey_vars/userNotes_variance.shtml
svyset cluster [pweight=perwt], strata(strata)

******************************
* 	  Descriptive Tables 	 *
******************************
local col = `yr'-2004

* How means in explanatory variables change over the years for Males & Females

* Males
matrix xmeansM = J(17,11,.)

local row = 1
* FIXME: later need to add eduhs_sp
foreach i in lwage edulths eduhs eduaa eduba lwage_sp unearned edulths_sp eduaa_sp eduba_sp nokids0 nokids1 nokids2 nokids3t5 nokids6t11 nokids12t17{
svy, subpop(if sample_hhheads25==1 & female==0): mean `i'
mat temp = r(table)
mat list temp
disp `row', `col'
mat xmeansM[`row', `col'] = temp[1,1]
local row = `row'+1
}
mat temp = e(N_sub)
mat xmeansM[`row', `col'] = temp[1,1]
mat list xmeansM

* Females
matrix xmeansF = J(17,11,.)

local row = 1
foreach i in lwage lwage_sp unearned edulths eduhs eduaa eduba edulths_sp eduaa_sp eduba_sp nokids0 nokids1 nokids2 nokids3t5 nokids6t11 nokids12t17{
svy, subpop(if sample_hhheads25==1 & female==1): mean `i'
mat temp = r(table)
mat xmeansF[`row', `col'] = temp[1,1]
local row = `row'+1
}
mat temp = r(N_sub)
mat xmeansF[`row', `col'] = temp[1,1]
mat list xmeansF


* Trends in work for partnered males and females
matrix worktrendsM = J(3 ,11, .)

local row=1
foreach i in annualwkhrs outcomecond outcomeparticip {
svy, subpop(if sample_hhheads25==1 & female==0): mean `i'
mat temp = r(table)
mat worktrendsM[`row', `col'] = temp[1,1]
local row = `row'+1
}
mat list worktrendsM

matrix worktrendsF = J(3 ,11, .)
local row=1
foreach i in annualwkhrs outcomecond outcomeparticip {
svy, subpop(if sample_hhheads25==1 & female==1): mean `i'
mat temp = r(table)
mat worktrendsF[`row', `col'] = temp[1,1]
local row = `row'+1
}
mat list worktrendsF




