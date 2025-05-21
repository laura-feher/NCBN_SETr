detect_data_type <- function(data){

    cols <- colnames(data)

    if("pin_height_mm" %in% cols){

        ## conditions: is SET data and has correct columns in data frame
        return("SET")
        req_clms <- c("event_date_UTC", "network_code", "park_code", "site_name", "station_code", "SET_direction", "pin_position", "pin_height_mm", "SET_offset_mm", "pin_length_mm")

        ## stop and give an informative message if this isn't met
        if(sum(req_clms %in% names(data)) != length(req_clms)){
            stop(paste("Your data frame must have the following columns, with these names, but is missing at least one:", paste(req_clms, collapse = ", ")))
        }

    } else if("core_measurement_depth_mm" %in% cols){

        ## conditions: is MH data and has correct columns in data frame
        return("MH")
        req_clms <- c("event_date_UTC", "network_code", "park_code", "site_name", "station_code", "marker_horizon_name", "core_measurement_number", "core_measurement_depth_mm", "established_date")

        ## stop and give an informative message if this isn't met
        if(sum(req_clms %in% names(data)) != length(req_clms)){
            stop(paste("Your data frame must have the following columns, with these names, but is missing at least one:", paste(req_clms, collapse = ", ")))
        }
    } else {
        stop(paste("Data must include a column with either SET data or MH data."))
    }
}

detect_set_data <- function(data){

    cols <- colnames(data)

    if("pin_height_mm" %in% cols){

        ## conditions: is SET data and has correct columns in data frame
        return("SET")
        req_clms <- c("event_date_UTC", "network_code", "park_code", "site_name", "station_code", "SET_direction", "pin_position", "pin_height_mm", "SET_offset_mm", "pin_length_mm")

        ## stop and give an informative message if this isn't met
        if(sum(req_clms %in% names(data)) != length(req_clms)){
            stop(paste("Your data frame must have the following columns, with these names, but is missing at least one:", paste(req_clms, collapse = ", ")))
        }

    }
}

detect_mh_data <- function(data){

    cols <- colnames(data)

    if("core_measurement_depth_mm" %in% cols){

        ## conditions: is MH data and has correct columns in data frame
        return("MH")
        req_clms <- c("event_date_UTC", "network_code", "park_code", "site_name", "station_code", "marker_horizon_name", "core_measurement_number", "core_measurement_depth_mm", "established_date")

        ## stop and give an informative message if this isn't met
        if(sum(req_clms %in% names(data)) != length(req_clms)){
            stop(paste("Your data frame must have the following columns, with these names, but is missing at least one:", paste(req_clms, collapse = ", ")))
        }
    }
}

# remove a single grouping level
drop_groups2 = function(data, ...) {

    groups = map(groups(data), quo)
    drop = quos(...)

    if(any(!drop %in% groups)) {

                      paste(drop[!drop %in% groups], collapse=", ")
    }

    data %>% group_by(!!!setdiff(groups, drop))

}

# groups the stations into their correct sites for calculating cumulative change and rates of change
correct_site_groups <- function(station_code, site_name) {
    case_when(
        # station_code %in% c("M11-3", "M5-2", "M6-4", "M8-4") ~ "Fenced stations", # not sure if I want to group these like this or not - causes issues when grouping dates and getting cumu. change at the site-level
        station_code %in% c("G1", "G2", "G3", "GUT1", "GUT2", "GUT3") ~ "Herring River Gut",
        station_code %in% c("HighToss1", "HighToss2", "HighToss3") ~ "Herring River High Toss",
        station_code %in% c("Phrag1", "Phrag2", "Phrag3") ~ "Herring River Phrag",
        station_code %in% c("HH1", "HH2", "HH3", "HH4", "HH5", "HH6") ~ "Hatches Harbor Inside Dyke Original SETs",
        station_code %in% c("HH7", "HH8", "HH9") ~ "Hatches Harbor Outside Dyke Original SETs",
        station_code %in% c("H4", "H5", "H6") ~ "Hatches Harbor Inside Dyke Deep RSETs",
        station_code %in% c("H1", "H2", "H3") ~ "Hatches Harbor Outside Dyke Deep RSETs",
        station_code %in% c("EE1S", "EE2S", "EE3S") ~ "Elders East Shallow SETs",
        station_code %in% c("JR1S", "JR2S", "JR3S") ~ "Jamaica Bay Reference Shallow SETs",
        station_code %in% c("Creek1", "Creek2", "Creek3") ~ "Dyke Marsh Creek",
        station_code %in% c("Int1", "Int2", "Int3") ~ "Dyke Marsh Interior",
        station_code %in% c("River1", "River1A", "River2", "River3") ~ "Dyke Marsh River",
        TRUE ~ site_name
    )
}
