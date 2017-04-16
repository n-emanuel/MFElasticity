*************************************************************
* Cleaning ACS Dataset for Elasticity						*
* Natalia Emanuel   									   	*
* Written: 16 March 2017								   	*
* Last Edited: 6 April 2017								   	*
*               										   	*
* NOTES: 										   			*
*************************************************************


********************* Variables on kids in the HH *****************************
gen kidcat0 = (age==0)
gen kidcat1 = (age==1)
gen kidcat2 = (age==2)
gen kidcat3t5 = (age>=3 & age<=5)
gen kidcat6t11 = (age>=6 & age <=11)
gen kidcat12t17 = (age>=12 & age<=17)

foreach cat in 0 1 2 3t5 6t11 12t17{
bys year serial: egen nkids`cat' = total(kidcat`cat')
} 

egen nkidstot = rowtotal(nkids*)

label var nkids0 "number of kids in hh less than 1"
label var nkids1 "number of kids in hh age 1"
label var nkids2 "number of kids in hh age 2"
label var nkids3t5 "number of kids in hh aged 3 to 5"
label var nkids6t11 "number of kids in hh aged 6 to 11"
label var nkids12t17 "number of kids in hh aged 12 to 17"

drop kidcat*

********************** Indicators of who is in the sample ************************************
* generate a loc(line-number) variable that will help match partners even when there are multiple couples in a family
bys year serial: gen loc=_n

* Local for the age range
local agereq18 inrange(age, 18, 54)
local agereq25 inrange(age, 25, 54)

* Keep heads/householders, their spouses, and their unmarried partners
*N.B. this does not include subfamilies where neither partner is the head/householder
gen sample_hhheads18= (related==101  /// /*householder*/
		| related == 201  /// /*spouse*/
		| related == 1114) /// /*unmarried partner*/
		& `agereq18'
label var sample_hhheads18 "families in hh with one partner is head, 18-54"

gen sample_hhheads25=  (related==101  /// /*householder*/
		| related == 201  /// /*spouse*/
		| related == 1114) /// /*unmarried partner*/
		& `agereq25'
label var sample_hhheads25 "families in hh with one partner is head, 25-54"



* If want all families in HH (even where neither partner is head), use this
* NB only unmarried partners are included if one partner is the head of the household
gen sample_allhh18=  (related==101  /// /*householder*/
		| related == 201  /// /*spouse*/
		| related == 1114 /// /*unmarried partner*/
		| (marst==1 & sploc!=0 & subfam!=0)) ////* married, spouse present & not head of household or head's spouse */
		& `agereq18'
label var sample_allhh18 "all families in hh (even where neither partner is head), 18-54"

gen sample_allhh25= (related==101  /// /*householder*/
		| related == 201  /// /*spouse*/
		| related == 1114 /// /*unmarried partner*/
		| (marst==1 & sploc!=0 & subfam!=0)) ////* married, spouse present & not head of household or head's spouse */
		& `agereq25'
label var sample_allhh25 "all families in hh (even where neither partner is head), 25-54"


* reorder so unmarried partner is adjacent to head of household	
gen loc2 = loc 
replace loc2 = 1.5 if related==1114
replace subfam=0 if related==1114
sort year serial subfam loc2

