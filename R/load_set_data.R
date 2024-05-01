#' Calculate Cumulative Change at a SET
#'
#' @param data_type Either "database" if you want to connect to the NPS SET database (authorized users) or "saved_file" if you have a saved .csv or xlse file.
#'
#' @param file_path If using a saved .csv or .xlsx file, the full file path to the saved file. Must be table with one row per pin reading, and the following columns, named exactly: event_date_UTC, network_code, park_code, site_name, station_code, SET_direction, pin_position, pin_height_mm.
#'
#' @param park_code A 4 character park code that can be used to filter results from the NPS database to a specific park.
#'
#' @return A data frame of raw SET data.
#'
#' @export
#'
#' @examples
#'
#' load_set_data(data_type = "database")
#'
#' load_set_data(data_type = "saved_file", file_path = "C:/Documents/Data/my_SET_data.csv")
#'
load_set_data <- function(data_type = "database", file_path = NULL, park_code = NULL){

    if(data_type == "database") {
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

    # get data from SET db and filter to NCBN data
    if(!is.null(park_code)) {
        data <- DBI::dbGetQuery(con, 'SELECT * FROM ssrs.vw_dbx_SET_data_FINAL') %>%
            dplyr::filter(park_code == !!park_code)
    }

    else if(is.null(park_code)) {
        data <- DBI::dbGetQuery(con, 'SELECT * FROM ssrs.vw_dbx_SET_data_FINAL')
    }
    # close database connection to free up resources
    DBI::dbDisconnect(con)
    }

    else if(data_type == "saved_file" & grepl(file_path, ".csv")) {
        data <- read.csv(file_path)
    }

    else if(data_type == "saved_file" & (grepl(file_path, ".xls") | grepl(file_path, ".xlsx"))) {
        data <- readxl::read_xlsx(file_path)
    }
    return(data)

}
