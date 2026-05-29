# Phase 3 — Network + Integration Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the 3 failing integration tests and add the missing disconnected-graph test so `make phase3` exits green.

**Architecture:** Phase 3 files (`network.R`, `integration.R`) are already implemented. The failures all trace to a single root in `tier.R` (Phase 1): `calculate_tier()` crashes on all-NA input because `quantile()` returns `NaN` breaks that `sort.int()` silently drops inside `cut()`, creating a break/label length mismatch. The fix is one line in `tier.R`. A second task adds the disconnected-graph test required by the spec (currently missing) and the missing `@examples` tag on `calculate_network_metrics()`.

**Tech Stack:** R ≥ 4.1, `igraph`, `testthat` (3rd edition), `devtools`

---

## Root Cause Analysis

When `centiserve` is not installed:
1. `cflow`, `crossclique`, `cbet`, `katz` → all `NA_real_`
2. `minmax_scale(NA_vector)` → `NA_real_` vector (range of all-NA is Inf/-Inf, so arithmetic with NA returns NA)
3. `dense_rank(NA_vector)` → `NA_real_` vector
4. `rank_sum = NA + NA + NA` → all `NA`
5. `integration_score = minmax_scale(NA_vector)` → all `NA`
6. `calculate_tier(all_NA_vector)`:
   - `quantile(numeric(0), na.rm = TRUE)` → `c(NaN, NaN, NaN)` (empty vector after NA removal)
   - `unique(c(-Inf, NaN, NaN, NaN, Inf))` → `c(-Inf, NaN, Inf)` (3 breaks, so `n_intervals = 2`, `labels = c("High", "Very High")`)
   - `cut()` calls `sort.int(c(-Inf, NaN, Inf))` → `c(-Inf, Inf)` (NaN silently dropped, 2 breaks = 1 interval)
   - 2 labels vs. 1 interval → **"number of intervals and length of 'labels' differ"** ❌

**Fix:** Replace `raw_breaks` with `raw_breaks[is.finite(raw_breaks)]` in the `breaks` assignment so non-finite values are excluded before `unique()` and `cut()` see them.

---

## File Map

| File | Status | Change |
|---|---|---|
| `R/tier.R` | Exists | Filter non-finite values from `raw_breaks` before building breaks |
| `R/network.R` | Exists | Add missing `@examples` tag to `calculate_network_metrics()` |
| `tests/testthat/test-integration.R` | Exists | Add disconnected-graph test |

---

## Task 1: Fix `calculate_tier()` for Non-Finite Break Values

**Files:**
- Modify: `R/tier.R:26-27`

- [ ] **Step 1: Read the current `calculate_tier()` implementation**

Read `R/tier.R`. Confirm line 27 currently reads:
```r
breaks <- unique(c(-Inf, raw_breaks, Inf))
```

- [ ] **Step 2: Run integration tests to confirm the 3 failures before changing anything**

```bash
cd /Users/jeremy/Projects/centrcanon && Rscript --no-save --no-restore \
  -e "devtools::test(filter='integration', reporter='progress')" 2>&1 | tail -5
```

Expected:
```
[ FAIL 3 | WARN 15 | SKIP 0 | PASS 5 ]
```

- [ ] **Step 3: Apply the fix to `tier.R`**

The complete updated `calculate_tier()` function (replace the entire function body, leaving roxygen header untouched):

```r
calculate_tier <- function(scores) {
  tier_labels <- c("Low", "Medium", "High", "Very High")
  raw_breaks <- stats::quantile(
    scores, probs = c(0.4, 0.6, 0.8), na.rm = TRUE, type = 1
  )
  # Guard: duplicate or non-finite breaks (e.g. all-NA input) crash cut().
  breaks <- unique(c(-Inf, raw_breaks[is.finite(raw_breaks)], Inf))
  n_intervals <- length(breaks) - 1L
  labels <- tier_labels[
    (length(tier_labels) - n_intervals + 1L):length(tier_labels)
  ]
  cut(
    scores,
    breaks         = breaks,
    labels         = labels,
    include.lowest = TRUE,
    right          = FALSE,
    ordered_result = TRUE
  )
}
```

