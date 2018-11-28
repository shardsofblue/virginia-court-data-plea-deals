##GETTING POSTGRESQL TO WORK IN RSTUDIO##

##BASIC UTILITY LIB INSTALL
#install.packages("tidyverse")
#install.packages('stringr')
#install.packages('lubridate')
library(tidyverse)
library(stringr)
library(lubridate)

#SEE THE FOLLOWING LINKS:----
#http://db.rstudio.com/databases/postgresql/
#http://db.rstudio.com/best-practices/drivers/


#STEP-BY-STEP SETUP----
#Only needs to be done once per machine

##1. Install Homebrew onto Mac
#http://brew.sh/

##2. Install the unixODBC library onto Mac by inputting the following into the Terminal
#brew install unixodbc

##3. Install common database libraries onto Mac by inputting the following into the Terminal
#brew install freetds --with-unixodbc
#brew install psqlodbc
#brew install mysql
#brew install sqliteodbc

##4. Install the latest odbc release from CRAN into RStudio:
#install.packages("odbc")

#END SETUP----

con <- DBI::dbConnect(odbc::odbc(),
                      Driver   = "[your driver's path and name]",
                      #should look like:
                      #/usr/local/lib/psqlodbcw.so
                      Server   = "[your server's path]",
                      Database = "[your database's name as it is on the server]",
                      UID      = rstudioapi::askForPassword("Database user"),
                      PWD      = rstudioapi::askForPassword("Database password"),
                      Port     = 5432)
