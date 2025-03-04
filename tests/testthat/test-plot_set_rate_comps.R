test_that("returns a ggplot", {
    df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDccid"))
    p <- plot_set_rate_comps(df)
    expect_s3_class(p, "gg")
})

test_that("returns a ggplot", {
    df <- readr::read_rds(test_path("testdata", "test_plot_set_rate_comps_rates_df.rda"))
    p <- plot_set_rate_comps(df, calc_rates = FALSE)
    expect_s3_class(p, "gg")
})

test_that("returns an error", {
    df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDccid"))
    expect_error(plot_set_rate_comps(df, plot_type = 3), "please provide a value for comp1 and comp1_se")
})

test_that("returns an error", {
    df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDccid"))
    expect_error(plot_set_rate_comps(df, plot_type = 4, error_bar_type = "confint"), "please provide a value for comp1, comp1_ci_low, comp1_ci_high,\n\n             comp2, comp2_ci_low, and comp2_ci_high")
})

test_that("returns an error", {
    df <- readr::read_rds(test_path("testdata", "test_plot_set_rate_comps_rates_df.rda"))
    expect_error(plot_set_rate_comps(df, calc_rates = FALSE, station_ids = "f"), "column names 'f', 'station_rate', and/or 'station_se_rate' were not found in 'df'")
})

test_that("returns an error", {
    df <- readr::read_rds(test_path("testdata", "test_plot_set_rate_comps_rates_df.rda"))
    expect_error(plot_set_rate_comps(df, calc_rates = FALSE, error_bar_type = "confint", station_ci_low = "f"),
                 "column names 'station_code', 'station_rate', 'f', and/or 'station_ci_high' were not found in 'df'")
})

test_that("plot has expected elements", {
    df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDccid"))
    p <- plot_set_rate_comps(df, plot_type = 1)
    expect_identical(class(p[["layers"]][[1]][["geom"]])[1], "GeomVline")
    expect_identical(class(p[["layers"]][[2]][["geom"]])[1], "GeomPoint")
})

test_that("plot has expected elements", {
    df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDccid"))
    p <- plot_set_rate_comps(df, plot_type = 2)
    expect_identical(class(p[["layers"]][[1]][["geom"]])[1], "GeomVline")
    expect_identical(class(p[["layers"]][[2]][["geom"]])[1], "GeomErrorbarh")
    expect_identical(class(p[["layers"]][[3]][["geom"]])[1], "GeomPoint")

})

test_that("plot has expected elements", {
    df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDccid"))
    p <- plot_set_rate_comps(df, plot_type = 3, comp1 = 2.27, comp1_se = 1.00)
    expect_identical(class(p[["layers"]][[1]][["geom"]])[1], "GeomVline")
    expect_identical(class(p[["layers"]][[2]][["geom"]])[1], "GeomRect")
    expect_identical(class(p[["layers"]][[3]][["geom"]])[1], "GeomVline")
    expect_identical(class(p[["layers"]][[4]][["geom"]])[1], "GeomErrorbarh")
    expect_identical(class(p[["layers"]][[5]][["geom"]])[1], "GeomPoint")

})

test_that("plot has expected elements", {
    df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDccid"))
    p <- plot_set_rate_comps(df, plot_type = 3, error_bar_type = "confint", comp1 = 2.27, comp1_ci_low = 1.27, comp1_ci_high = 3.37)
    expect_identical(class(p[["layers"]][[1]][["geom"]])[1], "GeomVline")
    expect_identical(class(p[["layers"]][[2]][["geom"]])[1], "GeomRect")
    expect_identical(class(p[["layers"]][[3]][["geom"]])[1], "GeomVline")
    expect_identical(class(p[["layers"]][[4]][["geom"]])[1], "GeomErrorbarh")
    expect_identical(class(p[["layers"]][[5]][["geom"]])[1], "GeomPoint")

})

test_that("plot has expected elements", {
    df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDccid"))
    p <- plot_set_rate_comps(df, plot_type = 4, comp1 = 2.27, comp1_se = 1.00, comp2 = 5.67, comp2_se = 2.00)
    expect_identical(class(p[["layers"]][[1]][["geom"]])[1], "GeomVline")
    expect_identical(class(p[["layers"]][[2]][["geom"]])[1], "GeomRect")
    expect_identical(class(p[["layers"]][[3]][["geom"]])[1], "GeomVline")
    expect_identical(class(p[["layers"]][[4]][["geom"]])[1], "GeomRect")
    expect_identical(class(p[["layers"]][[5]][["geom"]])[1], "GeomVline")
    expect_identical(class(p[["layers"]][[6]][["geom"]])[1], "GeomErrorbarh")
    expect_identical(class(p[["layers"]][[7]][["geom"]])[1], "GeomPoint")

})

test_that("plot has expected elements", {
    df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDccid"))
    p <- plot_set_rate_comps(df, plot_type = 4, error_bar_type = "confint", comp1 = 2.27, comp1_ci_low = 1.27, comp1_ci_high = 3.37, comp2 = 5.67, comp2_ci_low = 5.37, comp2_ci_high = 5.97)
    expect_identical(class(p[["layers"]][[1]][["geom"]])[1], "GeomVline")
    expect_identical(class(p[["layers"]][[2]][["geom"]])[1], "GeomRect")
    expect_identical(class(p[["layers"]][[3]][["geom"]])[1], "GeomVline")
    expect_identical(class(p[["layers"]][[4]][["geom"]])[1], "GeomRect")
    expect_identical(class(p[["layers"]][[5]][["geom"]])[1], "GeomVline")
    expect_identical(class(p[["layers"]][[6]][["geom"]])[1], "GeomErrorbarh")
    expect_identical(class(p[["layers"]][[7]][["geom"]])[1], "GeomPoint")

})
