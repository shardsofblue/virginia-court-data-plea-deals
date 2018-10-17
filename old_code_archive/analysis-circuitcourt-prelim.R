#Analysis file for Virginia court data for Plea Bargain Project. By Roxanne Ready, started on Aug. 27, 2018.
#install.packages("tidyverse")
#install.packages('stringr')
#install.packages('lubridate')
library(tidyverse)
library(stringr)
library(lubridate)

#Loading data: Virginia, circuit_criminal_20xx_anon_xx from virginiacourtdata.org/#open-data----
virginia_cc_2017_00 <- read_csv(col_types = cols(RestrictionEndDate=col_character()),'data/circuit_criminal/circuit_criminal_2017_anon_00.csv')
virginia_cc_2017_01 <- read_csv(col_types = cols(RestrictionEndDate=col_character()),'data/circuit_criminal/circuit_criminal_2017_anon_01.csv')
virginia_cc_2016_00 <- read_csv(col_types = cols(RestrictionEndDate=col_character()),'data/circuit_criminal/circuit_criminal_2016_anon_00.csv')
virginia_cc_2015_00 <- read_csv(col_types = cols(RestrictionEndDate=col_character()),'data/circuit_criminal/circuit_criminal_2015_anon_00.csv')
virginia_cc_2014_00 <- read_csv(col_types = cols(RestrictionEndDate=col_character()),'data/circuit_criminal/circuit_criminal_2014_anon_00.csv')
virginia_cc_2013_00 <- read_csv(col_types = cols(RestrictionEndDate=col_character()),'data/circuit_criminal/circuit_criminal_2013_anon_00.csv')
virginia_cc_2012_00 <- read_csv(col_types = cols(RestrictionEndDate=col_character()),'data/circuit_criminal/circuit_criminal_2012_anon_00.csv')
virginia_cc_2011_00 <- read_csv(col_types = cols(RestrictionEndDate=col_character()),'data/circuit_criminal/circuit_criminal_2011_anon_00.csv')
virginia_cc_2010_00 <- read_csv(col_types = cols(RestrictionEndDate=col_character()),'data/circuit_criminal/circuit_criminal_2010_anon_00.csv')

#----
  
#Combining data from 8 CSVs into one dataset----
virginia_cc_all <- bind_rows(
  type.convert(virginia_cc_2017_00, na.strings = "NA"), 
  type.convert(virginia_cc_2017_01, na.strings = "NA"), 
  type.convert(virginia_cc_2016_00, na.strings = "NA"), 
  type.convert(virginia_cc_2015_00, na.strings = "NA"), 
  type.convert(virginia_cc_2014_00, na.strings = "NA"), 
  type.convert(virginia_cc_2013_00, na.strings = "NA"), 
  type.convert(virginia_cc_2012_00, na.strings = "NA"), 
  type.convert(virginia_cc_2011_00, na.strings = "NA"), 
  type.convert(virginia_cc_2010_00, na.strings = "NA") 
  )
#----

#Removing original files----
rm(
  virginia_cc_2017_00,
  virginia_cc_2017_01,
  virginia_cc_2016_00,
  virginia_cc_2015_00,
  virginia_cc_2014_00,
  virginia_cc_2013_00,
  virginia_cc_2012_00,
  virginia_cc_2011_00,
  virginia_cc_2010_00
)

##Useful functions##----
#A function to group and count each field individually
summarise_and_count <- function(table_name, col_name) {
  table_name %>%
    group_by(!! col_name) %>%
    summarise(count=n()) %>%
    arrange(desc(count))
}

#A function to create cross-tabs
cross_tab_analysis <- function(table_name, var1, var2) {
  table_name %>%
    group_by(!!var1, !!var2) %>%
    summarise(count=n()) %>%
    arrange(desc(count))
}

#A function to compute the percentage of a row and put the results in a new column
compute_percentage <- function(which_summary) {
  cell_used <- which_summary$count
  total <- sum(which_summary$count)
  #Take each row, col2, divide it by total_count, and multiply it by 100
  percentage <- round((cell_used / total)*100,2)
  #Store that data in row1, col3, under the name Percentage
  mutate(which_summary, percentage)
}
##----

##Exploratory research##----

#A variable to hold the master table name----
thistable <- virginia_cc_all

#Computing the summaries and storing them----
summary_hearingdate <- summarise_and_count(thistable, quo(HearingDate))

#----


##Some cross-tab evaluation----


#-----
