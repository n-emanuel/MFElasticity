###########################################
# Main Elasticity Analysis                #
# Natalia Emanuel   			                #	
# Written: 10 April 2017		              #
# Last Edited: 13 April 2017              #
#               										   	  #
# NOTES:                                  #
###########################################

# Set Working Directory -- analysis output folder
setwd('/Users/nemanuel/_Files/Research/FunDataProj/MFElasticity/Output')

# Libraires
#install.packages("srvyr")
install.packages("tidyr")
install.packages("memisc")
library(lmtest)
library(xtable)
library(sandwich)
library(parallel)
library(abind)
library(foreign)
library(memisc)
library(survey)
library(tidyr)
library(dplyr)
#library(srvyr)
library(readstata13)


# clear all
rm(list=ls())

# override R's tendency to use scientific notation
options("scipen" =100, "digits" = 4) 

# Set up base tables to be able to call
OutcomeTrends = c()
PartnerTrends = c()
HoursGroups = c()



# Call the subanalysis once for each yr
for (year in 2005:2015){
  yrcol=c(year, year)
  # Load that year's data
  # Run the analysis on it
}



