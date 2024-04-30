#' Graphical comparison of Site-level elevation change rates
#'
#' @param data Either 1) a data frame with one row per pin reading, and the following columns, named exactly: event_date_UTC, network_code, park_code, site_name, station_code, SET_direction, pin_position, pin_height_mm; or 2) a user-supplied data frame of site-level elevation change rates with (at least) columns for site IDs, site-level rates, and either a) a single column with site-level rate std error, or b) 2 columns with the high and low site-level rate confidence intervals.
#' @param plot_type One of various combinations of points, error bars, or confidence intervals; default is 2. 1 = basic; points only; no error bars/confidence intervals; 2 = SEs/CIs for SET rates; 3 = SEs/CIs for SET rates and a rate for comparison (e.g. sea-level rise); 4 = SEs/CIs for SET rates and 2 different rates for comparisons.
#' @param site_ids Column name containing unique site IDs or names. Defaults to site_name. The column name must be specified if using a user-supplied data frame of site-level rates.
#' @param rates Column name of numbers representing the linear estimates of site-level rates of elevation change. Defaults to site_rate. The column name must be specified if using a user-supplied data frame of site-level rates.
#' @param error_bar_type For plot_types 2-4, choose display with either standard errors or 95% confidence intervals. 'se' = standard errors (default); 'confint' = 95% confidence intervals.
#' @param site_se Column name of numbers representing the standard errors for each site-level rate of elevation change. Defaults to se_rate. The column name must be specified if using a user-supplied data frame of site-level rates.
#' @param site_ci_low Column name of numbers representing the lower limit of the 95\% confidence interval for each site-level rate of elevation change. Defaults to ci_low. The column name must be specified if using a user-supplied data frame of site-level rates.
#' @param site_ci_high Column of numbers representing the upper limit of the 95\% confidence interval for each site-level rate of elevation change. Defaults to ci_high. The column name must be specified if using a user-supplied data frame of site-level rates.
#' @param comp1 optional; Single number for comparing to site-level rates of change (e.g. long-term Sea Level Rise) - will appear as a line on the graph.
#' @param comp1_se optional; Single number representing 1 standard error for the point estimate 'comp1'. Required if comp1 is specified and error_bar_type = "se".
#' @param comp1_ci_low optional; Single number representing the lower limit of the 95\% confidence interval for the point estimate `comp1`. Required if comp1 is specified and error_bar_type = "confint".
#' @param comp1_ci_high optional; Single number representing the upper limit of the 95\% confidence interval for the point estimate `comp1`. Required if comp1 is specified and error_bar_type = "confint".
#' @param comp1_name optional; Label for comp1 value (e.g. "Local, long-term SLR").
#' @param comp2 optional; Single number for comparing to site-level rates of change (e.g. 19-year water level change) - will appear as a line on the graph.
#' @param comp2_se optional; Single number representing 1 standard error for the point estimate 'comp2'. Required if comp2 is specified and error_bar_type = "se".
#' @param comp2_ci_low optional; Single number representing the lower limit of the 95\% confidence interval for the point estimate `comp2`. Required if comp2 is specified and error_bar_type = "confint".
#' @param comp2_ci_high optional; a single number representing the upper limit of the 95\% confidence interval for the point estimate `comp2`. Required if comp2 is specified and error_bar_type = "confint".
#' @param comp2_name optional; Label for comp2 value (e.g. "19-yr water level change").
#' @return a ggplot object
#' @export
#'
#' @examples
#'
#' plot_site_rate_comps(data = example_sets,
#'                 plot_type = 1)
#'
#' plot_site_rate_comps(data = example_sets,
#'                plot_type = 2,
#'                error_bar_type = "confint")
#'
#' plot_site_rate_comps(
#'     data = example_sets,
#'     plot_type = 3,
#'     error_bar_type = "se",
#'     comp1 = 3.5,
#'     comp1_se = 0.2,
#'     comp1_name = "Local, long-term SLR")
#'
#'
#' # Example with a user-supplied data frame of site-level rates
#' example_rates <- data.frame("site_id" = c("site1", "site2", "site3"),
#'                             "set_rate" = c(3.2, 4.0, 5.4),
#'                             "ci_low" = c(3.0, 3.2, 5.2),
#'                             "ci_high" = c(3.4, 4.8, 5.6))
#'
#'
#' plot_site_rate_comps(data = example_rates,
#'                 plot_type = 4,
#'                 error_bar_type = "confint",
#'                 site_ids = set_id,
#'                 rates = site_rate,
#'                 set_ci_low = ci_low,
#'                 set_ci_high = ci_high,
#'                 comp1 = 3.5,
#'                 comp1_ci_low = 3.3,
#'                 comp1_ci_high = 3.7,
#'                 comp1_name = "Local, long-term SLR",
#'                 comp2 = 4.0,
#'                 comp2_ci_low = 3.6,
#'                 comp2_ci_high = 4.4,
#'                 comp2_name = "19-yr water level change")
#'
plot_site_rate_comps <- function(data,
                                plot_type = 2,
                                error_bar_type = "se",
                                site_ids = site_name,
                                rates = site_rate,
                                site_se = se_rate,
                                site_ci_low = ci_low,
                                site_ci_high = ci_high,
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

    data <- calc_site_rates(data)

    # assemble the base plot, with axes and line for 0
    #####################################################################
    p <- ggplot() +
        geom_blank(data = data,
                   aes(x = {{rates}},
                       y = {{site_ids}})) +
        geom_vline(aes(xintercept = 0),
                   col = "gray70",
                   linetype = "dashed") +
        theme_classic()


    # assemble each piece
    #####################################################################

    # points
    points_same <- geom_point(data = data,
                              aes(x = {{rates}},
                                  y = {{site_ids}}),
                              size = 3,
                              col = "red3")


    # axis titles
    x_axis_title <- "Rate of change (mm/yr)"
    y_axis_title <- "Site name"

    # plot titles
    title_minimal <- "Elevation change (mm/yr)"
    title_se <- "Elevation change ± 1 standard error (mm/yr)"
    title_ci <- "Elevation change with 95% confidence intervals (mm/yr)"

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

    labels_site_se <- labs(title = title_se, # plot type 2: labels when SEs are included for sites
                          x = x_axis_title,
                          y = y_axis_title)

    labels_site_ci <- labs(title = title_ci, # plot type 2: labels when CIs are included for sites
                          x = x_axis_title,
                          y = y_axis_title)

    labels_site_se_comp1_se <- labs(title = title_se, # plot type 3: labels when SEs for sites and comp1 are included
                                   subtitle = subtitle_comp1_se,
                                   x = x_axis_title,
                                   y = y_axis_title)

    labels_set_ci_comp1_ci <- labs(title = title_ci, # plot type 3: labels when CIs for SETs and comp1 are included
                                   subtitle = subtitle_comp1_ci,
                                   x = x_axis_title,
                                   y = y_axis_title)

    labels_site_se_comp2_se <- labs(title = title_se,
                                   subtitle = subtitle_comp2_se,
                                   x = x_axis_title,
                                   y = y_axis_title)

    labels_site_ci_comp2_ci <- labs(title = title_ci,
                                   subtitle = subtitle_comp2_ci,
                                   x = x_axis_title,
                                   y = y_axis_title)


    # assemble geoms
    site_se_lines <- geom_errorbarh(data = data,  # plot type 2 & SE error bars for SETs
                                   aes(y = {{site_ids}},
                                       xmin = {{rates}} - {{site_se}},
                                       xmax = {{rates}} + {{site_se}}),
                                   col = "gray55",
                                   height = 0.2,
                                   size = 1)

    site_cis_lines <- geom_errorbarh(data = data, # plot type 2 & CI error bars for SETs
                                    aes(y = {{site_ids}},
                                        xmin = {{site_ci_low}},
                                        xmax = {{site_ci_high}}),
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

    comp1_se_bars <- geom_rect(aes(ymin = -Inf, # plot type 3 & SE error bars
                                   ymax = Inf,
                                   xmin = {{comp1}} - {{comp1_se}},
                                   xmax = {{comp1}} + {{comp1_se}}),
                               fill = "#08519c",
                               alpha = 0.2)

    comp1_ci_bars <- geom_rect(aes(ymin = -Inf, # plot type 3 & CI error bars
                                   ymax = Inf,
                                   xmin = {{comp1_ci_low}},
                                   xmax = {{comp1_ci_high}}),
                               fill = "#08519c",
                               alpha = 0.2)

    comp2_se_bars <- geom_rect(aes(ymin = -Inf, # plot type 4 & SE error bars
                                   ymax = Inf,
                                   xmin = {{comp2}} - {{comp2_se}},
                                   xmax = {{comp2}} + {{comp2_se}}),
                               fill = "#7bccc4",
                               alpha = 0.2)

    comp2_ci_bars <- geom_rect(aes(ymin = -Inf, # plot type 4 & CI error bars
                                   ymax = Inf,
                                   xmin = {{comp1_ci_low}},
                                   xmax = {{comp1_ci_high}}),
                               fill = "#7bccc4",
                               alpha = 0.2)


    ### Assemble in different ways
    #####################################################################


    # minimal plot: points only; no confidence intervals
    if(plot_type == 1){
        p <- p +
            points_same +
            labels_minimal
    }

    # Add in SEs or CIs for SETs

    if(plot_type == 2 & error_bar_type == "se"){
        p <- p +
            site_se_lines +
            points_same +
            labels_site_se
    }


    if(plot_type == 2 & error_bar_type == "confint"){
        p <- p +
            site_cis_lines +
            points_same +
            labels_site_ci
    }

    # Add in comp1 with SEs or CIs for sites
    if(plot_type == 3 & error_bar_type == "se"){
        p <- p +
            comp1_se_bars +
            comp1_line +
            site_se_lines +
            points_same +
            labels_site_se +
            labels_site_se_comp1_se
    }

    if(plot_type == 3 & error_bar_type == "confint"){
        p <- p +
            comp1_ci_bars +
            comp1_line +
            site_cis_lines +
            points_same +
            labels_site_ci +
            labels_site_ci_comp1_ci
    }

    # Add in comp2 with SEs or CIs for sites
    if(plot_type == 4 & error_bar_type == "se"){
        p <- p +
            comp2_se_bars +
            comp2_line +
            comp1_se_bars +
            comp1_line +
            site_se_lines +
            points_same +
            labels_site_se +
            labels_site_se_comp2_se
    }

    if(plot_type == 4 & error_bar_type == "confint"){
        p <- p +
            comp2_ci_bars +
            comp2_line +
            comp1_ci_bars +
            comp1_line +
            site_cis_lines +
            points_same +
            labels_site_ci +
            labels_site_ci_comp2_ci
    }

    return(p)

}
