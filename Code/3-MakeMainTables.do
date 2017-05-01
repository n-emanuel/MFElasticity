*****************************************************************************
* Generating graphs and tables of analysis results							*
* Natalia Emanuel   									   					*
* Written: 16 Feb 2017									   					*
* Last Edited: 30 April 2017							   					*
*               										   					*
* NOTES: to be called by 3-MainAnalysis after 3-SubReg-Mini.do				*										   			*
*****************************************************************************


**********************************
* 	Print Elasticity Graphs		 *
**********************************

* Male/Female elasticity wrt own  & sp wages over time 
* (annual hrs, gmean)
clear
svmat M_hrs_gmean_kids_edu_own, names(col)
rename b bMown
rename se seMown
svmat F_hrs_gmean_kids_edu_own, names(col)
rename b bFown
rename se seFown
svmat M_hrs_gmean_kids_edu_sp, names(col)
rename b bMsp
rename se seMsp
svmat F_hrs_gmean_kids_edu_sp, names(col)
rename b bFsp
rename se seFsp
gen Year = _n+2004

graph twoway (line bMown Year, lpattern("l") lcolor("red")) ///
	(line bFown Year, lpattern("l") lcolor("blue")) ///
	(line bMsp Year, lpattern("dash") lcolor("red")) ///
	(line bFsp Year, lpattern("dash") lcolor("blue")), ///
	graphregion(color(white)) bgcolor(white) ///
	legend(label(1 "Males, own") label(2 "Females, own") label(3 "Males, spouse") label(4 "Females, sp")) ///
	title("Elasticity of Hours with respect to Wages and Spouse's Wages by Sex, 2005-2015")
graph export `analysis_output'/Figures/hrs_elasticity.png, replace


* Conditional Hours: Male/Female elasticity wrt own  & sp wages over time 
* (condl hrs, gmean)
clear
svmat M_chrs_gmean_kids_edu_own, names(col)
rename b bMown
rename se seMown
svmat F_chrs_gmean_kids_edu_own, names(col)
rename b bFown
rename se seFown
svmat M_chrs_gmean_kids_edu_sp, names(col)
rename b bMsp
rename se seMsp
svmat F_chrs_gmean_kids_edu_sp, names(col)
rename b bFsp
rename se seFsp
gen Year = _n+2004

graph twoway (line bMown Year, lpattern("l") lcolor("red")) ///
	(line bFown Year, lpattern("l") lcolor("blue")) ///
	(line bMsp Year, lpattern("dash") lcolor("red")) ///
	(line bFsp Year, lpattern("dash") lcolor("blue")), ///
	graphregion(color(white)) bgcolor(white) ///
	legend(label(1 "Males, own") label(2 "Females, own") label(3 "Males, spouse") label(4 "Females, sp")) ///
	title("Elasticity of Conditional Hours with respect to Wages and Spouse's Wages by Sex, 2005-2015")
graph export `analysis_output'/Figures/chrs_elasticity.png, replace


* Participation: Male/Female elasticity wrt own  & sp wages over time 
* (gmean)
clear
svmat M_part_gmean_kids_edu_own, names(col)
rename b bMown
rename se seMown
svmat F_part_gmean_kids_edu_own, names(col)
rename b bFown
rename se seFown
svmat M_part_gmean_kids_edu_sp, names(col)
rename b bMsp
rename se seMsp
svmat F_part_gmean_kids_edu_sp, names(col)
rename b bFsp
rename se seFsp
gen Year = _n+2004

graph twoway (line bMown Year, lpattern("l") lcolor("red")) ///
	(line bFown Year, lpattern("l") lcolor("blue")) ///
	(line bMsp Year, lpattern("dash") lcolor("red")) ///
	(line bFsp Year, lpattern("dash") lcolor("blue")), ///
	graphregion(color(white)) bgcolor(white) ///
	legend(label(1 "Males, own") label(2 "Females, own") label(3 "Males, spouse") label(4 "Females, sp")) ///
	title("Elasticity of Participation with respect to Wages and Spouse's Wages by Sex, 2005-2015")
graph export `analysis_output'/Figures/part_elasticity.png, replace


**********************************
* 	Print Regression Tables		 *
**********************************

*************** Female Comparing Specifications in 2005 ********************
esttab F_hrs_decile_nokids_noedu_2005 F_hrs_decile_kids_noedu_2005 ///
	F_hrs_decile_nokids_edu_2005 F_hrs_decile_kids_edu_2005 ///
	using `analysis_output'/Tables/Four_models_F_05.tex, replace stats(N) ///
	title("Comparing Four Models")


