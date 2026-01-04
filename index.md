# moschooldata

**[Documentation](https://almartin82.github.io/moschooldata/)** \|
**[Getting
Started](https://almartin82.github.io/moschooldata/articles/quickstart.html)**
\| **[Enrollment
Trends](https://almartin82.github.io/moschooldata/articles/enrollment-trends.html)**

Fetch and analyze Missouri school enrollment data from the Department of
Elementary and Secondary Education (DESE) in R or Python.

## What can you find with moschooldata?

**20 years of enrollment data (2006-2025).** 870,000 students. 550+
districts. Here are ten stories hiding in the numbers (see the
[Enrollment
Trends](https://almartin82.github.io/moschooldata/articles/enrollment-trends.html)
vignette for interactive visualizations):

1.  **St. Louis City: A district in crisis** - Lost over 50% of
    enrollment since 2000
2.  **Kansas City 33 isn’t much better** - Lost nearly half its students
3.  **St. Louis County’s fragmented system** - Dozens of tiny districts,
    most fragmented in America
4.  **Springfield is stable** - Third-largest city maintains ~25,000
    students
5.  **Missouri is diversifying slowly** - From 80% white to ~70% with
    Hispanic growth
6.  **COVID crushed kindergarten** - Lost 10,000+ kindergartners, a 14%
    drop
7.  **Charter schools limited to KC and STL** - Over 30,000 students in
    state-law restricted charters
8.  **Columbia grows with the university** - One of few mid-Missouri
    districts gaining students
9.  **Economic disadvantage is widespread** - Over 50% of students
    economically disadvantaged
10. **The Ozarks are aging out** - Rural districts lost 20-30% as young
    families leave

## Installation

``` r
# install.packages("remotes")
remotes::install_github("almartin82/moschooldata")
```

## Quick start

### R

``` r
library(moschooldata)
library(dplyr)

# Fetch one year
enr_2025 <- fetch_enr(2025)

# Fetch multiple years
enr_multi <- fetch_enr_multi(2020:2025)

# State totals
enr_2025 %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL")

# Largest districts
enr_2025 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  head(15)

# Kansas City demographics
enr_2025 %>%
  filter(district_id == "048078", grade_level == "TOTAL",
         subgroup %in% c("white", "black", "hispanic", "asian")) %>%
  select(subgroup, n_students, pct)
```

### Python

``` python
import pymoschooldata as mo

# Fetch 2025 data (2024-25 school year)
enr = mo.fetch_enr(2025)

# Statewide total
total = enr[enr['is_state'] & (enr['subgroup'] == 'total_enrollment') & (enr['grade_level'] == 'TOTAL')]['n_students'].sum()
print(f"{total:,} students")
#> ~870,000 students

# Get multiple years
enr_multi = mo.fetch_enr_multi([2020, 2021, 2022, 2023, 2024, 2025])

# Check available years
years = mo.get_available_years()
print(f"Data available: {years['min_year']}-{years['max_year']}")
#> Data available: 2006-2025
```

## Data availability

| Years         | Source       | Notes                                      |
|---------------|--------------|--------------------------------------------|
| **2018-2025** | MCDS Current | Current SSRS report format                 |
| **2006-2017** | MCDS Legacy  | Legacy format with some column differences |

Data is sourced from the Missouri Department of Elementary and Secondary
Education: - MCDS Portal: <https://apps.dese.mo.gov/MCDS/home.aspx> -
School Data: <https://dese.mo.gov/school-data>

### What’s included

- **Levels:** State, District (~550), Building (campus)
- **Demographics:** White, Black, Hispanic, Asian, Pacific Islander,
  Native American, Multiracial
- **Special populations:** Economically disadvantaged (Free/Reduced
  Lunch), English learners, Special education
- **Grade levels:** PK through 12

### Missouri-specific notes

- **County-District Code:** 6 digits (first 3 = county, last 3 =
  district within county)
  - Example: 048078 = Jackson County (048) + Kansas City 33 (078)
- **Building Code:** 4 digits appended to district code
- **Full Campus ID:** 10 digits (district + building)
- **Data suppression:** Cells with 5 or fewer students are suppressed
- **October membership counts:** Enrollment figures are based on October
  counts
- **Charter schools:** Limited to Kansas City and St. Louis by state law

### Major districts

| District          | Code   | Notes                  |
|-------------------|--------|------------------------|
| Kansas City 33    | 048078 | Largest urban district |
| St. Louis City    | 115115 | City school district   |
| Springfield R-XII | 077077 | Third largest district |
| Columbia 93       | 010004 | University town        |

## Part of the State Schooldata Project

A simple, consistent interface for accessing state-published school data
in Python and R.

**All 50 state packages:**
[github.com/almartin82](https://github.com/almartin82?tab=repositories&q=schooldata)

## Author

[Andy Martin](https://github.com/almartin82) (<almartin@gmail.com>)

## License

MIT