* See who doesn't have a partner in the household (aka is the only person in their subfam)
* this will eliminate single heads, as well as people whose +1 is outside the age limits
duplicates tag year serial subfam, gen(singleton)
foreach each in allhh18 allhh25 hhheads18 hhheads25{
	replace sample_`each'=0 if singleton==0
}
drop singleton

* Identify spouse locator for non-married partners
replace sploc=loc[_n+1] if sploc==0 & sploc[_n+1]==0 & related==101 & related[_n+1]==1114
replace sploc=loc[_n-1] if sploc==0 & related==1114	& related[_n-1]==101
		
* Indicator of Married or Partnered
gen married = (marst==1)
label var married "indicator of married partner rather than unmarried partner"
gen partnered = (marst!=1 & sploc!=0)
label var partnered "indicator of unmarried partner rather than married"
		
* see a useful set of variables
br year serial loc loc2 sploc subfam related sex age marst inctot ftotinc incwage inctot_sp 

		
************************ Demographic variables  ************************************************
* Age
gen age2 = age*age
label var age2 "age squared"

* Age Category
gen agecat = (age>=25 & age<=34)
replace agecat = 2 if (age>=35 & age<=44)
replace agecat = 3 if (age>=45 & age<=54)
label define agecat 0 "Outside Prime Age" 1 "25-34" 2 "35-44" 3 "45-54"
label values agecat agecat

* Age Categories
gen age2534 = inrange(age, 25, 34)
gen age3544 = inrange(age, 35, 44)
gen age4554 = inrange(age, 45, 54)

* Educ
gen edu = 1 if educd<62
replace edu = 2 if educd==62
replace edu = 3 if inlist(educd, 65, 71, 81)
replace edu = 4 if educd>=101
	label define edu 1 lths 2 hs 3 aa 4 baplus
	label values edu edu
gen edulths = edu==1
gen eduhs = edu==2
gen eduaa = edu==3
gen eduba = edu==4

* Female
gen female = (sex==2)

* Race
gen hisp= (hispan!=0)
gen race_orig = race
replace race = 3 if !inlist(race_orig, 1, 2) /* Other & Asian toget*/
*replace race = 3 if inlist(race, 4, 5, 6) /* if Asian is separate category*/
replace race = 4 if hisp == 1 
	label define race 1 "White non-H" 2 "Black non-H" 3 "Other non-H" 4 "Hisp"
	label values race race
gen raceblack = race==2
gen raceother = race==3
gen racehisp = race==4

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
	label var regn_mountn "region: Mountain"
	label var regn_pacifc "region: Pacific"
	
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
foreach v in race female edu age2 edulths eduaa eduba raceblack racehisp raceother{
	disp "`v'"
	gen `v'_sp = `v'[_n+1] if mod(_n, 2)==1
	replace `v'_sp = `v'[_n-1] if mod(_n, 2)==0
}
label values edu_sp edu



************************ Real Dollars: Converting Wages to 2015 dollars ***************

* A note on which variables are used:
* ftotinc pools across subfamilies and doesn't include unmarried partners
* incwage_sp doesn't include unmarried partners.
* inctot includes income that isn't wages
* thus we use incwage 

* merge in price index data
merge m:1 year using `priceindex'

egen pcepi15=mean(pcepi) if year==2015
egen pi15 = mean(pcepi15)
drop pcepi15

* Real Wage = (Old Wage * New CPI) / Old CPI
gen wage15 = (incwage * pi15)/pcepi
gen wage15_sp = (incwage_sp * pi15)/pcepi
label var wage15 "wages in 2015 dollars"
label var wage15_sp "wages of spouse in 2015 dollars"

* delete the unnecessary years of the price index 
* (this line is later than the merge so that can have year==2015 in other years)
drop if _m==2 
drop _m

br year serial loc loc2 sploc subfam related sex age marst inctot ftotinc incwage inctot_sp pi15 pcepi wage15 wage15_sp


************************ Assets: Summing them and making into Real 2015 dollars ***************
gen assets = inctot-incwage
gen assets_sp = inctot_sp - incwage_sp
gen fam_assets = assets + assets_sp 

* real assets = (old assets * new CPI)/old CPI
gen fam_assets15 = (fam_assets * pi15)/pcepi
label var fam_assets15 "family assets in 2015 dollars"


************************ Weeks worked ******************************

* wkswork1 is only available until 2007. 
* After 2007, I take the midlevel number of weeks in the interval from wkswork2
gen wksworked = wkswork1
replace wksworked=0 if year>2007 & wkswork2==0
replace wksworked=7 if year>2007 & wkswork2==1
replace wksworked=20 if year>2007 & wkswork2==2
replace wksworked=33 if year>2007 & wkswork2==3
replace wksworked=43.5 if year>2007 & wkswork2==4
replace wksworked=48.5 if year>2007 & wkswork2==5
replace wksworked=51 if year>2007 & wkswork2==6

********************* Indicator of Nonworkers, low-hr-workers, high-hr-workers *********
gen hrsgroups = (uhrswork>0)
replace hrsgroups = 2 if uhrswork>20
label define hrsgroups 0 "0 hrs" 1 "<20 hrs" 2 "20+ hrs"
label values hrsgroups hrsgroups

********************* Outcome: Labor Supply *****************************
* outcome var: annual hours
gen annualwkhrs = uhrswork * wksworked
label var annualwkhrs "annual work hours"

* outcome var: Participation (positive work hours)
gen outcomeparticip = (uhrswork>0)
label var outcomeparticip "Labor force participation"

* outcome var: cond'l hrs (work hours given participation)
gen outcomecondhrs = uhrswork
label var outcomecondhrs "Hours worked conditional on participation"



**************** Imputing Wages for those who don't have (Juhn & Murphy) ***************

* Hrly wage for those who have valid information (work some hours and hrly wage is between 3, 200)
gen hrwage15 = wage15/annualwkhrs if wage15>0
replace hrwage15=. if hrwage15<3 | hrwage15>200 | qwks==4 | quhr==4
gen validwage = hrwage15!=.
label var validwage "wages not imputed. Wages are imputed if outside range 3-200, or if wks worked or hrsworked imputed"

* Predictions for those who dont have valid wage information
**The regressors used were own and spouse variables for age, age squared, 
**three education categories, and three race/Hispanic categories, 
**plus eight region categories and a metropolitan area indicator.
* regressions separate for each year.

** Reference Cell: hs edu, white, South Atlantic region
local region regn_neweng regn_midatl  regn_centne regn_centnw regn_centse regn_centsw regn_mountn regn_pacifc 
local ages age age2 age_sp age2_sp 
local edus edulths eduaa eduba edulths_sp eduaa_sp eduba_sp
local racecodes raceblack racehisp raceother raceblack_sp racehisp_sp raceother_sp 
gen imputedhrwage15 = .

	reg hrwage15 `ages' `edus' `racecodes' `region' metroarea if uhrswork<20
	predict predictedhrwage, xb
	replace imputedhrwage15 = predictedhrwage if hrwage15==.
