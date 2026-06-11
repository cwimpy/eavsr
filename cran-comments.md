## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

The note ("New submission") is expected for a first release. The package
URLs (https://github.com/cwimpy/eavsr, https://cwimpy.github.io/eavsr/)
are live and verified with `urlchecker::url_check()`.

## Test environments

* local: macOS (aarch64), R 4.6.0
* GitHub Actions: ubuntu-latest (R release, devel, oldrel-1),
  windows-latest (R release), macos-latest (R release)
* win-builder: devel and release

## Notes for CRAN

* Functions that download EAVS files from the U.S. Election Assistance
  Commission perform network access. All such examples are wrapped in
  `\dontrun{}`. Downloads fail gracefully with an informative message if
  the remote resource is unavailable, and are cached under
  `tools::R_user_dir("eavsr", "cache")`. The test suite uses only small
  synthetic in-memory data frames and does not access the network.
* The package is not affiliated with or endorsed by the U.S. Election
  Assistance Commission; this is stated in the DESCRIPTION and
  documentation.

## Downstream dependencies

There are currently no downstream dependencies (new package).
