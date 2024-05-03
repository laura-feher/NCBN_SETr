test_that("connects to SET db and returns a data.frame", {
    expect_type(load_set_data(), "list")
    expect_type(load_set_data(park_code = "ASIS"), "list")
    expect_type(load_set_data(park_code = "ABCD"), "list")
    expect_type(load_set_data(network_code = "NCBN"), "list")
    expect_type(load_set_data(park_code = "asis"), "list")
})

test_that("loads either .xls, .xlsx, or .csv when file_path is given", {
    expect_type(load_set_data(file_path = "./tests/testthat/testdata/test_list_calc_change_cumu.csv"), "list")
    expect_type(load_set_data(file_path = "./tests/testthat/testdata/test_list_calc_change_cumu.xls"), "list")
    expect_type(load_set_data(file_path = "./tests/testthat/testdata/test_list_calc_change_cumu.xlsx"), "list")
})
