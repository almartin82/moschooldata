# moschooldata: Fetch and Process Missouri School Data

Downloads and processes school data from the Missouri Department of
Elementary and Secondary Education (DESE). Provides functions for
fetching enrollment data from the Missouri Comprehensive Data System
(MCDS) and transforming it into tidy format for analysis.

## Main functions

- [`fetch_enr`](https://almartin82.github.io/moschooldata/reference/fetch_enr.md):

  Fetch enrollment data for a school year

- [`fetch_enr_multi`](https://almartin82.github.io/moschooldata/reference/fetch_enr_multi.md):

  Fetch enrollment data for multiple years

- [`tidy_enr`](https://almartin82.github.io/moschooldata/reference/tidy_enr.md):

  Transform wide data to tidy (long) format

- [`id_enr_aggs`](https://almartin82.github.io/moschooldata/reference/id_enr_aggs.md):

  Add aggregation level flags

- [`enr_grade_aggs`](https://almartin82.github.io/moschooldata/reference/enr_grade_aggs.md):

  Create grade-level aggregations

- [`get_available_years`](https://almartin82.github.io/moschooldata/reference/get_available_years.md):

  Get available data years

## Cache functions

- [`cache_status`](https://almartin82.github.io/moschooldata/reference/cache_status.md):

  View cached data files

- [`clear_cache`](https://almartin82.github.io/moschooldata/reference/clear_cache.md):

  Remove cached data files

## ID System

Missouri uses a county-district code system:

- County-District Code: 6 digits (e.g., 048078 = Kansas City 33)

- Building Code: 4 digits appended to district code for 10-digit campus
  ID

- County Code: First 3 digits of district code (e.g., 048 = Jackson
  County)

## Data Sources

Data is sourced from Missouri DESE's MCDS system:

- MCDS Portal: <https://apps.dese.mo.gov/MCDS/home.aspx>

- School Data: <https://dese.mo.gov/school-data>

- Data Downloads: <https://dese.mo.gov/school-directory/data-downloads>

## Format Eras

Missouri DESE data is available in two format eras:

- 2018-present: Current MCDS SSRS report format

- 2006-2017: Legacy MCDS format with some column differences

## See also

Useful links:

- <https://github.com/almartin82/moschooldata>

- Report bugs at <https://github.com/almartin82/moschooldata/issues>

## Author

**Maintainer**: Al Martin <almartin@example.com>
