# ==============================================================================
# Raw Enrollment Data Download Functions
# ==============================================================================
#
# This file contains functions for downloading raw enrollment data from
# Missouri DESE's MCDS (Missouri Comprehensive Data System).
#
# Data comes from SSRS reports accessible via the MCDS portal:
# - Building Demographic Data report
# - District Demographic Data report
#
# The data is exported in Excel format via URL-based report generation.
#
# Format Eras:
# - 2018-present: Current MCDS SSRS report format
# - 2006-2017: Legacy MCDS format with some column differences
#
# ==============================================================================

#' Download raw enrollment data from Missouri DESE
#'
#' Downloads building and district enrollment data from Missouri DESE's
#' MCDS system via SSRS report exports.
#'
#' @param end_year School year end (2023-24 = 2024)
#' @return List with building and district data frames
#' @keywords internal
get_raw_enr <- function(end_year) {

  # Validate year
  avail <- get_available_years()
  if (end_year < avail$min_year || end_year > avail$max_year) {
    stop(paste0(
      "end_year must be between ", avail$min_year, " and ", avail$max_year,
      ". Available years: ", avail$min_year, "-", avail$max_year
    ))
  }

  message(paste("Downloading Missouri DESE enrollment data for", format_school_year(end_year), "..."))

  # Determine which format era
  if (end_year >= 2018) {
    # Current MCDS SSRS format
    building_data <- download_mcds_building_data(end_year)
    district_data <- download_mcds_district_data(end_year)
  } else {
    # Legacy MCDS format (2006-2017)
    building_data <- download_mcds_building_data_legacy(end_year)
    district_data <- download_mcds_district_data_legacy(end_year)
  }

  # Add end_year column (handle empty dataframes gracefully)
  if (nrow(building_data) > 0) {
    building_data$end_year <- end_year
  } else {
    building_data$end_year <- integer(0)
  }
  if (nrow(district_data) > 0) {
    district_data$end_year <- end_year
  } else {
    district_data$end_year <- integer(0)
  }

  list(
    building = building_data,
    district = district_data
  )
}


#' Download building-level data from MCDS (current format, 2018+)
#'
#' Downloads the Building Demographic Data report from Missouri DESE's
#' MCDS SSRS system. The report is exported to Excel format.
#'
#' @param end_year School year end
#' @return Data frame with building-level enrollment data
#' @keywords internal
download_mcds_building_data <- function(end_year) {

  message("  Downloading building data...")

  # Build the SSRS report URL
  # The Building Demographic Data report ID is: 1bd1a115-127a-4be0-a3ee-41f4680d8761
  # We need to construct a URL that exports to Excel with year parameter

  # Missouri DESE SSRS reports use this pattern for export:
  # Format: rs:Format=EXCELOPENXML for Excel export
  school_year_str <- paste0(end_year - 1, "-", substr(as.character(end_year), 3, 4))

  base_url <- "https://apps.dese.mo.gov/MCDS/Reports/SSRS_Print.aspx"

  # Try to download via the report export endpoint
  # SSRS uses specific parameters for export
  report_url <- paste0(
    base_url,
    "?Reportid=1bd1a115-127a-4be0-a3ee-41f4680d8761",
    "&SCHOOL_YEAR=", school_year_str,
    "&rs:Format=EXCELOPENXML"
  )

  df <- download_dese_excel(report_url, "building", end_year)

  # If direct SSRS export fails, try alternative methods
  if (is.null(df) || nrow(df) == 0) {
    df <- download_building_via_data_download(end_year)
  }

  df
}


#' Download district-level data from MCDS (current format, 2018+)
#'
#' @param end_year School year end
#' @return Data frame with district-level enrollment data
#' @keywords internal
download_mcds_district_data <- function(end_year) {

  message("  Downloading district data...")

  school_year_str <- paste0(end_year - 1, "-", substr(as.character(end_year), 3, 4))

  # District Demographic Data report
  base_url <- "https://apps.dese.mo.gov/MCDS/Reports/SSRS_Print.aspx"

  report_url <- paste0(
    base_url,
    "?Reportid=94388269-c6af-4519-b40f-35014fe28ec3",
    "&SCHOOL_YEAR=", school_year_str,
    "&rs:Format=EXCELOPENXML"
  )

  df <- download_dese_excel(report_url, "district", end_year)

  # If direct SSRS export fails, try alternative methods
  if (is.null(df) || nrow(df) == 0) {
    df <- download_district_via_data_download(end_year)
  }

  df
}


