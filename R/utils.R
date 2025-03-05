detect_data_type <- function(data){

    cols <- colnames(data)

    if("pin_height_mm" %in% cols){

        ## conditions: is SET data and has correct columns in data frame
        return("SET")
        req_clms <- c("event_date_UTC", "network_code", "park_code", "site_name", "station_code", "SET_direction", "pin_position", "pin_height_mm")

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
        req_clms <- c("event_date_UTC", "network_code", "park_code", "site_name", "station_code", "SET_direction", "pin_position", "pin_height_mm")

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
