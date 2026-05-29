# The CEnTR\*MAP Analytical Pipeline

## Overview

`centrcanon` provides the analytical engine for **CEnTR\*MAP**, a
workflow that supports institutions and communities in collaboratively
constructing a **local definition of community-engaged research
(CEnR)**.

The package does not produce a definition. It produces scores that
surface the underlying structure of how a community of scholars talks
about their work — identifying which terms are most central, best
connected, and most influential. Those scores guide practitioners in
organizing and prioritizing terms into a locally-grounded,
community-constructed definition.

The three analytical pipelines each answer a different question about
that structure:

| Pipeline | Question | Output |
|----|----|----|
| **Anchoring** | Which concepts are most central to how this community describes CEnR? | `anchoring_score` |
| **Integration** | Which concepts serve as structural connectors across the network? | `integration_score` |
| **Leverage** | Which concepts hold the most influence in shaping the field? | `leverage_score` |

All three pipelines share a single prepared input: an **edgelist**
tibble.

------------------------------------------------------------------------

## Data preparation

The source CSV uses columns `group`, `hex1`, and `hex2`, where `hex1`
and `hex2` are the two concept descriptor codes associated with each
response. Rename those columns to `from` and `to` before passing to any
package function. `centrcanon` does not own this step.

``` r

library(readr)
library(dplyr)
library(centrcanon)

raw <- read_csv("path/to/data.csv")

edgelist <- raw |>
  rename(from = hex1, to = hex2) |>          # rename raw columns
  select(group, from, to) |>
  filter(!is.na(from), !is.na(to))
```

> **Note on reproducibility:** `centrcanon` never calls
> [`set.seed()`](https://rdrr.io/r/base/Random.html). If you need
> reproducible PAM or community-detection results, call
> [`set.seed()`](https://rdrr.io/r/base/Random.html) in your own script
> before running the pipeline.

------------------------------------------------------------------------

## Pipeline 1 — Anchoring

The anchoring pipeline uses correspondence analysis (CA) to find the
dimensional structure of the concept space, then PAM clustering to group
concepts, and finally scores each concept on salience, dimensional
definition, and cluster exemplar proximity.

``` r

# Step 0: build the group × descriptor contingency table
ct <- prepare_contingency_table(edgelist)

# Step 1: correspondence analysis
ca <- run_correspondence_analysis(ct)

# Step 2: PAM clustering on CA dimensions 1–2 (default k = 6)
pam <- run_pam_clustering(ca, k = 6L)

# Step 3: anchoring scores
anchoring <- calculate_anchoring_score(ca, pam$clustering)
anchoring
```

Cluster IDs in `anchoring$cluster` are integers. Human-readable labels
(e.g. “Methodological Foundations”) are the caller’s responsibility.

------------------------------------------------------------------------

## Pipeline 2 — Integration

The integration pipeline treats concept pairs as network edges and
scores each node on its structural role as a connector within the
network.

``` r

# Build the network
g <- create_network(edgelist)

# Compute centrality metrics
metrics <- calculate_network_metrics(g)

# Integration scores
integration <- calculate_integration_score(metrics)
integration
```

`crossclique`, `cflow`, `cbet`, and `katz` require the `centiserve`
package (not on CRAN). If it is not installed, those columns are `NA`
with a warning. Install it with:

``` r

remotes::install_github("muuankarski/centiserve")
```

------------------------------------------------------------------------

## Pipeline 3 — Leverage

The leverage pipeline classifies each node into one of eleven roles
based on how its eigenvector, communicability betweenness, and Katz
centrality compare to the rest of the network.

``` r

leverage <- calculate_leverage_score(metrics)
leverage |> select(name, node_role, leverage_score, tier)
```

Role levels (ordered for reference): `"Core Keystone"`,
`"Supporting Keystone"`, `"Beacon"`, `"Steward"`, `"Aqueduct"`,
`"Hybrid"`, `"Sage"`, `"Weaver"`, `"Messenger"`, `"Leaning"`,
`"Non-Key"`.

------------------------------------------------------------------------

## Color palettes

Two palettes are provided for use in visualizations (gradient helpers
and ggplot2 theme code belong in the calling application):

``` r

centr_earthtone_palette()  # 8-color earthtone palette
centr_layer_palette()      # 3-color palette: anchoring / integration / leverage
```
