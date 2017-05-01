*************************************************************
* Cleaning ACS Dataset for Elasticity						*
* Natalia Emanuel   									   	*
* Written: 16 Feb 2017									   	*
* Last Edited: 20 April 2017								*
*               										   	*
* NOTES: called within 1-ParseACS.do			   			*
*************************************************************



********************* Variables on kids in the HH & in family *****************************
gen kidcat0 = (age==0)
gen kidcat1 = (age==1)
gen kidcat2 = (age==2)
gen kidcat3t5 = (age>=3 & age<=5)
gen kidcat6t11 = (age>=6 & age <=11)
gen kidcat12t17 = (age>=12 & age<=17)

* Number of kids in the household
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

* Number of OWN kids in the family
foreach cat in 0 1 2 3t5 6t11 12t17{
bys year serial subfam: egen nokids`cat' = total(kidcat`cat')
} 

egen nokidstot = rowtotal(nkids*)

label var nokids0 "number of own kids in hh less than 1"
label var nokids1 "number of own kids in hh age 1"
label var nokids2 "number of own kids in hh age 2"
label var nokids3t5 "number of own kids in hh aged 3 to 5"
label var nokids6t11 "number of own kids in hh aged 6 to 11"
label var nokids12t17 "number of own kids in hh aged 12 to 17"

gen kidslt5 = (nokids0>0 | nokids1>0 | nokids2>0 | nokids3t5>0)

********************** Linking Unmarried Partners & Gen Fam Indicators ************************************

* reorder so unmarried partner is adjacent to head of household	
gen loc2 = pernum 
replace loc2 = 1.5 if related==1114
replace subfam=0 if related==1114
sort year serial subfam loc2

* Identify spouse locator for non-married partners
replace sploc=pernum[_n+1] if sploc==0 & sploc[_n+1]==0 & related==101 & related[_n+1]==1114 & serial[_n]==serial[_n+1]
replace sploc=pernum[_n-1] if sploc==0 & related==1114	& related[_n-1]==101 & serial[_n]==serial[_n-1]
	
* Indicator of Married or Partnered
gen married = (marst==1)
label var married "indicator of married partner rather than unmarried partner"
gen partnered = (marst!=1 & sploc!=0)
label var partnered "indicator of unmarried partner rather than married"




		
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

* Educ
gen edu = 1 if educd<62
replace edu = 2 if educd>=62 & educd<65
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

* Citizen
rename citizen cit
gen citizen = (cit==0 | cit==1)
label var citizen "not born a US citizen"

************************ Generate Wages & nonwage income **************************

* cleaning those coded as "NA"
foreach var in inctot hhincome ftotinc{
replace `var'=. if `var'==9999999
}
foreach var in bus00 wage invst retir{
replace inc`var'=. if inc`var'==999999
}
foreach var in ss welfr supp other {
replace inc`var'=. if inc`var'==99999 
}

*use incearn to capture wages, business income, and farm income 
gen wage = incearn
label var wage "income from wages, business income, and farm income"

gen unearnedinc = inctot - wage
label var unearned "non-labor income"


************************ Real Dollars: Converting Wages & Unearned Income to 2015 dollars ***************

