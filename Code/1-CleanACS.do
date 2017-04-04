*************************************************************
* Cleaning ACS Dataset for Elasticity						*
* Natalia Emanuel   									   	*
* Written: 16 March 2017								   	*
* Last Edited: 16 March 2017							   	*
*               										   	*
* NOTES: 										   			*
*************************************************************

* Paths for finding and saving data
local build_output "${DATA_PATH}/ACS/Build_IPUMS_Elasticity/Output"
local analysis_output "${PROJECTS}/MFElasticity/Output"
local analysis_input "${PROJECTS}/MFElasticity/Input"

********************** Grab price index data for calc'ing real wages ************************************
import delimited `analysis_input'/PCEPI.csv, clear

gen date1=date(date, "YMD")
format date1 %td
gen year=year(date1)

collapse (mean) pcepi, by(year)

tempfile priceindex
save `priceindex'

********************** Load Data for 2003+ ************************************
use `build_output'/mfelasticity.dta, clear

** FIXME: Keep 2005, 2010, 2015 & only a third of the observations
keep if inlist(year, 2005, 2010, 2015) & mod(serial, 3)==0

********************** Selecting those we want to study ************************************
* generate a loc(line-number) variable that will help match partners even when there are multiple couples in a family
bys year serial: gen loc=_n

* Local for the age range
local agereq inrange(age, 18, 54)

* Keep heads/householders, their spouses, and their unmarried partners
/* N.B. this does not include subfamilies where neither partner is the head/householder
keep if (related==101  /// /*householder*/
		| related == 201  /// /*spouse*/
		| related == 1114) /// /*unmarried partner*/
		& `agereq'
*/


* FIXME: If want all families in HH (even where neither partner is head), use this
* N.B. this does not include subfamilies where neither partner is the head/householder
keep if (related==101  /// /*householder*/
		| related == 201  /// /*spouse*/
		| related == 1114 /// /*unmarried partner*/
		| (marst==1 & sploc!=0 & subfam!=0)) ////* married, spouse present & not head of household or head's spouse */
		& `agereq'


* reorder so unmarried partner is adjacent to head of household	
gen loc2 = loc 
replace loc2 = 1.5 if related==1114
replace subfam=0 if related==1114
sort year serial subfam loc2

* See who doesn't have a partner in the household (aka is the only person in their subfam)
* this will eliminate single heads, as well as people whose +1 is outside the age limits
duplicates tag year serial subfam, gen(singleton)
drop if singleton==0
drop singleton

* Identify spouse locator for non-married partners
replace sploc=loc[_n+1] if sploc==0 & sploc[_n+1]==0 & related==101 & related[_n+1]==1114
replace sploc=loc[_n-1] if sploc==0 & related==1114	& related[_n-1]==101
		
* see a useful set of variables
br year serial loc loc2 sploc subfam related sex age marst inctot ftotinc incwage inctot_sp 

		
************************ Demographic variables  ************************************************
* Age
gen age2 = age*age

* Educ
gen edu = 1 if educd<62
replace edu = 2 if educd==62
replace edu = 3 if inlist(educd, 65, 71, 81)
replace edu = 4 if educd>=101
	label define edu 1 lths 2 hs 3 aa 4 baplus
	label values edu edu
gen edulths = edu==1
gen eduaa = edu==3
gen eduba = edu==4

* Female
gen female = (sex==2)

* Race
gen races = race
replace races = 4 if !inlist(race, 1, 2, 4, 5, 6)
replace races = 3 if inlist(race, 4, 5, 6)
	label define races 1 White 2 Black 3 Asian 4 Other
	label values races races
gen raceblack = races==2
gen raceasian = races==3
gen raceother = races==4
*FIXME: there's no hispanic code used here

* region
gen regn_neweng = region==11
gen regn_midatl = region==12
gen regn_centne = region==21
gen regn_centnw = region==22
gen regn_souatl = region==31
gen regn_centse = region==32
gen regn_centsw = region==33
gen regn_mountn = region==41
gen regn_pacifc = region==42
	label var regn_neweng "region: New England"
	label var regn_midatl "region: Mid Atlantic"
	label var regn_centne "region: North East Central"
	label var regn_centnw "region: North West Central"
	label var regn_souatl "region: South Atlantic"
	label var regn_centse "region: South East Central"
	label var regn_centsw "region: South West Central"
	label var regn_mountn "region: mountain"
	label var regn_pacifc "region: pacific"
	
* Metro area
* FIXME: It is an open question which variable is better: metro metroarea, met2013.
gen metroarea = (met2013!=0)


************************ Transfering Vars of Partner into your line ************************************

*insert information for all the unmarried partners into the spouse variables
foreach v in sex age educ empstat labforce occ ind classwkr wkswork1 wkswork2 inctot incwage{
	disp "`v'"
	replace `v'_sp = `v'[_n+1] if `v'_sp==. & related==101 & related[_n+1]==1114
	replace `v'_sp = `v'[_n-1] if `v'_sp==. & related==1114 & related[_n-1]==101
}

