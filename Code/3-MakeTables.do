*****************************************************************************
* Generating graphs and tables of analysis results							*
* Natalia Emanuel   									   					*
* Written: 16 Feb 2017									   					*
* Last Edited: 30 April 2017							   					*
*               										   					*
* NOTES: to be called by 2-MainAnalysis after running the rest of 2-....do	*										   			*
*****************************************************************************

**********************************
* 	Make Descriptive Graphs		 *
**********************************

* Work trends over time
mat worktrends = worktrendsM \ worktrendsF
mat worktrendsT = worktrends' 
mat colnames worktrendsT = annualM condhrsM particM annualF condhrsF particF
clear 
svmat worktrendsT, names(col)
label var annualM "Annual work hours, Male"
label var annualF "Annual work hours, Female"
gen year = _n+2004

* annual work hours and conditional hours
graph twoway (line annualM year, lpattern("l") lcolor("red")) ///
	(line annualF year, lpattern("l") lcolor("blue")) ///
	(line condhrsM year, lpattern("dash") lcolor("red")) ///
	(line condhrsF year, lpattern("dash") lcolor("blue")), /// 
	graphregion(color(white)) bgcolor(white) ///
	legend(label(1 "Annual hrs, Males") label(2 "Annual hrs, Females") label(3 "Conditional hrs, Males") label(4 "Conditional hrs, Females")) ///
	title("Hours of Work by Sex, 2005-2015")
graph export `analysis_output'/Figures/worktrends.png, replace

* participation 
graph twoway line particM particF year, graphregion(color(white)) bgcolor(white) ///
	legend(label(1 "Males") label(2 "Females")) ///
	title("Labor Force Participation by Sex, 2005-2015")
graph export `analysis_output'/Figures/participtrends.png, replace



**********************************
* 	Print Descriptive Tables	 *
**********************************

* Explanatory Variables' means shift with time
mat colname xmeansM = 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 
* FixME: Later need to add eduhs_sp to rownames
mat rowname xmeansM= "Log wage" "Less than HS" "High School" "Some College" "BA" ///
	"Spouse log wage" "Spouse Unearned Income" "Spouse Less than HS" "Spouse Some College" "Spouse BA" ///
	"Kids <1" "Kids 1 year old" "Kids 2 years old" "Kids 3-5" "Kids 6-11" "Kids 12-17" ///
	"N"
esttab matrix(xmeansM, fmt(%9.2f)) using ${PROJECTS}/MFElasticity/Output/Tables/xmeansM.tex, replace label 

mat colname xmeansF = 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 
* FixME: Later need to add eduhs_sp to rownames
mat rowname xmeansF= "Log wage" "Less than HS" "High School" "Some College" "BA" ///
	"Spouse log wage" "Spouse Unearned Income" "Spouse Less than HS" "Spouse Some College" "Spouse BA" ///
	"Kids <1" "Kids 1 year old" "Kids 2 years old" "Kids 3-5" "Kids 6-11" "Kids 12-17" ///
	"N"
esttab matrix(xmeansF, fmt(%9.2f)) using ${PROJECTS}/MFElasticity/Output/Tables/xmeansF.tex, replace label 



**********************************
* 	Print Elasticity Graphs		 *
**********************************

* Male/Female elasticity wrt own  & sp wages over time
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
	(line bFown Year, lpattern("l") lcolor("blue")), ///
	(line bMsp Year, lpattern("dash") lcolor("red")) ///
	(line bFsp Year, lpattern("dash") lcolor("blue"))
	graphregion(color(white)) bgcolor(white) ///
	legend(label(1 "Males, own") label(2 "Females, own") label(3 "Males, spouse") label(4 "Females, sp")) ///
	title("Elasticity with respect to Wages and Spouse's Wages by Sex, 2005-2015")
graph export `analysis_output'/Figures/elasticity.png, replace



**********************************
* 	Print Regression Tables		 *
**********************************


*************** Male Comparing Instrument ***********************
M_hrs_decile_kids_edu_2005
M_hrs_gmean_kids_edu_2005
M_chrs_decile_kids_edu_2005
M_chrs_gmean_kids_edu_2005
M_part_decile_kids_edu_2005
M_part_gmean_kids_edu_2005

esttab female1_2005 female2_2005 female3_2005 female4_2005 ///
	using `analysis_output'/Tables/Female_four_models.tex, label replace booktabs ///
	cells(b(fmt(2 4)) se _star)  stats(N) ///
	title(Four Models\label{tab1})


*************** Female Annual Hours: Across Time ***********************



*************** Males Annual Hrs: Across Time ***********************
esttab M_hrs_gmean_kids_edu_2005  M_hrs_gmean_kids_edu_2006  M_hrs_gmean_kids_edu_2007  M_hrs_gmean_kids_edu_2008 ///
	 M_hrs_gmean_kids_edu_2009  M_hrs_gmean_kids_edu_2010 M_hrs_gmean_kids_edu_2011 M_hrs_gmean_kids_edu_2012 ///
	 M_hrs_gmean_kids_edu_2013 M_hrs_gmean_kids_edu_2014 M_hrs_gmean_kids_edu_20115 ///
	 using `analysis_output'/Tables/Males_across_time.tex, ///
	 label replace title("Male Hours, 2005-2015") ///
	 stats(N) keep(lwage lwage_sp unearnedinc15_sp raceblack racehisp raceother edulths eduaa eduba)

esttab M_hrs_gmean_kids_edu_2005  ///
	 using ${PROJECTS}/MFElasticity/Output/Tables/Males_across_time.tex, ///
	 label replace title("Male Hours, 2005-2015"\label{malesacrosstime}) ///
	 stats(N) keep(lwage lwage_sp unearnedinc15_sp raceblack racehisp raceother edulths eduaa eduba)


 
M_part_decile_kids_edu_2005

*************** Female Conditional Hours: Across Time ************************

*************** Male Conditional Hours: Across Time **************************

*************** Female Participation: Across Time ****************************
*************** Male Participation: Across Time ******************************

*************** Males by Edu ***********************


*************** Males w/ kids under 5 ***********************


*************** Males by Age  Groups ***********************
*mat list Age

*************** Males by Race/Ethn **************************

*************** Males by Citizenship ************************
*************** Males by Region *****************************
*************** Males by married status *********************


