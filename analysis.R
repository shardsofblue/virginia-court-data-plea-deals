#Analysis file for Virginia court data for Plea Bargain Project. By Roxanne Ready, started on Aug. 27, 2018.
#install.packages("tidyverse")
#install.packages('stringr')
#install.packages('lubridate')
library(tidyverse)
library(stringr)
library(lubridate)

#Loading data: Virginia, district_criminal_2017_anon_00 from virginiacourtdata.org/#open-data----
virginia_dc_2017_00 <- read_csv(col_types = cols(RestrictionEndDate=col_character()),'data/district_criminal_2017_anon_UG6NRN/district_criminal_2017_anon_00.csv')
virginia_dc_2017_01 <- read_csv(col_types = cols(RestrictionEndDate=col_character()),'data/district_criminal_2017_anon_UG6NRN/district_criminal_2017_anon_01.csv')
virginia_dc_2017_02 <- read_csv(col_types = cols(RestrictionEndDate=col_character()),'data/district_criminal_2017_anon_UG6NRN/district_criminal_2017_anon_02.csv')
virginia_dc_2017_03 <- read_csv(col_types = cols(RestrictionEndDate=col_character()),'data/district_criminal_2017_anon_UG6NRN/district_criminal_2017_anon_03.csv')
virginia_dc_2017_04 <- read_csv(col_types = cols(RestrictionEndDate=col_character()),'data/district_criminal_2017_anon_UG6NRN/district_criminal_2017_anon_04.csv')
virginia_dc_2017_05 <- read_csv(col_types = cols(RestrictionEndDate=col_character()),'data/district_criminal_2017_anon_UG6NRN/district_criminal_2017_anon_05.csv')
virginia_dc_2017_06 <- read_csv(col_types = cols(RestrictionEndDate=col_character()),'data/district_criminal_2017_anon_UG6NRN/district_criminal_2017_anon_06.csv')
virginia_dc_2017_07 <- read_csv(col_types = cols(RestrictionEndDate=col_character()),'data/district_criminal_2017_anon_UG6NRN/district_criminal_2017_anon_07.csv')
virginia_dc_2017_08 <- read_csv(col_types = cols(RestrictionEndDate=col_character()),'data/district_criminal_2017_anon_UG6NRN/district_criminal_2017_anon_08.csv')
#----
  
#Combining data from 8 CSVs into one dataset----
virginia_dc_2017_all <- bind_rows(virginia_dc_2017_00, virginia_dc_2017_01, virginia_dc_2017_02, virginia_dc_2017_03, virginia_dc_2017_04, virginia_dc_2017_05, virginia_dc_2017_06, virginia_dc_2017_07, virginia_dc_2017_08)
#----

#Removing original files
rm(virginia_dc_2017_00,virginia_dc_2017_01,virginia_dc_2017_02,virginia_dc_2017_03,virginia_dc_2017_04,virginia_dc_2017_05,virginia_dc_2017_06,virginia_dc_2017_07,virginia_dc_2017_08)

##Exploratory research##

#A function to group and count each field
summarise_and_count <- function(table_name, col_name) {
  table_name %>%
    group_by(!! col_name) %>%
    summarise(count=n()) %>%
    arrange(desc(count))
}

#A variable to hold the master table name----
thistable <- virginia_dc_2017_all

