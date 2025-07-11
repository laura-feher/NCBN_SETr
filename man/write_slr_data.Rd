% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/write_slr_data.R
\name{write_slr_data}
\alias{write_slr_data}
\title{Save SLR data and rates to a csv file}
\usage{
write_slr_data(
  data,
  dest_folder = NULL,
  create_folders = FALSE,
  overwrite = FALSE
)
}
\arguments{
\item{data}{list. Specifically a list of 2 data frames produced by
`get_sea_level_data`.}

\item{dest_folder}{string (optional). The folder where you want the file to
be saved. Defaults to the current working directory.}

\item{create_folders}{boolean (TRUE/FALSE). If the folder specified in
`dest_folder` doesn't exist, do you want to create it? Defaults to FALSE.}

\item{overwrite}{boolean (TRUE/FALSE). If a file with the same name already
exists in `dest_folder`, do you want to overwrite it? Defaults to FALSE.}
}
\value{
Saves the SLR data and calculated SLR rate to two separate csv
  files. The file names will be the name of the data frame supplied to `data`
  suffixed with "_slr_data" or "_slr_rate" and the current date e.g.
  "asis_slr_data_2025-06-05.csv" and "asis_slr_rate_2025-06-05.csv".
}
\description{
This function saves a data frame produced by `get_sea_level_data`. Creates
one csv file containing the sea-level data and another csv file containing
the calculated rate of sea-level rise.
}
\examples{
\dontrun{
# Load SLR data for ASIS

asis <- get_sea_level_data(park = "ASIS")

write_slr_data(
    data = asis,
    dest_folder = "C:/Documents/SLR_data",
    create_folders = TRUE,
    overwrite = FALSE
    )
}

}