#' Download building-level data (legacy format, 2006-2017)
#'
#' @param end_year School year end
#' @return Data frame with building-level enrollment data
#' @keywords internal
download_mcds_building_data_legacy <- function(end_year) {

  message("  Downloading building data (legacy format)...")

  # Legacy data may use different report IDs or endpoints
  # Try the same endpoint first with adjusted parameters
  school_year_str <- paste0(end_year - 1, "-", substr(as.character(end_year), 3, 4))

  base_url <- "https://apps.dese.mo.gov/MCDS/Reports/SSRS_Print.aspx"

  report_url <- paste0(
    base_url,
    "?Reportid=1bd1a115-127a-4be0-a3ee-41f4680d8761",
    "&SCHOOL_YEAR=", school_year_str,
    "&rs:Format=EXCELOPENXML"
  )

  df <- download_dese_excel(report_url, "building_legacy", end_year)

  # If that fails, try the data download approach
  if (is.null(df) || nrow(df) == 0) {
    df <- download_building_via_data_download(end_year)
  }

  df
}


#' Download district-level data (legacy format, 2006-2017)
#'
#' @param end_year School year end
#' @return Data frame with district-level enrollment data
#' @keywords internal
download_mcds_district_data_legacy <- function(end_year) {

  message("  Downloading district data (legacy format)...")

  school_year_str <- paste0(end_year - 1, "-", substr(as.character(end_year), 3, 4))

  base_url <- "https://apps.dese.mo.gov/MCDS/Reports/SSRS_Print.aspx"

  report_url <- paste0(
    base_url,
    "?Reportid=94388269-c6af-4519-b40f-35014fe28ec3",
    "&SCHOOL_YEAR=", school_year_str,
    "&rs:Format=EXCELOPENXML"
  )

  df <- download_dese_excel(report_url, "district_legacy", end_year)

  if (is.null(df) || nrow(df) == 0) {
    df <- download_district_via_data_download(end_year)
  }

  df
}


#' Download Excel file from Missouri DESE
#'
#' @param url URL to download from
#' @param type Type of data ("building" or "district")
#' @param end_year School year end
#' @return Data frame or NULL if download fails
#' @keywords internal
download_dese_excel <- function(url, type, end_year) {

  # Create temp file
  tname <- tempfile(
    pattern = paste0("mo_", type, "_", end_year, "_"),
    tmpdir = tempdir(),
    fileext = ".xlsx"
  )

  tryCatch({
    response <- httr::GET(
      url,
      httr::write_disk(tname, overwrite = TRUE),
      httr::timeout(300),
      httr::add_headers(
        "User-Agent" = "Mozilla/5.0 (compatible; moschooldata R package)"
      )
    )

    # Check for HTTP errors
    if (httr::http_error(response)) {
      warning(paste("HTTP error:", httr::status_code(response), "for", type, "data"))
      return(NULL)
    }

    # Check content type
    content_type <- httr::headers(response)$`content-type`
    if (!is.null(content_type) && grepl("html|text", content_type, ignore.case = TRUE)) {
      # May have received login page or error page
      warning(paste("Received HTML instead of Excel for", type, "data"))
      return(NULL)
    }

    # Check file size
    file_info <- file.info(tname)
    if (file_info$size < 1000) {
      warning(paste("Downloaded file too small for", type, "data"))
      return(NULL)
    }

    # Read Excel file
    df <- readxl::read_excel(
      tname,
      col_types = "text",
      .name_repair = "unique"
    )

    unlink(tname)

    df

  }, error = function(e) {
    warning(paste("Failed to download", type, "data:", e$message))
    unlink(tname)
    return(NULL)
  })
}


#' Download building data via school directory data download
#'
#' Alternative download method using the school directory exports.
#'
#' @param end_year School year end
#' @return Data frame with building data
#' @keywords internal
download_building_via_data_download <- function(end_year) {

  message("  Trying alternative download method for building data...")

  # Missouri provides school directory files that include enrollment
  # These are refreshed weekly and available at:
  # https://dese.mo.gov/school-directory/data-downloads

  # Try to get the building-level directory with enrollment data
  school_year_str <- paste0(end_year - 1, "-", substr(as.character(end_year), 3, 4))

  # The FileDownloadWebHandler endpoint for school statistics
  # Pattern observed: apps.dese.mo.gov/MCDS/FileDownloadWebHandler.ashx?filename=...
  # We need to try known file patterns

  # Try the school statistics file which contains enrollment
  file_patterns <- c(
    paste0(end_year, "_Missouri_School_Statistics_and_Directory.xlsx"),
    paste0(end_year - 1, "-", end_year, "_School_Statistics.xlsx"),
    paste0("BuildingDemographics_", end_year, ".xlsx")
  )

  for (pattern in file_patterns) {
    url <- paste0(
      "https://apps.dese.mo.gov/MCDS/FileDownloadWebHandler.ashx?filename=",
      pattern
    )

    df <- download_dese_excel(url, "building_alt", end_year)
    if (!is.null(df) && nrow(df) > 0) {
      return(df)
    }
  }

  # If all else fails, create an empty placeholder with expected columns
  warning(paste(
    "Could not download building data for", end_year,
    ". Check if data is available at https://dese.mo.gov/school-data"
  ))

  create_empty_building_df()
}