#Computing the summaries and storing them----
summary_hearingdate <- summarise_and_count(thistable, quo(HearingDate))
summary_hearingresult <- summarise_and_count(thistable, quo(HearingResult))
summary_hearingplea <- summarise_and_count(thistable, quo(HearingPlea))
summary_hearingcontinuancecode <- summarise_and_count(thistable, quo(HearingContinuanceCode))
summary_hearingtype <- summarise_and_count(thistable, quo(HearingType))
summary_hearingcourtroom <- summarise_and_count(thistable, quo(HearingCourtroom))
summary_fips <- summarise_and_count(thistable, quo(fips))
summary_fileddate <- summarise_and_count(thistable, quo(FiledDate))
summary_locality <- summarise_and_count(thistable, quo(Locality))
summary_status <- summarise_and_count(thistable, quo(Status))
summary_defenseattorney <- summarise_and_count(thistable, quo(DefenseAttorney))
summary_address <- summarise_and_count(thistable, quo(Address))
summary_gender <- summarise_and_count(thistable, quo(Gender))
summary_race <- summarise_and_count(thistable, quo(Race))
summary_charge <- summarise_and_count(thistable, quo(Charge))
summary_codesection <- summarise_and_count(thistable, quo(CodeSection))
summary_casetype <- summarise_and_count(thistable, quo(CaseType))
summary_class <- summarise_and_count(thistable, quo(Class))
summary_offensedate <- summarise_and_count(thistable, quo(OffenseDate))
summary_arrestdate <- summarise_and_count(thistable, quo(ArrestDate))
summary_complainant <- summarise_and_count(thistable, quo(Complainant))
summary_amendedcharge <- summarise_and_count(thistable, quo(AmendedCharge))
summary_amendedcasetype <- summarise_and_count(thistable, quo(AmendedCaseType))
summary_finaldisposition <- summarise_and_count(thistable, quo(FinalDisposition))
summary_sentencetime <- summarise_and_count(thistable, quo(SentenceTime))
summary_sentencesuspendedtime <- summarise_and_count(thistable, quo(SentenceSuspendedTime))
summary_probationtype <- summarise_and_count(thistable, quo(ProbationType))
summary_probationtime <- summarise_and_count(thistable, quo(ProbationTime))
summary_oplisusptime <- summarise_and_count(thistable, quo(OperatorLicenseSuspentionTime))
summary_restrictioneffectivedate <- summarise_and_count(thistable, quo(RestricitonEffectiveDate))
summary_restrictionenddate <- summarise_and_count(thistable, quo(RestrictionEndDate))
summary_oplirestrictcodes <- summarise_and_count(thistable, quo(OperatorLicenceRestrictionCodes))
summary_fine <- summarise_and_count(thistable, quo(Fine))
summary_costs <- summarise_and_count(thistable, quo(Costs))
summary_fcostsdue <- summarise_and_count(thistable, quo(FineCostsDue))
summary_fcostspaid <- summarise_and_count(thistable, quo(FineCostsPaid))
summary_fcostspaiddate <- summarise_and_count(thistable, quo(FineCostsPaidDate))
summary_fcostspastdue <- summarise_and_count(thistable, quo(FineCostsPastDue))
summary_personid <- summarise_and_count(thistable, quo(person_id))
#----

#Notes----
#The vast majority of pleas were recorded as NA.

#Some cross-tab evaluation----

#A function to analyse cross-tabs
cross_tab_analysis <- function(table_name, var1, var2) {
  table_name %>%
    group_by(!!var1, !!var2) %>%
    summarise(count=n()) %>%
    arrange(desc(count))
}

#Computing cross-tabs----
summary_pleaandtype <- cross_tab_analysis(thistable, quo(HearingPlea), quo(HearingType))
#When discounting NA values (which account for the majority of the data), adjudicatory cases

summary_pleaandgender <- cross_tab_analysis(thistable, quo(HearingPlea), quo(Gender))
#More men than women pled guilty, but more men than women were charged
#Need to discover the percentage of men and women who plead guilty vs. those who did not w/in their gender

summary_pleaandrace <- cross_tab_analysis(thistable, quo(HearingPlea), quo(Race))
#More caucasian than any other race pled guilty, but more caucasian than other races were charged
#Need to discover the percentage of guilty pleas w/in each race

#A function to compute the percentage of a row and put the results in a new column
#Step1: I want to take each row, col2, and divide it by total_count, and multiply it by 100
#Step2: I want to store that data in row1, col3, under the name Percentage
compute_percentage <- function(which_summary) {
  
  cell_used <- which_summary$count
  total <- sum(which_summary$count)
  percentage <- round((cell_used / total)*100,2)
  mutate(which_summary, percentage)
}

plea_type_percentagetest <- compute_percentage(summary_hearingplea)

#-----

