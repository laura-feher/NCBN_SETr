test_that("returns a ggplot", {
    df <- read.csv(test_path("testdata", "test_list_calc_change_cumu.csv"))
    p <- plot_cumu_arm(df)
    expect_s3_class(p, "gg")
})

test_that("plot has expected elements", {
    df <- read.csv(test_path("testdata", "test_list_calc_change_cumu.csv"))
    p <- plot_cumu_arm(df)
    expect_identical(class(p[["layers"]][[1]][["geom"]])[1], "GeomPoint")
    expect_identical(class(p[["layers"]][[2]][["geom"]])[1], "GeomLine")
})
