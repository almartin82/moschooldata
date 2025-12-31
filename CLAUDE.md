# Claude Code Instructions for moschooldata

## Commit and PR Guidelines

- Do NOT include "Generated with Claude Code" in commit messages
- Do NOT include "Co-Authored-By: Claude" in commit messages
- Do NOT mention Claude or AI assistance in PR descriptions
- Keep commit messages clean and professional

## Project Context

This is an R package for fetching and processing Missouri school data from the Missouri Department of Elementary and Secondary Education (DESE).

### Key Data Characteristics

- **Data Source**: Missouri DESE via MCDS (Missouri Comprehensive Data System)
- **MCDS Portal**: https://apps.dese.mo.gov/MCDS/home.aspx
- **ID System**:
  - County-District Code: 6 digits (e.g., 048078 for Kansas City 33)
  - Building Code: 4 digits appended to district code
  - Full Campus ID: 10 digits (district + building)
- **Number of Districts**: ~550 LEAs
- **Data Collection**: October membership counts

### Format Eras

1. **MCDS Current (2018-present)**: Current SSRS report format
2. **MCDS Legacy (2006-2017)**: Legacy format with some column differences

### Key SSRS Report IDs

- Building Demographic Data: `1bd1a115-127a-4be0-a3ee-41f4680d8761`
- District Demographic Data: `94388269-c6af-4519-b40f-35014fe28ec3`

## Package Structure

The package follows the same patterns as txschooldata:
- `fetch_enrollment.R` - Main user-facing function
- `get_raw_enrollment.R` - Download raw data from DESE
- `process_enrollment.R` - Process raw data into standard schema
- `tidy_enrollment.R` - Transform to long format
- `cache.R` - Local caching functions
- `utils.R` - Utility functions

## Missouri-Specific Notes

- Missouri uses "building" instead of "campus" in DESE terminology
- County codes are the first 3 digits of the county-district code
- Charter schools are identified by a charter flag when available
- Data suppression occurs for cells with 5 or fewer students
