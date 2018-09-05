####
#Code scraps file: to practice, store incomplete code, and store old code in case of FUBAR

library(tidyverse)
library(stringr)
library(lubridate)

#create a function to compute percentages of cross tabs
crosstab_percentage <- function(which_summary) {
  #call col names by num
  col1 <- colnames(which_summary[1]) 
  col2 <- colnames(which_summary[2]) 
  #drop NA from the dataset
  subset <- subset(which_summary, col1!="NA")
  #group by col2 and compute total of pleas w/in col2
  group_by(subset, !!col2) %>%
    mutate(Total_Count = sum(count)) %>%
    #group by col1 and compute percentage w/in each col2
    group_by(!!col1, add=TRUE) %>%
    mutate(Percentage_of_Total_Count = paste0(round(100*count/Total_Count,2),'%'))
}

test <- crosstab_percentage(summary_pleaandrace)


#stored old code in case of FUBAR

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

#A function to compute the total count of a summary
compute_total <- function(which_summary) {
  total <- sum(which_summary$count)
}


#Computing the summaries and storing them----
summary_hearingdate <- virginia_dc_2017_all %>%
  group_by(HearingDate) %>%
  summarise(date_count = n()) %>%
  arrange(desc(date_count))

summary_hearingresult <- virginia_dc_2017_all %>%
  group_by(HearingResult) %>%
  summarise(result_count = n()) %>%
  arrange(desc(result_count))

summary_hearingplea <- virginia_dc_2017_all %>%
  group_by(HearingPlea) %>%
  summarise(plea_count = n()) %>%
  arrange(desc(plea_count))

summary_hearingcontinuancecode <- virginia_dc_2017_all %>%
  group_by(HearingContinuanceCode) %>%
  summarise(contincode_count = n()) %>%
  arrange(desc(contincode_count))

summary_hearingtype <- virginia_dc_2017_all %>%
  group_by(HearingType) %>%
  summarise(type_count = n()) %>%
  arrange(desc(type_count))

summary_hearingcourtroom <- virginia_dc_2017_all %>%
  group_by(HearingCourtroom) %>%
  summarise(courtroom_count = n()) %>%
  arrange(desc(courtroom_count))

summary_fips <- virginia_dc_2017_all %>%
  group_by(fips) %>%
  summarise(fips_count = n()) %>%
  arrange(desc(fips_count))

summary_fileddate <- virginia_dc_2017_all %>%
  group_by(FiledDate) %>%
  summarise(fdate_count = n()) %>%
  arrange(desc(fdate_count))

summary_locality <- virginia_dc_2017_all %>%
  group_by(Locality) %>%
  summarise(locality_count = n()) %>%
  arrange(desc(locality_count))

summary_status <- virginia_dc_2017_all %>%
  group_by(Status) %>%
  summarise(status_count = n()) %>%
  arrange(desc(status_count))

summary_defenseattourney <- virginia_dc_2017_all %>%
  group_by(DefenseAttorney) %>%
  summarise(attourney_count = n()) %>%
  arrange(desc(attourney_count))

summary_address <- virginia_dc_2017_all %>%
  group_by(Address) %>%
  summarise(address_count = n()) %>%
  arrange(desc(address_count))

summary_gender <- virginia_dc_2017_all %>%
  group_by(Gender) %>%
  summarise(gender_count = n()) %>%
  arrange(desc(gender_count))

summary_race <- virginia_dc_2017_all %>%
  group_by(Race) %>%
  summarise(race_count = n()) %>%
  arrange(desc(race_count))

summary_charge <- virginia_dc_2017_all %>%
  group_by(Charge) %>%
  summarise(charge_count = n()) %>%
  arrange(desc(charge_count))

summary_codesection <- virginia_dc_2017_all %>%
  group_by(CodeSection) %>%
  summarise(codesection_count = n()) %>%
  arrange(desc(codesection_count))

summary_casetype <- virginia_dc_2017_all %>%
  group_by(CaseType) %>%
  summarise(type_count = n()) %>%
  arrange(desc(type_count))

summary_class <- virginia_dc_2017_all %>%
  group_by(Class) %>%
  summarise(class_count = n()) %>%
  arrange(desc(class_count))

summary_offensedate <- virginia_dc_2017_all %>%
  group_by(OffenseDate) %>%
  summarise(offensedate_count = n()) %>%
  arrange(desc(offensedate_count))

summary_arrestdate <- virginia_dc_2017_all %>%
  group_by(ArrestDate) %>%
  summarise(arrestdate_count = n()) %>%
  arrange(desc(arrestdate_count))

summary_complainant <- virginia_dc_2017_all %>%
  group_by(Complainant) %>%
  summarise(complainant_count = n()) %>%
  arrange(desc(complainant_count))

summary_amendedcharge <- virginia_dc_2017_all %>%
  group_by(AmendedCharge) %>%
  summarise(amendcharge_count = n()) %>%
  arrange(desc(amendcharge_count))

summary_amendedcode <- virginia_dc_2017_all %>%
  group_by(AmendedCode) %>%
  summarise(amendcode_count = n()) %>%
  arrange(desc(amendcode_count))

summary_amendedcasetype <- virginia_dc_2017_all %>%
  group_by(AmendedCaseType) %>%
  summarise(amendcasetype_count = n()) %>%
  arrange(desc(amendcasetype_count))

