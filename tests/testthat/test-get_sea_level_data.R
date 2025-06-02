test_that("returns a list of 2 correctly named objects", suppressWarnings({
    expect_true(is.list(get_sea_level_data(park = "ASIS")))
    expect_length(get_sea_level_data(park = "ASIS"), n = 2)
    expect_named(get_sea_level_data(park = "ASIS"), expected = c("slr_data", "slr_rate"), ignore.order = T)
}))
