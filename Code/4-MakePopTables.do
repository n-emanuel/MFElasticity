*****************************************************************************
* Generating graphs and tables of analysis results							*
* Natalia Emanuel   									   					*
* Written: 16 Feb 2017									   					*
* Last Edited: 30 April 2017							   					*
*               										   					*
* NOTES: to be called by 2-MainAnalysis after running the rest of 2-....do	*										   			*
*****************************************************************************

**********************************
* 			Make Graphs			 *
**********************************

***************  by Edu ***********************
* (annual hrs, gmean)
clear
foreach s in M F{
svmat `s'_subEDU_lths_own, names(col)
rename b b`s'lths
rename se se`s'lths
svmat `s'_subEDU_hs_own, names(col)
rename b b`s'hs
rename se se`s'hs
svmat `s'_subEDU_aa_own, names(col)
rename b b`s'aa
rename se se`s'aa
svmat `s'_subEDU_ba_own, names(col)
rename b b`s'ba
rename se se`s'ba
}
gen Year = _n+2004

graph twoway (line bMlths Year, lpattern("dot") lcolor("red")) ///
	(line bMhs Year, lpattern("shortdash") lcolor("red")) ///
	(line bMaa Year, lpattern("dash") lcolor("red")) ///
	(line bMba Year, lpattern("l") lcolor("red")) ///
	(line bFlths Year, lpattern("dot") lcolor("blue")) ///
	(line bFhs Year, lpattern("shortdash") lcolor("blue")) ///
	(line bFaa Year, lpattern("dash") lcolor("blue")) ///
	(line bFba Year, lpattern("l") lcolor("blue")) ///
	graphregion(color(white)) bgcolor(white) ///
	legend(label(1 "Males, less than HS") label(2 "Males, HS") label(3 "Males, Some College") label(4 "Males, BA plus") ///
	label(5 "Females, less than HS") label(6 "Females, HS") label(7 "Females, Some College") label(8 "Females, BA plus")) ///
	title("Elasticity of Hours with respect to Wages by Sex and Education, 2005-2015")
graph export `analysis_output'/Figures/Subpop_Edu.png, replace





***************  w/ kids under 5 ***********************
* (annual hrs, gmean)
clear
foreach s in M F{
svmat `s'_subKIDS_kids0_own, names(col)
rename b b`s'nok
rename se se`s'nok
svmat `s'_subKIDS_kids1_own, names(col)
rename b b`s'kids
rename se se`s'kids
}
gen Year = _n+2004

graph twoway (line bMnok Year, lpattern("dash") lcolor("red")) ///
	(line bMkids Year, lpattern("l") lcolor("red")) ///
	(line bFnok Year, lpattern("dash") lcolor("blue")) ///
	(line bFkids Year, lpattern("l") lcolor("blue")) ///
	graphregion(color(white)) bgcolor(white) ///
	legend(label(1 "Males, No kids <5") label(2 "Males, Kids <5") ///
	label(3 "Females, No kids <5") label(4 "Females, Kids <5") ) ///
	title("Elasticity of Hours with respect to Wages by Sex and Presence of Kids <5, 2005-2015")
graph export `analysis_output'/Figures/Subpop_kids.png, replace