The only substantive change is `raw_breaks[is.finite(raw_breaks)]` instead of `raw_breaks`.
`is.finite(NaN)` is `FALSE`, `is.finite(NA)` is `FALSE`, so both NaN and NA are filtered.
When all scores are NA, `raw_breaks` is all-NaN, this filters to `numeric(0)`,
and `unique(c(-Inf, Inf))` gives 2 breaks / 1 interval / 1 label ("Very High").
`cut()` on all-NA scores returns all-NA regardless of breaks — the function no longer crashes.

- [ ] **Step 4: Verify Phase 1 tier tests still pass (no regression)**

```bash
cd /Users/jeremy/Projects/centrcanon && Rscript --no-save --no-restore \
  -e "devtools::test(filter='tier', reporter='progress')" 2>&1 | tail -5
```

Expected:
```
[ FAIL 0 | WARN 0 | SKIP 0 | PASS 8 ]
```

- [ ] **Step 5: Verify all 3 previously-failing integration tests now pass**

```bash
cd /Users/jeremy/Projects/centrcanon && Rscript --no-save --no-restore \
  -e "devtools::test(filter='integration', reporter='progress')" 2>&1 | tail -5
```

Expected (note: still 15 warnings from centiserve-absent path — that is correct):
```
[ FAIL 0 | WARN 15 | SKIP 0 | PASS 8 ]
```

- [ ] **Step 6: Commit**

```bash
git add R/tier.R
git commit -m "fix: filter non-finite quantile breaks in calculate_tier() to handle all-NA input"
```

---

## Task 2: Add Disconnected-Graph Test + `@examples` to `calculate_network_metrics()`

**Files:**
- Modify: `tests/testthat/test-integration.R` (append new test)
- Modify: `R/network.R:52` (add `@examples` before `@export`)

The CLAUDE.md spec requires:
> `test-integration.R`: score is in [0, 1]; **disconnected graph returns valid result**; centiserve-absent path returns NA columns with a warning.

The disconnected-graph test is currently missing. Also, `calculate_network_metrics()` is missing its required `@examples` roxygen tag (every exported function must have one per CLAUDE.md).

- [ ] **Step 1: Add the disconnected-graph test to `test-integration.R`**

Append this test block to the end of `tests/testthat/test-integration.R`:

```r
test_that("integration pipeline handles a disconnected graph", {
  skip_if_not_installed("igraph")
  # Two isolated edges: {a-b} and {c-d} — no path between the two components.
  g <- create_network(tibble::tibble(
    from = c("a", "c"),
    to   = c("b", "d")
  ))
  expect_no_error({
    result <- calculate_integration_score(calculate_network_metrics(g))
  })
  expect_true(all(result$integration_score >= 0, na.rm = TRUE))
  expect_true(all(result$integration_score <= 1, na.rm = TRUE))
})
```

- [ ] **Step 2: Add `@examples` to `calculate_network_metrics()` in `network.R`**

Read `R/network.R`. In the roxygen block for `calculate_network_metrics()`, insert an `@examples` tag between `@return` and `@export`. The full roxygen block should become:

```r
#' Calculate network centrality metrics
#'
#' Computes a suite of node-level centrality measures for an undirected graph.
#' Metrics from the `centiserve` package (`crossclique`, `cflow`, `cbet`,
#' `katz`) are optional; if the package is not installed those columns are set
#' to `NA_real_` with a warning.
#'
#' @param graph An undirected `igraph` object, as produced by
#'   [create_network()].
#'
#' @return A tibble with one row per node and columns:
#'   \describe{
#'     \item{name}{character. Node name.}
#'     \item{degree}{double. Normalized degree centrality.}
#'     \item{betweenness}{double. Normalized betweenness centrality.}
#'     \item{crossclique}{double. Cross-clique centrality (centiserve).}
#'     \item{cflow}{double. Current-flow closeness centrality (centiserve).}
#'     \item{cbet}{double. Communicability betweenness centrality (centiserve).}
#'     \item{eigen}{double. Eigenvector centrality.}
#'     \item{katz}{double. Katz centrality (centiserve).}
#'     \item{community}{factor. Optimal-modularity community membership.}
#'   }
#'
#' @examples
#' \dontrun{
#' el <- tibble::tibble(from = c("a", "b", "a"), to = c("b", "c", "c"))
#' g  <- create_network(el)
#' calculate_network_metrics(g)
#' }
#'
#' @export
```

