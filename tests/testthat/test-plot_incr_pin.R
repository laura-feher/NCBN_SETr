test_that("returns a ggplot", {
    df <- readr::read_csv(test_path("testdata", "test_list_calc_change_cumu.csv"), col_types = c("Dcccccin"))
    p <- plot_incr_pin(df, set = "M11-1")
    expect_s3_class(p, "gg")
})

test_that("plot has expected elements", {
    df <- readr::read_csv(test_path("testdata", "test_list_calc_change_cumu.csv"), col_types = c("Dcccccin"))
    p <- plot_incr_pin(df, set = "M11-1")
    expect_identical(class(p[["layers"]][[1]][["geom"]])[1], "GeomPoint")
    expect_identical(class(p[["layers"]][[2]][["geom"]])[1], "GeomHline")
    expect_identical(class(p[["layers"]][[3]][["geom"]])[1], "GeomHline")
})

test_that("gives an error if SET isn't specified", {
    df <- readr::read_csv(test_path("testdata", "test_list_calc_change_cumu.csv"), col_types = c("Dcccccin"))
    expect_error(plot_incr_pin(df))
})
