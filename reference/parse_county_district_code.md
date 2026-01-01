# Parse Missouri county-district code

Missouri uses a county-district code format where the first 3 digits are
the county code and the remaining digits are the district number.

## Usage

``` r
parse_county_district_code(code)
```

## Arguments

- code:

  The county-district code (e.g., "048078" for Kansas City)

## Value

Named list with county_code and district_number
