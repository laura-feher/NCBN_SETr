test_that("returns a data frame", {
    df <- readr::read_csv(test_path("testdata", "test_list_calc_change_cumu_set.csv"), col_types = "Dcccccin")
    expect_type(calc_linear_rates(df), "list")
})

test_that("returns a data frame", {
    df <- readr::read_csv(test_path("testdata", "test_list_calc_change_cumu_mh.csv"), col_types = "ccccccDcidD")
    expect_type(calc_linear_rates(df), "list")
})
