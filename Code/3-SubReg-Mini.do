*************************************************************************
* Main Elasticity Analysis - Mini (only Male regs, only preferred spec	*
* Natalia Emanuel   									   				*
* Written: 16 Feb 2017									   				*
* Last Edited: 16 March 2017							   				*
*               										   				*
* NOTES: to be called by 3-MainAnalysis 								*										   			*
*************************************************************************


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
	
******************************
* 	  Main Regressions	 	 *
******************************

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


***********************************
* 	 Outcome: Annual wk hrs	  	  *
***********************************
*FIXME: add -indicate- to the models where trying different specifications
************************ Instrument: Wage Deciles ****************************
local outname hrs
local outcome annualwkhrs 
local instname decile
local instrument i.wagedecile

* Female
local group F
local sampspecs female==1 & sample_hhheads25==1 
foreach specification in nokids_noedu kids_noedu nokids_edu kids_edu{
	di in green "`group'_`outname'_`instname'_`specification'_`yr'"
	eststo `group'_`outname'_`instname'_`specification'_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	margins, eydx(lwage lwage_sp /*unearnedinc15_sp*/) atmeans
	storeelasticities `group'_`outname'_`instname'_`specification'
}

* Male 
local group M 
local sampspecs female==0 & sample_hhheads25==1 
foreach specification in nokids_noedu kids_noedu nokids_edu  kids_edu{
	di in green "`group'_`outname'_`instname'_`specification'_`yr'"
	eststo `group'_`outname'_`instname'_`specification'_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, eydx(lwage lwage_sp /*unearnedinc15_sp*/) atmeans
	storeelasticities `group'_`outname'_`instname'_`specification'
}

****************************  Instrument: Group Mean  ****************************
local outname hrs
local outcome annualwkhrs 
local instname gmean
local instrument groupmean

* Male 
local group M 
local sampspecs female==0 & sample_hhheads25==1 
foreach specification in /* nokids_noedu kids_noedu nokids_edu */ kids_edu{
	di in green "`group'_`outname'_`instname'_`specification'_`yr'"
	eststo `group'_`outname'_`instname'_`specification'_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, eydx(lwage lwage_sp /*unearnedinc15_sp*/) atmeans
	storeelasticities `group'_`outname'_`instname'_`specification'
}
* Female
local group F
local sampspecs female==1 & sample_hhheads25==1 
foreach specification in /* nokids_noedu kids_noedu nokids_edu */ kids_edu{
	di in green "`group'_`outname'_`instname'_`specification'_`yr'"
	eststo `group'_`outname'_`instname'_`specification'_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, eydx(lwage lwage_sp /*unearnedinc15_sp*/) atmeans
	storeelasticities `group'_`outname'_`instname'_`specification'
}



*******************************************
* 	Outcome: Log Cond Annual wk hrs	  	  *
*******************************************

************************ Instrument: Wage Deciles ****************************
local outname chrs
local outcome logcondhrs 
local instname decile
local instrument i.wagedecile

* Male 
local group M 
local sampspecs female==0 & sample_hhheads25==1 
foreach specification in /* nokids_noedu kids_noedu nokids_edu */ kids_edu{
	di in green "`group'_`outname'_`instname'_`specification'_`yr'"
	eststo `group'_`outname'_`instname'_`specification'_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	storeelasticities `group'_`outname'_`instname'_`specification'
}

* Female
local group F
local sampspecs female==1 & sample_hhheads25==1 
foreach specification in /* nokids_noedu kids_noedu nokids_edu */ kids_edu{
	di in green "`group'_`outname'_`instname'_`specification'_`yr'"
	eststo `group'_`outname'_`instname'_`specification'_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	storeelasticities `group'_`outname'_`instname'_`specification'
}


****************************  Instrument: Group Mean  ****************************
local outname chrs
local outcome logcondhrs 
local instname gmean
local instrument groupmean

* Male 
local group M 
local sampspecs female==0 & sample_hhheads25==1 
foreach specification in /* nokids_noedu kids_noedu nokids_edu */ kids_edu{
	di in green "`group'_`outname'_`instname'_`specification'_`yr'"
	eststo `group'_`outname'_`instname'_`specification'_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	storeelasticities `group'_`outname'_`instname'_`specification'
}

* Female
local group F
local sampspecs female==1 & sample_hhheads25==1 
foreach specification in /* nokids_noedu kids_noedu nokids_edu */ kids_edu{
	di in green "`group'_`outname'_`instname'_`specification'_`yr'"
	eststo `group'_`outname'_`instname'_`specification'_`yr': ivregress 2sls `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	storeelasticities `group'_`outname'_`instname'_`specification'
}


*****************************  
*     	Participation  		*
*****************************

************************ Instrument: Wage Deciles ****************************
local outname part
local outcome outcomeparticip 
local instname decile
local instrument i.wagedecile


* Male 
local group M 
local sampspecs female==0 & sample_hhheads25==1 
foreach specification in /* nokids_noedu kids_noedu nokids_edu */ kids_edu{
	di in green "`group'_`outname'_`instname'_`specification'_`yr'"
	eststo `group'_`outname'_`instname'_`specification'_`yr': ivprobit `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, dydx(lwage lwage_sp /*unearnedinc15_sp*/) atmeans
	storeelasticities `group'_`outname'_`instname'_`specification'
}
* Female
local group F
local sampspecs female==1 & sample_hhheads25==1
foreach specification in /* nokids_noedu kids_noedu nokids_edu */ kids_edu{
	di in green "`group'_`outname'_`instname'_`specification'_`yr'"
	eststo `group'_`outname'_`instname'_`specification'_`yr': ivprobit `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, dydx(lwage lwage_sp /*unearnedinc15_sp*/) atmeans
	storeelasticities `group'_`outname'_`instname'_`specification'
}

****************************  Instrument: Group Mean  ****************************
local outname part
local outcome outcomepart 
local instname gmean
local instrument groupmean


* Male 
local group M 
local sampspecs female==0 & sample_hhheads25==1 
foreach specification in /* nokids_noedu kids_noedu nokids_edu */ kids_edu{
	di in green "`group'_`outname'_`instname'_`specification'_`yr'"
	eststo `group'_`outname'_`instname'_`specification'_`yr': ivprobit `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, dydx(lwage lwage_sp /*unearnedinc15_sp*/) atmeans
	storeelasticities `group'_`outname'_`instname'_`specification'
}

* Female
local group F
local sampspecs female==1 & sample_hhheads25==1 
foreach specification in /* nokids_noedu kids_noedu nokids_edu */ kids_edu{
	eststo `group'_`outname'_`instname'_`specification'_`yr': ivprobit `outcome' (lwage = `instrument') ``specification'' if `sampspecs' [pw=perwt]
	estadd margins, dydx(lwage lwage_sp /*unearnedinc15_sp*/) atmeans
	storeelasticities `group'_`outname'_`instname'_`specification'
}






