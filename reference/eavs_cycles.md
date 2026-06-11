# EAVS survey cycles available in `eavsr`

Returns a tibble of EAVS survey cycles known to the package, along with
the URLs used to download each cycle's public-release data and codebook.

## Usage

``` r
eavs_cycles()
```

## Value

A tibble with columns `cycle` (integer year), `data_url`, `data_kind`
(`"csv"` or `"zip"`), `codebook_url`, `codebook_kind` (`"xlsx"` or
`"pdf"`), and `status` (`"supported"` or `"planned"`).

## Details

The EAC reorganizes its site periodically, so URLs in this table may be
patched in point releases. Open an issue if you find a broken link.

## Examples

``` r
eavs_cycles()
#> # A tibble: 9 × 6
#>   cycle data_url                     data_kind codebook_url codebook_kind status
#>   <int> <chr>                        <chr>     <chr>        <chr>         <chr> 
#> 1  2004 NA                           NA        NA           NA            plann…
#> 2  2008 NA                           NA        NA           NA            plann…
#> 3  2012 NA                           NA        NA           NA            plann…
#> 4  2014 NA                           NA        NA           NA            plann…
#> 5  2016 https://www.eac.gov/sites/d… zip       https://www… pdf           suppo…
#> 6  2018 https://www.eac.gov/sites/d… csv       https://www… xlsx          suppo…
#> 7  2020 https://www.eac.gov/sites/d… zip       https://www… xlsx          suppo…
#> 8  2022 https://www.eac.gov/sites/d… zip       https://www… xlsx          suppo…
#> 9  2024 https://www.eac.gov/sites/d… zip       https://www… xlsx          suppo…
```