replace imputedhrwage15 = hrwage15 if hrwage15!=.

* Bottom-code the imputed wages at $3. 
replace imputedhrwage15 = 3 if imputedhrwage<3 
label var imputedhrwage15 "imputed wages"


br year serial loc loc2 sploc subfam related sex age marst incwage pi15 pcepi wage15 wage15_sp uhrswork wkswork1 annualwkhrs hrwage15



****************** Impute Wages for non-workers v2 (Heckman79) *********************
*FIXME: Look into this


******************** Impute post-tax income (pg 9) ******************************
*FIXME: Look into this



******************** Same sex, younger partner  ******************************
gen samesex = (sex==1 & sex_sp==1) | (sex==2 & sex_sp==2)
label var samesex "indicator that both members of couple have same sex"

gen youngerpartner = (age < age_sp)
label var youngerpartner "indicator that spouse is younger"


******************** Calc person weights that are equal for each year ******************************
/* DON"T NEED TO DO UNLESS POOLING YEARS AS BLAU & KAHN DO
bys year: egen totwt = total(perwt)

gen totwtinter = totwt if year==2015
egen totwt15 = mean(totwtinter)
drop totwtinter

* Set so that they all have the same weight as the total in 2015
gen perwt15 = perwt * (totwt/totwt15)
*/
*FIXME: If you're using replicate weights, these should also be adjusted accordingly


******************** Generate Group Means to use as Instruments ******************************
gen wagedecile = .
forval cat=1/3{
	xtile decile_temp_f = hrwage15 [pw=perwt] if female==1 & agecat==`cat', nq(10)
	xtile decile_temp_m = hrwage15 [pw=perwt] if female==0 & agecat==`cat', nq(10)
	replace wagedecile = decile_temp_f if female==1 & wagedecile==.
	replace wagedecile = decile_temp_m if female==0 & wagedecile==.
	drop decile_temp* 
}
label var wagedecile "decile of wages of individual, by sex, age category"




******************** keep only the variables needed for analyses ******************************

keep year statefip countyfips serial cluster strata hhwt perwt sample_* loc loc2 sploc married partnered subfam related marst* age age2 age_sp age2_sp agecat female female_sp edu* race race_sp raceblack* raceother* racehisp* regn_* metroarea nkids* hrwage15* imputedhrwage15* validwage hrsgroups outcome* annualwkhrs* wksworked* wage15* wagedecile fam_assets15 occ* ind* empstat* labforce* classwkr* samesex youngerpartner 

