test_that("returns a list of 2 correctly named objects", suppressWarnings({
    expect_true(is.list(get_sea_level_data(park_code = "ASIS")))
    expect_length(get_sea_level_data(park_code = "ASIS"), n = 2)
    expect_named(get_sea_level_data(park_code = "ASIS"), expected = c("data", "model_summ"), ignore.order = T)
}))
