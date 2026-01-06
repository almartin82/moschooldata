# ==============================================================================
# Enrollment Data Processing Functions
# ==============================================================================
#
# This file contains functions for processing raw Missouri DESE enrollment
# data into a clean, standardized format.
#
# ==============================================================================

#' Process raw Missouri DESE enrollment data
#'
#' Transforms raw MCDS data into a standardized schema combining building
#' and district data.
#'
#' @param raw_data List containing building and district data frames from get_raw_enr
#' @param end_year School year end
#' @return Processed data frame with standardized columns
#' @keywords internal
process_enr <- function(raw_data, end_year) {

  # Process building (campus) data
  building_processed <- process_building_enr(raw_data$building, end_year)

  # Process district data
  district_processed <- process_district_enr(raw_data$district, end_year)

  # Validate that we have some data
  if (nrow(building_processed) == 0 && nrow(district_processed) == 0) {
    stop(
      "No enrollment data available for ", format_school_year(end_year), ". ",
      "Data source may be broken or year may not be available. ",
      "Check https://dese.mo.gov/school-data for current data availability."
    )
  }

  # Create state aggregate
  state_processed <- create_state_aggregate(district_processed, end_year)

  # Combine all levels
  result <- dplyr::bind_rows(state_processed, district_processed, building_processed)

  result
}


#' Process building-level enrollment data
#'
#' @param df Raw building data frame
#' @param end_year School year end
#' @return Processed building data frame
#' @keywords internal
process_building_enr <- function(df, end_year) {

  if (is.null(df) || nrow(df) == 0) {
    return(create_empty_processed_df("Campus", end_year))
  }

  cols <- names(df)
  n_rows <- nrow(df)
  col_map <- get_mo_column_map()

  # Helper to find column by pattern (case-insensitive)
  find_col <- function(patterns) {
    for (pattern in patterns) {
      matched <- grep(paste0("^", pattern, "$"), cols, value = TRUE, ignore.case = TRUE)
      if (length(matched) > 0) return(matched[1])
    }
    NULL
  }

  # Build result dataframe
  result <- data.frame(
    end_year = rep(end_year, n_rows),
    type = rep("Campus", n_rows),
    stringsAsFactors = FALSE
  )

  # IDs
  cd_col <- find_col(col_map$county_district_code)
  if (!is.null(cd_col)) {
    result$district_id <- stringr::str_pad(
      as.character(df[[cd_col]]),
      width = 6, side = "left", pad = "0"
    )
  } else {
    result$district_id <- NA_character_
  }

  bldg_col <- find_col(col_map$building_code)
  if (!is.null(bldg_col)) {
    # Campus ID combines district ID and building code
    bldg_code <- stringr::str_pad(
      as.character(df[[bldg_col]]),
      width = 4, side = "left", pad = "0"
    )
    if (!is.null(cd_col)) {
      result$campus_id <- paste0(result$district_id, bldg_code)
    } else {
      result$campus_id <- bldg_code
    }
  } else {
    result$campus_id <- NA_character_
  }

  # Names
  campus_name_col <- find_col(col_map$building_name)
  if (!is.null(campus_name_col)) {
    result$campus_name <- trimws(as.character(df[[campus_name_col]]))
  } else {
    result$campus_name <- NA_character_
  }

  district_name_col <- find_col(col_map$district_name)
  if (!is.null(district_name_col)) {
    result$district_name <- trimws(as.character(df[[district_name_col]]))
  } else {
    result$district_name <- NA_character_
  }

  # County
  county_col <- find_col(col_map$county_name)
  if (!is.null(county_col)) {
    result$county <- trimws(as.character(df[[county_col]]))
  } else {
    result$county <- NA_character_
  }

  # Missouri doesn't have regions in the same way as Texas, but we include for compatibility

  result$region <- NA_character_

  # Missouri charter flag (if available)
  charter_patterns <- c("CHARTER", "Charter", "IS_CHARTER", "IsCharter")
  charter_col <- find_col(charter_patterns)
  if (!is.null(charter_col)) {
    result$charter_flag <- as.character(df[[charter_col]])
  } else {
    result$charter_flag <- NA_character_
  }

  # Total enrollment
  total_col <- find_col(col_map$total)
  if (!is.null(total_col)) {
    result$row_total <- safe_numeric(df[[total_col]])
  } else {
    result$row_total <- NA_integer_
  }

  # Demographics (race/ethnicity)
  demo_map <- list(
    white = col_map$white,
    black = col_map$black,
    hispanic = col_map$hispanic,
    asian = col_map$asian,
    pacific_islander = col_map$pacific_islander,
    native_american = col_map$native_american,
    multiracial = col_map$multiracial
  )

  for (name in names(demo_map)) {
    col <- find_col(demo_map[[name]])
    if (!is.null(col)) {
      result[[name]] <- safe_numeric(df[[col]])
    } else {
      result[[name]] <- NA_integer_
    }
  }

  # Special populations
  special_map <- list(
    econ_disadv = col_map$econ_disadv,
    lep = col_map$lep,
    special_ed = col_map$special_ed
  )

  for (name in names(special_map)) {
    col <- find_col(special_map[[name]])
    if (!is.null(col)) {
      result[[name]] <- safe_numeric(df[[col]])
    } else {
      result[[name]] <- NA_integer_
    }
  }

  # Grade levels
  grade_map <- list(
    grade_pk = col_map$grade_pk,
    grade_k = col_map$grade_k,
    grade_01 = col_map$grade_01,
    grade_02 = col_map$grade_02,
    grade_03 = col_map$grade_03,
    grade_04 = col_map$grade_04,
    grade_05 = col_map$grade_05,
    grade_06 = col_map$grade_06,
    grade_07 = col_map$grade_07,
    grade_08 = col_map$grade_08,
    grade_09 = col_map$grade_09,
    grade_10 = col_map$grade_10,
    grade_11 = col_map$grade_11,
    grade_12 = col_map$grade_12
  )

  for (name in names(grade_map)) {
    col <- find_col(grade_map[[name]])
    if (!is.null(col)) {
      result[[name]] <- safe_numeric(df[[col]])
    } else {
      result[[name]] <- NA_integer_
    }
  }

  result
}


