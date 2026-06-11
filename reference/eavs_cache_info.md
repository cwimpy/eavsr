# Inspect or clear the EAVS cache

`eavs_cache_info()` returns a tibble of files currently cached, with
sizes and modification times. `eavs_clear_cache()` removes cached files
(optionally restricted to a single cycle).

## Usage

``` r
eavs_cache_info()

eavs_clear_cache(cycle = NULL)
```

## Arguments

- cycle:

  Optional integer cycle to restrict to.

## Value

`eavs_cache_info()` returns a tibble; `eavs_clear_cache()` returns the
number of files removed, invisibly.
