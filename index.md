# moschooldata

**[Documentation](https://almartin82.github.io/moschooldata/)** \|
**[Getting
Started](https://almartin82.github.io/moschooldata/articles/quickstart.html)**
\| **[Enrollment
Trends](https://almartin82.github.io/moschooldata/articles/enrollment-trends.html)**

Fetch and analyze Missouri school enrollment data from the Department of
Elementary and Secondary Education (DESE) in R or Python.

## What can you find with moschooldata?

**20 years of enrollment data (2006-2024).** 870,000 students. 550+
districts. Here are fifteen stories hiding in the numbers:

------------------------------------------------------------------------

### 1. St. Louis City: A district in crisis

St. Louis Public Schools has lost over half its enrollment since 2000,
one of the steepest declines in the nation. The district now serves
fewer than 20,000 students.

``` r
library(moschooldata)
library(dplyr)

enr <- fetch_enr_multi(2010:2024)

enr |>
  filter(is_district, district_id == "115115",
         subgroup == "total_enrollment", grade_level == "TOTAL") |>
  select(end_year, district_name, n_students)
```

![St. Louis City
decline](https://almartin82.github.io/moschooldata/articles/enrollment-trends_files/figure-html/stl-city-decline-1.png)

St. Louis City decline

------------------------------------------------------------------------

### 2. Kansas City 33: Decades of struggle

Kansas City 33 lost accreditation in 2012 and has struggled to rebuild.
Enrollment has dropped dramatically as families flee to surrounding
districts or charter schools.

``` r
enr |>
  filter(is_district, district_id == "048078",
         subgroup == "total_enrollment", grade_level == "TOTAL") |>
  select(end_year, district_name, n_students)
```

![Kansas City
decline](https://almartin82.github.io/moschooldata/articles/enrollment-trends_files/figure-html/kc-decline-1.png)

Kansas City decline

------------------------------------------------------------------------

### 3. St. Louis County: America’s most fragmented

St. Louis County has over 20 separate school districts, a patchwork left
over from white flight and municipal fragmentation. This creates
dramatic inequities.

``` r
enr_2024 <- fetch_enr(2024)

enr_2024 |>
  filter(is_district, county == "St. Louis",
         subgroup == "total_enrollment", grade_level == "TOTAL") |>
  arrange(desc(n_students)) |>
  select(district_name, n_students) |>
  head(15)
```

![St. Louis County
fragmentation](https://almartin82.github.io/moschooldata/articles/enrollment-trends_files/figure-html/stl-county-fragmentation-1.png)

St. Louis County fragmentation

------------------------------------------------------------------------

### 4. Springfield R-XII holds steady

Springfield, Missouri’s third-largest city, has maintained stable
enrollment around 25,000 students while urban cores decline.

``` r
enr |>
  filter(is_district, district_id == "077077",
         subgroup == "total_enrollment", grade_level == "TOTAL") |>
  select(end_year, district_name, n_students)
```

![Springfield
stable](https://almartin82.github.io/moschooldata/articles/enrollment-trends_files/figure-html/springfield-stable-1.png)

Springfield stable

------------------------------------------------------------------------

### 5. KC suburbs boom while urban core shrinks

While Kansas City 33 declines, surrounding districts like Lee’s Summit,
Blue Springs, and Park Hill have seen growth.

``` r
kc_metro <- c("048078", "048053", "048011", "068063")  # KC 33, Lee's Summit, Blue Springs, Park Hill

enr |>
  filter(is_district, district_id %in% kc_metro,
         subgroup == "total_enrollment", grade_level == "TOTAL") |>
  select(end_year, district_name, n_students)
```

![KC suburb
growth](https://almartin82.github.io/moschooldata/articles/enrollment-trends_files/figure-html/kc-suburb-growth-1.png)

KC suburb growth

------------------------------------------------------------------------

### 6. Missouri is diversifying slowly

Missouri’s student population has become more diverse over the past two
decades. The state remains majority-white but with growing Hispanic,
Asian, and multiracial populations.

``` r
enr |>
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("white", "black", "hispanic", "asian", "multiracial")) |>
  mutate(pct = round(pct * 100, 1)) |>
  select(end_year, subgroup, n_students, pct)
```

![Demographic
shift](https://almartin82.github.io/moschooldata/articles/enrollment-trends_files/figure-html/demographics-shift-1.png)

Demographic shift

------------------------------------------------------------------------

### 7. COVID crushed kindergarten

Kindergarten enrollment dropped sharply in 2020-21 and has not
recovered, creating a “missing cohort” that will move through the
system.

``` r
enr |>
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("K", "01", "06", "12")) |>
  select(end_year, grade_level, n_students)
```

![COVID
kindergarten](https://almartin82.github.io/moschooldata/articles/enrollment-trends_files/figure-html/covid-kindergarten-1.png)

COVID kindergarten

------------------------------------------------------------------------

### 8. Charter schools limited to KC and STL

Missouri law restricts charter schools to Kansas City and St. Louis, but
those charters now serve over 30,000 students.

``` r
enr |>
  filter(is_charter, is_campus, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  group_by(end_year) |>
  summarize(total_charter = sum(n_students, na.rm = TRUE))
```

![Charter
enrollment](https://almartin82.github.io/moschooldata/articles/enrollment-trends_files/figure-html/charter-enrollment-1.png)

Charter enrollment

------------------------------------------------------------------------

### 9. Columbia grows with the university

Columbia 93, home to the University of Missouri, is one of few
mid-Missouri districts seeing enrollment growth.

``` r
enr |>
  filter(is_district, district_id == "010004",
         subgroup == "total_enrollment", grade_level == "TOTAL") |>
  select(end_year, district_name, n_students)
```

![Columbia
growth](https://almartin82.github.io/moschooldata/articles/enrollment-trends_files/figure-html/columbia-growth-1.png)

Columbia growth

------------------------------------------------------------------------

### 10. Economic disadvantage is widespread

Over 50% of Missouri students qualify as economically disadvantaged,
with rates even higher in rural and urban core districts.

``` r
enr |>
  filter(is_state, subgroup == "econ_disadv", grade_level == "TOTAL") |>
  mutate(pct = round(pct * 100, 1)) |>
  select(end_year, n_students, pct)
```

![Economic
disadvantage](https://almartin82.github.io/moschooldata/articles/enrollment-trends_files/figure-html/econ-disadvantage-1.png)

Economic disadvantage

------------------------------------------------------------------------

### 11. The Ozarks are aging out

Rural districts in the Ozarks have lost 20-30% of enrollment as young
families leave for cities.

``` r
enr |>
  filter(is_district,
         county %in% c("Taney", "Stone", "Barry", "Christian", "Douglas"),
         subgroup == "total_enrollment", grade_level == "TOTAL") |>
  group_by(end_year) |>
  summarize(n_students = sum(n_students, na.rm = TRUE))
```

![Ozarks
decline](https://almartin82.github.io/moschooldata/articles/enrollment-trends_files/figure-html/ozarks-decline-1.png)

Ozarks decline

------------------------------------------------------------------------

### 12. English learners concentrated in urban areas

English learners are heavily concentrated in Kansas City, St. Louis,
Springfield, and a few meatpacking towns.

``` r
enr_2024 |>
  filter(is_district, subgroup == "lep", grade_level == "TOTAL") |>
  arrange(desc(n_students)) |>
  select(district_name, n_students) |>
  head(10)
```

![EL
concentration](https://almartin82.github.io/moschooldata/articles/enrollment-trends_files/figure-html/el-concentration-1.png)

EL concentration

------------------------------------------------------------------------

### 13. Special education serves 14% of students

Missouri’s special education population has grown steadily, now serving
about 14% of all students.

``` r
enr |>
  filter(is_state, subgroup == "special_ed", grade_level == "TOTAL") |>
  mutate(pct = round(pct * 100, 1)) |>
  select(end_year, n_students, pct)
```

![Special education
trend](https://almartin82.github.io/moschooldata/articles/enrollment-trends_files/figure-html/special-ed-trend-1.png)

Special education trend

------------------------------------------------------------------------

### 14. Largest districts dominate enrollment

The top 10 districts serve about 25% of all Missouri students, while
hundreds of tiny rural districts serve the rest.

``` r
enr_2024 |>
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  arrange(desc(n_students)) |>
  select(district_name, n_students) |>
  head(10)
```

![Largest
districts](https://almartin82.github.io/moschooldata/articles/enrollment-trends_files/figure-html/largest-districts-1.png)

Largest districts

------------------------------------------------------------------------

### 15. State total enrollment is declining

Missouri’s total K-12 enrollment has been slowly declining as birth
rates drop and families leave for other states.

``` r
enr |>
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") |>
  select(end_year, n_students)
```

![State total
trend](https://almartin82.github.io/moschooldata/articles/enrollment-trends_files/figure-html/state-total-trend-1.png)

State total trend

------------------------------------------------------------------------

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

``` python
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

| Years         | Source       | Notes                                      |
|---------------|--------------|--------------------------------------------|
| **2018-2024** | MCDS Current | Current SSRS report format                 |
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
