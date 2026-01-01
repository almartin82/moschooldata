# Get available years for Missouri enrollment data

Returns the range of years for which enrollment data is available from
Missouri DESE.

## Usage

``` r
get_available_years()
```

## Value

Named list with min_year, max_year, and available_years

## Examples

``` r
get_available_years()
#> $min_year
#> [1] 2006
#> 
#> $max_year
#> [1] 2025
#> 
#> $available_years
#>  [1] 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020
#> [16] 2021 2022 2023 2024 2025
#> 
#> $format_eras
#> $format_eras$mcds_current
#> $format_eras$mcds_current$years
#> [1] 2018 2019 2020 2021 2022 2023 2024 2025
#> 
#> $format_eras$mcds_current$description
#> [1] "MCDS SSRS Reports (current format)"
#> 
#> 
#> $format_eras$mcds_legacy
#> $format_eras$mcds_legacy$years
#>  [1] 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017
#> 
#> $format_eras$mcds_legacy$description
#> [1] "MCDS SSRS Reports (legacy format)"
#> 
#> 
#> 
```
