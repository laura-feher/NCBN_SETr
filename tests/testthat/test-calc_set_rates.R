test_that("returns a nested data frame", {
    df <- readr::read_csv(test_path("testdata", "test_list_calc_change_cumu.csv"), col_types = "Dcccccin")
    expect_type(calc_set_rates(df), "list")
})
