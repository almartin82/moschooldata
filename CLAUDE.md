# moschooldata Package Instructions

## State Schooldata Project (Universal Rules)

This package is part of the 49-state schooldata project. These rules apply to ALL state packages.

### CRITICAL DATA SOURCE RULES

**NEVER use Urban Institute API, NCES CCD, or ANY federal data source** — the entire point of these packages is to provide STATE-LEVEL data directly from state DOEs. Federal sources aggregate/transform data differently and lose state-specific details. If a state DOE source is broken, FIX IT or find an alternative STATE source — do not fall back to federal data.

---

## Git Workflow (REQUIRED)

### Feature Branch + PR + Auto-Merge Policy

**NEVER push directly to main.** All changes must go through PRs with auto-merge:

```bash
# 1. Create feature branch
git checkout -b fix/description-of-change

# 2. Make changes, commit
git add -A
git commit -m "Fix: description of change"

# 3. Push and create PR with auto-merge
git push -u origin fix/description-of-change
gh pr create --title "Fix: description" --body "Description of changes"
gh pr merge --auto --squash

# 4. Clean up stale branches after PR merges
git checkout main && git pull && git fetch --prune origin
```

### Branch Cleanup (REQUIRED)

**Clean up stale branches every time you touch this package:**

```bash
# Delete local branches merged to main
git branch --merged main | grep -v main | xargs -r git branch -d

# Prune remote tracking branches
git fetch --prune origin
```

### Auto-Merge Requirements

PRs auto-merge when ALL CI checks pass:
- R-CMD-check (0 errors, 0 warnings)
- Python tests (if py{st}schooldata exists)
- pkgdown build (vignettes must render)

If CI fails, fix the issue and push - auto-merge triggers when checks pass.

---

## Local Testing Before PRs (REQUIRED)

**PRs will not be merged until CI passes.** Run these checks locally BEFORE opening a PR:

### CI Checks That Must Pass

| Check | Local Command | What It Tests |
|-------|---------------|---------------|
| R-CMD-check | `devtools::check()` | Package builds, tests pass, no errors/warnings |
| Python tests | `pytest tests/test_pymoschooldata.py -v` | Python wrapper works correctly |
| pkgdown | `pkgdown::build_site()` | Documentation and vignettes render |

### Quick Commands

```r
# R package check (required)
devtools::check()

# Python tests (required)
system("pip install -e ./pymoschooldata && pytest tests/test_pymoschooldata.py -v")

# pkgdown build (required)
pkgdown::build_site()
```

### Pre-PR Checklist

Before opening a PR, verify:
- [ ] `devtools::check()` — 0 errors, 0 warnings
- [ ] `pytest tests/test_pymoschooldata.py` — all tests pass
- [ ] `pkgdown::build_site()` — builds without errors
- [ ] Vignettes render (no `eval=FALSE` hacks)

---

## LIVE Pipeline Testing

This package includes `tests/testthat/test-pipeline-live.R` with LIVE network tests.

### Test Categories:
1. URL Availability - HTTP 200 checks
2. File Download - Verify actual file (not HTML error)
3. File Parsing - readxl/readr succeeds
4. Column Structure - Expected columns exist
5. get_raw_enr() - Raw data function works
6. Data Quality - No Inf/NaN, non-negative counts
7. Aggregation - State total > 0
8. Output Fidelity - tidy=TRUE matches raw

### Running Tests:
```r
devtools::test(filter = "pipeline-live")
```

---

## Fidelity Requirement

**tidy=TRUE MUST maintain fidelity to raw, unprocessed data:**
- Enrollment counts in tidy format must exactly match the wide format
- No rounding or transformation of counts during tidying
- Percentages are calculated fresh but counts are preserved
- State aggregates are sums of school-level data

---

## README Images from Vignettes (REQUIRED)

**NEVER use `man/figures/` or `generate_readme_figs.R` for README images.**

README images MUST come from pkgdown-generated vignette output so they auto-update on merge:

```markdown
![Chart name](https://almartin82.github.io/{package}/articles/{vignette}_files/figure-html/{chunk-name}-1.png)
```

**Why:** Vignette figures regenerate automatically when pkgdown builds. Manual `man/figures/` requires running a separate script and is easy to forget, causing stale/broken images.

---

## README and Vignette Code Matching (REQUIRED)

**CRITICAL RULE (as of 2026-01-08):** ALL code blocks in the README MUST match code in a vignette EXACTLY (1:1 correspondence).

### Why This Matters

The Idaho fix revealed critical bugs when README code didn't match vignettes:
- Wrong district names (lowercase vs ALL CAPS)
- Text claims that contradicted actual data
- Missing data output in examples

### README Story Structure (REQUIRED)

Every story/section in the README MUST follow this structure:

1. **Claim**: A factual statement about the data
2. **Explication**: Brief explanation of why this matters
3. **Code**: R code that fetches and analyzes the data (MUST exist in a vignette)
4. **Code Output**: Data table/print statement showing actual values (REQUIRED)
5. **Visualization**: Chart from vignette (auto-generated from pkgdown)

### Enforcement

The `state-deploy` skill verifies this before deployment:
- Extracts all README code blocks
- Searches vignettes for EXACT matches
- Fails deployment if code not found in vignettes
- Randomly audits packages for claim accuracy

### What This Prevents

- Wrong district/entity names (case sensitivity, typos)
- Text claims that contradict data
- Broken code that fails silently
- Missing data output
- Verified, accurate, reproducible examples

---

# moschooldata Package (Missouri)

## Data Source Status

**CURRENT STATUS: DATA SOURCE UNAVAILABLE**

The Missouri DESE data source is currently unavailable. The package functions exist but cannot fetch data until the state DOE source is fixed or replaced.

**Historical coverage (when source was available):**
- **Years:** 2006-2024 (19 years)
- **Students:** ~870,000 students statewide
- **Districts:** ~550 districts
- **Schools:** ~2,000 buildings/campuses

## Missouri Data Notes

### Data Format Differences

**Two distinct eras:**
- **2018-2024:** MCDS Current format (SSRS report format)
- **2006-2017:** MCDS Legacy format (column differences)

### Missouri-Specific Features

- **County-District Code:** 6 digits (first 3 = county, last 3 = district within county)
  - Example: 048078 = Jackson County (048) + Kansas City 33 (078)
- **Building Code:** 4 digits appended to district code
- **Full Campus ID:** 10 digits (district + building)
- **Data suppression:** Cells with 5 or fewer students are suppressed
- **October membership counts:** Enrollment figures are based on October counts
- **Charter schools:** Limited to Kansas City and St. Louis by state law

### Major Districts

| District | Code | Notes |
|----------|------|-------|
| Kansas City 33 | 048078 | Largest urban district |
| St. Louis City | 115115 | City school district |
| Springfield R-XII | 077077 | Third largest district |
| Columbia 93 | 010004 | University town |

## Data Source

**Primary:** Missouri Department of Elementary and Secondary Education (DESE)
- MCDS Portal: https://apps.dese.mo.gov/MCDS/home.aspx
- School Data: https://dese.mo.gov/school-data

**If this source is broken:** FIX IT or find an alternative STATE source — do not fall back to federal data.
