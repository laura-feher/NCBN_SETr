test_that("returns a ggplot of raw pin data", {
    df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDccid"))
    p <- plot_raw_data(df, data_level = "pin", station = "M11-1")
    expect_s3_class(p, "gg")
})

test_that("returns a ggplot of raw arm data", {
    df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDccid"))
    p <- plot_raw_data(df, data_level = "arm", station = "M11-1")
    expect_s3_class(p, "gg")
})

test_that("returns a ggplot of raw MH data", {
    df <- readr::read_csv(test_path("testdata", "test_raw_mh_data.csv"), col_types = c("ccccccDcidD"))
    p <- plot_raw_data(df, data_level = "mh", station = "M11-1")
    expect_s3_class(p, "gg")
})

test_that("plot has expected elements", {
    df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDccid"))
    p <- plot_raw_data(df, data_level = "pin", station = "M11-1")
    expect_identical(class(p[["layers"]][[1]][["geom"]])[1], "GeomPoint")
    expect_identical(class(p[["layers"]][[2]][["geom"]])[1], "GeomLine")
})

test_that("gives an error if data level isn't specified", {
    df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDccid"))
    expect_error(plot_raw_data(df))
})
