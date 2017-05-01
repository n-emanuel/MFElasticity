*************************************************************
* Imputing wages & generating Instruments for Elasticity	*
* Natalia Emanuel   									   	*
* Written: 16 Feb 2017									   	*
* Last Edited: 20 April 2017							   	*
*               										   	*
* NOTES: called within 1-ParseACS.do			   			*
*************************************************************


****************** Imputing Wages (Juhn & Murphy) ******************************

* Hrly wage for those who have valid information (work some hours and hrly wage is between 3, 200)
gen hrwage15 = wage15/annualwkhrs if annualwkhrs>0
replace hrwage15=. if hrwage15<3 | hrwage15>200 | qwks==4 | quhr==4

* indicator for if have valid wages
gen validwage = hrwage15!=.
label var validwage "wages not imputed. Wages are imputed if outside $3-200, or if wks worked or hrsworked allocated"

* Predictions for those who dont have valid wage information, 
* based only on those w/ valid wages
gen imputedhrwage15 = .

** Reference Cell: hs edu, white, South Atlantic region
local region regn_neweng regn_midatl regn_centne regn_centnw regn_centse regn_centsw regn_mountn regn_pacifc 
local ages age age2 age_sp age2_sp 
local edus edulths eduaa eduba edulths_sp eduaa_sp eduba_sp
local racecodes raceblack racehisp raceother raceblack_sp racehisp_sp raceother_sp 
	* impute wages for nonworkers and those without valid wages who work <20 hr/wk
	reg hrwage15 `ages' `edus' `racecodes' `region' metroarea if uhrswork<20
	predict predictedhrwage, xb
	replace imputedhrwage15 = predictedhrwage if hrwage15==. & uhrswork<20

	* Impute wages for those who are self-employed, who have allocated earnings or 
	* invalid wage obs & whose hours are >20
	reg hrwage15 `ages' `edus' `racecodes' `region' metroarea if uhrswork>=20
	predict predictedhrwage2, xb
	replace imputedhrwage15 = predictedhrwage2 if hrwage15==. & uhrswork>=20

	replace imputedhrwage15 = hrwage15 if hrwage15!=. & validwage==1


* Bottom-code the imputed wages at $3. 
replace imputedhrwage15 = 3 if imputedhrwage15<3 
label var imputedhrwage15 "imputed wages"

* Generate log wages 
gen lwage = log(imputedhrwage15)
label var lwage "log hourly wage in 2015 dollars"

br year serial pernum loc2 sploc subfam related sex age marst incearn pi15 pcepi hrwage15 imputedhr uhrswork wksworked annualwkhrs hrwage15 qwks quhr predicted*


******************** Generate Deciles to use as Instruments ******************************
gen wagedecile = .
forval cat=1/3{
	xtile decile_temp_f = imputedhrwage15 [pw=perwt] if female==1 & agecat==`cat', nq(10)
	xtile decile_temp_m = imputedhrwage15 [pw=perwt] if female==0 & agecat==`cat', nq(10)
	replace wagedecile = decile_temp_f if female==1 & wagedecile==.
	replace wagedecile = decile_temp_m if female==0 & wagedecile==.
	drop decile_temp* 
}
label var wagedecile "decile of wages of individual, by sex, age category"


******************** Generate Group Means to use as Instruments ******************************
bys sex edu age: egen groupmean = mean(imputedhrwage15)
label var groupmean "mean wages for sex/education/age"



************************ Transfering Vars of Partner into your line ************************************
sort year serial pernum
* Transfer spouse's decile & group mean & hrly income
foreach v in wagedecile imputedhrwage15 groupmean lwage{
	disp "`v'"
	bys year serial: gen `v'_sp = `v'[sploc] 
}


******************** keep only the variables needed for analyses ******************************

keep year statefip countyfips serial cluster strata hhwt perwt sample_* pernum loc2 sploc married partnered subfam related marst* age age2 age_sp age2_sp agecat female female_sp edu* race race_sp raceblack* raceother* racehisp* regn_* metroarea nkids* nokids* kidslt5 citizen lwage* hrwage15* imputedhrwage15* validwage hrsgroups outcome* annualwkhrs* wksworked* wagedecile* groupmean unearnedinc15_sp occ* ind* empstat* labforce* classwkr* samesex youngerpartner logcondhrs










**************
** ARCHIVED **
**************

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
