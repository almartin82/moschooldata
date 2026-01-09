# Missouri School Data Expansion Research

**Last Updated:** 2026-01-04 **Theme Researched:** Graduation Rates

------------------------------------------------------------------------

## Package Status

**WARNING:** moschooldata is currently FAILING R-CMD-check. Fix existing
issues before implementing new features.

- R-CMD-check: FAILING
- Python tests: PASSING
- pkgdown: FAILING

------------------------------------------------------------------------

## Current Package Capabilities

The moschooldata package currently supports: - **Enrollment data**
([`fetch_enr()`](https://almartin82.github.io/moschooldata/reference/fetch_enr.md))
for years 2006-2024 - District and building-level data via MCDS SSRS
reports - Demographics (race/ethnicity, FRL, LEP, IEP) - Grade-level
enrollment

**No graduation data is currently implemented.**

------------------------------------------------------------------------

## Data Sources Found

### Source 1: District Adjusted Cohort Graduation Rate (PRIMARY - VERIFIED WORKING)

- **URL:**
  `https://apps.dese.mo.gov/MCDS/FileDownloadWebHandler.ashx?filename=3321d711-15e9District%20Adjusted%20Cohort%20Graduation%20Rate.xlsx`
- **HTTP Status:** 200 OK (verified 2026-01-04)
- **Format:** Excel (.xlsx), 3.4 MB
- **Years Available:** 2011-2025 (15 years, multi-year file)
- **Access Method:** Direct download, no authentication required
- **Level:** District-level only
- **Update Frequency:** Unknown (appears to be updated annually with new
  cohort data)

### Source 2: School/Building Level Graduation Rate

- **URL Pattern:** Not found
- **HTTP Status:** Building-level graduation files return 302 redirect
  (requires login)
- **Access Method:** Requires DESE login credentials
- **Note:** Building-level graduation data may only be available via
  MCDS Data Request (4-6 week processing time)

### Source 3: MCDS SSRS Reports

- **URL:** `https://apps.dese.mo.gov/MCDS/Reports/SSRS_Print.aspx`
- **HTTP Status:** Varies (many require authentication)
- **Format:** SSRS reports with Excel export
- **Access Method:** Some reports require DESE Web Login

### Source 4: Dropout Reports (Monthly)

- **URL:**
  `https://dese.mo.gov/college-career-readiness/adult-education-literacy/dropout-prevention-reporting`
- **HTTP Status:** 200 OK
- **Format:** PDF (monthly reports)
- **Years:** Monthly reports available (e.g., November 2025)
- **Note:** Per RSMo 167.275, dropout reports are published monthly
- **Limitation:** PDF format, not suitable for automated processing

### Source 5: Annual Performance Report (APR)

- **URL:**
  `https://dese.mo.gov/quality-schools/accountability-data/annual-performance-report`
- **HTTP Status:** 403 Forbidden (main page blocked)
- **Access:** May require accessing through MCDS portal with login
- **Contains:** Graduation rates as one component of APR scores

------------------------------------------------------------------------

## Schema Analysis

### District Adjusted Cohort Graduation Rate File

#### File Structure

- **Sheets:** 1 (Sheet1)
- **Total Rows:** 8,457
- **Total Columns:** 112
- **Row Distribution:** ~560-567 districts per year

#### Column Names (Consistent 2011-2025)

| Category                 | Columns                                                                                             |
|--------------------------|-----------------------------------------------------------------------------------------------------|
| **Identifiers**          | YEAR, COUNTY_DISTRICT_CODE, DISTRICT_NAME                                                           |
| **Overall**              | GRADUATES, GRADUATES_4YR_COHORT, ADJUSTED_4YR_COHORT, GRADUATION_RATE_4YR_COHORT                    |
| **Race/Ethnicity (4YR)** | ASIAN\_*, BLACK\_*, HAWAIIAN_PACIFIC_ISLANDER\_*, HISPANIC\_*, INDIAN\_*, MULTIRACIAL\_*, WHITE\_\* |
| **Special Pops (4YR)**   | IEP_GRADUATION_RATE_4YR_COHORT, LEP_GRADUATION_RATE_4YR_COHORT, FRL_GRADUATION_RATE_4YR_COHORT      |
| **5-Year Cohort**        | Same pattern with \_5YR_COHORT suffix                                                               |
| **6-Year Cohort**        | Same pattern with \_6YR_COHORT suffix                                                               |
| **7-Year Cohort**        | Same pattern with \_7YR_COHORT suffix                                                               |

#### Schema Observations

1.  **Column name inconsistency:** Some columns have double underscores
    (e.g., `BLACK_ADJUSTED_5YR__COHORT` vs
    `BLACK_ADJUSTED_4YR_COHORT`) - likely typos in source
2.  **Data types:** All numeric columns stored as text (to accommodate
    suppression marker `*`)
3.  **Suppression marker:** `*` used for small counts (privacy
    protection)
4.  **Cohort types:** 4-year, 5-year, 6-year, and 7-year adjusted cohort
    graduation rates

#### ID System

- **District ID Format:** 6-digit COUNTY_DISTRICT_CODE (e.g., “048078”)
  - First 3 digits: County code
  - Last 3 digits: District number within county
- **Leading zeros preserved:** Yes (stored as character)
- **No building codes:** District-level only

### Schema Changes Noted

| Year Range | Schema Version | Notes                                      |
|------------|----------------|--------------------------------------------|
| 2011-2025  | Consistent     | No schema changes detected across 15 years |

### Known Data Issues

1.  **Suppressed values:** `*` used extensively (~62% of 4YR cohort
    rates are suppressed due to small N)
2.  **Double underscores:** Typos in some column names (e.g.,
    `_5YR__COHORT` instead of `_5YR_COHORT`)
3.  **Floating point representation:** Some rates have floating-point
    artifacts (e.g., `19.190000000000001` instead of `19.19`)
4.  **No state totals:** State-level aggregations not included in file
    (must be computed)

------------------------------------------------------------------------

## Years Available

| Year | Districts | Notes                |
|------|-----------|----------------------|
| 2011 | 564       | First year available |
| 2012 | 570       |                      |
| 2013 | 564       |                      |
| 2014 | 564       |                      |
| 2015 | 563       |                      |
| 2016 | 563       |                      |
| 2017 | 562       |                      |
| 2018 | 564       |                      |
| 2019 | 561       |                      |
| 2020 | 562       | COVID year           |
| 2021 | 562       |                      |
| 2022 | 563       |                      |
| 2023 | 564       |                      |
| 2024 | 564       |                      |
| 2025 | 567       | Most recent          |

------------------------------------------------------------------------

## Time Series Heuristics

Based on analysis of the downloaded data:

### Statewide Metrics

| Metric                    | Expected Range | Red Flag If                  |
|---------------------------|----------------|------------------------------|
| Total graduates per year  | 60,000-66,000  | Change \>10% YoY             |
| Number of districts       | 560-570        | Sudden drop/spike \>20       |
| Non-suppressed rate count | 3,100-3,200    | \<2,500 (data quality issue) |
| Graduation rate range     | 19%-100%       | Values \<0 or \>100          |

### Observed State Totals (Total Graduates)

| Year | Total Graduates | YoY Change |
|------|-----------------|------------|
| 2011 | 62,618          | \-         |
| 2012 | 61,276          | -2.1%      |
| 2013 | 61,202          | -0.1%      |
| 2014 | 60,940          | -0.4%      |
| 2015 | 60,409          | -0.9%      |
| 2016 | 61,393          | +1.6%      |
| 2017 | 61,095          | -0.5%      |
| 2018 | 61,580          | +0.8%      |
| 2019 | 61,195          | -0.6%      |
| 2020 | 60,512          | -1.1%      |
| 2021 | 60,383          | -0.2%      |
| 2022 | 61,479          | +1.8%      |
| 2023 | 61,830          | +0.6%      |
| 2024 | 63,025          | +1.9%      |
| 2025 | 65,313          | +3.6%      |

All YoY changes are within normal range (\<10%).

### Major Districts (Must Exist in All Years)

| District          | ID     | 2024 Graduates | 2024 4YR Rate |
|-------------------|--------|----------------|---------------|
| Kansas City 33    | 048078 | 994            | 86.65%        |
| St. Louis City    | 115115 | 1,032          | 73.01%        |
| Springfield R-XII | 039141 | 1,956          | 97.69%        |

------------------------------------------------------------------------

## Recommended Implementation

### Priority: HIGH

- Graduation rates are a high-value data point commonly requested
- Data source is verified and stable (15 years available)

### Complexity: EASY/MEDIUM

- Single consolidated file with all years
- Schema is consistent across years
- No authentication required
- Main complexity is handling suppressed values and the wide-to-long
  transformation

### Estimated Files to Modify

1.  `R/get_raw_graduation.R` (NEW) - Download raw graduation data
2.  `R/process_graduation.R` (NEW) - Process to standard schema
3.  `R/tidy_graduation.R` (NEW) - Transform to tidy format
4.  `R/fetch_graduation.R` (NEW) - Public API function
5.  `R/utils.R` - Add graduation-specific utilities (possibly)
6.  `tests/testthat/test-graduation.R` (NEW) - Fidelity tests
7.  `tests/testthat/test-pipeline-live-graduation.R` (NEW) - Live
    pipeline tests
8.  `NAMESPACE` - Export new functions
9.  `man/` - Documentation

### Implementation Steps

1.  **Create get_raw_grad()** function to download the district
    graduation rate Excel file
    - URL:
      `https://apps.dese.mo.gov/MCDS/FileDownloadWebHandler.ashx?filename=3321d711-15e9District%20Adjusted%20Cohort%20Graduation%20Rate.xlsx`
    - Returns data frame with all years
2.  **Create process_grad()** function to filter by year and standardize
    columns
    - Handle suppression marker (`*`) -\> NA
    - Fix floating-point artifacts
    - Parse district IDs
3.  **Create tidy_grad()** function to pivot from wide to long format
    - Subgroup column: race/ethnicity groups, IEP, LEP, FRL, total
    - Cohort type column: 4YR, 5YR, 6YR, 7YR
    - Metrics: graduates, cohort_size, graduation_rate
4.  **Create fetch_grad()** public function
    - Parameters: end_year, tidy = TRUE, use_cache = TRUE
    - Similar API to fetch_enr()
5.  **Create fetch_grad_multi()** for multi-year retrieval

------------------------------------------------------------------------

## Test Requirements

### Raw Data Fidelity Tests Needed

| Year | District                   | Metric                     | Expected Value    |
|------|----------------------------|----------------------------|-------------------|
| 2024 | Kansas City 33 (048078)    | GRADUATES                  | 994               |
| 2024 | Kansas City 33 (048078)    | GRADUATION_RATE_4YR_COHORT | 86.65             |
| 2024 | St. Louis City (115115)    | GRADUATES                  | 1,032             |
| 2024 | St. Louis City (115115)    | GRADUATION_RATE_4YR_COHORT | 73.01             |
| 2024 | Springfield R-XII (039141) | GRADUATES                  | 1,956             |
| 2024 | Springfield R-XII (039141) | GRADUATION_RATE_4YR_COHORT | 97.69             |
| 2025 | Kansas City 33 (048078)    | GRADUATES                  | 1,036             |
| 2025 | Kansas City 33 (048078)    | GRADUATION_RATE_4YR_COHORT | 88.16             |
| 2011 | Any                        | YEAR                       | 2011 (first year) |

### Data Quality Checks

1.  **No negative values** - All graduation rates \>= 0
2.  **No values \> 100** - All graduation rates \<= 100
3.  **State total in range** - 60,000 - 70,000 graduates per year
4.  **Major entities exist** - Kansas City, St. Louis, Springfield in
    all years
5.  **No Inf/NaN** - All numeric columns checked
6.  **Suppression handling** - `*` converted to NA correctly
7.  **ID format** - All COUNTY_DISTRICT_CODE are 6-character strings

### LIVE Pipeline Test Categories

1.  **URL Availability** - HEAD request to FileDownloadWebHandler
    returns 200
2.  **File Download** - GET request returns valid Excel file (\>1MB)
3.  **File Parsing** - readxl::read_excel() succeeds
4.  **Column Structure** - Expected columns exist (YEAR,
    COUNTY_DISTRICT_CODE, etc.)
5.  **Year Filtering** - Can filter to single year, get expected row
    count (~560-570)
6.  **Data Quality** - No negative rates, no rates \>100, suppression
    handled
7.  **Output Fidelity** - tidy output matches raw data values

------------------------------------------------------------------------

## Limitations

1.  **District-level only** - Building/school-level graduation data
    requires DESE login
2.  **No dropout rates** - Dropout data only available as monthly PDF
    reports
3.  **Suppression** - Small districts have many suppressed values (~62%
    of rates)
4.  **No state aggregates** - Must compute from district data

------------------------------------------------------------------------

## Alternative Data Sources Considered

| Source               | Status      | Reason Not Used                                     |
|----------------------|-------------|-----------------------------------------------------|
| NCES/Ed Data Express | NOT ALLOWED | Federal data prohibited per project rules           |
| Urban Institute API  | NOT ALLOWED | Federal data prohibited per project rules           |
| PRiME Center (SLU)   | Evaluated   | Uses same DESE data, Google Drive links less stable |
| MCDS Data Request    | Evaluated   | 4-6 week processing time, not automated             |

------------------------------------------------------------------------

## URL Pattern Documentation

    Base: https://apps.dese.mo.gov/MCDS/FileDownloadWebHandler.ashx

    Working URLs:
    - District Graduation Rate:
      ?filename=3321d711-15e9District%20Adjusted%20Cohort%20Graduation%20Rate.xlsx

    Not Working (302 redirect to login):
    - Building Graduation Rate patterns attempted:
      ?filename=3321d711-15e9School%20Adjusted%20Cohort%20Graduation%20Rate.xlsx
      ?filename=3321d711-15e9Building%20Adjusted%20Cohort%20Graduation%20Rate.xlsx

------------------------------------------------------------------------

## Contact for Data Issues

- **Accountability Data Section:** <accountabilitydata@dese.mo.gov>
- **Phone:** 573-526-4886
- **Data Request Form:**
  <https://apps.dese.mo.gov/DataRequestForm/DataRequest.aspx>
