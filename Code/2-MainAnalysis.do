*************************************************************
* Main Elasticity Analysis									*
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
log using `analysis_output'/Analysis_log.txt, replace text

* Clear matrices
mat drop _all

********************** Run Analysis 2005+, year by year ************************************
forval yr=2005(1)2015{
	use `analysis_input'/ACS`yr'.dta, clear
	disp "`yr' Loaded"
	include `analysis_code'/2-SubDescriptive.do
	include `analysis_code'/2-SubReg-Mini.do
	include `analysis_code'/2-SubReg-subgroup-Mini.do
}

include `analysis_code'/3-MakeTables.do


* Log Close
log close
/*

*****************************
*	 	Print Results		*
*****************************


**************************************
* 	 Outputting Tables to Latex 	 *
**************************************

* Output to LaTeX
* Resource: http://repec.org/bocode/e/estout/esttab.html#esttab012
* Resource: http://www.jwe.cc/2012/03/stata-latex-tables-estout/#comment-152
* Resource: http://asjadnaqvi.com/stata-to-latex-part-2/
* estout using example.tex, label replace booktabs ///
*	alignment(D{.}{.}{-1}) width(0.8\hsize)        ///
*	title(Regression table\label{tab1})




* Log Close
log close


**************************************
* 	 		Save Tables 			 *
**************************************


* Save tables for discussion
local analysis_output "${PROJECTS}/MFElasticity/Output"

log using `analysis_output'/Tables/Tables.txt, replace text
estout female1_2005 female2_2005 female3_2005 female4_2005, cells(b(fmt(2 4)) se _star)  stats(N) title("Four Models")

estout female4_2005 female4_2006 female4_2007 female4_2008 female4_2009 female4_2010 female4_2011 female4_2012, cells(b(fmt(2 4)) se _star)  stats(N) title("Female Regressions over time")
mat list female

estout male4_2005 male4_2006 male4_2007 male4_2008 male4_2009 male4_2010 male4_2011 male4_2012 , cells(b(fmt(2 4)) se _star)  stats(N) title("Male Regressions over time")
mat list male

estout sames4_2005 sames4_2006 sames4_2007 sames4_2008 sames4_2009 sames4_2010 sames4_2011, cells(b(fmt(2 4)) se _star)  stats(N) title("Same Sex Regressions over time")
mat list sames

* Log Close
log close
