get_sea_level_data <- function (park_code, nauset = FALSE, trend_start_year = NULL, trend_end_year = NULL) 
{
  valid_parks <- c("COLO", "ASIS", "GWMP", "NACE", "GATE", "FIIS", 
                  "CACO", "BOHA", "ACAD")
  
  if (!park_code %in% valid_parks) {
    stop(park_code, " is an invalid park code. Valid park codes are:\n\t", 
         paste(valid_parks, collapse = ", "))
  }
  
  if (park_code == "COLO") {
    dat <- as.data.frame(readr::read_csv("https://tidesandcurrents.noaa.gov/sltrends/data/8638610_meantrend.csv", 
                    skip = 5, show_col_types = FALSE))
  }
  else if (park_code == "ASIS") {
    dat <- as.data.frame(readr::read_csv("https://tidesandcurrents.noaa.gov/sltrends/data/8570283_meantrend.csv", 
                     skip = 5, show_col_types = FALSE))
  }
  else if (park_code == "GWMP") {
    dat <- as.data.frame(readr::read_csv("https://tidesandcurrents.noaa.gov/sltrends/data/8594900_meantrend.csv", 
                    skip = 5, show_col_types = FALSE))
  }
  else if (park_code == "NACE") {
    dat <- as.data.frame(readr::read_csv("https://tidesandcurrents.noaa.gov/sltrends/data/8594900_meantrend.csv", 
                    skip = 5, show_col_types = FALSE))
  }
  else if (park_code == "GATE") {
    dat <- as.data.frame(readr::read_csv("https://tidesandcurrents.noaa.gov/sltrends/data/8531680_meantrend.csv", 
                    skip = 5, show_col_types = FALSE))
  }
  else if (park_code == "FIIS") {
    dat <- as.data.frame(readr::read_csv("https://tidesandcurrents.noaa.gov/sltrends/data/8531680_meantrend.csv", 
                    skip = 5, show_col_types = FALSE))
  }
  else if (park_code == "CACO") {
    if (nauset) {
      dat <- as.data.frame(readr::read_csv("https://tidesandcurrents.noaa.gov/sltrends/data/8449130_meantrend.csv", 
                      skip = 5, show_col_types = FALSE))
    }
    else {
      dat <- as.data.frame(readr::read_csv("https://tidesandcurrents.noaa.gov/sltrends/data/8443970_meantrend.csv", 
                      skip = 5, show_col_types = FALSE))
    }
  }
  else if (park_code == "BOHA") {
    dat <- as.data.frame(readr::read_csv("https://tidesandcurrents.noaa.gov/sltrends/data/8443970_meantrend.csv", 
                    skip = 5, show_col_types = FALSE))
  }
  else if (park_code == "ACAD") {
    dat <- as.data.frame(readr::read_csv("https://tidesandcurrents.noaa.gov/sltrends/data/8413320_meantrend.csv", 
                    skip = 5, show_col_types = FALSE))
  }
  else {
    stop("Park code problem")
  }
  
  dat <- dat %>%
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
           yr = as.numeric(date - min_date)/365.25)
  
  model <- lm((Monthly_MSL * 1000) ~ yr, data = dat)
  coeffs <- coefficients(model)
  cis <- confint(model)
  model_summ <- data.frame(
    variable = c("slope", "int"),
    coeff = c(coeffs[["yr"]], coeffs[["(Intercept)"]]),
    lower = c(cis["yr", "2.5 %"], cis["(Intercept)", "2.5 %"]),
    upper = c(cis["yr", "97.5 %"], cis["(Intercept)", "97.5 %"])
  )
  
  return(list(dat = dat, model_summ = model_summ))
}