* creating new variables for the vars that don't have variables already
foreach v in races female edu age2 edulths eduaa eduba raceblack raceasian raceother{
	disp "`v'"
	gen `v'_sp = `v'[_n+1] if mod(_n, 2)==1
	replace `v'_sp = `v'[_n-1] if mod(_n, 2)==0
}
label values edu_sp edu



************************ Real Dollars: Converting Wages to 2015 dollars ***************
* merge in price index data
merge m:1 year using `priceindex'
drop if _m==2 
drop _m

egen pcepi15=mean(pcepi) if year==2015
egen pi15 = mean(pcepi15)
drop pcepi15

* Real Wage = (Old Wage * New CPI) / Old CPI
gen wage15 = (incwage * pi15)/pcepi
gen wage15_sp = (incwage_sp * pi15)/pcepi

br year serial loc loc2 sploc subfam related sex age marst inctot ftotinc incwage inctot_sp pi15 pcepi wage15 wage15_sp

************************ Labor Supply Variables ******************************

* A note on which variables are used:
* ftotinc pools across subfamilies and doesn't include unmarried partners
* incwage_sp doesn't include unmarried partners.
* inctot includes income that isn't wages
* thus we use incwage 

* wkswork1 is only available until 2007. After 2007, I take the midlevel number of weeks in the interval from wkswork2
replace wkswork1=0 if year>2007 & wkswork2==0
replace wkswork1=7 if year>2007 & wkswork2==1
replace wkswork1=20 if year>2007 & wkswork2==2
replace wkswork1=33 if year>2007 & wkswork2==3
replace wkswork1=43.5 if year>2007 & wkswork2==4
replace wkswork1=48.5 if year>2007 & wkswork2==5
replace wkswork1=51 if year>2007 & wkswork2==6


********************* Outcome variables *****************************
* outcome var: annual hours
gen annualwkhrs = uhrswork * wkswork1
label var annualwkhrs "annual work hours"

* outcome var: Participation (positive work hours)
gen outcomeparticip = (uhrswork>0)
label var outcomeparticip "Labor force participation"

* outcome var: cond'l hrs (work hours given participation)
gen outcomecondhrs = uhrswork
label var outcomeconhrs "Hours worked conditional on participation"



**************** Imputing Wages for those who don't have v1 (Juhn & Murphy) ***************

* Hrly wage for those who have valid information (work some hours and hrly wage is between 4, 200)
gen hrwage15 = wage15/annualwkhrs if wage15>0
replace hrwage15=. if hrwage15<2 | hrwage15>200

* Predictions for those who dont have valid information
**The regressors used were own and spouse variables for age, age squared, 
**three education categories, and three race/Hispanic categories, 
**plus eight region categories and a metropolitan area indicator.
* regressions separate for each year.

** REFERENCES: hs edu, white, South Atlantic
* FIXME: Hispanic is not included here
local region regn_neweng regn_midatl  regn_centne regn_centnw regn_centse regn_centsw regn_mountn regn_pacifc 
local ages age age2 age_sp age2_sp 
local edus edulths eduaa eduba edulths_sp eduaa_sp eduba_sp
local racecodes raceblack raceasian raceother raceblack_sp raceasian_sp raceother_sp 
gen imputedhrwage15 = .
forvalues yr = 2005(5)2015{
	disp `yr'
	reg hrwage15 `ages' `edus' `racecodes' `region' metroarea if year==`yr' & uhrswork<20
	predict predictedhrwage`yr' if year==`yr' & hrwage15==., xb
	replace imputedhrwage15 = predictedhrwage`yr' if year==`yr' 
	drop predictedhrwage`yr'
}
replace imputedhrwage15 = hrwage15 if hrwage15!=.

* Bottom-code the imputed wages at $2. 
replace imputedhrwage15 = 2 if imputewage<2 | imputewage>200
label var imputedhrwage "imputed wages"


br year serial loc loc2 sploc subfam related sex age marst incwage pi15 pcepi wage15 wage15_sp uhrswork wkswork1 annualwkhrs hrwage15



****************** Impute Wages for non-workers v2 (Heckman79) *********************
*FIXME: Look into this

******************** Impute post-tax income (pg 9) ******************************
*FIXME: Look into this


******************** Calc person weights that are equal for each year ******************************
bys year: egen totwt = total(perwt)

gen totwtinter = totwt if year==2015
egen totwt15 = mean(totwtinter)
drop totwtinter

* Set so that they all have the same weight as the total in 2015
gen perwt15 = perwt * (totwt/totwt15)

