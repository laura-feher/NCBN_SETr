#' Save SLR data to a csv file
#'
#' This function saves a data frame of sea-level rise data produced by
#' `get_sea_level_data` to csv files.
#'
#' @param data list. Specifically a list of 2 data frames produced by
#'   `get_sea_level_data`.
#'
#' @param dest_folder string (optional). The folder where you want the file to
#'   be saved. Defaults to the current working directory.
#'
#' @param create_folders boolean (TRUE/FALSE). If the folder specified in
#'   `dest_folder` doesn't exist, do you want to create it? Defaults to FALSE.
#'
#' @param overwrite boolean (TRUE/FALSE). If a file with the same name already
#'   exists in `dest_folder`, do you want to overwrite it? Defaults to FALSE.
#'
#' @returns Saves the SLR data and calculated SLR rate to csv files. The file
#'   names will be the name of the data frame supplied to `data` suffixed with
#'   "_slr_data" or "_slr_rate" and the current date e.g.
#'   "asis_slr_data_2025-06-05.csv" and "asis_slr_rate_2025-06-05.csv".
#'
#' @export
#'
#' @importFrom readr write_csv
#'
#' @examples
#' \dontrun{
#' # Load SLR data for ASIS
#'
#' asis <- get_sea_level_data(park = "ASIS")
#'
#' write_slr_data(
#'     data = asis,
#'     dest_folder = "C:/Documents/SLR_data",
#'     create_folders = TRUE,
#'     overwrite = FALSE
#'     )
#' }
#'
write_slr_data <- function(data, dest_folder = NULL, create_folders = FALSE, overwrite = FALSE) {

    # Adapted from WritePACNVeg by Jake Gross https://github.com/jakegross808/pacn-veg-package

    file_name <- deparse(substitute(data))
    current_date <- Sys.Date()

    # remove any nested or list columns created with calc_linear rates
    slr_rate <- data$slr_rate %>%
        select(-where(is.list))

    if (is.null(dest_folder)) {
        dest_folder <- getwd()
    } else {
        dest_folder <- normalizePath(dest_folder, mustWork = FALSE)
    }

    file_path_slr_data <- file.path(dest_folder, paste0(file_name, "_slr_data_", current_date, ".csv"))
    file_path_slr_rate <- file.path(dest_folder, paste0(file_name, "_slr_rate_", current_date, ".csv"))

    if (!dir.exists(dest_folder)) {
        if (create_folders == TRUE) {
            dir.create(dest_folder)
        } else {
            stop("Destination folder does not exist. To create it automatically, set create_folders to TRUE.")
        }
    }

    if (!overwrite & any(file.exists(c(file_path_slr_data, file_path_slr_rate)))) {
        stop("Saving data in the folder provided would overwrite existing data. To automatically overwrite existing data, set overwrite to TRUE.")
    }

    message(paste("Writing", file_path_slr_data))
    suppressMessages(readr::write_csv(data$slr_data, file_path_slr_data, na = "", append = FALSE, col_names = TRUE))

    message(paste("Writing", file_path_slr_rate))
    suppressMessages(readr::write_csv(slr_rate, file_path_slr_rate, na = "", append = FALSE, col_names = TRUE))

    message("Done writing to CSV")

}
