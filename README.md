# moschooldata

<!-- badges: start -->
[![R-CMD-check](https://github.com/almartin82/moschooldata/workflows/R-CMD-check/badge.svg)](https://github.com/almartin82/moschooldata/actions)
<!-- badges: end -->

`moschooldata` is an R package for fetching, processing, and analyzing school enrollment data from the Missouri Department of Elementary and Secondary Education (DESE). It provides a programmatic interface to public school data via the Missouri Comprehensive Data System (MCDS), enabling researchers, analysts, and education policy professionals to easily access Missouri public school data.

## Installation

You can install the development version of moschooldata from GitHub:

```r
# install.packages("devtools")
devtools::install_github("almartin82/moschooldata")
```

## Quick Start

```r
library(moschooldata)

# Get 2024 enrollment data (2023-24 school year)
enr_2024 <- fetch_enr(2024)

# Get wide format (one row per school/district)
enr_wide <- fetch_enr(2024, tidy = FALSE)

# Get multiple years
enr_multi <- fetch_enr_multi(2020:2024)

# Filter to a specific district (Kansas City 33)
kc <- enr_2024 %>%
  dplyr::filter(district_id == "048078")

# Get state totals over time
state_totals <- enr_multi %>%
  dplyr::filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  dplyr::select(end_year, n_students)
```

## Data Availability

### Years Available

| Format Era | Years | Description |
|------------|-------|-------------|
| **MCDS Current** | 2018-2025 | Current SSRS report format |
| **MCDS Legacy** | 2006-2017 | Legacy format with some column differences |

**Total**: 20 years of historical data (2006-2025)

### Available Data

- **Aggregation Levels**: State, District, Building (Campus)
- **Demographics**: White, Black, Hispanic, Asian, Pacific Islander, Native American, Multiracial
- **Special Populations**: Free/Reduced Lunch (Economically Disadvantaged), LEP/ELL, Special Education (IEP)
- **Grade Levels**: PK, K, 1-12

### Known Caveats

1. **Data Suppression**: Missouri DESE suppresses data for cells with 5 or fewer students to protect privacy. These appear as NA values.

2. **Charter Schools**: Charter school reporting may vary. Charter status is indicated by the `charter_flag` column when available.

3. **Building vs Campus**: Missouri uses "building" terminology rather than "campus", but this package standardizes to "campus" for consistency with other state packages.

4. **County-District Codes**: Missouri uses a 6-digit county-district code where the first 3 digits represent the county and the last 3 represent the district within that county.

5. **October Count**: Enrollment figures are based on October membership counts as reported to DESE.

## ID System

Missouri uses a hierarchical county-district-building code system:

| Identifier | Format | Example | Description |
|------------|--------|---------|-------------|
| **County-District Code** | 6 digits | 048078 | First 3 = county (048 = Jackson), Last 3 = district (078 = Kansas City 33) |
| **Building Code** | 4 digits | 1234 | Unique within district |
| **Full Campus ID** | 10 digits | 0480781234 | County-District + Building |

### Major Districts

| District | Code | Notes |
|----------|------|-------|
| Kansas City 33 | 048078 | Largest urban district |
| St. Louis City | 115115 | City school district |
| Springfield R-XII | 077077 | Third largest district |
| Columbia 93 | 010004 | University town |

## Output Schema

### Wide Format (`tidy = FALSE`)

| Column | Type | Description |
|--------|------|-------------|
| end_year | integer | School year end (2024 = 2023-24) |
| district_id | character | 6-digit county-district code |
| campus_id | character | 10-digit building code (NA for districts) |
| district_name | character | District name |
| campus_name | character | Building name (NA for districts) |
| type | character | "State", "District", or "Campus" |
| county | character | County name |
| row_total | integer | Total enrollment |
| white, black, hispanic, asian, pacific_islander, native_american, multiracial | integer | Demographic counts |
| econ_disadv, lep, special_ed | integer | Special population counts |
| grade_pk, grade_k, grade_01 ... grade_12 | integer | Grade-level enrollment |

### Tidy Format (`tidy = TRUE`, default)

| Column | Type | Description |
|--------|------|-------------|
| end_year | integer | School year end |
| district_id | character | District identifier |
| campus_id | character | Campus identifier |
| district_name | character | District name |
| campus_name | character | Campus name |
| type | character | Aggregation level |
| grade_level | character | "TOTAL", "PK", "K", "01"-"12" |
| subgroup | character | "total_enrollment", "white", "black", etc. |
| n_students | integer | Student count |
| pct | numeric | Percentage of total (0-1 scale) |
| is_state, is_district, is_campus | logical | Aggregation level flags |
| is_charter | logical | Charter school indicator |

## Data Sources

Data is sourced from the Missouri Department of Elementary and Secondary Education:

- **MCDS Portal**: https://apps.dese.mo.gov/MCDS/home.aspx
- **School Data**: https://dese.mo.gov/school-data
- **Data Downloads**: https://dese.mo.gov/school-directory/data-downloads
- **Building Demographic Data Report**: SSRS Report ID 1bd1a115-127a-4be0-a3ee-41f4680d8761

## Caching

Downloaded data is cached locally to avoid repeated downloads:

```r
# View cached files
cache_status()

# Clear all cached data
clear_cache()

# Clear specific year
clear_cache(2024)

# Force fresh download
fetch_enr(2024, use_cache = FALSE)
```

Cache location: `rappdirs::user_cache_dir("moschooldata")`

## Related Packages

This package is part of a family of state education data packages:

- [txschooldata](https://github.com/almartin82/txschooldata) - Texas
- [ilschooldata](https://github.com/almartin82/ilschooldata) - Illinois
- [nyschooldata](https://github.com/almartin82/nyschooldata) - New York
- [caschooldata](https://github.com/almartin82/caschooldata) - California
- [paschooldata](https://github.com/almartin82/paschooldata) - Pennsylvania
- [ohschooldata](https://github.com/almartin82/ohschooldata) - Ohio

## License
MIT
