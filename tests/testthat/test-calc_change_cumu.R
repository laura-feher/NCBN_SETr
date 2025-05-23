test_that("message about missing columns shows", {
    df <- read.csv(test_path("testdata", "test_message_calc_change_cumu.csv"))
    expect_error(calc_change_cumu(df), "Your data frame must have the following columns, with these names, but is missing at least one: event_date_UTC, network_code, park_code, site_name, station_code, SET_direction, pin_position, pin_height_mm")
})

test_that("returns a list of 3 correctly named objects", {
    df <- read.csv(test_path("testdata", "test_list_calc_change_cumu_set.csv"))
    expect_true(is.list(calc_change_cumu(df)))
    expect_length(calc_change_cumu(df), n = 3)
    expect_named(calc_change_cumu(df), expected = c("pin", "arm", "station"), ignore.order = T)
})
