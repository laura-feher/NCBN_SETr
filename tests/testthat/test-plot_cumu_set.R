test_that("returns a ggplot", {
    df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDccid"))
    p <- plot_cumu_set(df, data_level = "arm", station = "M11-1")
    expect_s3_class(p, "gg")
})

test_that("returns a ggplot", {
    df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDccid"))
    p <- plot_cumu_set(df, data_level = "station", site = "Marsh 11")
    expect_s3_class(p, "gg")
})

test_that("plot has expected elements", {
    df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDccid"))
    p <- plot_cumu_set(df, data_level = "station", station = "M11-1")
    expect_identical(class(p[["layers"]][[1]][["geom"]])[1], "GeomLine")
    expect_identical(class(p[["layers"]][[2]][["geom"]])[1], "GeomSmooth")
    expect_identical(class(p[["layers"]][[3]][["geom"]])[1], "GeomPoint")
    expect_identical(class(p[["layers"]][[4]][["geom"]])[1], "GeomText")
})
