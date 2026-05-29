# Phase 2 — Anchoring Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the one failing test in the anchoring pipeline so `make phase2` exits green.

**Architecture:** Phase 2 is already implemented across three files (`ca_analysis.R`, `pam_clustering.R`, `anchoring.R`). Eleven of twelve tests pass. The single failure is a boundary-condition bug in `run_pam_clustering()`: `cluster::pam()` requires `k < n`, but the test passes `k = n_concepts` (e.g., k=4 for 4 concepts), triggering a hard error before `calculate_anchoring_score()` can exercise its single-member-cluster branch. The fix is a one-line clamp.

**Tech Stack:** R ≥ 4.1, `cluster::pam()`, `testthat` (3rd edition), `devtools`

---

## File Map

| File | Status | Change |
|---|---|---|
| `R/pam_clustering.R` | Exists | Clamp `k` to `min(k, nrow(coords) - 1L)` |
| `tests/testthat/test-anchoring.R` | Exists | No change needed — test is correct |

---

## Task 1: Confirm the Failure Baseline

**Files:**
- Read: `R/pam_clustering.R:23-26`
- Run: `make test-anchoring`

- [ ] **Step 1: Read the current implementation**

Open `R/pam_clustering.R`. Verify that `run_pam_clustering()` passes `k` straight
to `cluster::pam()` with no clamping:

```r
run_pam_clustering <- function(ca_result, k = 6L) {
  coords <- ca_result$col$coord[, 1:2, drop = FALSE]
  cluster::pam(coords, k = as.integer(k))
}
```

- [ ] **Step 2: Run the anchoring tests and observe the failure**

```bash
make test-anchoring
```

Expected output (failure):

```
✖ | 1       11 | anchoring
Error ('test-anchoring.R:47:3'): calculate_anchoring_score handles single-member clusters
Error in `cluster::pam(coords, k = as.integer(k))`:
  Number of clusters 'k' must be in {1,2, .., n-1}; hence n >= 2
```

The test calls `run_pam_clustering(fx$ca, k = n_concepts)` where `n_concepts = 4`
(alpha, beta, gamma, delta). PAM requires `k ≤ n - 1 = 3`, so `k = 4` is out of
range.

---

## Task 2: Fix `run_pam_clustering()` — Clamp k

**Files:**
- Modify: `R/pam_clustering.R:23-26`

`★ Insight ─────────────────────────────────────`
- `cluster::pam()` uses a strict `k < n` constraint. Clamping inside the wrapper is
  the right defense: it keeps the invariant close to the boundary where it matters
  and avoids requiring every caller to pre-validate k.
- Clamping to `nrow(coords) - 1L` (not `nrow(coords)`) is deliberate — PAM needs
  at least one cluster to have ≥ 2 members to compute medoids meaningfully.
`─────────────────────────────────────────────────`

- [ ] **Step 1: Write the failing test (already exists — confirm it describes what we want)**

The test at `tests/testthat/test-anchoring.R:42-51` is:

```r
test_that("calculate_anchoring_score handles single-member clusters", {
  skip_if_not_installed("FactoMineR")
  skip_if_not_installed("cluster")
  fx         <- make_ca_pam()
  n_concepts <- nrow(fx$ca$col$coord)
  pam_solo   <- run_pam_clustering(fx$ca, k = n_concepts)
  expect_no_error(
    calculate_anchoring_score(fx$ca, pam_solo$clustering)
  )
})
```

Intent: verify that when every cluster has exactly one member (k = n − 1 clusters,
meaning at least one cluster is a singleton), `calculate_anchoring_score()` handles
the singleton branch without error. Do NOT modify this test.

- [ ] **Step 2: Apply the fix to `run_pam_clustering()`**

Edit `R/pam_clustering.R`. Replace the function body so that `k` is clamped before
being passed to `cluster::pam()`:

```r
run_pam_clustering <- function(ca_result, k = 6L) {
  coords <- ca_result$col$coord[, 1:2, drop = FALSE]
  k      <- min(as.integer(k), nrow(coords) - 1L)
  cluster::pam(coords, k = k)
}
```

The clamp `min(k, nrow(coords) - 1L)` ensures k never equals n, which is the exact
constraint `cluster::pam()` enforces. The roxygen header (`@param`, `@return`,
`@examples`, `@export`) is already correct and does not need updating.

- [ ] **Step 3: Run the failing test in isolation to verify it now passes**

```bash
make test-anchoring
```

Expected output:

```
✔ | F W  S  OK | Context
✔ |          12 | anchoring

[ FAIL 0 | WARN 0 | SKIP 0 | PASS 12 ]
=== Phase 2 complete ===
```

All 12 tests should pass. If any test other than the fixed one now fails, investigate
before continuing.

- [ ] **Step 4: Commit**

```bash
git add R/pam_clustering.R
git commit -m "fix: clamp k in run_pam_clustering() to satisfy PAM's k < n constraint"
```

---

## Task 3: Run `make phase2` and Verify Clean Exit

**Files:**
- Run: `make document` then `make phase2`

- [ ] **Step 1: Regenerate documentation**

```bash
make document
```

Expected: no warnings about undocumented arguments or mismatched tags. The NAMESPACE
and `man/` files are already up to date since no roxygen tags changed, but always
re-run after any R file edit.

- [ ] **Step 2: Run the full Phase 2 target**

```bash
make phase2
```

Expected output:

```
=== Phase 2: anchoring pipeline ===
✔ |          12 | anchoring
[ FAIL 0 | WARN 0 | SKIP 0 | PASS 12 ]
=== Phase 2 complete ===
```

- [ ] **Step 3: Confirm no regressions in Phase 1 tests**

```bash
make test-tier
```

Expected: all tier tests still pass (no cross-phase regressions from the change).

---

## Self-Review Checklist

**Spec coverage:**

| CLAUDE.md requirement | Covered by |
|---|---|
| `run_pam_clustering(ca_result, k = 6L)` clusters on dims 1–2 | Already implemented; Task 2 preserves this |
| Default `k = 6L`; caller may override | Preserved — clamp only activates when k ≥ n |
| `calculate_anchoring_score` handles single-member clusters | Task 2, Step 2 |
| All 12 anchoring tests green | Task 2, Step 3 + Task 3 |
| `make phase2` exits clean | Task 3 |

**Placeholder scan:** No TBDs, no "implement later", no steps without code.

**Type consistency:** `k` remains integer throughout; `coords` is the same matrix object.