#' Download district data via data download
#'
#' @param end_year School year end
#' @return Data frame with district data
#' @keywords internal
download_district_via_data_download <- function(end_year) {

  message("  Trying alternative download method for district data...")

  file_patterns <- c(
    paste0(end_year, "_Missouri_School_Statistics_and_Directory.xlsx"),
    paste0(end_year - 1, "-", end_year, "_District_Statistics.xlsx"),
    paste0("DistrictDemographics_", end_year, ".xlsx")
  )

  for (pattern in file_patterns) {
    url <- paste0(
      "https://apps.dese.mo.gov/MCDS/FileDownloadWebHandler.ashx?filename=",
      pattern
    )

    df <- download_dese_excel(url, "district_alt", end_year)
    if (!is.null(df) && nrow(df) > 0) {
      # District data might be in a different sheet or need filtering
      return(df)
    }
  }

  warning(paste(
    "Could not download district data for", end_year,
    ". Check if data is available at https://dese.mo.gov/school-data"
  ))

  create_empty_district_df()
}


#' Create empty building data frame with expected columns
#'
#' @return Empty data frame with expected column structure
#' @keywords internal
create_empty_building_df <- function() {
  data.frame(
    COUNTY_DISTRICT_CODE = character(),
    BUILDING_CODE = character(),
    DISTRICT_NAME = character(),
    BUILDING_NAME = character(),
    COUNTY_NAME = character(),
    TOTAL_ENROLLMENT = character(),
    GRADE_PK = character(),
    GRADE_K = character(),
    GRADE_1 = character(),
    GRADE_2 = character(),
    GRADE_3 = character(),
    GRADE_4 = character(),
    GRADE_5 = character(),
    GRADE_6 = character(),
    GRADE_7 = character(),
    GRADE_8 = character(),
    GRADE_9 = character(),
    GRADE_10 = character(),
    GRADE_11 = character(),
    GRADE_12 = character(),
    WHITE = character(),
    BLACK = character(),
    HISPANIC = character(),
    ASIAN = character(),
    PACIFIC_ISLANDER = character(),
    AMERICAN_INDIAN = character(),
    MULTI_RACIAL = character(),
    FREE_REDUCED = character(),
    LEP = character(),
    IEP = character(),
    stringsAsFactors = FALSE
  )
}


#' Create empty district data frame with expected columns
#'
#' @return Empty data frame with expected column structure
#' @keywords internal
create_empty_district_df <- function() {
  data.frame(
    COUNTY_DISTRICT_CODE = character(),
    DISTRICT_NAME = character(),
    COUNTY_NAME = character(),
    TOTAL_ENROLLMENT = character(),
    GRADE_PK = character(),
    GRADE_K = character(),
    GRADE_1 = character(),
    GRADE_2 = character(),
    GRADE_3 = character(),
    GRADE_4 = character(),
    GRADE_5 = character(),
    GRADE_6 = character(),
    GRADE_7 = character(),
    GRADE_8 = character(),
    GRADE_9 = character(),
    GRADE_10 = character(),
    GRADE_11 = character(),
    GRADE_12 = character(),
    WHITE = character(),
    BLACK = character(),
    HISPANIC = character(),
    ASIAN = character(),
    PACIFIC_ISLANDER = character(),
    AMERICAN_INDIAN = character(),
    MULTI_RACIAL = character(),
    FREE_REDUCED = character(),
    LEP = character(),
    IEP = character(),
    stringsAsFactors = FALSE
  )
}


