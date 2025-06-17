test_that("returns a list of 2 correctly named objects", suppressWarnings({
    expect_true(is.list(scale_slr_line(rate = 3.13, int = 9.80, first_date = "2019-07-29")))
    expect_length(scale_slr_line(rate = 3.13, int = 9.80, first_date = "2019-07-29"), n = 2)
    expect_named(scale_slr_line(rate = 3.13, int = 9.80, first_date = "2019-07-29"), expected = c("scaled_slope", "scaled_int"), ignore.order = T)
}))
