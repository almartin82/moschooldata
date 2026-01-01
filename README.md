# moschooldata

<!-- badges: start -->
[![R-CMD-check](https://github.com/almartin82/moschooldata/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/almartin82/moschooldata/actions/workflows/R-CMD-check.yaml)
[![Python Tests](https://github.com/almartin82/moschooldata/actions/workflows/python-test.yaml/badge.svg)](https://github.com/almartin82/moschooldata/actions/workflows/python-test.yaml)
[![pkgdown](https://github.com/almartin82/moschooldata/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/almartin82/moschooldata/actions/workflows/pkgdown.yaml)
<!-- badges: end -->

**[Documentation](https://almartin82.github.io/moschooldata/)** | **[Getting Started](https://almartin82.github.io/moschooldata/articles/quickstart.html)**

Fetch and analyze Missouri school enrollment data from the Department of Elementary and Secondary Education (DESE) in R or Python.

## What can you find with moschooldata?

**20 years of enrollment data (2006-2025).** 870,000 students. 550+ districts. Here are ten stories hiding in the numbers:

---

### 1. St. Louis City: A district in crisis

St. Louis Public Schools has lost over 50% of its enrollment since 2000, now serving under 20,000 students.

```r
library(moschooldata)
library(dplyr)

enr <- fetch_enr_multi(c(2006, 2010, 2015, 2020, 2025))

enr %>%
  filter(is_district, district_id == "115115",
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, district_name, n_students)
```

![St. Louis decline](man/figures/stl-decline.png)

---

### 2. Kansas City 33 isn't much better

KCPS has lost nearly half its students, now enrolling around 14,000.

```r
enr %>%
  filter(is_district, district_id == "048078",
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, district_name, n_students)
```

![Kansas City decline](man/figures/kc-decline.png)

---

### 3. Suburban St. Louis County is fragmenting

With dozens of tiny districts, St. Louis County has the most fragmented school system in America.

```r
enr_2025 <- fetch_enr(2025)

# Count districts under 2,000 students
enr_2025 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  mutate(size = case_when(
    n_students < 500 ~ "Under 500",
    n_students < 1000 ~ "500-999",
    n_students < 2000 ~ "1,000-1,999",
    n_students < 5000 ~ "2,000-4,999",
    TRUE ~ "5,000+"
  )) %>%
  group_by(size) %>%
  summarize(n_districts = n())
```

![District fragmentation](man/figures/fragmentation.png)

---

### 4. Springfield is stable

Missouri's third-largest city has maintained consistent enrollment around 25,000 students.

```r
enr %>%
  filter(is_district, grepl("Springfield R-XII", district_name),
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, n_students)
```

![Springfield stability](man/figures/springfield-stable.png)

---

### 5. Missouri is diversifying slowly

The state has gone from 80% white to about 70% white, with Hispanic students driving the change.

```r
enr %>%
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("white", "black", "hispanic", "asian")) %>%
  mutate(pct = round(pct * 100, 1)) %>%
  select(end_year, subgroup, pct)
```

![Demographics](man/figures/demographics.png)

---

### 6. COVID crushed kindergarten

Missouri lost over 10,000 kindergartners in 2021, a drop of nearly 14%.

```r
enr <- fetch_enr_multi(2018:2025)

enr %>%
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("PK", "K", "01", "06", "12")) %>%
  select(end_year, grade_level, n_students)
```

![COVID kindergarten](man/figures/covid-k.png)

---

### 7. Charter schools concentrated in cities

Missouri's charter schools are limited to Kansas City and St. Louis by law, serving over 30,000 students.

```r
enr_2025 %>%
  filter(is_charter, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  summarize(
    total_charter = sum(n_students, na.rm = TRUE),
    n_schools = n()
  )
```

![Charter enrollment](man/figures/charter-enrollment.png)

---

### 8. Columbia grows with the university

Home to Mizzou, Columbia 93 is one of the few mid-Missouri districts gaining students.

```r
enr %>%
  filter(is_district, grepl("Columbia 93", district_name),
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, n_students)
```

![Columbia growth](man/figures/columbia-growth.png)

---

### 9. Economic disadvantage is widespread

Over 50% of Missouri students are economically disadvantaged, with rates exceeding 80% in many rural and urban districts.

```r
enr_2025 %>%
  filter(is_district, subgroup == "econ_disadv", grade_level == "TOTAL") %>%
  arrange(desc(pct)) %>%
  mutate(pct = round(pct * 100, 1)) %>%
  select(district_name, n_students, pct) %>%
  head(10)
```

![Economic disadvantage](man/figures/econ-disadvantage.png)

---

### 10. The Ozarks are aging out

Rural districts in the Ozarks region have lost 20-30% of students as young families leave.

```r
ozarks <- c("Mountain Grove", "West Plains", "Willow Springs", "Cabool")

enr %>%
  filter(is_district, grepl(paste(ozarks, collapse = "|"), district_name),
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, district_name, n_students)
```

![Ozarks decline](man/figures/ozarks-decline.png)

---

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

```python
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

| Years | Source | Notes |
|-------|--------|-------|
| **2018-2025** | MCDS Current | Current SSRS report format |
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
