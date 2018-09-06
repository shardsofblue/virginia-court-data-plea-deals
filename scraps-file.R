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