*************** by Age  Groups ***********************
* (annual hrs, gmean)
clear
foreach s in M F{
svmat `s'_subAGE_age1_own, names(col)
rename b b`s'1
rename se se`s'1
svmat `s'_subAGE_age2_own, names(col)
rename b b`s'2
rename se se`s'2
svmat `s'_subAGE_age3_own, names(col)
rename b b`s'3
rename se se`s'3
}
gen Year = _n+2004

graph twoway (line bM1 Year, lpattern("dot") lcolor("red")) ///
	(line bM2 Year, lpattern("shortdash") lcolor("red")) ///
	(line bM3 Year, lpattern("dash") lcolor("red")) ///
	(line bF1 Year, lpattern("dot") lcolor("blue")) ///
	(line bF2 Year, lpattern("shortdash") lcolor("blue")) ///
	(line bF3 Year, lpattern("dash") lcolor("blue")) ///
	graphregion(color(white)) bgcolor(white) ///
	legend(label(1 "Males, 25-34") label(2 "Males, 35-44") label(3 "Males, 45-54") ///
	label(4 "Females, 25-34") label(5 "Females, 34-44") label(6 "Females, 45-54") ) ///
	title("Elasticity of Hours with respect to Wages by Sex and Age, 2005-2015")
graph export `analysis_output'/Figures/Subpop_Age.png, replace



*************** by Race/Ethn **************************
* (annual hrs, gmean)
clear
foreach s in M F{
svmat `s'_subRACE_race1_own, names(col)
rename b b`s'white
rename se se`s'white
svmat `s'_subRACE_race2_own, names(col)
rename b b`s'black
rename se se`s'black
svmat `s'_subRACE_race3_own, names(col)
rename b b`s'oth
rename se se`s'oth
svmat `s'_subRACE_race4_own, names(col)
rename b b`s'hisp
rename se se`s'hisp
}
gen Year = _n+2004

graph twoway (line bMwhite Year, lpattern("dot") lcolor("red")) ///
	(line bMblack Year, lpattern("shortdash") lcolor("red")) ///
	(line bMoth Year, lpattern("dash") lcolor("red")) ///
	(line bMhisp Year, lpattern("l") lcolor("red")) ///
	(line bFwhite Year, lpattern("dot") lcolor("blue")) ///
	(line bFblack Year, lpattern("shortdash") lcolor("blue")) ///
	(line bFoth Year, lpattern("dash") lcolor("blue")) ///
	(line bFhisp Year, lpattern("l") lcolor("blue")) ///
	graphregion(color(white)) bgcolor(white) ///
	legend(label(1 "Males, white non-Hispanic") label(2 "Males, black  non-Hispanic") label(3 "Males, other non-Hispanic") label(4 "Males, Hispanic") ///
	label(5 "Females, white non-Hispanic") label(6 "Females, black non-Hispanic") label(7 "Females, other non-Hispanic") label(8 "Females, Hispanic")) ///
	title("Elasticity of Hours with respect to Wages by Sex and Race, 2005-2015")
graph export `analysis_output'/Figures/Subpop_race.png, replace




*************** Males by Citizenship ************************
* (annual hrs, gmean)
clear
foreach s in M F{
svmat `s'_subCITZ_cit1_own, names(col)
rename b b`s'citizen
rename se se`s'citizen
svmat `s'_subCITZ_cit0_own, names(col)
rename b b`s'noncitizen
rename se se`s'noncitizen
}
gen Year = _n+2004

graph twoway (line bMcitizen Year, lpattern("dash") lcolor("red")) ///
	(line bMnoncitizen Year, lpattern("l") lcolor("red")) ///
	(line bFcitizen Year, lpattern("dash") lcolor("blue")) ///
	(line bFnoncitizen Year, lpattern("l") lcolor("blue")) ///
	graphregion(color(white)) bgcolor(white) ///
	legend(label(1 "Males, citizen") label(2 "Males, noncitizen") ///
	label(3 "Females, citizen") label(4 "Females, noncitizen") ) ///
	title("Elasticity of Hours with respect to Wages by Sex and Citizenship, 2005-2015")
graph export `analysis_output'/Figures/Subpop_citizen.png, replace

*************** Males by Region *****************************

*************** Males by married status *********************
* (annual hrs, gmean)
clear
foreach s in M F{
svmat `s'_subMAR_married_own, names(col)
rename b b`s'married
rename se se`s'married
svmat `s'_subMAR_partnered_own, names(col)
rename b b`s'partnered
rename se se`s'partnered
}
gen Year = _n+2004

graph twoway (line bMmarried Year, lpattern("dash") lcolor("red")) ///
	(line bMpartnered Year, lpattern("l") lcolor("red")) ///
	(line bFmarried Year, lpattern("dash") lcolor("blue")) ///
	(line bFpartnered Year, lpattern("l") lcolor("blue")) ///
	graphregion(color(white)) bgcolor(white) ///
	legend(label(1 "Males, married") label(2 "Males, partnered") ///
	label(3 "Females, married") label(4 "Females, partnered") ) ///
	title("Elasticity of Hours with respect to Wages by Sex and Marital Status, 2005-2015")
graph export `analysis_output'/Figures/Subpop_marst.png, replace



