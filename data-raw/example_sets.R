## code to prepare `example_sets` dataset goes here

library(DBI)
library(odbc)
library(tidyverse)

# Set up connection variables
database_server <- "inp2300irmadb01.nps.doi.net\\ntwk"
database_name <- "SET"
database_driver <- "ODBC Driver 17 for SQL Server"

# Build a new connection and connect to the database server
con <- DBI::dbConnect(odbc::odbc(),
                      Driver = database_driver,
                      Server = database_server,
                      Database = "SET",
                      Trusted_Connection = "Yes",
                      Port = 1433)


example_sets <- dbGetQuery(con, 'SELECT * FROM ssrs.vw_dbx_SET_data_FINAL') %>%
    filter(network_code == "NCBN" & observation_type == "Standard") %>%
    select(event_date_UTC, network_code, park_code, site_name, station_code, SET_direction, pin_position, pin_height_mm) %>%
    filter(park_code == "ASIS" & site_name == "Marsh 11")

usethis::use_data(example_sets, overwrite = T)

DBI::dbDisconnect(con)
