# Process raw Missouri DESE enrollment data

Transforms raw MCDS data into a standardized schema combining building
and district data.

## Usage

``` r
process_enr(raw_data, end_year)
```

## Arguments

- raw_data:

  List containing building and district data frames from get_raw_enr

- end_year:

  School year end

## Value

Processed data frame with standardized columns
