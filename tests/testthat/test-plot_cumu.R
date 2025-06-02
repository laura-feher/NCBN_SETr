test_that("returns a ggplot", {
    df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDcciddd"))
    p <- plot_cumu(df)
    expect_s3_class(p, "gg")
})

test_that("returns a ggplot", {
    df <- readr::read_csv(test_path("testdata", "test_raw_MH_data.csv"), col_types = c("ccccccDcidD"))
    p <- plot_cumu(MH_data = df)
    expect_s3_class(p, "gg")
})

test_that("returns a ggplot", {
    set_df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDcciddd"))
    mh_df <- readr::read_csv(test_path("testdata", "test_raw_MH_data.csv"), col_types = c("ccccccDcidD"))
    p <- plot_cumu(SET_data = set_df, MH_data = mh_df, level = "site")
    expect_s3_class(p, "gg")
})

test_that("returns a ggplot", {
    set_df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDcciddd"))
    mh_df <- readr::read_csv(test_path("testdata", "test_raw_MH_data.csv"), col_types = c("ccccccDcidD"))
    p <- plot_cumu(SET_data = set_df, MH_data = mh_df, level = "site", rate_type = "linear")
    expect_s3_class(p, "gg")
})

test_that("plot has expected elements", {
    df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDcciddd"))
    p <- plot_cumu(df, level = "site", rate_type = "linear")
    expect_identical(class(p[["layers"]][[1]][["geom"]])[1], "GeomLine")
    expect_identical(class(p[["layers"]][[2]][["geom"]])[1], "GeomSmooth")
    expect_identical(class(p[["layers"]][[3]][["geom"]])[1], "GeomErrorbar")
    expect_identical(class(p[["layers"]][[4]][["geom"]])[1], "GeomPoint")
    expect_identical(class(p[["layers"]][[5]][["geom"]])[1], "GeomText")
    expect_identical(class(p[["layers"]][[6]][["geom"]])[1], "GeomText")
})

test_that("plot has expected elements", {
    set_df <- readr::read_csv(test_path("testdata", "test_raw_SET_data.csv"), col_types = c("ccccccDcciddd"))
    mh_df <- readr::read_csv(test_path("testdata", "test_raw_MH_data.csv"), col_types = c("ccccccDcidD"))
    p <- plot_cumu(SET_data = set_df, MH_data = mh_df, level = "site", rate_type = "linear")
    expect_identical(class(p[["layers"]][[1]][["geom"]])[1], "Newcolour1GeomLine")
    expect_identical(class(p[["layers"]][[2]][["geom"]])[1], "Newcolour2GeomSmooth")
    expect_identical(class(p[["layers"]][[3]][["geom"]])[1], "GeomErrorbar")
    expect_identical(class(p[["layers"]][[4]][["geom"]])[1], "NewfillNewcolour3GeomPoint")
    expect_identical(class(p[["layers"]][[5]][["geom"]])[1], "GeomText")
    expect_identical(class(p[["layers"]][[6]][["geom"]])[1], "GeomText")
    expect_identical(class(p[["layers"]][[7]][["geom"]])[1], "GeomText")
    expect_identical(class(p[["layers"]][[8]][["geom"]])[1], "GeomText")
})

test_that("throws error about mismatched grouping", {
    set_df <- readr::read_rds(test_path("testdata", "test_grouping_calc_change_cumu.rds"))
    mh_df <- readr::read_csv(test_path("testdata", "test_raw_MH_data.csv"), col_types = c("ccccccDcidD"))
    expect_error(plot_cumu(SET_data = set_df, MH_data = mh_df), "SET and MH data must have the same grouping in order to plot them together.")
})
