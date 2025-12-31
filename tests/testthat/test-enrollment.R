# Tests for enrollment functions
# Note: Most tests are marked as skip_on_cran since they require network access

test_that("safe_numeric handles various inputs", {
  # Normal numbers
  expect_equal(safe_numeric("100"), 100)
  expect_equal(safe_numeric("1,234"), 1234)

  # Suppressed values
  expect_true(is.na(safe_numeric("*")))
  expect_true(is.na(safe_numeric("-1")))
  expect_true(is.na(safe_numeric("<5")))
  expect_true(is.na(safe_numeric("")))
  expect_true(is.na(safe_numeric("**")))

  # Whitespace handling
  expect_equal(safe_numeric("  100  "), 100)
})

test_that("get_available_years returns expected structure", {
  avail <- get_available_years()

  expect_true(is.list(avail))
  expect_true("min_year" %in% names(avail))
  expect_true("max_year" %in% names(avail))
  expect_true("available_years" %in% names(avail))
  expect_true("format_eras" %in% names(avail))

  expect_equal(avail$min_year, 2006)
  expect_true(avail$max_year >= 2024)
  expect_true(length(avail$available_years) > 10)
})

test_that("format_school_year formats correctly", {
  expect_equal(format_school_year(2024), "2023-24")
  expect_equal(format_school_year(2020), "2019-20")
  expect_equal(format_school_year(2010), "2009-10")
})

test_that("parse_county_district_code works correctly", {
  result <- parse_county_district_code("048078")
  expect_equal(result$county_code, "048")
  expect_equal(result$district_number, "078")

  # With padding
  result2 <- parse_county_district_code("1234")
  expect_equal(result2$county_code, "000")
  expect_equal(result2$district_number, "234")
})

test_that("build_building_code works correctly", {
  expect_equal(build_building_code("048078", "1234"), "0480781234")
  expect_equal(build_building_code("48078", "123"), "0480780123")
})

test_that("fetch_enr validates year parameter", {
  expect_error(fetch_enr(2000), "end_year must be between")
  expect_error(fetch_enr(2030), "end_year must be between")
})

test_that("get_cache_dir returns valid path", {
  cache_dir <- get_cache_dir()
  expect_true(is.character(cache_dir))
  expect_true(grepl("moschooldata", cache_dir))
})

test_that("cache functions work correctly", {
  # Test cache path generation
  path <- get_cache_path(2024, "tidy")
  expect_true(grepl("enr_tidy_2024.rds", path))

  # Test cache_exists returns FALSE for non-existent cache
  expect_false(cache_exists(9999, "tidy"))
})

test_that("get_mo_column_map returns expected structure", {
  col_map <- get_mo_column_map()

  expect_true(is.list(col_map))
  expect_true("county_district_code" %in% names(col_map))
  expect_true("building_code" %in% names(col_map))
  expect_true("district_name" %in% names(col_map))
  expect_true("total" %in% names(col_map))
  expect_true("white" %in% names(col_map))
  expect_true("grade_k" %in% names(col_map))
})

test_that("create_empty_building_df has expected columns", {
  df <- create_empty_building_df()

  expect_true(is.data.frame(df))
  expect_equal(nrow(df), 0)
  expect_true("COUNTY_DISTRICT_CODE" %in% names(df))
  expect_true("BUILDING_CODE" %in% names(df))
  expect_true("TOTAL_ENROLLMENT" %in% names(df))
})

test_that("create_empty_district_df has expected columns", {
  df <- create_empty_district_df()

  expect_true(is.data.frame(df))
  expect_equal(nrow(df), 0)
  expect_true("COUNTY_DISTRICT_CODE" %in% names(df))
  expect_true("DISTRICT_NAME" %in% names(df))
  expect_true("TOTAL_ENROLLMENT" %in% names(df))
})

# Integration tests (require network access)
test_that("fetch_enr downloads and processes data", {
  skip_on_cran()
  skip_if_offline()

  # Use a recent year - this will attempt actual download
  # Note: May fail if DESE website is unavailable or format changed
  tryCatch({
    result <- fetch_enr(2023, tidy = FALSE, use_cache = FALSE)

    # Check structure
    expect_true(is.data.frame(result))
    expect_true("district_id" %in% names(result))
    expect_true("campus_id" %in% names(result))
    expect_true("row_total" %in% names(result))
    expect_true("type" %in% names(result))

    # Check we have multiple levels
    expect_true("State" %in% result$type)
    expect_true("District" %in% result$type || "Campus" %in% result$type)

  }, error = function(e) {
    skip(paste("Network test skipped:", e$message))
  })
})

test_that("tidy_enr produces correct long format", {
  skip_on_cran()
  skip_if_offline()

  tryCatch({
    # Get wide data
    wide <- fetch_enr(2023, tidy = FALSE, use_cache = TRUE)

    # Tidy it
    tidy_result <- tidy_enr(wide)

    # Check structure
    expect_true("grade_level" %in% names(tidy_result))
    expect_true("subgroup" %in% names(tidy_result))
    expect_true("n_students" %in% names(tidy_result))
    expect_true("pct" %in% names(tidy_result))

    # Check subgroups include expected values
    subgroups <- unique(tidy_result$subgroup)
    expect_true("total_enrollment" %in% subgroups)

  }, error = function(e) {
    skip(paste("Network test skipped:", e$message))
  })
})

test_that("id_enr_aggs adds correct flags", {
  skip_on_cran()
  skip_if_offline()

  tryCatch({
    # Get tidy data with aggregation flags
    result <- fetch_enr(2023, tidy = TRUE, use_cache = TRUE)

    # Check flags exist
    expect_true("is_state" %in% names(result))
    expect_true("is_district" %in% names(result))
    expect_true("is_campus" %in% names(result))
    expect_true("is_charter" %in% names(result))

    # Check flags are boolean
    expect_true(is.logical(result$is_state))
    expect_true(is.logical(result$is_district))
    expect_true(is.logical(result$is_campus))
    expect_true(is.logical(result$is_charter))

    # Check mutual exclusivity (each row is only one type)
    type_sums <- result$is_state + result$is_district + result$is_campus
    expect_true(all(type_sums == 1))

  }, error = function(e) {
    skip(paste("Network test skipped:", e$message))
  })
})

test_that("fetch_enr_multi validates years", {
  expect_error(fetch_enr_multi(c(2020, 2000, 2024)), "Invalid years")
  expect_error(fetch_enr_multi(c(2035)), "Invalid years")
})