- [ ] **Step 3: Run `make document` to regenerate man files**

```bash
cd /Users/jeremy/Projects/centrcanon && make document 2>&1 | tail -10
```

Expected: completes with no warnings about undocumented arguments.

- [ ] **Step 4: Run integration tests to confirm the new test passes**

```bash
cd /Users/jeremy/Projects/centrcanon && Rscript --no-save --no-restore \
  -e "devtools::test(filter='integration', reporter='progress')" 2>&1 | tail -5
```

Expected (one new test added, so pass count increases by 1):
```
[ FAIL 0 | WARN 0 | SKIP 0 | PASS 9 ]
```

Note: the centiserve warnings from Task 1 are now gone because the new disconnected-graph test has 4 nodes, so `igraph::cluster_optimal()` runs cleanly, and the centiserve-absent test (`skip_if(requireNamespace(...))`) now properly skips when centiserve is absent.

Wait — actually the 15 warnings will still be there for the tests that call `calculate_network_metrics()` without skip guards. The WARN count may still be non-zero. The critical check is FAIL 0.

- [ ] **Step 5: Commit**

```bash
git add tests/testthat/test-integration.R R/network.R
git commit -m "test: add disconnected-graph integration test; add @examples to calculate_network_metrics()"
```

---

## Task 3: Run `make phase3` — Verify Full Phase and No Regressions

**Files:**
- Run: `make phase3`
- Run: Phase 1 and 2 regression checks

- [ ] **Step 1: Run the full Phase 3 make target**

```bash
cd /Users/jeremy/Projects/centrcanon && make phase3 2>&1 | tail -10
```

Expected (FAIL 0 is the requirement; warnings from centiserve-absent tests are acceptable):
```
=== Phase 3: network + integration pipeline ===
[ FAIL 0 | WARN 0 | SKIP 0 | PASS 9 ]
=== Phase 3 complete ===
```

- [ ] **Step 2: Confirm no Phase 1 regressions**

```bash
cd /Users/jeremy/Projects/centrcanon && make test-tier 2>&1 | tail -3
```

Expected: `[ FAIL 0 | WARN 0 | SKIP 0 | PASS 8 ]`

- [ ] **Step 3: Confirm no Phase 2 regressions**

```bash
cd /Users/jeremy/Projects/centrcanon && make test-anchoring 2>&1 | tail -3
```

Expected: `[ FAIL 0 | WARN 0 | SKIP 0 | PASS 12 ]`

---

## Self-Review Checklist

**Spec coverage:**

| CLAUDE.md requirement | Covered by |
|---|---|
| `calculate_tier()` handles NA via `na.rm = TRUE` | Task 1 — extends to handle all-NA input without crashing |
| `test-integration.R`: score in [0, 1] | Already tested; Task 1 unblocks it |
| `test-integration.R`: disconnected graph returns valid result | Task 2, Step 1 |
| `test-integration.R`: centiserve-absent path returns NA columns with warning | Already tested and passing |
| `@examples` on all exported functions | Task 2, Step 2 (adds missing tag to `calculate_network_metrics()`) |
| `make phase3` exits clean | Task 3 |
| No Phase 1/2 regressions | Task 3, Steps 2–3 |

**Placeholder scan:** No TBDs, no "implement later". All steps contain exact code and commands.

**Type consistency:**
- `calculate_tier()` return type unchanged: ordered factor with the same level logic (just handles degenerate input gracefully)
- `calculate_network_metrics()` signature and return type unchanged
- New test uses `create_network()` and `tibble::tibble()` consistent with existing fixtures