*************** Male Comparing Instrument in 2005 ***********************
esttab M_hrs_decile_kids_edu_2005 M_hrs_gmean_kids_edu_2005 ///
	M_chrs_decile_kids_edu_2005 M_chrs_gmean_kids_edu_2005 ///
	M_part_decile_kids_edu_2005 M_part_gmean_kids_edu_2005 ///
	using `analysis_output'/Tables/Comparing_instrument_M_05.tex, replace stats(N) ///
	title("Comparing Instruments")	

*************** Females Annual Hrs Across Time (hrs, gmean, kids_edu) ***********************
esttab F_hrs_gmean_kids_edu_2005  F_hrs_gmean_kids_edu_2006  F_hrs_gmean_kids_edu_2007  F_hrs_gmean_kids_edu_2008 ///
	 F_hrs_gmean_kids_edu_2009  F_hrs_gmean_kids_edu_2010 F_hrs_gmean_kids_edu_2011 F_hrs_gmean_kids_edu_2012 ///
	 F_hrs_gmean_kids_edu_2013 F_hrs_gmean_kids_edu_2014 F_hrs_gmean_kids_edu_20115 ///
	 using `analysis_output'/Tables/Females_hrs_across_time.tex, ///
	 label replace title("Female Hours, 2005-2015") ///
	 stats(N) keep(lwage lwage_sp unearnedinc15_sp raceblack racehisp raceother edulths eduaa eduba)



*************** Males Annual Hrs Across Time (hrs, gmean, kids_edu) ***********************
esttab M_hrs_gmean_kids_edu_2005  M_hrs_gmean_kids_edu_2006  M_hrs_gmean_kids_edu_2007  M_hrs_gmean_kids_edu_2008 ///
	 M_hrs_gmean_kids_edu_2009  M_hrs_gmean_kids_edu_2010 M_hrs_gmean_kids_edu_2011 M_hrs_gmean_kids_edu_2012 ///
	 M_hrs_gmean_kids_edu_2013 M_hrs_gmean_kids_edu_2014 M_hrs_gmean_kids_edu_20115 ///
	 using `analysis_output'/Tables/Males_hrs_across_time.tex, ///
	 label replace title("Male Hours, 2005-2015") ///
	 stats(N) keep(lwage lwage_sp unearnedinc15_sp raceblack racehisp raceother edulths eduaa eduba)

	 
*************** Female Conditional Hours: Across Time ************************
esttab F_chrs_gmean_kids_edu_2005  F_chrs_gmean_kids_edu_2006  F_chrs_gmean_kids_edu_2007  F_chrs_gmean_kids_edu_2008 ///
	 F_chrs_gmean_kids_edu_2009  F_chrs_gmean_kids_edu_2010 F_chrs_gmean_kids_edu_2011 F_chrs_gmean_kids_edu_2012 ///
	 F_chrs_gmean_kids_edu_2013 F_chrs_gmean_kids_edu_2014 F_chrs_gmean_kids_edu_20115 ///
	 using `analysis_output'/Tables/Females_chrs_across_time.tex, ///
	 label replace title("Female Conditional Hours, 2005-2015") ///
	 stats(N) keep(lwage lwage_sp unearnedinc15_sp raceblack racehisp raceother edulths eduaa eduba)

*************** Male Conditional Hours: Across Time **************************
esttab M_chrs_gmean_kids_edu_2005  M_chrs_gmean_kids_edu_2006  M_chrs_gmean_kids_edu_2007  M_chrs_gmean_kids_edu_2008 ///
	 M_chrs_gmean_kids_edu_2009  M_chrs_gmean_kids_edu_2010 M_chrs_gmean_kids_edu_2011 M_chrs_gmean_kids_edu_2012 ///
	 M_chrs_gmean_kids_edu_2013 M_chrs_gmean_kids_edu_2014 M_chrs_gmean_kids_edu_20115 ///
	 using `analysis_output'/Tables/Males_chrs_across_time.tex, ///
	 label replace title("Male Conditional Hours, 2005-2015") ///
	 stats(N) keep(lwage lwage_sp unearnedinc15_sp raceblack racehisp raceother edulths eduaa eduba)


*************** Female Participation: Across Time ****************************
esttab F_part_gmean_kids_edu_2005  F_part_gmean_kids_edu_2006  F_part_gmean_kids_edu_2007  F_part_gmean_kids_edu_2008 ///
	 F_part_gmean_kids_edu_2009  F_part_gmean_kids_edu_2010 F_part_gmean_kids_edu_2011 F_part_gmean_kids_edu_2012 ///
	 F_part_gmean_kids_edu_2013 F_part_gmean_kids_edu_2014 F_part_gmean_kids_edu_20115 ///
	 using `analysis_output'/Tables/Females_part_across_time.tex, ///
	 label replace title("Female Participation, 2005-2015") ///
	 stats(N) keep(lwage lwage_sp unearnedinc15_sp raceblack racehisp raceother edulths eduaa eduba)


*************** Male Participation: Across Time ******************************
esttab M_part_gmean_kids_edu_2005  M_part_gmean_kids_edu_2006  M_part_gmean_kids_edu_2007  M_part_gmean_kids_edu_2008 ///
	 M_part_gmean_kids_edu_2009  M_part_gmean_kids_edu_2010 M_part_gmean_kids_edu_2011 M_part_gmean_kids_edu_2012 ///
	 M_part_gmean_kids_edu_2013 M_part_gmean_kids_edu_2014 M_part_gmean_kids_edu_20115 ///
	 using `analysis_output'/Tables/Males_part_across_time.tex, ///
	 label replace title("Male Participation, 2005-2015") ///
	 stats(N) keep(lwage lwage_sp unearnedinc15_sp raceblack racehisp raceother edulths eduaa eduba)