summary_finaldisposition <- virginia_dc_2017_all %>%
  group_by(FinalDisposition) %>%
  summarise(fdisposition_count = n()) %>%
  arrange(desc(fdisposition_count))

summary_sentencetime <- virginia_dc_2017_all %>%
  group_by(SentenceTime) %>%
  summarise(sentencetime_count = n()) %>%
  arrange(desc(sentencetime_count))

summary_sentencesuspendedtime <- virginia_dc_2017_all %>%
  group_by(SentenceSuspendedTime) %>%
  summarise(sentencesuspt_count = n()) %>%
  arrange(desc(sentencesuspt_count))

summary_probationtype <- virginia_dc_2017_all %>%
  group_by(ProbationType) %>%
  summarise(probtype_count = n()) %>%
  arrange(desc(probtype_count))

summary_probationtime <- virginia_dc_2017_all %>%
  group_by(ProbationTime) %>%
  summarise(probtime_count = n()) %>%
  arrange(desc(probtime_count))

summary_probationstarts <- virginia_dc_2017_all %>%
  group_by(ProbationStarts) %>%
  summarise(probstarts_count = n()) %>%
  arrange(desc(probstarts_count))

summary_oplisuspendtime <- virginia_dc_2017_all %>%
  group_by(OperatorLicenseSuspensionTime) %>%
  summarise(oplisuspendtime_count = n()) %>%
  arrange(desc(oplisuspendtime_count))

summary_restrictioneffectivedate <- virginia_dc_2017_all %>%
  group_by(RestrictionEffectiveDate) %>%
  summarise(restrictioneffectivedate_count = n()) %>%
  arrange(desc(restrictioneffectivedate_count))

summary_restrictionenddate <- virginia_dc_2017_all %>%
  group_by(RestrictionEndDate) %>%
  summarise(renddate_count = n()) %>%
  arrange(desc(renddate_count))

summary_olrestrictioncodes <- virginia_dc_2017_all %>%
  group_by(OperatorLicenseRestrictionCodes) %>%
  summarise(olrestrictioncodes_count = n()) %>%
  arrange(desc(olrestrictioncodes_count))

summary_fine <- virginia_dc_2017_all %>%
  group_by(Fine) %>%
  summarise(fine_count = n()) %>%
  arrange(desc(fine_count))

summary_costs <- virginia_dc_2017_all %>%
  group_by(Costs) %>%
  summarise(costs_count = n()) %>%
  arrange(desc(costs_count))

summary_finecostsdue <- virginia_dc_2017_all %>%
  group_by(FineCostsDue) %>%
  summarise(fcdue_count = n()) %>%
  arrange(desc(fcdue_count))

summary_finecostspaid <- virginia_dc_2017_all %>%
  group_by(FineCostsPaid) %>%
  summarise(fcpaid_count = n()) %>%
  arrange(desc(fcpaid_count))

summary_finecostspaiddate <- virginia_dc_2017_all %>%
  group_by(FineCostsPaidDate) %>%
  summarise(fcpdate_count = n()) %>%
  arrange(desc(fcpdate_count))

summary_vasap <- virginia_dc_2017_all %>%
  group_by(VASAP) %>%
  summarise(vasap_count = n()) %>%
  arrange(desc(vasap_count))

summary_hearingplea <- virginia_dc_2017_all %>%
  group_by(HearingPlea) %>%
  summarise(plea_count = n()) %>%
  arrange(desc(plea_count))

summary_finecostspastdue <- virginia_dc_2017_all %>%
  group_by(FineCostsPastDue) %>%
  summarise(fcpd_count = n()) %>%
  arrange(desc(fcpd_count))

summary_personid <- virginia_dc_2017_all %>%
  group_by(person_id) %>%
  summarise(person_count = n()) %>%
  arrange(desc(person_count))
#----

#Adding column total to each summary----
sum1 <- data.frame('Total', sum(summary_hearingplea$count))
names(sum1)<-c("HearingPlea","count")

summary_hearingplea <- rbind(summary_hearingplea, sum1)

#A function to compute and append the total count of a summary ONLY WORKS with STRING cols
total_count <- function(which_summary) {
  sum1 <- data.frame('Total', sum(which_summary$count))
  col_used <- colnames(which_summary[1])
  names(sum1) <- c(col_used,'count')
  which_summary <- rbind(which_summary, sum1)
}

#A function to compute the total count of a summary and put it in a new column
total_count <- function(which_summary) {
  Total <- sum(which_summary$count)
  mutate(which_summary, Total)
}

test_total_count3 <- total_count(summary_hearingdate)

#A function to compute the percentage of a row and put the results in a new column
#Step1: I want to take row1, col2, and divide it by total_count, and multiply it by 100
#Step2: I want to store that data in row1, col3, under the name Percentage
#Step3: I want to repeat this for every row
compute_percentage <- function(which_summary) {
  
  cell_used <- which_summary$count
  total <- sum(which_summary$count)
  percentage <- round((cell_used / total)*100,2)
  mutate(which_summary, percentage)
}

plea_type_percentagetest <- compute_percentage(summary_hearingplea)

#-----

#cross-tab----
summary_pleaandresult <- virginia_dc_2017_all %>%
  group_by(HearingPlea, CaseType) %>%
  summarise(plea_count = n()) %>%
  arrange(desc(plea_count))
View(summary_pleaandresult)
