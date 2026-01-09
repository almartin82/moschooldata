# moschooldata

<!-- badges: start -->
[![R-CMD-check](https://github.com/almartin82/moschooldata/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/almartin82/moschooldata/actions/workflows/R-CMD-check.yaml)
[![Python Tests](https://github.com/almartin82/moschooldata/actions/workflows/python-test.yaml/badge.svg)](https://github.com/almartin82/moschooldata/actions/workflows/python-test.yaml)
[![pkgdown](https://github.com/almartin82/moschooldata/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/almartin82/moschooldata/actions/workflows/pkgdown.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

**[Documentation](https://almartin82.github.io/moschooldata/)** | **[Getting Started](https://almartin82.github.io/moschooldata/articles/quickstart.html)** | **[Enrollment Trends](https://almartin82.github.io/moschooldata/articles/enrollment-trends.html)**

Fetch and analyze Missouri school enrollment data from the Department of Elementary and Secondary Education (DESE) in R or Python.

## Data availability

**NOTE: The Missouri DESE data source is currently unavailable.** The package functions exist but cannot fetch data until the state DOE source is fixed or replaced.

**Historical data coverage (when source was available):**
- **Years:** 2006-2024 (19 years)
- **Students:** ~870,000 students statewide
- **Districts:** ~550 districts
- **Schools:** ~2,000 buildings/campuses

## Installation

```r
# install.packages("remotes")
remotes::install_github("almartin82/moschooldata")
```

## Quick start

### R

```r
library(moschooldata)
library(dplyr)

# Fetch one year
enr_2024 <- fetch_enr(2024)

# Fetch multiple years
enr_multi <- fetch_enr_multi(2020:2024)

# State totals
enr_2024 |>
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL")

# Largest districts
enr_2024 |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  arrange(desc(n_students)) |>
  head(15)

# Kansas City demographics
enr_2024 |>
  filter(district_id == "048078", grade_level == "TOTAL",
         subgroup %in% c("white", "black", "hispanic", "asian")) |>
  select(subgroup, n_students, pct)
```

### Python

```python
import pymoschooldata as mo

# Fetch 2024 data (2023-24 school year)
enr = mo.fetch_enr(2024)

# Statewide total
total = enr[enr['is_state'] & (enr['subgroup'] == 'total_enrollment') & (enr['grade_level'] == 'TOTAL')]['n_students'].sum()
print(f"{total:,} students")
#> ~870,000 students

# Get multiple years
enr_multi = mo.fetch_enr_multi([2020, 2021, 2022, 2023, 2024])

# Check available years
years = mo.get_available_years()
print(f"Data available: {years['min_year']}-{years['max_year']}")
#> Data available: 2006-2024
```

## Data availability

| Years | Source | Notes |
|-------|--------|-------|
| **2018-2024** | MCDS Current | Current SSRS report format |
| **2006-2017** | MCDS Legacy | Legacy format with some column differences |

Data is sourced from the Missouri Department of Elementary and Secondary Education:
- MCDS Portal: https://apps.dese.mo.gov/MCDS/home.aspx
- School Data: https://dese.mo.gov/school-data

### What's included

- **Levels:** State, District (~550), Building (campus)
- **Demographics:** White, Black, Hispanic, Asian, Pacific Islander, Native American, Multiracial
- **Special populations:** Economically disadvantaged (Free/Reduced Lunch), English learners, Special education
- **Grade levels:** PK through 12

### Missouri-specific notes

- **County-District Code:** 6 digits (first 3 = county, last 3 = district within county)
  - Example: 048078 = Jackson County (048) + Kansas City 33 (078)
- **Building Code:** 4 digits appended to district code
- **Full Campus ID:** 10 digits (district + building)
- **Data suppression:** Cells with 5 or fewer students are suppressed
- **October membership counts:** Enrollment figures are based on October counts
- **Charter schools:** Limited to Kansas City and St. Louis by state law

### Major districts

| District | Code | Notes |
|----------|------|-------|
| Kansas City 33 | 048078 | Largest urban district |
| St. Louis City | 115115 | City school district |
| Springfield R-XII | 077077 | Third largest district |
| Columbia 93 | 010004 | University town |

## Part of the State Schooldata Project

A simple, consistent interface for accessing state-published school data in Python and R.

**All 50 state packages:** [github.com/almartin82](https://github.com/almartin82?tab=repositories&q=schooldata)

## Author

[Andy Martin](https://github.com/almartin82) (almartin@gmail.com)

## License

MIT
