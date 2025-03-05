#' Get SLR rates from NOAA tides and currents
#'
#' @param park A capitalized four-letter park code. Parks include COLO, ASIS,
#'   GWMP, NACE, GATE, FIIS, CACO, BOHA, and ACAD.
#'
#' @param nauset logical; used to select the Nauset gauge for CACO.
#'
#' @param trend_start_year (optional) The starting year that you want to use to
#'   calculate SLR. If trend_start_year is not supplied (default), the SLR
#'   calculation uses the earliest available date.
#'
#' @param trend_end_year (optional) The ending year that you want to use to
#'   calculate SLR. If trend_end_year is not supplied (default), the SLR
#'   calculation uses the latest available date.
#'
#' @description The rate of sea-level rise for each park is calculated using
#'   relative sea-level data (RSLR) from the nearest NOAA tide gauge. RSLR Data
#'   is downloaded from the NOAA tides and currents website
#'   https://tidesandcurrents.noaa.gov/.
#'
#' @return A list with 2 data frames: The first data frame, 'slr_data', is the
#'   relative sea-level data downloaded from NOAA tides and current. The second data frame, 'slr_rate',
#'   gives the calculated rate of sea-level rise ('slr_rate'), standard error of the SLR
#'   rate ('slr_rate_se'), lower confidence interval ('lower_ci'), upper
#'   confidence interval ('upper_ci'), minimum year of data used for calculating
#'   SLR ('min_year'), and maximum year of data used for calculating SLR
#'   ('max_year').
#'
#' @export
#'
#' @import readr
#' @import dplyr
#' @import purrr
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
        dplyr::mutate(date = as.Date(paste0(Month, "/", "1/", Year), format = "%m/%d/%Y")) %>%
        {if (!is.null(trend_start_year) & is.null(trend_end_year))
            dplyr::filter(., Year >= trend_start_year)
            else if(!is.null(trend_end_year) & is.null(trend_start_year))
                dplyr::filter(., Year <= trend_end_year)
            else if(!is.null(trend_start_year) & !is.null(trend_end_year))
                dplyr::filter(., Year >= trend_start_year & Year <= trend_end_year)
            else
                dplyr::filter(.)
        } %>%
        dplyr::mutate(min_date = min(date),
                      yr = as.numeric(date - min_date)/365.25)

    slr_rate <- data %>%
        tidyr::nest(data = everything(.)) %>%
        dplyr::mutate(model = purrr::map(data, ~lm(Monthly_MSL*1000 ~ yr, data = .x)),
               model_summary = purrr::map(model, ~summary(.x)),
               slr_rate = purrr::map_dbl(model, ~coefficients(.x)[['yr']]),
               slr_rate_se = purrr::map_dbl(model_summary, ~.x$coefficients[['yr', 'Std. Error']]),
               cis = purrr::map(model, ~confint(.x)),
               lower_ci = purrr::map_dbl(cis, ~.x[['yr', '2.5 %']]),
               upper_ci = purrr::map_dbl(cis, ~.x[['yr', '97.5 %']]),
               min_year = as.Date(unlist(purrr::map(data, ~min(.x$date)))),
               max_year = as.Date(unlist(purrr::map(data, ~max(.x$date))))) %>%
        dplyr::select(slr_rate, slr_rate_se, lower_ci, upper_ci, min_year, max_year)

    return(list("slr_data" = data, "slr_rate" = slr_rate))
}
