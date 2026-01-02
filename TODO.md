# TODO - pkgdown Build Issues

## Issue: CRAN Link Check Network Error

**Date:** 2026-01-01

**Error Summary:**
The pkgdown build fails during the home page build step when attempting to check CRAN links. The error occurs in `pkgdown:::cran_link()` when making an HTTP request via `httr2::req_perform()`.

**Full Error Stack:**
```
1. pkgdown::build_site(...)
2. pkgdown:::build_site_local(...)
3. pkgdown::build_home(...)
4. pkgdown::build_home_index(...)
5. pkgdown:::data_home(pkg)
6. pkgdown:::print_yaml(...)
7. pkgdown:::data_home_sidebar(pkg, call = call)
8. pkgdown:::data_home_sidebar_links(pkg)
9. pkgdown:::cran_link(pkg$package)
10. httr2::req_perform(req)
11. httr2:::handle_resp(req, resp, error_call = error_call)
12. rlang::cnd_signal(resp)
```

**Possible Causes:**
1. Network connectivity issues when checking CRAN
2. CRAN server temporarily unavailable
3. Package not yet on CRAN (expected for development packages)

**Potential Solutions:**
1. Retry the build when network conditions improve
2. Add `cran: null` to `_pkgdown.yml` to disable CRAN link checking
3. Build with `pkgdown::build_site(override = list(template = list(params = list(cran = ""))))`

**Workaround:**
Try building offline or with CRAN checks disabled:
```r
# Option 1: Disable CRAN link in _pkgdown.yml
# Add under template > params:
#   cran: ~

# Option 2: Build with override
pkgdown::build_site(override = list(development = list(mode = "release")))
```
