test_that("returns a ggplot", {
    df <- readr::read_csv(test_path("testdata", "test_list_calc_change_cumu.csv"), col_types = c("Dcccccin"))
    p <- plot_hist_arm(df)
    expect_s3_class(p, "gg")
})

test_that("plot has expected elements", {
    df <- readr::read_csv(test_path("testdata", "test_list_calc_change_cumu.csv"), col_types = c("Dcccccin"))
    p <- plot_hist_arm(df)
    expect_identical(class(p[["layers"]][[1]][["geom"]])[1], "GeomBar")
})