* merge in price index data
merge m:1 year using `priceindex'

egen pcepi15=mean(pcepi) if year==2015
egen pi15 = mean(pcepi15)
drop pcepi15
* delete the unnecessary years of the price index 
* (this line is later than the merge so that can have year==2015 in other years)
drop if _m==2 
drop _m

* Real Wage = (Old Wage * New CPI) / Old CPI
gen wage15 = (wage * pi15)/pcepi
label var wage15 "wages in 2015 dollars"

* Real unearnedinc = (old unearnedinc * new CPI)/old CPI
gen unearnedinc15 = (unearnedinc * pi15)/pcepi
label var unearnedinc15 "unearnedinc in 2015 dollars"

br year serial pernum loc2 sploc subfam related sex age marst inctot ftotinc incwage pi15 pcepi wage15 unearnedinc15



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

* Indicator of Nonworkers, low-hr-workers, high-hr-workers 
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
gen outcomecondhrs = uhrswork * wksworked if annualwkhrs>0
label var outcomecondhrs "Hours worked conditional on participation"

gen logcondhrs = log(annualwkhrs) 
label var logcondhrs "log annual work hours, cond'l on participation"


************************ Transfering Vars of Partner into your line ************************************

*insert information for all the unmarried partners into the spouse variables
foreach v in sex age educ occ ind wkswork1 wkswork2{
	disp "`v'"
	replace `v'_sp = `v'[_n+1] if `v'_sp==. & related==101 & related[_n+1]==1114 & serial[_n]==serial[_n+1]
	replace `v'_sp = `v'[_n-1] if `v'_sp==. & related==1114 & related[_n-1]==101 & serial[_n]==serial[_n-1]
}

* creating new variables for the vars that don't have variables already
foreach v in race female edu age2 edulths eduhs eduaa eduba raceblack racehisp raceother wage unearnedinc15 empstat labforce classwkr{
	disp "`v'"
	bys year serial: gen `v'_sp = `v'[sploc] 
}
label values edu_sp edu

************************ Demographic Indicators that rely on accurate Partner vars ************************************

* Indicator of Same Sex
gen samesex = (sex==1 & sex_sp==1) | (sex==2 & sex_sp==2) | ssmc==2
label var samesex "indicator that both members of couple have same sex"

* Indicator of younger partner
gen youngerpartner = (age < age_sp)
label var youngerpartner "indicator that spouse is younger"

********************** Indicators of who is in the sample ************************************

* Local for the age range
local agereq18 inrange(age, 18, 54) & inrange(age_sp, 18,54)
local agereq25 inrange(age, 25, 54) & inrange(age_sp, 25,54)

* Keep heads/householders, their spouses, and their unmarried partners
*N.B. this does not include subfamilies where neither partner is the head/householder
gen sample_hhheads18= (related==101  /// /*householder*/
		| related == 201  /// /*spouse*/
		| related == 1114) /// /*unmarried partner*/
		& sploc!=0 ///
		& `agereq18'
label var sample_hhheads18 "families in hh with one partner is head, 18-54"

gen sample_hhheads25=  (related==101  /// /*householder*/
		| related == 201  /// /*spouse*/
		| related == 1114) /// /*unmarried partner*/
		& sploc!=0 ///
		& `agereq25'
label var sample_hhheads25 "families in hh with one partner is head, 25-54"

/*
* If want all families in HH (even where neither partner is head), use this
* NB unmarried partners are only included if one partner is the head of the household
* Else it is just married couples
gen sample_allhh18=  (related==101  /// /*householder*/
		| related == 201  /// /*spouse*/
		| related == 1114 /// /*unmarried partner*/
		| (marst==1 & sploc!=0 & subfam!=0)) ////* married, spouse present & not head of household or head's spouse */
		& sploc!=0 ///
		& `agereq18'
label var sample_allhh18 "all families in hh (even where neither partner is head), 18-54"

gen sample_allhh25= (related==101  /// /*householder*/
		| related == 201  /// /*spouse*/
		| related == 1114 /// /*unmarried partner*/
		| (marst==1 & sploc!=0 & subfam!=0)) ////* married, spouse present & not head of household or head's spouse */
		& sploc!=0 ///
		& `agereq25'
label var sample_allhh25 "all families in hh (even where neither partner is head), 25-54"


* See who doesn't have a partner in the household (aka is the only person in their subfam)
* this will eliminate single heads, as well as people whose +1 is outside the age limits
duplicates tag year serial subfam, gen(singleton)
foreach each in allhh18 allhh25 hhheads18 hhheads25{
	replace sample_`each'=0 if singleton==0
}
drop singleton

*/

