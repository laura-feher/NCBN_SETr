test_that("connects to SET db and returns a data.frame", {
    expect_type(load_set_data(), "list")
    expect_type(load_set_data(park = "ASIS"), "list")
    expect_type(load_set_data(park = "ABCD"), "list")
    expect_type(load_set_data(network_code = "NCBN"), "list")
    expect_type(load_set_data(park = "asis"), "list")
})

test_that("loads either .xls, .xlsx, or .csv when file_path is given", {
    expect_type(load_set_data(file_path = test_path("testdata", "test_list_load_set_data.csv")), "list")
    expect_type(load_set_data(file_path = test_path("testdata", "test_list_load_set_data.xls")), "list")
    expect_type(load_set_data(file_path = test_path("testdata", "test_list_load_set_data.xlsx")), "list")
})