#' Process district-level enrollment data
#'
#' @param df Raw district data frame
#' @param end_year School year end
#' @return Processed district data frame
#' @keywords internal
process_district_enr <- function(df, end_year) {

  if (is.null(df) || nrow(df) == 0) {
    return(create_empty_processed_df("District", end_year))
  }

  cols <- names(df)
  n_rows <- nrow(df)
  col_map <- get_mo_column_map()

  # Helper to find column by pattern (case-insensitive)
  find_col <- function(patterns) {
    for (pattern in patterns) {
      matched <- grep(paste0("^", pattern, "$"), cols, value = TRUE, ignore.case = TRUE)
      if (length(matched) > 0) return(matched[1])
    }
    NULL
  }

  # Build result dataframe
  result <- data.frame(
    end_year = rep(end_year, n_rows),
    type = rep("District", n_rows),
    stringsAsFactors = FALSE
  )

  # IDs
  cd_col <- find_col(col_map$county_district_code)
  if (!is.null(cd_col)) {
    result$district_id <- stringr::str_pad(
      as.character(df[[cd_col]]),
      width = 6, side = "left", pad = "0"
    )
  } else {
    result$district_id <- NA_character_
  }

  # Campus ID is NA for district rows
  result$campus_id <- rep(NA_character_, n_rows)

  # Names
  district_name_col <- find_col(col_map$district_name)
  if (!is.null(district_name_col)) {
    result$district_name <- trimws(as.character(df[[district_name_col]]))
  } else {
    result$district_name <- NA_character_
  }

  result$campus_name <- rep(NA_character_, n_rows)

  # County
  county_col <- find_col(col_map$county_name)
  if (!is.null(county_col)) {
    result$county <- trimws(as.character(df[[county_col]]))
  } else {
    result$county <- NA_character_
  }

  result$region <- NA_character_

  # Charter flag
  charter_patterns <- c("CHARTER", "Charter", "IS_CHARTER", "IsCharter")
  charter_col <- find_col(charter_patterns)
  if (!is.null(charter_col)) {
    result$charter_flag <- as.character(df[[charter_col]])
  } else {
    result$charter_flag <- NA_character_
  }

  # Total enrollment
  total_col <- find_col(col_map$total)
  if (!is.null(total_col)) {
    result$row_total <- safe_numeric(df[[total_col]])
  } else {
    result$row_total <- NA_integer_
  }

  # Demographics
  demo_map <- list(
    white = col_map$white,
    black = col_map$black,
    hispanic = col_map$hispanic,
    asian = col_map$asian,
    pacific_islander = col_map$pacific_islander,
    native_american = col_map$native_american,
    multiracial = col_map$multiracial
  )

  for (name in names(demo_map)) {
    col <- find_col(demo_map[[name]])
    if (!is.null(col)) {
      result[[name]] <- safe_numeric(df[[col]])
    } else {
      result[[name]] <- NA_integer_
    }
  }

  # Special populations
  special_map <- list(
    econ_disadv = col_map$econ_disadv,
    lep = col_map$lep,
    special_ed = col_map$special_ed
  )

  for (name in names(special_map)) {
    col <- find_col(special_map[[name]])
    if (!is.null(col)) {
      result[[name]] <- safe_numeric(df[[col]])
    } else {
      result[[name]] <- NA_integer_
    }
  }

  # Grade levels
  grade_map <- list(
    grade_pk = col_map$grade_pk,
    grade_k = col_map$grade_k,
    grade_01 = col_map$grade_01,
    grade_02 = col_map$grade_02,
    grade_03 = col_map$grade_03,
    grade_04 = col_map$grade_04,
    grade_05 = col_map$grade_05,
    grade_06 = col_map$grade_06,
    grade_07 = col_map$grade_07,
    grade_08 = col_map$grade_08,
    grade_09 = col_map$grade_09,
    grade_10 = col_map$grade_10,
    grade_11 = col_map$grade_11,
    grade_12 = col_map$grade_12
  )

  for (name in names(grade_map)) {
    col <- find_col(grade_map[[name]])
    if (!is.null(col)) {
      result[[name]] <- safe_numeric(df[[col]])
    } else {
      result[[name]] <- NA_integer_
    }
  }

  result
}