#' Get column name mappings for Missouri DESE data
#'
#' Maps Missouri DESE column names to standardized package column names.
#' Missouri uses various column naming conventions across years.
#'
#' @return Named list of column mappings
#' @keywords internal
get_mo_column_map <- function() {
  list(
    # ID columns
    county_district_code = c(
      "COUNTY_DISTRICT_CODE", "County District Code", "COUNTY_DISTRICT",
      "CountyDistrictCode", "CD_CODE", "LEA_CODE"
    ),
    building_code = c(
      "BUILDING_CODE", "Building Code", "BUILDING", "BuildingCode",
      "SCHOOL_CODE", "SchoolCode", "BLDG_CODE"
    ),

    # Name columns
    district_name = c(
      "DISTRICT_NAME", "District Name", "DistrictName", "DISTRICT",
      "LEA_NAME", "LEAName"
    ),
    building_name = c(
      "BUILDING_NAME", "Building Name", "BuildingName", "SCHOOL_NAME",
      "SchoolName", "SCHOOL", "BLDG_NAME"
    ),
    county_name = c(
      "COUNTY_NAME", "County Name", "CountyName", "COUNTY"
    ),

    # Total enrollment
    total = c(
      "TOTAL_ENROLLMENT", "Total Enrollment", "TotalEnrollment", "TOTAL",
      "ENROLLMENT", "Enrollment", "MEMBERSHIP", "Membership",
      "OCTOBER_MEMBERSHIP", "Oct Membership"
    ),

    # Demographics (race/ethnicity)
    white = c(
      "WHITE", "White", "WHITE_CNT", "WHITE_COUNT", "WhiteCount",
      "CAUCASIAN", "Caucasian"
    ),
    black = c(
      "BLACK", "Black", "BLACK_CNT", "BLACK_COUNT", "BlackCount",
      "AFRICAN_AMERICAN", "AfricanAmerican", "African American"
    ),
    hispanic = c(
      "HISPANIC", "Hispanic", "HISPANIC_CNT", "HISPANIC_COUNT",
      "HispanicCount", "LATINO", "Latino"
    ),
    asian = c(
      "ASIAN", "Asian", "ASIAN_CNT", "ASIAN_COUNT", "AsianCount"
    ),
    pacific_islander = c(
      "PACIFIC_ISLANDER", "Pacific Islander", "PACIFIC_ISLAND",
      "PacificIslander", "HAWAIIAN", "Hawaiian", "NHPI"
    ),
    native_american = c(
      "AMERICAN_INDIAN", "American Indian", "NATIVE_AMERICAN",
      "NativeAmerican", "INDIAN", "AmericanIndian", "AIAN"
    ),
    multiracial = c(
      "MULTI_RACIAL", "Multi Racial", "MULTIRACIAL", "MultiRacial",
      "TWO_OR_MORE", "TwoOrMore", "Two or More Races"
    ),

    # Special populations
    econ_disadv = c(
      "FREE_REDUCED", "Free Reduced", "FreeReduced", "FRL",
      "FREE_REDUCED_LUNCH", "FreeReducedLunch", "ECON_DISADV",
      "EconomicallyDisadvantaged"
    ),
    lep = c(
      "LEP", "Lep", "ELL", "Ell", "LIMITED_ENGLISH", "LimitedEnglish",
      "ENGLISH_LEARNER", "EnglishLearner", "EL"
    ),
    special_ed = c(
      "IEP", "Iep", "SPECIAL_ED", "SpecialEd", "SPED", "SpEd",
      "SPECIAL_EDUCATION", "SpecialEducation", "SWD"
    ),

    # Grade levels
    grade_pk = c(
      "GRADE_PK", "Grade PK", "PK", "PREK", "PreK", "PRE_K",
      "PREKINDERGARTEN", "PreKindergarten"
    ),
    grade_k = c(
      "GRADE_K", "Grade K", "K", "KG", "KINDERGARTEN", "Kindergarten"
    ),
    grade_01 = c("GRADE_1", "Grade 1", "G1", "GRADE1", "Grade1", "01"),
    grade_02 = c("GRADE_2", "Grade 2", "G2", "GRADE2", "Grade2", "02"),
    grade_03 = c("GRADE_3", "Grade 3", "G3", "GRADE3", "Grade3", "03"),
    grade_04 = c("GRADE_4", "Grade 4", "G4", "GRADE4", "Grade4", "04"),
    grade_05 = c("GRADE_5", "Grade 5", "G5", "GRADE5", "Grade5", "05"),
    grade_06 = c("GRADE_6", "Grade 6", "G6", "GRADE6", "Grade6", "06"),
    grade_07 = c("GRADE_7", "Grade 7", "G7", "GRADE7", "Grade7", "07"),
    grade_08 = c("GRADE_8", "Grade 8", "G8", "GRADE8", "Grade8", "08"),
    grade_09 = c("GRADE_9", "Grade 9", "G9", "GRADE9", "Grade9", "09"),
    grade_10 = c("GRADE_10", "Grade 10", "G10", "GRADE10", "Grade10", "10"),
    grade_11 = c("GRADE_11", "Grade 11", "G11", "GRADE11", "Grade11", "11"),
    grade_12 = c("GRADE_12", "Grade 12", "G12", "GRADE12", "Grade12", "12")
  )
}
