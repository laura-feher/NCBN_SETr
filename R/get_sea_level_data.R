#' Get park-specific SLR rates from NOAA tides and currents
#'
#' This function downloads NOAA tides and currents from the nearest gauge and
#' calculates a rate of SLR.
#'
#' @param park A string (required). A capitalized four-letter park code. One of:
#'  * `"COLO"`: Colonial National Historical Park: NOAA gauge 8638610.
#'  * `"ASIS"`: Assateague Island National Seashore: NOAA gauge 8570283.
#'  * `"GWMP"`: George Washington Memorial Parkway: NOAA gauge 8594900.
#'  * `"NACE"`: National Capital Area East: NOAA gauge 8594900.
#'  * `"GATE"`: Gateway National Recreation Area: NOAA gauge 8531680.
#'  * `"FIIS"`: Fire Island National Seashore: NOAA gauge 8531680.
#'  * `"CACO"`: Cape Cod National Seashore: NOAA gauge 8443970 or 8449130 (Nauset).
#'  * `"BOHA"`: Boston Harbor Islands National Recreation Area: NOAA gauge 8443970.
#'  * `"ACAD"`: Acadia National Park: NOAA gauge 8413320.
#'
#' @param nauset Logical. Used to select the Nauset gauge for CACO; defaults to
#'   FALSE.
#'
#' @param trend_start_year An integer year (optional). The starting year that
#'   you want to use to calculate SLR. If trend_start_year is not supplied
#'   (default), the SLR calculation uses the earliest available date.
#'
#' @param trend_end_year An integer year (optional). The ending year that you
#'   want to use to calculate SLR. If trend_end_year is not supplied (default),
#'   the SLR calculation uses the latest available date.
#'
#' @details The rate of sea-level rise for each park is calculated using
#'   relative sea-level data (RSLR) from the nearest NOAA tide gauge. RSLR Data
#'   is downloaded from the NOAA tides and currents website
#'   https://tidesandcurrents.noaa.gov/.
#'
#' @return A list with 2 data frames: The first data frame, `slr_data`, is the
#'   relative sea-level data downloaded from NOAA tides and current. The column
#'   "Monthly_MSL_m" gives the monthly mean sea-level in meters, whereas
#'   "Monthly_MSL_mm" is in millimeters. The second data frame, `slr_rate`,
#'   gives the calculated rate of sea-level rise in mm/yr (column "slr_rate"),
#'   standard error of the SLR rate (column "slr_rate_se"), lower confidence
#'   interval (column "lower_ci"), upper confidence interval (column
#'   "upper_ci"), minimum year of data used for calculating SLR (column
#'   "min_year"), and maximum year of data used for calculating SLR (column
#'   "max_year").
#'
#' @note Right now this only works for parks in NCBN, NCRN, and NETN
#'
#' @note Note that monthly mean sea level values are relative to the mean
#'   sea-level datum for each station.
#'
#' @export
#'
#' @import dplyr
#' @import purrr
#' @importFrom readr read_csv
#' @importFrom tidyr nest
#'
#' @examples
#' get_sea_level_data(park = "ASIS")
#'
#' get_sea_level_data(park = "CACO", nauset = TRUE)
#'
#' get_sea_level_data(park = "COLO", trend_start_year = 2008, trend_end_year = 2018)
#'
get_sea_level_data <- function (park, nauset = FALSE, trend_start_year = NULL, trend_end_year = NULL){

    valid_parks <- c("COLO", "ASIS", "GWMP", "NACE", "GATE", "FIIS", "CACO", "BOHA", "ACAD")

    if (!park %in% valid_parks) {
        stop(park, " is an invalid park code. Valid park codes are:\n\t",
             paste(valid_parks, collapse = ", "))
    }

    if (park == "COLO") {
        dat <- as.data.frame(readr::read_csv("https://tidesandcurrents.noaa.gov/sltrends/data/8638610_meantrend.csv",
                                             skip = 5, show_col_types = FALSE))
    }
    else if (park == "ASIS") {
        dat <- as.data.frame(readr::read_csv("https://tidesandcurrents.noaa.gov/sltrends/data/8570283_meantrend.csv",
                                             skip = 5, show_col_types = FALSE))
    }
    else if (park == "GWMP") {
        dat <- as.data.frame(readr::read_csv("https://tidesandcurrents.noaa.gov/sltrends/data/8594900_meantrend.csv",
                                             skip = 5, show_col_types = FALSE))
    }
    else if (park == "NACE") {
        dat <- as.data.frame(readr::read_csv("https://tidesandcurrents.noaa.gov/sltrends/data/8594900_meantrend.csv",
                                             skip = 5, show_col_types = FALSE))
    }
    else if (park == "GATE") {
        dat <- as.data.frame(readr::read_csv("https://tidesandcurrents.noaa.gov/sltrends/data/8531680_meantrend.csv",
                                             skip = 5, show_col_types = FALSE))
    }
    else if (park == "FIIS") {
        dat <- as.data.frame(readr::read_csv("https://tidesandcurrents.noaa.gov/sltrends/data/8531680_meantrend.csv",
                                             skip = 5, show_col_types = FALSE))
    }
    else if (park == "CACO") {
        if (nauset) {
            dat <- as.data.frame(readr::read_csv("https://tidesandcurrents.noaa.gov/sltrends/data/8449130_meantrend.csv",
                                                 skip = 5, show_col_types = FALSE))
        }
        else {
            dat <- as.data.frame(readr::read_csv("https://tidesandcurrents.noaa.gov/sltrends/data/8443970_meantrend.csv",
                                                 skip = 5, show_col_types = FALSE))
        }
    }
    else if (park == "BOHA") {
        dat <- as.data.frame(readr::read_csv("https://tidesandcurrents.noaa.gov/sltrends/data/8443970_meantrend.csv",
                                             skip = 5, show_col_types = FALSE))
    }
    else if (park == "ACAD") {
        dat <- as.data.frame(readr::read_csv("https://tidesandcurrents.noaa.gov/sltrends/data/8413320_meantrend.csv",
                                             skip = 5, show_col_types = FALSE))
    }
    else {
        stop("Please supply a valid 4 letter park code")
    }

    data <- dat %>%
        mutate(date = as.Date(paste0(Month, "/", "1/", Year), format = "%m/%d/%Y")) %>%
        {if (!is.null(trend_start_year) & is.null(trend_end_year))
            filter(., Year >= trend_start_year)
            else if(!is.null(trend_end_year) & is.null(trend_start_year))
                filter(., Year <= trend_end_year)
            else if(!is.null(trend_start_year) & !is.null(trend_end_year))
                filter(., Year >= trend_start_year & Year <= trend_end_year)
            else
                filter(.)
        } %>%
        mutate(min_date = min(date),
                      yr = as.numeric(date - min_date)/365.25,
                      Monthly_MSL_m = Monthly_MSL, # rename this column to make it obvious that this is meters
                      Monthly_MSL_mm = Monthly_MSL*1000) %>% # convert to millimeters for comparisons to SET/MH data
        select(-Monthly_MSL)

    slr_rate <- data %>%
        tidyr::nest(data = everything(.)) %>%
        mutate(model = map(data, ~lm(Monthly_MSL_mm ~ yr, data = .x)),
               model_summary = map(model, ~summary(.x)),
               slr_rate = map_dbl(model, ~coefficients(.x)[['yr']]),
               slr_intc = map_dbl(model, ~coefficients(.x)[['(Intercept)']]),
               slr_rate_se = map_dbl(model_summary, ~.x$coefficients[['yr', 'Std. Error']]),
               cis = map(model, ~confint(.x)),
               lower_ci = map_dbl(cis, ~.x[['yr', '2.5 %']]),
               upper_ci = map_dbl(cis, ~.x[['yr', '97.5 %']]),
               min_year = as.Date(unlist(map(data, ~min(.x$date)))),
               max_year = as.Date(unlist(map(data, ~max(.x$date))))) %>%
        select(model, model_summary, slr_rate, slr_intc, slr_rate_se, lower_ci, upper_ci, min_year, max_year)

    return(list("slr_data" = data, "slr_rate" = slr_rate))
}
