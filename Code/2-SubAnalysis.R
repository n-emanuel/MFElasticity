###########################################
# Elasticity Analysis - run once per yr   #
# Natalia Emanuel   			                #	
# Written: 10 April 2017		              #
# Last Edited: 10 April 2017              #
#               										   	  #
# NOTES:                                  #
###########################################

# Data (from dataset folder)
acs = read.dta13('/Users/nemanuel/_Files/Research/Datasets/ACS/Build_IPUMS_Elasticity/Output/mfelasticity_sample_cleaned.dta')

# Set Survey 
# mimic's stata's "svyset cluster [pweight=hhwt], strata(strata)"
# https://usa.ipums.org/usa/complex_survey_vars/userNotes_variance.shtml
acs.hh.design = svydesign(id=~cluster, strata=~strata, data=acs, weights=acs$hhwt)

# subset to just our heads of households' couples (the Survey package allows us to do this without messing up std errors)
# See: http://stats.idre.ucla.edu/stata/faq/how-can-i-analyze-a-subpopulation-of-my-survey-data-in-stata/
acs_hhheads = subset(acs.hh.design, sample_hhheads25==1)


############################# Descriptive Tables ################################################

# Outcomes (annual hours, conditional hours, LFP) by Sex over the years
t1 = svyby(~annualwkhrs+outcomecondhrs+outcomeparticip, ~female, design=acs_hhheads, svymean)
t1 = cbind(t1, yr)
OutcomeTrends = rbind(OutcomeTrends, t1)


# Percentage of householders Married, Percentage of householders Partnered 
t2 = svyby(~partnered+married, ~female, design=acs_hhheads, svymean)
t2 = cbind(t2, yr)
PartnerTrends = rbind(PartnerTrends, t2)

# Descriptives by sex and  nonworker/low-hr-worker/high-hr-worker 
#edu
edu = svymean(~interaction(female,hrsgroups,edu), design=acs_hhheads)
edut = ftable(t4, rownames=list(
  Sex = c("Male", "Female"),
  Hours=c("20+","<20","0"), 
  edu=c("less than HS", "HS", "Some Col", "BA +")
  ))
#edu of sp
edusp = svymean(~interaction(female,hrsgroups,edu_sp), design=acs_hhheads)
eduspt = ftable(edusp, rownames=list(
  Sex = c("Male", "Female"),
  Hours=c("0","<20","20+"), 
  "Spouse's edu"=c("less than HS", "HS", "Some Col", "BA +")
  ))
# number of kids
kids = svyby(~nkids0 + nkids1 + nkids2 + nkids3t5 + nkids6t11 +nkids12t17, 
             ~as.factor(female)+as.factor(hrsgroups), 
             design = acs_hhheads, svymean)
kidst = ftable(kids, rownames=list(
  Sex = c("Male", "Female"),
  Hours=c("0","<20","20+"), 
  "Number of Children" = c("Kids <1", "1 Year Olds", "2 Year Olds", "3-5 Year Olds", "6-11 Year Olds", "12-17 Year Olds")
))
kidst

# age
age = svyby(~age, ~as.factor(female)+as.factor(hrsgroups), design=acs_hhheads, svymean)
age
# age of spouse
agesp = svyby(~agesp, ~female+hrsgroups, design=acs_hhheads, svymean)
agesp
# combine into one nice table
HoursGroups = toLatex(
  rbind(
    edut, 
    eduspt
    ), 
  digits=c(3)
  )

# Remove the temporary variables
rm(t1, t2, t3)


############################# Leave Out Mean Coefficients ################################################


# Generate Group Mean
mutate()
