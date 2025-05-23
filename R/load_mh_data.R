#' Load MH data from database or saved file
#'
#' @param park (optional); A 4 character park code that can be used to filter
#'   results from the NPS SET database to a specific park. If not specified,
#'   will return data for all parks.
#'
#' @param network_code (optional); A 4 character network code that can be used to
#'   filter results from the NPS SET database to a specific I&M network. If not
#'   specified, will return data for all networks.
#'
#' @param file_path (optional); If, instead of connecting to the NPS SET database,
#'   you want to use a saved .csv or .xlsx file, the full file path to the saved
#'   file. Must be table with one row per marker horizon reading, and the
#'   following columns, named exactly: event_date_UTC, network_code, park_code,
#'   site_name, marker_horizon_name, core_measurement_number,
#'   core_measurement_depth_mm, established_date.
#'
#' @param db_version (optional); If getting data from database, do you want to
#'   connect to the production or development version of the database? Default
#'   is "production".
#'
#' @return A data frame of raw MH data.
#'
#' @details Note that you must be on VPN and have read access to the NPS I&M SET
#'   database for the database option to work.#'
#'
#' @export
#'
#' @import DBI
#' @import odbc
#' @import readr
#' @import readxl
#'
#' @examples
#'
#' load_mh_data(park = "ASIS")
#'
#' load_mh_data(network_code = "NCBN",  db_version = "development")
#'
#' load_mh_data(file_path = "C:/Documents/Data/my_MH_data.csv")
#'
load_mh_data <- function(park = NULL, network_code = NULL, file_path = NULL, db_version = "production"){

    if(is.null(file_path)) {

        # Set up connection variables

        if(db_version == "production") {
            database_server <- "inp2300irmadb01.nps.doi.net\\ntwk"
        }
        else if(db_version == "development") {
            database_server <- "inp2300irmadb04.nps.doi.net\\ntwk"
        }

        database_name <- "SET"
        database_driver <- "ODBC Driver 17 for SQL Server"

        # Build a new connection and connect to the database server
        con <- DBI::dbConnect(odbc::odbc(),
                              Driver = database_driver,
                              Server = database_server,
                              Database = "SET",
                              Trusted_Connection = "Yes",
                              Port = 1433)

        # get data from SET db and filter to a specific park
        if(!is.null(park) & is.null(network_code)) {
            dataf <- DBI::dbSendQuery(con, 'SELECT * FROM ssrs.vw_dbx_marker_horizon_data WHERE park_code = ?')
            data <- DBI::dbBind(dataf, list(toupper(park)))
            data <- DBI::dbFetch(data)
            DBI::dbClearResult(dataf)
        }

        # get data from SET db and filter to a specific I&M network
        else if(!is.null(network_code) & is.null(park)) {
            dataf <- DBI::dbSendQuery(con, 'SELECT * FROM ssrs.vw_dbx_marker_horizon_data WHERE network_code = ?')
            data <- DBI::dbBind(dataf, list(toupper(network_code)))
            data <- DBI::dbFetch(data)
            DBI::dbClearResult(dataf)
        }

        # if both park and network are specified, ignore network_code and filter to park_code
        else if(!is.null(park) & !is.null(network_code)) {
            dataf <- DBI::dbSendQuery(con, 'SELECT * FROM ssrs.vw_dbx_marker_horizon_data WHERE park_code = ?')
            data <- DBI::dbBind(dataf, list(toupper(park)))
            data <- DBI::dbFetch(data)
            DBI::dbClearResult(dataf)
        }

        # or return the whole database
        else if(is.null(park_code) & is.null(network_code)) {
            data <- DBI::dbGetQuery(con, 'SELECT * FROM ssrs.vw_dbx_marker_horizon_data')
        }

        # close database connection to free up resources
        DBI::dbDisconnect(con)
    }

    else if(!is.null(file_path) & stringr::str_detect(file_path, ".csv")) {
        data <- readr::read_csv(file_path)

        cols <- colnames(data)

        ## conditions: have correct columns in data frame
        ## stop and give an informative message if this isn't met
        req_clms <- c("event_date_UTC", "network_code", "park_code", "site_name", "station_code", "marker_horizon_name", "core_measurement_number", "core_measurement_depth_mm", "established_date")

        if(sum(req_clms %in% names(data)) != length(req_clms)){
            stop(paste("Your data frame must have the following columns, with these names, but is missing at least one:", paste(req_clms, collapse = ", ")))
        }
    }

    else if(!is.null(file_path) & (stringr::str_detect(file_path, ".xls") | stringr::str_detect(file_path, ".xlsx"))) {
        data <- readxl::read_excel(file_path)

        cols <- colnames(data)

        ## conditions: have correct columns in data frame
        ## stop and give an informative message if this isn't met
        req_clms <- c("event_date_UTC", "network_code", "park_code", "site_name", "station_code", "marker_horizon_name", "core_measurement_number", "core_measurement_depth_mm", "established_date")

        if(sum(req_clms %in% names(data)) != length(req_clms)){
            stop(paste("Your data frame must have the following columns, with these names, but is missing at least one:", paste(req_clms, collapse = ", ")))
        }
    }

    return(data)
}
