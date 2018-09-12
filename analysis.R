#Analysis file for Virginia court data for Plea Bargain Project. By Roxanne Ready, started on Aug. 27, 2018.
#install.packages("tidyverse")
#install.packages('stringr')
#install.packages('lubridate')
library(tidyverse)
library(stringr)
library(lubridate)
#brew install freetds --with-unixodbc
#brew install psqlodbc
#brew install mysql
#brew install sqliteodbc
#install.packages("odbc")

con <- DBI::dbConnect(odbc::odbc(),
                      Driver   = "/usr/local/lib/psqlodbcw.so",
                      Server   = "va-court-data.c7epjo1jekfc.us-east-1.rds.amazonaws.com",
                      Database = "vacourtscraper",
                      UID      = rstudioapi::askForPassword("readonly"),
                      PWD      = rstudioapi::askForPassword("HamptonRoadsTreeLeaves"),
                      Port     = 5432)

virginia_dc_2017_00 <- read_csv(col_types = cols(RestrictionEndDate=col_character()),'data/district_criminal_2017_anon_UG6NRN/district_criminal_2017_anon_00.csv')