# ==============================================================================
# Utility Functions
# ==============================================================================

#' Pipe operator
#'
#' See \code{dplyr::\link[dplyr:reexports]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom dplyr %>%
#' @usage lhs \%>\% rhs
#' @param lhs A value or the magrittr placeholder.
#' @param rhs A function call using the magrittr semantics.
#' @return The result of calling `rhs(lhs)`.
NULL


#' Convert to numeric, handling suppression markers
#'
#' Missouri DESE uses various markers for suppressed data (*, <, >, etc.)
#' and may use commas in large numbers.
#'
#' @param x Vector to convert
#' @return Numeric vector with NA for non-numeric values
#' @keywords internal
safe_numeric <- function(x) {
  # Remove commas and whitespace
  x <- gsub(",", "", x)
  x <- trimws(x)

  # Handle common suppression markers
  # Missouri uses * for suppression, < for "less than", > for "greater than"
  x[x %in% c("*", ".", "-", "-1", "<5", "<", ">", "N/A", "NA", "", "**")] <- NA_character_
  x[grepl("^<[0-9]+$", x)] <- NA_character_  # <5, <10, etc.
  x[grepl("^>[0-9]+$", x)] <- NA_character_  # >95, etc.


  suppressWarnings(as.numeric(x))
}


#' Get available years for Missouri enrollment data
#'
#' Returns the range of years for which enrollment data is available
#' from Missouri DESE.
#'
#' @return Named list with min_year, max_year, and available_years
#' @export
#' @examples
#' get_available_years()
get_available_years <- function() {
  # Missouri MCDS data availability:
  # - Building/District Demographic Data: 2006-present
  # - Earlier data may be available in different formats
  list(
    min_year = 2006,
    max_year = 2025,
    available_years = 2006:2025,
    format_eras = list(
      mcds_current = list(
        years = 2018:2025,
        description = "MCDS SSRS Reports (current format)"
      ),
      mcds_legacy = list(
        years = 2006:2017,
        description = "MCDS SSRS Reports (legacy format)"
      )
    )
  )
}


#' Format school year for display
#'
#' @param end_year The end year of the school year (e.g., 2024 for 2023-24)
#' @return Formatted string like "2023-24"
#' @keywords internal
format_school_year <- function(end_year) {

  paste0(end_year - 1, "-", substr(as.character(end_year), 3, 4))
}


#' Parse Missouri county-district code
#'
#' Missouri uses a county-district code format where the first 3 digits
#' are the county code and the remaining digits are the district number.
#'
#' @param code The county-district code (e.g., "048078" for Kansas City)
#' @return Named list with county_code and district_number
#' @keywords internal
parse_county_district_code <- function(code) {
  code <- as.character(code)
  code <- stringr::str_pad(code, width = 6, side = "left", pad = "0")

  list(
    county_code = substr(code, 1, 3),
    district_number = substr(code, 4, 6)
  )
}


#' Build Missouri building code from county-district and building number
#'
#' @param county_district_code The 6-digit county-district code
#' @param building_number The 4-digit building number
#' @return 10-digit building code
#' @keywords internal
build_building_code <- function(county_district_code, building_number) {
  cd <- stringr::str_pad(as.character(county_district_code), width = 6, side = "left", pad = "0")
  bn <- stringr::str_pad(as.character(building_number), width = 4, side = "left", pad = "0")
  paste0(cd, bn)
}