#' Create state-level aggregate from district data
#'
#' @param district_df Processed district data frame
#' @param end_year School year end
#' @return Single-row data frame with state totals
#' @keywords internal
create_state_aggregate <- function(district_df, end_year) {

  # Columns to sum
  sum_cols <- c(
    "row_total",
    "white", "black", "hispanic", "asian",
    "pacific_islander", "native_american", "multiracial",
    "econ_disadv", "lep", "special_ed",
    "grade_pk", "grade_k",
    "grade_01", "grade_02", "grade_03", "grade_04",
    "grade_05", "grade_06", "grade_07", "grade_08",
    "grade_09", "grade_10", "grade_11", "grade_12"
  )

  # Filter to columns that exist
  sum_cols <- sum_cols[sum_cols %in% names(district_df)]

  # Create state row
  state_row <- data.frame(
    end_year = end_year,
    type = "State",
    district_id = NA_character_,
    campus_id = NA_character_,
    district_name = NA_character_,
    campus_name = NA_character_,
    county = NA_character_,
    region = NA_character_,
    charter_flag = NA_character_,
    stringsAsFactors = FALSE
  )

  # Sum each column
  for (col in sum_cols) {
    if (col %in% names(district_df)) {
      state_row[[col]] <- sum(district_df[[col]], na.rm = TRUE)
    }
  }

  state_row
}


#' Create empty processed data frame
#'
#' @param type Row type ("State", "District", or "Campus")
#' @param end_year School year end
#' @return Empty data frame with expected structure
#' @keywords internal
create_empty_processed_df <- function(type, end_year) {
  data.frame(
    end_year = integer(),
    type = character(),
    district_id = character(),
    campus_id = character(),
    district_name = character(),
    campus_name = character(),
    county = character(),
    region = character(),
    charter_flag = character(),
    row_total = integer(),
    white = integer(),
    black = integer(),
    hispanic = integer(),
    asian = integer(),
    pacific_islander = integer(),
    native_american = integer(),
    multiracial = integer(),
    econ_disadv = integer(),
    lep = integer(),
    special_ed = integer(),
    grade_pk = integer(),
    grade_k = integer(),
    grade_01 = integer(),
    grade_02 = integer(),
    grade_03 = integer(),
    grade_04 = integer(),
    grade_05 = integer(),
    grade_06 = integer(),
    grade_07 = integer(),
    grade_08 = integer(),
    grade_09 = integer(),
    grade_10 = integer(),
    grade_11 = integer(),
    grade_12 = integer(),
    stringsAsFactors = FALSE
  )
}
