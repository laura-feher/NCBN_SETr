test_that("message about missing columns shows", {
    df <- read.csv(test_path("testdata", "test_message_calc_change_cumu.csv"))
    expect_error(calc_change_cumu(df), "Your data frame must have the following columns, with these names, but is missing at least one: event_date_UTC, network_code, park_code, site_name, station_code, SET_direction, pin_position, pin_height_mm, SET_offset_mm, pin_length_mm")
})

test_that("calc_change_cumu uses only pin_height_mm to calculate cumulative change if SET_offset_mm or pin_length_mm are blank", {
    df <- read.csv(test_path("testdata", "test_blank_calc_change_cumu.csv"))
    expect_true(is.numeric(calc_change_cumu(df)$mean_cumu))
    expect_true(!is.null(calc_change_cumu(df)$mean_cumu))
})

test_that("calc_change_cumu maintains proper pre-defined grouping throughout calculations", {
    df <- readRDS(test_path("testdata", "test_grouping_calc_change_cumu.rds"))
    expect_in(calc_change_cumu(df) %>%
                  attr(., "groups") %>%
                  select(-c(network_code, park_code, site_name, station_code)) %>%
                  names(),
              c("SET_group", ".rows"))
})
