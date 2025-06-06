test_that("loads either .xls, .xlsx, or .csv when file_path is given", {
    expect_type(load_set_data(file_path = test_path("testdata", "test_list_load_set_data.csv")), "list")
    expect_type(load_set_data(file_path = test_path("testdata", "test_list_load_set_data.xls")), "list")
    expect_type(load_set_data(file_path = test_path("testdata", "test_list_load_set_data.xlsx")), "list")
})

test_that("gets data from the most recent data package if neither file_path or db_server are given", {
    expect_type(load_set_data(park = "COLO"), "list")
})
