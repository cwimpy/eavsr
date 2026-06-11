# Local cache directory for EAVS files

Returns the directory used to cache downloaded EAVS files. By default
this is `tools::R_user_dir("eavsr", "cache")`. The location can be
overridden for a single session with the `EAVSR_CACHE_DIR` environment
variable.

## Usage

``` r
eavs_cache_dir()
```

## Value

Path to the cache directory.

## Details

The directory is created on first access.

## Examples

``` r
eavs_cache_dir()
#> [1] "/home/runner/.cache/R/eavsr"
```
