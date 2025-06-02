test_that("returns a ggplot", {
    df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDcciddd"))
    p <- plot_rate_comps(df)
    expect_s3_class(p, "gg")
})

test_that("returns a ggplot", {
    df <- readr::read_rds(test_path("testdata", "test_plot_rate_comps_set_station_rates.rds"))
    p <- plot_rate_comps(rates = df)
    expect_s3_class(p, "gg")
})

test_that("returns a ggplot", {
    df <- readr::read_rds(test_path("testdata", "test_plot_rate_comps_set_site_rates.rds"))
    p <- plot_rate_comps(rates = df, level = "site")
    expect_s3_class(p, "gg")
})

test_that("returns a ggplot", {
    df <- readr::read_rds(test_path("testdata", "test_plot_rate_comps_set_site_rates_chr_col.rds"))
    p <- plot_rate_comps(rates = df, level = "site")
    expect_s3_class(p, "gg")
})

test_that("plot_rate_comps maintains proper pre-defined grouping throughout calculations", {
    df <- readRDS(test_path("testdata", "test_grouping_calc_change_cumu.rds"))
    expect_equal(length(plot_rate_comps(data = df, level = "site")[["data"]]$grouping), 6)
})

test_that("plot has expected elements", {
    df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDcciddd"))
    p <- plot_rate_comps(df)
    expect_identical(class(p[["layers"]][[1]][["geom"]])[1], "GeomVline")
    expect_identical(class(p[["layers"]][[2]][["geom"]])[1], "GeomErrorbar")
    expect_identical(class(p[["layers"]][[3]][["geom"]])[1], "GeomPoint")
})

test_that("plot has expected elements", {
    df <- readr::read_csv(test_path("testdata", "test_raw_MH_data.csv"), col_types = c("ccccccDcidD"))
    p <- plot_rate_comps(df)
    expect_identical(class(p[["layers"]][[1]][["geom"]])[1], "GeomVline")
    expect_identical(class(p[["layers"]][[2]][["geom"]])[1], "GeomErrorbar")
    expect_identical(class(p[["layers"]][[3]][["geom"]])[1], "GeomPoint")
})

test_that("plot has expected elements", {
    df <- readr::read_rds(test_path("testdata", "test_plot_rate_comps_set_station_rates.rds"))
    p <- plot_rate_comps(rates = df, level = "station")
    expect_identical(class(p[["layers"]][[1]][["geom"]])[1], "GeomVline")
    expect_identical(class(p[["layers"]][[2]][["geom"]])[1], "GeomErrorbar")
    expect_identical(class(p[["layers"]][[3]][["geom"]])[1], "GeomPoint")

})

test_that("plot has expected elements", {
    df <- readr::read_rds(test_path("testdata", "test_plot_rate_comps_set_site_rates_chr_col.rds"))
    p <- plot_rate_comps(rates = df, level = "site")
    expect_identical(class(p[["layers"]][[1]][["geom"]])[1], "GeomVline")
    expect_identical(class(p[["layers"]][[2]][["geom"]])[1], "GeomErrorbar")
    expect_identical(class(p[["layers"]][[3]][["geom"]])[1], "GeomPoint")

})
