#' Plot station- or site-level cumulative surface elevation change or vertical
#' accretion
#'
#' Creates a faceted plot of cumulative surface elevation change and/or vertical
#' accretion at each station or site. Optionally calculates and displays linear
#' rates of change.
#'
#' @param SET_data A data frame. A data frame of raw SET data. See details below
#'   for requirements. If both SET and MH data are supplied, plots both.
#'
#' @param MH_data A data frame. A data frame of raw MH data. See details below
#'   for requirements. If both SET and MH data are supplied, plots both.
#'
#' @param level A string (optional). Level at which to calculate rates of
#'   surface elevation change and/or vertical accretion. One of:
#'   * `"station"` (default) station-level rates of surface elevation change.
#'   * `"site"` site-level rates of surface elevation change.
#'
#' @param rate_type A string (optional); Calculate linear rate of change and
#'   include in the plot? Use rate_type = `"linear"` to display station- (level
#'   = `"station"`) or site-level (level = `"site"`) rates of surface elevation
#'   change or vertical accretion in mm/yr.
#'
#' @param columns An integer. Number of columns you want in the faceted output;
#'   defaults to 4. Utilizes the `ncol` argument of [ggplot2::facet_wrap].
#'
#' @param pointsize A number. Size of points on the plot; defaults to 3.5.
#'   Utilizes the `size` argument of [ggplot2::geom_point].
#'
#' @param scales Do you want axis scales to be the same in all facets ("fixed")
#'   or to vary between facets? Defaults to using the same scale between all
#'   panels. Utilizes the `scales` parameter of [ggplot2::facet_wrap]. One of:
#'   * `"fixed"`: default; use the same axis scales in all panels.
#'   * `"free_x"`: allow x-axis scales to vary between panels.
#'   * `"free_y"`: allow y-axis scales to vary between panels.
#'   * `"free"`: allow both x- and y-axis scales to vary between panels.
#'
#' @inheritSection calc_change_cumu Data Requirements
#'
#' @inheritSection calc_change_cumu Details
#'
#' @section Note:
#'
#'   Cumulative change is calculated via the function [calc_change_cumu] and
#'   linear rates of change are calculated via the function [calc_linear_rates].
#'   See function documentation for details.
#'
#' @return A ggplot object: x-axis is date; depending on the type of data
#'   supplied, y-axis is either (a) cumulative surface elevation change and/or
#'   (b) vertical accretion. level = "station" returns a plot with one panel per
#'   station, whereas level = "site" returns a plot with one panel per site.
#'
#' @export
#'
#' @import ggplot2
#' @import dplyr
#' @importFrom ggh4x scale_listed
#'
#' @examples
#' # Station-level cumulative change
#' plot_cumu(SET_data = example_sets)
#'
#' # Combined plot of site-level SET and MH cumulative change
#' plot_cumu(SET_data = example_sets, MH_data = example_mh, level = "site")
#'
#' # Change the number of columns, point size, or scaling of x- and/or y-axis
#' plot_cumu(SET_data = example_sets, MH_data = example_mh, columns = 2, pointsize = 1, scales = "free")
#'
#' # Apply a date filter to both SET and MH, and then plot
#' df_list <- list("SET" = example_sets, "MH" = example_mh) %>%
#' map(., ~.x %>%
#'        filter(event_date_UTC < as.Date("2016-01-01")) %>%
#'        nest()) %>%
#'        list_cbind()
#'
#' # Modify the 'station_code' or 'site_name' columns to facet plots by custom groups
#' plot_cumu(SET_data = unnest(df_list$SET, cols = "data"), MH_data = unnest(df_list$MH, cols = "data"))
#'
#' example_sets_set_type <- example_sets %>%
#'     mutate(site_name = if_else(station_code == "M11-2", paste0(site_name, " shallow"), paste0(site_name," deep")))
#'
#' example_mh_set_type <- example_mh %>%
#'     mutate(site_name = if_else(station_code == "M11-2", paste0(site_name, " shallow"), paste0(site_name," deep")))
#'
#' plot_cumu(SET_data = example_sets_set_type, MH_data = example_mh_set_type, level = "site", rate_type = "linear")
#'
plot_cumu <- function(SET_data = NULL, MH_data = NULL, level = "station", rate_type = NULL, columns = 4, pointsize = 2, scales = "fixed") {

    if(!is.null(SET_data) & is.null(MH_data)) {

        # make sure SET_data is SET data
        data_type <- detect_data_type(SET_data)

        if(data_type != "SET") {
            stop(paste0("SET_data must be SET data"))
        } else {
            if(level == "station") {

                # plot
                p <- SET_data %>%
                    calc_change_cumu(., level = "station") %>%
                    ggplot(., aes(x = event_date_UTC, y = mean_cumu)) +
                    geom_line(color = 'lightsteelblue4') +
                    geom_smooth(formula = y~x, se = FALSE, method = 'lm', color = 'steelblue4', linewidth = 1) +
                    geom_errorbar(aes(x = event_date_UTC, ymin = mean_cumu - se_cumu, ymax = mean_cumu + se_cumu)) +
                    geom_point(shape = 21, fill = 'lightsteelblue1', color = 'steelblue3', size = pointsize, alpha = 0.9) +
                    facet_wrap(~station_code, ncol = columns, scales = scales) +
                    labs(title = 'Cumulative surface elevation change by station', x = 'Date', y = 'Cumulative surface elevation change (mm)') +
                    theme_classic()

                if(is.null(rate_type)) {
                  p
                } else if(rate_type == "linear") {

                    set_rates <- SET_data %>%
                        calc_linear_rates(., level = "station") %>%
                        mutate(format_rate = if_else(abs(round(rate, 2)) >= 0.01, format(round(rate, 2), nsmall = 2), as.character(signif(rate))),
                               format_rate_se = if_else(abs(round(rate_se, 2)) >= 0.01, format(round(rate_se, 2), nsmall = 2), as.character(signif(rate_se))),
                               format_r2  = format(round(rate_r2, 2), nsmall =2),
                               format_p = case_when(rate_p > 0.05 ~ "ns",
                                                    rate_p <= 0.05 & rate_p > 0.01 ~ "0.05",
                                                    rate_p <= 0.01 & rate_p > 0.001 ~ "0.01",
                                                    rate_p <= 0.001 ~ "0.001")) %>%
                        mutate(rate_label = paste0("SEC: ", format_rate, " ± ", format_rate_se, " mm/yr"),
                               r2p_label = if_else(rate_p > 0.05,
                                                  deparse(bquote(italic(r)^2~"="~.(format_r2)*plain(",")~italic(p)~"="~italic(.(format_p)))),
                                                  deparse(bquote(italic(r)^2~"="~.(format_r2)*plain(",")~italic(p)~"<"~.(format_p)))
                               ))

                    p +
                        geom_text(data = set_rates, aes(x = structure(-Inf, class = "Date"), y = Inf, label = rate_label), hjust = -0.1, vjust = 1.5) +
                        geom_text(data = set_rates, aes(x = structure(-Inf, class = "Date"), y = Inf, label = r2p_label), parse = T, hjust = -0.2, vjust = 2)
                }

            } else if(level == "site") {

                #plot
                p <- SET_data %>%
                    calc_change_cumu(., level = "site") %>%
                    ggplot(., aes(x = event_date_UTC, y = mean_cumu)) +
                    geom_line(color = 'lightsteelblue4') +
                    geom_smooth(formula = y~x, se = FALSE, method = 'lm', color = 'steelblue4', linewidth = 1) +
                    geom_errorbar(aes(x = event_date_UTC, ymin = mean_cumu - se_cumu, ymax = mean_cumu + se_cumu)) +
                    geom_point(shape = 21, fill = 'lightsteelblue1', color = 'steelblue3', size = pointsize, alpha = 0.9) +
                    facet_wrap(~site_name, ncol = columns, scales = scales) +
                    labs(title = 'Cumulative surface elevation change by site', x = 'Date', y = 'Cumulative surface elevation change (mm)') +
                    theme_classic()

                if(is.null(rate_type)) {
                    p
                } else if(rate_type == "linear") {

                    set_rates <- SET_data %>%
                        calc_linear_rates(., level = "site") %>%
                        mutate(format_rate = if_else(abs(round(rate, 2)) >= 0.01, format(round(rate, 2), nsmall = 2), as.character(signif(rate))),
                               format_rate_se = if_else(abs(round(rate_se, 2)) >= 0.01, format(round(rate_se, 2), nsmall = 2), as.character(signif(rate_se))),
                               format_r2  = format(round(rate_r2, 2), nsmall =2),
                               format_p = case_when(rate_p > 0.05 ~ "ns",
                                                    rate_p <= 0.05 & rate_p > 0.01 ~ "0.05",
                                                    rate_p <= 0.01 & rate_p > 0.001 ~ "0.01",
                                                    rate_p <= 0.001 ~ "0.001")) %>%
                        mutate(rate_label = paste0("SEC: ", format_rate, " ± ", format_rate_se, " mm/yr"),
                               r2p_label = if_else(rate_p > 0.05,
                                                   deparse(bquote(italic(r)^2~"="~.(format_r2)*plain(",")~italic(p)~"="~italic(.(format_p)))),
                                                   deparse(bquote(italic(r)^2~"="~.(format_r2)*plain(",")~italic(p)~"<"~.(format_p)))
                               ))

                    p +
                        geom_text(data = set_rates, aes(x = structure(-Inf, class = "Date"), y = Inf, label = rate_label), hjust = -0.1, vjust = 1.5) +
                        geom_text(data = set_rates, aes(x = structure(-Inf, class = "Date"), y = Inf, label = r2p_label), parse = T, hjust = -0.2, vjust = 2)
                }
            }
        }
    } else if(is.null(SET_data) & !is.null(MH_data)) {

        # make sure MH_data is MH data
        data_type <- detect_data_type(MH_data)

        if(data_type != "MH") {
            stop(paste0("MH_data must be MH data"))
        } else {
            if(level == "station") {

                # plot
                p <- MH_data %>%
                    calc_change_cumu(., level = "station") %>%
                    ggplot(., aes(x = event_date_UTC, y = mean_cumu)) +
                    geom_line(color = 'indianred4') +
                    geom_smooth(formula = y~x, se = FALSE, method = 'lm', color = 'tomato4', linewidth = 1) +
                    geom_errorbar(aes(x = event_date_UTC, ymin = mean_cumu - se_cumu, ymax = mean_cumu + se_cumu)) +
                    geom_point(shape = 21, fill = 'indianred1', col = 'tomato3', size = pointsize, alpha = 0.9) +
                    facet_wrap(~station_code, ncol = columns, scales = scales) +
                    labs(title = 'Cumulative vertical accretion by station', x = 'Date', y = 'Cumulative vertical accretion (mm)') +
                    theme_classic()

                if(is.null(rate_type)) {
                    p
                } else if(rate_type == "linear") {

                    mh_rates <- MH_data %>%
                        calc_linear_rates(., level = "station") %>%
                        mutate(format_rate = if_else(abs(round(rate, 2)) >= 0.01, format(round(rate, 2), nsmall = 2), as.character(signif(rate))),
                               format_rate_se = if_else(abs(round(rate_se, 2)) >= 0.01, format(round(rate_se, 2), nsmall = 2), as.character(signif(rate_se))),
                               format_r2  = format(round(rate_r2, 2), nsmall =2),
                               format_p = case_when(rate_p > 0.05 ~ "ns",
                                                    rate_p <= 0.05 & rate_p > 0.01 ~ "0.05",
                                                    rate_p <= 0.01 & rate_p > 0.001 ~ "0.01",
                                                    rate_p <= 0.001 ~ "0.001")) %>%
                        mutate(rate_label = paste0("VA: ", format_rate, " ± ", format_rate_se, " mm/yr"),
                               r2p_label = if_else(rate_p > 0.05,
                                                   deparse(bquote(italic(r)^2~"="~.(format_r2)*plain(",")~italic(p)~"="~italic(.(format_p)))),
                                                   deparse(bquote(italic(r)^2~"="~.(format_r2)*plain(",")~italic(p)~"<"~.(format_p)))
                               ))

                    p +
                        geom_text(data = mh_rates, aes(x = structure(-Inf, class = "Date"), y = Inf, label = rate_label), hjust = -0.1, vjust = 1.5) +
                        geom_text(data = mh_rates, aes(x = structure(-Inf, class = "Date"), y = Inf, label = r2p_label), parse = T, hjust = -0.2, vjust = 2)
                }

            } else if(level == "site") {

                # plot
                p <- MH_data %>%
                    calc_change_cumu(., level = "site") %>%
                    ggplot(., aes(x = event_date_UTC, y = mean_cumu)) +
                    geom_line(color = 'indianred4') +
                    geom_smooth(formula = y~x, se = FALSE, method = 'lm', color = 'tomato4', linewidth = 1) +
                    geom_errorbar(aes(x = event_date_UTC, ymin = mean_cumu - se_cumu, ymax = mean_cumu + se_cumu)) +
                    geom_point(shape = 21, fill = 'indianred1', col = 'tomato3', size = pointsize, alpha = 0.9) +
                    facet_wrap(~site_name, ncol = columns, scales = scales) +
                    labs(title = 'Cumulative vertical accretion by site', x = 'Date', y = 'Cumulative vertical accretion (mm)') +
                    theme_classic()

                if(is.null(rate_type)) {
                    p
                } else if(rate_type == "linear") {

                    mh_rates <- MH_data %>%
                        calc_linear_rates(., level = "site") %>%
                        mutate(format_rate = if_else(abs(round(rate, 2)) >= 0.01, format(round(rate, 2), nsmall = 2), as.character(signif(rate))),
                               format_rate_se = if_else(abs(round(rate_se, 2)) >= 0.01, format(round(rate_se, 2), nsmall = 2), as.character(signif(rate_se))),
                               format_r2  = format(round(rate_r2, 2), nsmall =2),
                               format_p = case_when(rate_p > 0.05 ~ "ns",
                                                    rate_p <= 0.05 & rate_p > 0.01 ~ "0.05",
                                                    rate_p <= 0.01 & rate_p > 0.001 ~ "0.01",
                                                    rate_p <= 0.001 ~ "0.001")) %>%
                        mutate(rate_label = paste0("VA: ", format_rate, " ± ", format_rate_se, " mm/yr"),
                               r2p_label = if_else(rate_p > 0.05,
                                                   deparse(bquote(italic(r)^2~"="~.(format_r2)*plain(",")~italic(p)~"="~italic(.(format_p)))),
                                                   deparse(bquote(italic(r)^2~"="~.(format_r2)*plain(",")~italic(p)~"<"~.(format_p)))
                               ))

                    p +
                        geom_text(data = mh_rates, aes(x = structure(-Inf, class = "Date"), y = Inf, label = rate_label), hjust = -0.1, vjust = 1.5) +
                        geom_text(data = mh_rates, aes(x = structure(-Inf, class = "Date"), y = Inf, label = r2p_label), parse = T, hjust = -0.2, vjust = 2)
                }
            }
        }
    } else if(!is.null(SET_data) & !is.null(MH_data)) {

        # make sure SET_data is SET data
        data_type_SET <- detect_data_type(SET_data)

        # make sure MH_data is MH data
        data_type_MH <- detect_data_type(MH_data)

        if(data_type_SET != "SET") {
            stop(paste0("must be a valid SET data frame"))
        } else if(data_type_MH != "MH") {
            stop(paste0("must be a valid MH data frame"))
        } else if(data_type_SET != "SET" & data_type_MH != "MH") {
            stop(paste0("SET_data must be a valid SET data frame and MH_data must be a valid MH data frame"))
        } else {

            if(level == "station") {

                # calculative cumulative change for SET and MH data
                plot_df_SET <- SET_data %>%
                    calc_change_cumu(., level = "station") %>%
                    mutate(data_type = "SET")

                plot_df_MH <- MH_data %>%
                    calc_change_cumu(., level = "station") %>%
                    select(-established_date) %>%
                    mutate(data_type = "MH")

                plot_df <- bind_rows(plot_df_SET, plot_df_MH)

                # plot data
                p <- ggplot(plot_df, aes(x = event_date_UTC, y = mean_cumu, group = data_type)) +
                    geom_line(aes(color1 = data_type)) +
                    geom_smooth(aes(color2 = data_type), formula = y~x, se = FALSE, method = 'lm', linewidth = 1) +
                    geom_errorbar(aes(x = event_date_UTC, ymin = mean_cumu - se_cumu, ymax = mean_cumu + se_cumu)) +
                    geom_point(aes(fill = data_type, color3 = data_type), shape = 21, size = pointsize, alpha = 0.9) +
                    facet_wrap(~station_code, ncol = columns, scales = scales) +
                    ggh4x::scale_listed(scalelist = list(
                        scale_colour_manual(values = c('lightsteelblue4', 'indianred4'), aesthetics = "color1", breaks = c("SET", "MH")),
                        scale_colour_manual(values = c('steelblue4', 'tomato4'), aesthetics = "color2", breaks = c("SET", "MH")),
                        scale_colour_manual(values = c('steelblue3', 'tomato3'), aesthetics = "color3", breaks = c("SET", "MH")),
                        scale_fill_manual(values = c('lightsteelblue1', 'indianred1'), breaks = c("SET", "MH"))
                    ), replaces = c("color", "color", "color", "fill")) +
                    labs(title = 'Cumulative surface elevation change and vertical accretion by station', x = 'Date', y = 'Cumulative surface elevation change and vertical accretion (mm)') +
                    theme_classic() +
                    theme(
                        legend.title = element_blank()
                    )

                if(is.null(rate_type)) {
                    p
                } else if(rate_type == "linear") {

                    set_rates <- SET_data %>%
                        calc_linear_rates(., level = "station") %>%
                        mutate(format_rate = if_else(abs(round(rate, 2)) >= 0.01, format(round(rate, 2), nsmall = 2), as.character(signif(rate))),
                               format_rate_se = if_else(abs(round(rate_se, 2)) >= 0.01, format(round(rate_se, 2), nsmall = 2), as.character(signif(rate_se))),
                               format_r2  = format(round(rate_r2, 2), nsmall =2),
                               format_p = case_when(rate_p > 0.05 ~ "ns",
                                                    rate_p <= 0.05 & rate_p > 0.01 ~ "0.05",
                                                    rate_p <= 0.01 & rate_p > 0.001 ~ "0.01",
                                                    rate_p <= 0.001 ~ "0.001")) %>%
                        mutate(rate_label = paste0("SEC: ", format_rate, " ± ", format_rate_se, " mm/yr"),
                               r2p_label = if_else(rate_p > 0.05,
                                                   deparse(bquote(italic(r)^2~"="~.(format_r2)*plain(",")~italic(p)~"="~italic(.(format_p)))),
                                                   deparse(bquote(italic(r)^2~"="~.(format_r2)*plain(",")~italic(p)~"<"~.(format_p)))
                               )) %>%
                        mutate(data_type = "SET")

                    mh_rates <- MH_data %>%
                        calc_linear_rates(., level = "station") %>%
                        mutate(format_rate = if_else(abs(round(rate, 2)) >= 0.01, format(round(rate, 2), nsmall = 2), as.character(signif(rate))),
                               format_rate_se = if_else(abs(round(rate_se, 2)) >= 0.01, format(round(rate_se, 2), nsmall = 2), as.character(signif(rate_se))),
                               format_r2  = format(round(rate_r2, 2), nsmall =2),
                               format_p = case_when(rate_p > 0.05 ~ "ns",
                                                    rate_p <= 0.05 & rate_p > 0.01 ~ "0.05",
                                                    rate_p <= 0.01 & rate_p > 0.001 ~ "0.01",
                                                    rate_p <= 0.001 ~ "0.001")) %>%
                        mutate(rate_label = paste0("VA: ", format_rate, " ± ", format_rate_se, " mm/yr"),
                               r2p_label = if_else(rate_p > 0.05,
                                                   deparse(bquote(italic(r)^2~"="~.(format_r2)*plain(",")~italic(p)~"="~italic(.(format_p)))),
                                                   deparse(bquote(italic(r)^2~"="~.(format_r2)*plain(",")~italic(p)~"<"~.(format_p)))
                               )) %>%
                        mutate(data_type = "MH")

                    p +
                        geom_text(data = set_rates, aes(x = structure(-Inf, class = "Date"), y = Inf, label = rate_label), hjust = -0.1, vjust = 1.5) +
                        geom_text(data = set_rates, aes(x = structure(-Inf, class = "Date"), y = Inf, label = r2p_label), parse = T, hjust = -0.2, vjust = 2.1) +
                        geom_text(data = mh_rates, aes(x = structure(-Inf, class = "Date"), y = Inf, label = rate_label), hjust = -0.1, vjust = 6) +
                        geom_text(data = mh_rates, aes(x = structure(-Inf, class = "Date"), y = Inf, label = r2p_label), parse = T, hjust = -0.15, vjust = 4.9)
                }

            } else if(level == "site") {

                # calculative cumulative change for SET and MH data
                plot_df_SET <- SET_data %>%
                    calc_change_cumu(., level = "site") %>%
                    mutate(data_type = "SET")

                plot_df_MH <- MH_data %>%
                    calc_change_cumu(., level = "site") %>%
                    select(-established_date) %>%
                    mutate(data_type = "MH")

                plot_df <- bind_rows(plot_df_SET, plot_df_MH)

                # plot data
                p <- ggplot(plot_df, aes(x = event_date_UTC, y = mean_cumu, group = data_type)) +
                    geom_line(aes(color1 = data_type)) +
                    geom_smooth(aes(color2 = data_type), formula = y~x, se = FALSE, method = 'lm', linewidth = 1) +
                    geom_errorbar(aes(x = event_date_UTC, ymin = mean_cumu - se_cumu, ymax = mean_cumu + se_cumu)) +
                    geom_point(aes(fill = data_type, color3 = data_type), shape = 21, size = pointsize, alpha = 0.9) +
                    facet_wrap(~site_name, ncol = columns, scales = scales) +
                    ggh4x::scale_listed(scalelist = list(
                        scale_colour_manual(values = c('lightsteelblue4', 'indianred4'), aesthetics = "color1", breaks = c("SET", "MH")),
                        scale_colour_manual(values = c('steelblue4', 'tomato4'), aesthetics = "color2", breaks = c("SET", "MH")),
                        scale_colour_manual(values = c('steelblue3', 'tomato3'), aesthetics = "color3", breaks = c("SET", "MH")),
                        scale_fill_manual(values = c('lightsteelblue1', 'indianred1'), breaks = c("SET", "MH"))
                    ), replaces = c("color", "color", "color", "fill")) +
                    labs(title = 'Cumulative surface elevation change and vertical accretion by site', x = 'Date', y = 'Cumulative surface elevation change and vertical accretion (mm)') +
                    theme_classic() +
                    theme(
                        legend.title = element_blank()
                    )

                if(is.null(rate_type)) {
                    p
                } else if(rate_type == "linear") {

                    set_rates <- SET_data %>%
                        calc_linear_rates(., level = "site") %>%
                        mutate(format_rate = if_else(abs(round(rate, 2)) >= 0.01, format(round(rate, 2), nsmall = 2), as.character(signif(rate))),
                               format_rate_se = if_else(abs(round(rate_se, 2)) >= 0.01, format(round(rate_se, 2), nsmall = 2), as.character(signif(rate_se))),
                               format_r2  = format(round(rate_r2, 2), nsmall =2),
                               format_p = case_when(rate_p > 0.05 ~ "ns",
                                                    rate_p <= 0.05 & rate_p > 0.01 ~ "0.05",
                                                    rate_p <= 0.01 & rate_p > 0.001 ~ "0.01",
                                                    rate_p <= 0.001 ~ "0.001")) %>%
                        mutate(rate_label = paste0("SEC: ", format_rate, " ± ", format_rate_se, " mm/yr"),
                               r2p_label = if_else(rate_p > 0.05,
                                                   deparse(bquote(italic(r)^2~"="~.(format_r2)*plain(",")~italic(p)~"="~italic(.(format_p)))),
                                                   deparse(bquote(italic(r)^2~"="~.(format_r2)*plain(",")~italic(p)~"<"~.(format_p)))
                               )) %>%
                        mutate(data_type = "SET")

                    mh_rates <- MH_data %>%
                        calc_linear_rates(., level = "site") %>%
                        mutate(format_rate = if_else(abs(round(rate, 2)) >= 0.01, format(round(rate, 2), nsmall = 2), as.character(signif(rate))),
                               format_rate_se = if_else(abs(round(rate_se, 2)) >= 0.01, format(round(rate_se, 2), nsmall = 2), as.character(signif(rate_se))),
                               format_r2  = format(round(rate_r2, 2), nsmall =2),
                               format_p = case_when(rate_p > 0.05 ~ "ns",
                                                    rate_p <= 0.05 & rate_p > 0.01 ~ "0.05",
                                                    rate_p <= 0.01 & rate_p > 0.001 ~ "0.01",
                                                    rate_p <= 0.001 ~ "0.001")) %>%
                        mutate(rate_label = paste0("VA: ", format_rate, " ± ", format_rate_se, " mm/yr"),
                               r2p_label = if_else(rate_p > 0.05,
                                                   deparse(bquote(italic(r)^2~"="~.(format_r2)*plain(",")~italic(p)~"="~italic(.(format_p)))),
                                                   deparse(bquote(italic(r)^2~"="~.(format_r2)*plain(",")~italic(p)~"<"~.(format_p)))
                               )) %>%
                        mutate(data_type = "MH")

                    p +
                        geom_text(data = set_rates, aes(x = structure(-Inf, class = "Date"), y = Inf, label = rate_label), hjust = -0.1, vjust = 1.5) +
                        geom_text(data = set_rates, aes(x = structure(-Inf, class = "Date"), y = Inf, label = r2p_label), parse = T, hjust = -0.2, vjust = 2.1) +
                        geom_text(data = mh_rates, aes(x = structure(-Inf, class = "Date"), y = Inf, label = rate_label), hjust = -0.1, vjust = 6) +
                        geom_text(data = mh_rates, aes(x = structure(-Inf, class = "Date"), y = Inf, label = r2p_label), parse = T, hjust = -0.15, vjust = 4.9)
                }
            }
        }
    }
}
