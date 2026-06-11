## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

The note ("New submission") is expected for a first release.

The same note also flags the package URLs as possibly invalid (HTTP 404).
These are correct and resolve once the public repository and pkgdown site
are live at submission time:

* https://github.com/cwimpy/eavsr
* https://cwimpy.github.io/eavsr/

## Test environments

* local: macOS (aarch64), R 4.6.0
* <TODO: add before submitting, e.g.>
  * win-builder (devel and release)
  * R-hub: Windows, macOS, Ubuntu
  * GitHub Actions R-CMD-check (release, devel, oldrel)

## Notes for CRAN

* Functions that download EAVS files from the U.S. Election Assistance
  Commission perform network access. All such examples are wrapped in
  `\dontrun{}`. The test suite uses only small synthetic in-memory data
  frames and does not access the network.
* The package is not affiliated with or endorsed by the U.S. Election
  Assistance Commission; this is stated in the DESCRIPTION and
  documentation.

## Downstream dependencies

There are currently no downstream dependencies (new package).
