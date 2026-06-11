# Getting started with eavsr

`eavsr` provides a tidy interface to the U.S. Election Assistance
Commission’s **Election Administration and Voting Survey (EAVS)** — the
largest public dataset on local election administration in the United
States. This vignette walks through the main workflow: discovering
cycles, downloading and reading data, harmonizing variables, classifying
jurisdictions, and rolling everything up to county-equivalent geography.

> Not affiliated with or endorsed by the U.S. Election Assistance
> Commission.

``` r

library(eavsr)
```

## Which cycles are available?

[`eavs_cycles()`](https://cwimpy.github.io/eavsr/reference/eavs_cycles.md)
returns the cycles the package knows about, the source URLs, and whether
each is ready to download (`supported`) or still being verified
(`planned`).

``` r

eavs_cycles()
#>   cycle
#> 1  2004
#> 2  2008
#> 3  2012
#> 4  2014
#> 5  2016
#> 6  2018
#> 7  2020
#> 8  2022
#> 9  2024
#>                                                                                            data_url
#> 1                                                                                              <NA>
#> 2                                                                                              <NA>
#> 3                                                                                              <NA>
#> 4                                                                                              <NA>
#> 5 https://www.eac.gov/sites/default/files/2023-12/EAVS_2016_for_Public_Release_nolabel_V1.1_CSV.zip
#> 6   https://www.eac.gov/sites/default/files/2019-10/EAVS_2018_for_Public_Release_nolabel%20v1.1.csv
#> 7 https://www.eac.gov/sites/default/files/2023-12/2020_EAVS_for_Public_Release_nolabel_V1.2_CSV.zip
#> 8   https://www.eac.gov/sites/default/files/2023-06/2022_EAVS_for_Public_Release_nolabel_V1_CSV.zip
#> 9   https://www.eac.gov/sites/default/files/2025-06/2024_EAVS_for_Public_Release_nolabel_V1_csv.zip
#>   data_kind
#> 1      <NA>
#> 2      <NA>
#> 3      <NA>
#> 4      <NA>
#> 5       zip
#> 6       csv
#> 7       zip
#> 8       zip
#> 9       zip
#>                                                                     codebook_url
#> 1                                                                           <NA>
#> 2                                                                           <NA>
#> 3                                                                           <NA>
#> 4                                                                           <NA>
#> 5  https://www.eac.gov/sites/default/files/eac_assets/1/6/EAVS_Codebook_2016.pdf
#> 6 https://www.eac.gov/sites/default/files/eac_assets/1/6/2018_EAVS_Codebook.xlsx
#> 7        https://www.eac.gov/sites/default/files/2021-08/2020_EAVS_Codebook.xlsx
#> 8        https://www.eac.gov/sites/default/files/2023-06/2022_EAVS_Codebook.xlsx
#> 9        https://www.eac.gov/sites/default/files/2025-06/2024_EAVS_Codebook.xlsx
#>   codebook_kind    status
#> 1          <NA>   planned
#> 2          <NA>   planned
#> 3          <NA>   planned
#> 4          <NA>   planned
#> 5           pdf supported
#> 6          xlsx supported
#> 7          xlsx supported
#> 8          xlsx supported
#> 9          xlsx supported
```

## Downloading and reading data

[`read_eavs()`](https://cwimpy.github.io/eavsr/reference/read_eavs.md)
downloads a cycle (if it is not already cached), reads it into a tibble,
and recodes EAVS missing-value codes (negative integers such as `-99`)
to `NA`. The download happens once and is cached locally, so later calls
are fast.

``` r

# One call: download (first time only), unzip, read, and clean.
eavs <- read_eavs(2024)

# The file exactly as released, with no recoding or name cleaning:
raw <- read_eavs(2024, level = "raw")
```

`read_eavs(level = "jurisdiction")` (the default) lower-cases column
names with
[`janitor::clean_names()`](https://sfirke.github.io/janitor/reference/clean_names.html)
and recodes missing values; `level = "raw"` returns the file untouched.
You can also call
[`download_eavs()`](https://cwimpy.github.io/eavsr/reference/download_eavs.md)
directly if you only want the file path.

### The codebook

EAVS ships a codebook describing all ~500 variables. For cycles whose
codebook is released as a spreadsheet,
[`eavs_codebook()`](https://cwimpy.github.io/eavsr/reference/eavs_codebook.md)
returns it as a tibble (this requires the `readxl` package):

``` r

cb <- eavs_codebook(2024)
```

## Harmonizing variables across cycles

EAVS variable codes drift across survey cycles, which makes multi-cycle
work painful.
[`eavs_crosswalk()`](https://cwimpy.github.io/eavsr/reference/eavs_crosswalk.md)
returns a hand-curated map from raw EAVS codes to a stable harmonized
name and topical section:

``` r

eavs_crosswalk()
#>    cycle variable                     harmonized        section
#> 1   2024      A1a        registered_voters_total   registration
#> 2   2024      A1b       registered_voters_active   registration
#> 3   2024      A1c     registered_voters_inactive   registration
#> 4   2024      B1a           voting_systems_count     technology
#> 5   2024      C1a   absentee_ballots_transmitted    mail_voting
#> 6   2024      C1b      absentee_ballots_returned    mail_voting
#> 7   2024      C1c       absentee_ballots_counted    mail_voting
#> 8   2024      D1a    polling_places_election_day polling_places
#> 9   2024      D2a           polling_places_total polling_places
#> 10  2024      D7a             poll_workers_total       staffing
#> 11  2024       D8         poll_worker_difficulty       staffing
#> 12  2024      E1a   ballots_rejected_provisional     rejections
#> 13  2024      F1a  turnout_total_ballots_counted  participation
#> 14  2024      F1b turnout_in_person_election_day  participation
#> 15  2024      F1c        turnout_in_person_early  participation
#> 16  2024      F1d                turnout_by_mail  participation
#> 17  2024      F1e            turnout_provisional  participation
#>                                             description
#> 1                               Total registered voters
#> 2                              Active registered voters
#> 3                            Inactive registered voters
#> 4                       Number of voting systems in use
#> 5           Absentee/mail ballots transmitted to voters
#> 6              Absentee/mail ballots returned by voters
#> 7                         Absentee/mail ballots counted
#> 8     Number of physical polling places on Election Day
#> 9           Total polling places (Election Day + early)
#> 10                         Total number of poll workers
#> 11 Difficulty obtaining sufficient poll workers (scale)
#> 12                         Provisional ballots rejected
#> 13                                Total ballots counted
#> 14               Ballots cast in person on Election Day
#> 15           Ballots cast in person during early voting
#> 16                        Ballots cast by mail/absentee
#> 17                             Provisional ballots cast
```

## Understanding EAVS geography

EAVS reporting units vary by state, and — importantly — so does the
`FIPSCode` field. There are three patterns to know about:

- **Most states** use a 10-digit code. A trailing `00000` marks a
  **county-level** row (county-reporting states); any other ending marks
  a **sub-county** row (the New England township states: ME, MA, NH, VT,
  CT, RI).
- **Wisconsin** uses a 5-digit internal code that is *not* a Census FIPS
  code; its ~1,850 municipalities carry the county only in the
  jurisdiction *name* (e.g. `TOWN OF ABRAMS - OCONTO COUNTY`).
- **Connecticut** reports by town and is mapped to its nine planning
  regions.

[`classify_jurisdiction()`](https://cwimpy.github.io/eavsr/reference/classify_jurisdiction.md)
reads these patterns and adds `jurisdiction_type`, `state_fips`,
`county_fips`, and `is_multi_county`. It keys off the `state_abbr`
column (not the raw FIPS prefix), and applies Connecticut and Wisconsin
name lookups where needed.

``` r

jur <- tibble::tibble(
  fips_code         = c("0100100000",     "2500112345",   "0900112345"),
  jurisdiction_name = c("AUTAUGA COUNTY", "EXAMPLE TOWN",  "ANDOVER TOWN"),
  state_abbr        = c("AL",             "MA",            "CT")
)

classify_jurisdiction(jur)
#> # A tibble: 3 × 7
#>   fips_code  jurisdiction_name state_abbr is_multi_county jurisdiction_type
#>   <chr>      <chr>             <chr>      <lgl>           <chr>            
#> 1 0100100000 AUTAUGA COUNTY    AL         FALSE           County           
#> 2 2500112345 EXAMPLE TOWN      MA         FALSE           Sub-county       
#> 3 0900112345 ANDOVER TOWN      CT         FALSE           Sub-county       
#> # ℹ 2 more variables: state_fips <chr>, county_fips <chr>
```

Here Autauga County (Alabama) is a county row; the Massachusetts town is
a sub-county row whose `county_fips` is derived from its code; and the
Connecticut town is mapped to its planning region (`09110`). The
Connecticut and Wisconsin lookup tables are extensible — pass your own
via the `ct_lookup` and `wi_lookup` arguments, or see
[`?ct_planning_regions`](https://cwimpy.github.io/eavsr/reference/ct_planning_regions.md)
and
[`?wi_subcounty_fips`](https://cwimpy.github.io/eavsr/reference/wi_subcounty_fips.md).

## Rolling up to county level

[`aggregate_to_county()`](https://cwimpy.github.io/eavsr/reference/aggregate_to_county.md)
produces one row per county-equivalent FIPS code. For each county it
prefers a directly reported county row; where only sub-county rows
exist, it sums their numeric columns up to the county. Ordinal questions
(like EAVS `d8`) can be summarized by their modal value instead of
summed. It calls
[`classify_jurisdiction()`](https://cwimpy.github.io/eavsr/reference/classify_jurisdiction.md)
for you if the data has not been classified.

``` r

example <- tibble::tibble(
  fips_code         = c("0100100000",     "2500112345", "2500167890"),
  jurisdiction_name = c("AUTAUGA COUNTY", "TOWN A",      "TOWN B"),
  state_abbr        = c("AL",             "MA",          "MA"),
  total_voters      = c(40000,            12000,         8000)
)

aggregate_to_county(example)
#> # A tibble: 2 × 10
#>   fips_code  jurisdiction_name state_abbr total_voters is_multi_county
#>   <chr>      <chr>             <chr>             <dbl> <lgl>          
#> 1 0100100000 AUTAUGA COUNTY    AL                40000 FALSE          
#> 2 2500112345 TOWN A            MA                20000 FALSE          
#> # ℹ 5 more variables: jurisdiction_type <chr>, state_fips <chr>,
#> #   county_fips <chr>, data_source <chr>, n_subjurisdictions <int>
```

The Alabama county is carried through directly
(`data_source = "direct_county"`), while the two Massachusetts towns are
summed into their shared county
(`data_source = "aggregated_subcounty"`). By default U.S. territories
and Alaska are dropped, since they do not roll up cleanly to county
FIPS; see
[`?aggregate_to_county`](https://cwimpy.github.io/eavsr/reference/aggregate_to_county.md)
to change that.

## Citing EAVS

The EAC asks researchers to cite the EAVS release.
[`cite_eavs()`](https://cwimpy.github.io/eavsr/reference/cite_eavs.md)
builds the recommended citation as text, BibTeX, or a structured list:

``` r

cite_eavs(2024)
#> [1] "U.S. Election Assistance Commission (2025). 2024 Election Administration and Voting Survey Comprehensive Report. U.S. Election Assistance Commission, Washington, DC. https://www.eac.gov/research-and-data/studies-and-reports"
```

``` r

cat(cite_eavs(2024, style = "bibtex"))
#> @techreport{eac_eavs_2024,
#>   author    = {{U.S. Election Assistance Commission}},
#>   title     = {{2024 Election Administration and Voting Survey Comprehensive Report}},
#>   institution = {{U.S. Election Assistance Commission}},
#>   address   = {Washington, DC},
#>   year      = {2025},
#>   url       = {https://www.eac.gov/research-and-data/studies-and-reports}
#> }
```

## Managing the cache

Downloaded files live under `tools::R_user_dir("eavsr", "cache")`.
Override the location with the `EAVSR_CACHE_DIR` environment variable.

``` r

eavs_cache_dir()    # where files are stored
eavs_cache_info()   # what is currently cached
eavs_clear_cache()  # remove cached files
```

## Pairing with rurality data

EAVS county-level output pairs naturally with the
[`rurality`](https://github.com/cwimpy/rurality) package, which provides
county-level rurality classifications (RUCC, RUCA, IRR, OMB) for
rural–urban analyses of election administration.
