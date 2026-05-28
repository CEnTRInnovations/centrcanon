################################################################################
# centrcanon — build targets
#
# Designed for incremental, phase-by-phase development with Claude Code.
# Run phases in order; each phase documents and tests before moving on.
#
# Usage:
#   make setup        Install all declared dependencies
#   make phase1       Utilities + tier  (utils-rank, tier)
#   make phase2       Anchoring pipeline (ca_analysis, pam_clustering, anchoring)
#   make phase3       Network + integration pipeline (network, integration)
#   make phase4       Leverage pipeline (leverage)
#   make phase5       Palettes + vignette check
#   make document     Regenerate NAMESPACE and man/ from roxygen2 tags
#   make test         Run all testthat tests
#   make test-FILE    Run a single test file, e.g. make test-tier
#   make check        Full R CMD check (run last, after all phases pass)
#   make build        Build the source tarball
#   make install      Install the package into the local R library
################################################################################

R       := Rscript --no-save --no-restore
PACKAGE := centrcanon

.PHONY: setup document test check build install \
        phase1 phase2 phase3 phase4 phase5 \
        test-tier test-anchoring test-integration test-leverage

# ── Dependency installation ────────────────────────────────────────────────────
setup:
	$(R) -e "\
	  pkgs <- c('devtools','roxygen2','testthat','tibble','dplyr','tidyr', \
	            'rlang','FactoMineR','cluster','igraph','knitr','rmarkdown'); \
	  missing <- pkgs[!pkgs %in% rownames(installed.packages())]; \
	  if (length(missing)) install.packages(missing, repos='https://cloud.r-project.org')"
	@echo "--- Optional: centiserve (not on CRAN) ---"
	@echo "    remotes::install_github('muuankarski/centiserve')"

# ── Phase 1: shared utilities ──────────────────────────────────────────────────
# Files: R/utils-rank.R, R/tier.R
# Tests: test-tier.R
phase1: document
	@echo "=== Phase 1: utilities + tier ==="
	$(R) -e "devtools::test(filter='tier', reporter='progress')"
	@echo "=== Phase 1 complete ==="

# ── Phase 2: anchoring pipeline ───────────────────────────────────────────────
# Files: R/ca_analysis.R, R/pam_clustering.R, R/anchoring.R
# Tests: test-anchoring.R
phase2: document
	@echo "=== Phase 2: anchoring pipeline ==="
	$(R) -e "devtools::test(filter='anchoring', reporter='progress')"
	@echo "=== Phase 2 complete ==="

# ── Phase 3: network + integration pipeline ───────────────────────────────────
# Files: R/network.R, R/integration.R
# Tests: test-integration.R
phase3: document
	@echo "=== Phase 3: network + integration pipeline ==="
	$(R) -e "devtools::test(filter='integration', reporter='progress')"
	@echo "=== Phase 3 complete ==="

# ── Phase 4: leverage pipeline ────────────────────────────────────────────────
# Files: R/leverage.R
# Tests: test-leverage.R
phase4: document
	@echo "=== Phase 4: leverage pipeline ==="
	$(R) -e "devtools::test(filter='leverage', reporter='progress')"
	@echo "=== Phase 4 complete ==="

# ── Phase 5: palettes + vignette ──────────────────────────────────────────────
# Files: R/palettes.R, vignettes/centr-pipeline.Rmd
phase5: document
	@echo "=== Phase 5: palettes + vignette ==="
	$(R) -e "devtools::build_vignettes()"
	@echo "=== Phase 5 complete ==="

# ── Core targets ──────────────────────────────────────────────────────────────
document:
	$(R) -e "devtools::document()"

test:
	$(R) -e "devtools::test(reporter='progress')"

test-tier:
	$(R) -e "devtools::test(filter='tier', reporter='progress')"

test-anchoring:
	$(R) -e "devtools::test(filter='anchoring', reporter='progress')"

test-integration:
	$(R) -e "devtools::test(filter='integration', reporter='progress')"

test-leverage:
	$(R) -e "devtools::test(filter='leverage', reporter='progress')"

check:
	$(R) -e "devtools::check()"

build:
	$(R) -e "devtools::build()"

install:
	$(R) -e "devtools::install()"
