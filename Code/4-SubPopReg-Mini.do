*****************************************************************************
* Subgroup Elasticity Analysis - Mini (only Male regs, only preferred spec)	*
* Natalia Emanuel   									   					*
* Written: 16 Feb 2017									   					*
* Last Edited: 16 March 2017							   					*
*               										   					*
* NOTES: to be called by 4-PopAnalysis										*										   			*
*****************************************************************************

**************************************
*  Program to store elasticities	 *
**************************************

capture program drop storeelasticities
program define storeelasticities
	* store output
	mat temp = r(table)
	* confirm the matrix exists. If not, create it & store there
	capture confirm mat `0'_own
	if _rc==0{
		matrix `0'_own = `0'_own \ temp[1..2,1]'
		matrix `0'_sp  = `0'_sp  \ temp[1..2,2]'
		*matrix `0'_une = `0'_une \ temp[1..2,3]'
	}
	else{
		matrix `0'_own = temp[1..2,1]'
		matrix `0'_sp  = temp[1..2,2]'
		*matrix `0'_une = temp[1..2,3]'
	}

end
	
* Subgroup Analyses have the following specification
* Instrument: Group Mean
* Specification Kids_Edu
* Outcome Annual Wk Hours

**************************** Controls ****************************
local income lwage_sp unearnedinc15_sp validwage
local location metroarea regn_neweng regn_midatl  regn_centne regn_centnw regn_centse regn_centsw regn_mountn regn_pacifc 
local ages age age2 age_sp age2_sp 
local racecodes raceblack racehisp raceother raceblack_sp racehisp_sp raceother_sp 
local edus edulths eduaa eduba edulths_sp eduaa_sp eduba_sp
local fam married nokids0 nokids1 nokids2 nokids3t5 nokids6t11 nokids12t17

************************ Four control specifications ****************************
local nokids_noedu `income' `location' `ages' `racecodes'
local kids_noedu `income' `location' `ages' `racecodes' `fam'
local nokids_edu `income' `location' `ages' `racecodes' `edus'
local kids_edu `income' `location' `ages' `racecodes' `edus' `fam'


**************************** Controls ****************************
local outcome annual 
local instrument groupmean
local specification kids_edu

******************************
* 		By Education 		 *
******************************


* Male
local group M
foreach educat in lths hs aa ba{
	local sampspecs edu`educat'==1 & female==0 & sample_hhheads25==1
	di in green "`group'_subEDU_`educat'_`yr'"
	eststo `group'_subEDU_`educat'_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, eydx(lwage lwage_sp /*unearnedinc15_sp*/) atmeans
	storeelasticities `group'_subEDU_`educat'
}

* Female
local group F
foreach educat in lths hs aa ba{
	di in green "`group'_subEDU_`educat'_`yr'"
	local sampspecs edu`educat'==1 & female==1 & sample_hhheads25==1
	eststo `group'_subEDU_`educat'_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, eydx(lwage lwage_sp /*unearnedinc15_sp*/) atmeans
	storeelasticities `group'_subEDU_`educat'
}


******************************
* 		Kids <5 yrs 		 *
******************************

* Male
local group M
forval i = 0/1{
local sampspecs kidslt5==`i' & female==0 & sample_hhheads25==1
	di in green "`group'_subKIDS_`yr'"
	eststo `group'_subKIDS_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, eydx(lwage lwage_sp /*unearnedinc15_sp*/)  atmeans
	storeelasticities `group'_subKIDS_kids`i'
}

* Female
local group F
forval i = 0/1{
	local sampspecs kidslt5==`i' & female==1 & sample_hhheads25==1
	di in green "`group'_subKIDS_`yr'"
	eststo `group'_subKIDS_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, eydx(lwage lwage_sp /*unearnedinc15_sp*/) atmeans
	storeelasticities `group'_subKIDS_kids`i'
}


******************************
* 		By Age Cat. 		 *
******************************

* Male
local group M
forval i = 1/3{
	local sampspecs agecat==`i' & female==0 & sample_hhheads25==1
	di in green "`group'_subAGE_age`i'_`yr'"
	eststo `group'_subAGE_age`i'_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, eydx(lwage lwage_sp /*unearnedinc15_sp*/)  atmeans
	storeelasticities `group'_subAGE_age`i'
}

* Female
local group F
forval i = 1/3{
	local sampspecs agecat==`i' & female==1 & sample_hhheads25==1
	di in green "`group'_subAGE_age`i'_`yr'"
	eststo `group'_subAGE_age`i'_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, eydx(lwage lwage_sp /*unearnedinc15_sp*/) atmeans
	storeelasticities `group'_subAGE_age`i'
}


******************************
* 		By Race/Ethn 		 *
******************************

* Male
local group M
forval i = 1/4{
	local sampspecs race==`i' & female==0 & sample_hhheads25==1
	di in green "`group'_subRACE_race`i'_`yr'"
	eststo `group'_subRACE_race`i'_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, eydx(lwage lwage_sp /*unearnedinc15_sp*/)  atmeans
	storeelasticities `group'_subRACE_race`i'
}

* Female
local group F
forval i = 1/4{
	local sampspecs race==`i' & female==1 & sample_hhheads25==1
	di in green "`group'_subRACE_race`i'_`yr'"
	eststo `group'_subRACE_race`i'_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, eydx(lwage lwage_sp /*unearnedinc15_sp*/) atmeans
	storeelasticities `group'_subRACE_race`i'
}

******************************
* 		By Citizenship 		 *
******************************


* Male
local group M
forval i = 0/1{
	local sampspecs citizen==`i' & female==0 & sample_hhheads25==1
	di in green "`group'_subCITZ_cit`i'_`yr'"
	eststo `group'_subCITZ_cit`i'_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, eydx(lwage lwage_sp /*unearnedinc15_sp*/) atmeans
	storeelasticities `group'_subCITZ_cit`i'
}

* Female
local group F
forval i = 0/1{
	local sampspecs citizen==`i' & female==1 & sample_hhheads25==1
	di in green "`group'_subCITZ_cit`i'_`yr'"
	eststo `group'_subCITZ_cit`i'_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, eydx(lwage lwage_sp /*unearnedinc15_sp*/) atmeans
	storeelasticities `group'_subCITZ_cit`i'
}


******************************
* 		By Region	 		 *
******************************

* Male
local group M
foreach region in neweng midatl centne centnw souatl centse centsw mountn pacifc{
	local sampspecs regn_`region'==1 & female==0 & sample_hhheads25==1
	di in green "`group'_subREGN_`region'_`yr'"
	eststo `group'_subREGN_`region'_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, eydx(lwage lwage_sp /*unearnedinc15_sp*/) atmeans
	storeelasticities `group'_subREGN_`region'
}

* Female
local group F
foreach region in neweng midatl centne centnw souatl centse centsw mountn pacifc{
	di in green "`group'_subREGN_`region'_`yr'"
	local sampspecs regn_`region'==1 & female==1 & sample_hhheads25==1
	eststo `group'_subREGN_`region'_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, eydx(lwage lwage_sp /*unearnedinc15_sp*/) atmeans
	storeelasticities `group'_subREGN_`region'
}


******************************
* 		By Married Satus	 *
******************************

* Male
local group M
foreach mars in married partnered{
	local sampspecs `mars'==1 & female==0 & sample_hhheads25==1
	di in green "`group'_subMAR_`mars'_`yr'"
	eststo `group'_subMAR_`mars'_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, eydx(lwage lwage_sp /*unearnedinc15_sp*/) atmeans
	storeelasticities `group'_subMAR_`mars'
}

* Female
local group F
foreach mars in married partnered{
	local sampspecs `mars'==1 & female==1 & sample_hhheads25==1
	di in green "`group'_subMAR_`mars'_`yr'"
	eststo `group'_subMAR_`mars'_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, eydx(lwage lwage_sp /*unearnedinc15_sp*/) atmeans
	storeelasticities `group'_subMAR_`mars'
}

*****************************
*	 	Resources			*
*****************************
* Elasticities	
* http://blog.modelworks.ch/elasticities-in-estimated-linear-models-2/
* after probit: estadd margins, expression(normalden(xb())*_b[lnx]/100)
