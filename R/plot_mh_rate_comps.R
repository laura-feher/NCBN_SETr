#' Graphical comparison of station-level accretion rates
#'
#' @param data Either 1) a data frame of raw marker horizon data or 2) a data
#'   frame of station-level rates of accretion. See details below for
#'   requirements.
#'
#' @param calc_rates do rates of accretion need to be calculated before
#'   generating plots? Defaults to TRUE. If supplying a data frame with rates,
#'   use `calc_rates` = FALSE. If supplying a data frame of raw MH data, use
#'   `calc_rates` = TRUE.
#'
#' @param plot_type One of various combinations of points, error bars, or
#'   confidence intervals; default is 2. 1 = basic points only - no error
#'   bars/confidence intervals; 2 = SEs/CIs for accretion rates; 3 = SEs/CIs for
#'   accretion rates and a rate for comparison (e.g. sea-level rise); 4 =
#'   SEs/CIs for accretion rates and 2 different rates for comparisons.
#'
#' @param error_bar_type For plot_types 2-4, choose display with either standard
#'   errors or 95% confidence intervals. 'se' = standard errors (default);
#'   'confint' = 95% confidence intervals.
#'
#' @param station_ids required if a supplying a data frame with rates. Column
#'   name of values representing the station ID for each station. Defaults to
#'   'station_code'.
#'
#' @param rates required if supplying a data frame with rates. Column name of
#'   values representing the linear estimates (i.e., rates) of accretion for
#'   each station. Defaults to 'station_rate'.
#'
#' @param station_se required if supplying a data frame with rates. Column name
#'   of values representing the standard errors for each station-level rate of
#'   accretion. Defaults to 'station_se_rate'.
#'
#' @param station_ci_low required if supplying a data frame with rates. Column
#'   name of values representing the lower limit of the 95\% confidence interval
#'   for each station-level rate of accretion. Defaults to 'station_ci_low'.
#'
#' @param station_ci_high required if supplying a data frame with rates. Column
#'   of values representing the upper limit of the 95\% confidence interval for
#'   each station-level rate of accretion. Defaults to 'station_ci_high'.
#'
#' @param comp1 optional; Single number for comparing with station-level rates
#'   of accretion (e.g. long-term Sea Level Rise) - will appear as a line on the
#'   graph.
#'
#' @param comp1_se optional; Single number representing 1 standard error for the
#'   point estimate `comp1`. Required if `comp1` is specified and
#'   `error_bar_type` = "se".
#'
#' @param comp1_ci_low optional; Single number representing the lower limit of
#'   the 95\% confidence interval for the point estimate `comp1`. Required if
#'   `comp1` is specified and `error_bar_type` = "confint".
#'
#' @param comp1_ci_high optional; Single number representing the upper limit of
#'   the 95\% confidence interval for the point estimate `comp1`. Required if
#'   `comp1` is specified and `error_bar_type` = "confint".
#'
#' @param comp1_name optional; Label for comp1 value (e.g. "Local, long-term
#'   SLR").
#'
#' @param comp2 optional; Single number for comparing with station-level rates
#'   of accretion (e.g. 19-year water level change) - will appear as a line on
#'   the graph.
#'
#' @param comp2_se optional; Single number representing 1 standard error for the
#'   point estimate `comp2`. Required if `comp2` is specified and error_bar_type
#'   = "se".
#'
#' @param comp2_ci_low optional; Single number representing the lower limit of
#'   the 95\% confidence interval for the point estimate `comp2`. Required if
#'   `comp2` is specified and `error_bar_type` = "confint".
#'
#' @param comp2_ci_high optional; a single number representing the upper limit
#'   of the 95\% confidence interval for the point estimate `comp2`. Required if
#'   `comp2` is specified and `error_bar_type` = "confint".
#'
#' @param comp2_name optional; Label for `comp2` value (e.g. "19-yr water level
#'   change").
#'
#' @description Station-level cumulative change is calculated via the function
#'   'calc_change_cumu'. Linear rates of change are calculated via the function
#'   'calc_linear_rates'. See function documentation for details.
#'
#' @details `data` must be either 1) a data frame of raw marker horizon data
#'   with 1 row per core measurement and the following columns, named exactly:
#'   event_date_UTC, network_code, park_code, site_name, station_code,
#'   marker_horizon_name, core_measurement_number, core_measurement_depth_mm,
#'   and established_date; or 2) a user-created data frame of station-level
#'   rates of accretion with (at least) columns for station IDs, station-level
#'   rates, and either a) a single column with station rate std error, or b) 2
#'   columns with the high and low station rate confidence intervals.
#'
#' @return a ggplot object
#'
#' @export
#'
#' @examples
#'
#' plot_mh_rate_comps(data = example_mh,
#'                 plot_type = 1)
#'
#' plot_mh_rate_comps(data = example_mh,
#'                plot_type = 2,
#'                error_bar_type = "confint")
#'
#' plot_mh_rate_comps(
#'     data = example_mh,
#'     plot_type = 3,
#'     error_bar_type = "se",
#'     comp1 = 3.5,
#'     comp1_se = 0.2,
#'     comp1_name = "Local, long-term SLR")
#'
#'
#' # Example with a user-supplied data frame of station-level rates
#' example_rates <- data.frame("station_id" = c("station_1", "station_2", "station_3"),
#'                             "station_rate" = c(3.2, 4.0, 5.4),
#'                             "station_ci_low" = c(3.0, 3.2, 5.2),
#'                             "station_ci_high" = c(3.4, 4.8, 5.6))
#'
#'
#' plot_mh_rate_comps(data = example_rates,
#'                 calc_rates = FALSE,
#'                 plot_type = 4,
#'                 error_bar_type = "confint",
#'                 station_ids = station_id,
#'                 rates = station_rate,
#'                 station_ci_low = station_ci_low,
#'                 station_ci_high = station_ci_high,
#'                 comp1 = 3.5,
#'                 comp1_ci_low = 3.3,
#'                 comp1_ci_high = 3.7,
#'                 comp1_name = "Local, long-term SLR",
#'                 comp2 = 4.0,
#'                 comp2_ci_low = 3.6,
#'                 comp2_ci_high = 4.4,
#'                 comp2_name = "19-yr water level change")
#'
plot_mh_rate_comps <- function(data,
                                calc_rates = TRUE,
                                plot_type = 2,
                                error_bar_type = "se",
                                station_ids = "station_code",
                                rates = "station_rate",
                                station_se = "station_se_rate",
                                station_ci_low = "station_ci_low",
                                station_ci_high = "station_ci_high",
                                comp1 = NULL,
                                comp1_se = NULL,
                                comp1_ci_low = NULL,
                                comp1_ci_high = NULL,
                                comp1_name = "Comp1 rate",
                                comp2 = NULL,
                                comp2_se = NULL,
                                comp2_ci_low = NULL,
                                comp2_ci_high = NULL,
                                comp2_name = "Comp2 rate"){

    # if plot_type = 3 or plot_type = 4, make sure comp values are supplied
    if(plot_type == 3 & error_bar_type == "se" &
       (is.null(comp1) | is.null(comp1_se))) {
        stop("please provide a value for comp1 and comp1_se")
    }
    else if(plot_type == 3 & error_bar_type == "confint" &
            (is.null(comp1) | is.null(comp1_ci_low) | is.null(comp1_ci_low))) {
        stop("please provide a value for comp1, comp1_ci_low, and comp1_ci_high")
    }
    else if(plot_type == 4 & error_bar_type == "se" &
            (is.null(comp1) | is.null(comp1_se) |
             is.null(comp2) | is.null(comp2_se))) {
        stop("please provide a value for comp1, comp1_se, comp2, and comp2_se")
    }
    else if(plot_type == 4 & error_bar_type == "confint" &
            (is.null(comp1) | is.null(comp1_ci_low) | is.null(comp1_ci_high) |
             is.null(comp2) | is.null(comp2_ci_low) | is.null(comp2_ci_high))) {
        stop("please provide a value for comp1, comp1_ci_low, comp1_ci_high,\n
             comp2, comp2_ci_low, and comp2_ci_high")
    }

    # if supplying df of rates, make sure that the specified columns exist in the df
    if(calc_rates == FALSE & error_bar_type == "se" & (!station_ids %in% colnames(data) |
                                                       !rates %in% colnames(data) |
                                                       !station_se %in% colnames(data))){
        stop(paste0("column names '", station_ids, "', '", rates, "', and/or '",
                    station_se, "' were not found in '", deparse(substitute(data)), "'"))
    }
    else if(calc_rates == FALSE & error_bar_type == "confint" & (!station_ids %in% colnames(data) |
                                                                 !rates %in% colnames(data) |
                                                                 !station_ci_low %in% colnames(data) |
                                                                 !station_ci_high %in% colnames(data))){
        stop(paste0("column names '", station_ids, "', '", rates, "', '",
                    station_ci_low, "', and/or '", station_ci_high,
                    "' were not found in '", deparse(substitude(data)), "'"))
    }


    if(calc_rates == FALSE) {
        dataf <- data # if supplying a df of rates, don't use calc_linear_rates to get rates
    }
    else if(calc_rates == TRUE) {
        dataf <- calc_linear_rates(data) # if supplying a raw data df, use calc_linear_rates to get rates
    }

    # assemble the base plot, with axes and line for 0
    #####################################################################
    p <- ggplot(data = dataf, aes(x = .data[[rates]], y = .data[[station_ids]])) +
        geom_vline(aes(xintercept = 0),
                   col = "gray70",
                   linetype = "dashed") +
        theme_classic()

    points_same <- geom_point(size = 3, col = "red3", inherit.aes = T)


    # assemble each piece
    #####################################################################
    # axis titles
    x_axis_title <- "Rate of surface accretion (mm/yr)"
    y_axis_title <- "Station name"

    # plot titles
    title_minimal <- "Rates of surface accretion (mm/yr)"
    title_se <- "Rates of surface accretion ± 1 standard error (mm/yr)"
    title_ci <- "Rates of surface accretion with 95% confidence intervals (mm/yr)"

    # plot_subtitles
    subtitle_comp1_se <- paste0(comp1_name, ", blue line & shading: ",
                                format({{comp1}}, nsmall = 1), " +/- ",
                                format({{comp1_se}}, nsmall = 1), " mm/yr")

    subtitle_comp1_ci <- paste0(comp1_name, ", blue line & shading: ",
                                format({{comp1}}, nsmall = 1), " +/- ",
                                format(({{comp1_ci_high}} - {{comp1_ci_low}}) / 2, nsmall = 1), " mm/yr")

    subtitle_comp2_se <- paste0(comp1_name, ", blue line & shading: ",
                                format({{comp1}}, nsmall = 1), " +/- ",
                                format({{comp1_se}}, nsmall = 1), " mm/yr",
                                "\n", comp2_name, ", green line & shading: ",
                                format({{comp2}}, nsmall = 1), " +/- ",
                                format({{comp2_se}}, nsmall = 1), " mm/yr")

    subtitle_comp2_ci <- paste0("Long-term SLR, blue line & shading: ",
                                format({{comp1}}, nsmall = 1), " +/- ",
                                format(({{comp1_ci_high}} - {{comp2_ci_low}}) / 2, nsmall = 1), " mm/yr",
                                "\n", comp2_name, ", green line & shading: ",
                                format({{comp2}}, nsmall = 1), " +/- ",
                                format(({{comp2_ci_high}} - {{comp2_ci_low}}) / 2, nsmall = 1), " mm/yr")


    # assemble axis labels and plot titles
    labels_minimal <- labs(title = title_minimal, # plot type 1: labels when no SEs/CIs are included
                           x = x_axis_title,
                           y = y_axis_title)

    labels_station_se <- labs(title = title_se, # plot type 2: labels when SEs are included for stations
                              x = x_axis_title,
                              y = y_axis_title)

    labels_station_ci <- labs(title = title_ci, # plot type 2: labels when CIs are included for stations
                              x = x_axis_title,
                              y = y_axis_title)

    labels_station_se_comp1_se <- labs(title = title_se, # plot type 3: labels when SEs for stations and comp1 are included
                                       subtitle = subtitle_comp1_se,
                                       x = x_axis_title,
                                       y = y_axis_title)

    labels_station_ci_comp1_ci <- labs(title = title_ci, # plot type 3: labels when CIs for stations and comp1 are included
                                       subtitle = subtitle_comp1_ci,
                                       x = x_axis_title,
                                       y = y_axis_title)

    labels_station_se_comp2_se <- labs(title = title_se, # plot type 4: labels when SEs for stations and comp1 and comp2 are included
                                       subtitle = subtitle_comp2_se,
                                       x = x_axis_title,
                                       y = y_axis_title)

    labels_station_ci_comp2_ci <- labs(title = title_ci, # plot type 4: labels when SEs for stations and comp1 and comp2 are included
                                       subtitle = subtitle_comp2_ci,
                                       x = x_axis_title,
                                       y = y_axis_title)


    # assemble geoms
    station_se_lines <- geom_errorbarh(data = dataf,  # plot type 2 & SE error bars for stations
                                       aes(y = .data[[station_ids]],
                                           xmin = .data[[rates]] - .data[[station_se]],
                                           xmax = .data[[rates]] + .data[[station_se]]),
                                       col = "gray55",
                                       height = 0.2,
                                       size = 1)

    station_cis_lines <- geom_errorbarh(data = dataf, # plot type 2 & CI error bars for stations
                                        aes(y = .data[[station_ids]],
                                            xmin = .data[[station_ci_low]],
                                            xmax = .data[[station_ci_high]]),
                                        col = "gray55",
                                        height = 0.2,
                                        size = 1)

    comp1_line <- geom_vline(aes(xintercept = {{comp1}}), # plot type 3: dark blue line for comp1
                             col = "navyblue",
                             size = 1,
                             alpha = 0.9)

    comp2_line <- geom_vline(aes(xintercept = {{comp2}}), # plot type 4: dark blue line for comp1
                             col = "darkgreen",
                             size = 1,
                             alpha = 0.9)

    comp1_se_bars <- annotate(geom = "rect", # plot type 3 & SE error bars
                              ymin = -Inf, ymax = Inf,
                              xmin = comp1 - comp1_se, xmax = comp1 + comp1_se,
                              fill = "#08519c",
                              alpha = 0.2)

    comp1_ci_bars <- annotate(geom = "rect", ymin = -Inf, # plot type 3 & CI error bars
                              ymax = Inf,
                              xmin = comp1_ci_low,
                              xmax = comp1_ci_high,
                              fill = "#08519c",
                              alpha = 0.2)

    comp2_se_bars <- annotate(geom = "rect", ymin = -Inf, # plot type 4 & SE error bars
                              ymax = Inf,
                              xmin = comp2 - comp2_se,
                              xmax = comp2 + comp2_se,
                              fill = "#7bccc4",
                              alpha = 0.2)

    comp2_ci_bars <- annotate(geom = "rect", ymin = -Inf, # plot type 4 & CI error bars
                              ymax = Inf,
                              xmin = comp2_ci_low,
                              xmax = comp2_ci_high,
                              fill = "#7bccc4",
                              alpha = 0.2)


    # ### Assemble in different ways
    # #####################################################################


    # minimal plot: points only; no confidence intervals
    if(plot_type == 1){
        p <- p +
            points_same +
            labels_minimal
    }

    # Add in SEs or CIs for stations

    if(plot_type == 2 & error_bar_type == "se"){
        p <- p +
            station_se_lines +
            points_same +
            labels_station_se
    }


    if(plot_type == 2 & error_bar_type == "confint"){
        p <- p +
            station_cis_lines +
            points_same +
            labels_station_ci
    }

    # Add in comp1 with SEs or CIs for stations
    if(plot_type == 3 & error_bar_type == "se"){
        p <- p +
            comp1_se_bars +
            comp1_line +
            station_se_lines +
            points_same +
            labels_station_se +
            labels_station_se_comp1_se
    }

    if(plot_type == 3 & error_bar_type == "confint"){
        p <- p +
            comp1_ci_bars +
            comp1_line +
            station_cis_lines +
            points_same +
            labels_station_ci +
            labels_station_ci_comp1_ci
    }

    # Add in comp2 with SEs or CIs for stations
    if(plot_type == 4 & error_bar_type == "se"){
        p <- p +
            comp2_se_bars +
            comp2_line +
            comp1_se_bars +
            comp1_line +
            station_se_lines +
            points_same +
            labels_station_se +
            labels_station_se_comp2_se
    }

    if(plot_type == 4 & error_bar_type == "confint"){
        p <- p +
            comp2_ci_bars +
            comp2_line +
            comp1_ci_bars +
            comp1_line +
            station_cis_lines +
            points_same +
            labels_station_ci +
            labels_station_ci_comp2_ci
    }

    return(p)

}
