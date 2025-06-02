test_that("connects to SET db and returns a data.frame", {
    expect_type(load_mh_data(), "list")
    expect_type(load_mh_data(park = "ASIS"), "list")
    expect_type(load_mh_data(park = "ABCD"), "list")
    expect_type(load_mh_data(network_code = "NCBN"), "list")
    expect_type(load_mh_data(park = "asis"), "list")
})

test_that("loads either .xls, .xlsx, or .csv when file_path is given", {
    expect_type(load_mh_data(file_path = test_path("testdata", "test_list_load_mh_data.csv")), "list")
    expect_type(load_mh_data(file_path = test_path("testdata", "test_list_load_mh_data.xls")), "list")
    expect_type(load_mh_data(file_path = test_path("testdata", "test_list_load_mh_data.xlsx")), "list")
})
