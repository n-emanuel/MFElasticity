*****************************************************************************
* Generating graphs and tables of analysis results							*
* Natalia Emanuel   									   					*
* Written: 16 Feb 2017									   					*
* Last Edited: 30 April 2017							   					*
*               										   					*
* NOTES: to be called by 2-DescriptiveAnalysis after 2-SubDescriptive.do	*										   			*
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


