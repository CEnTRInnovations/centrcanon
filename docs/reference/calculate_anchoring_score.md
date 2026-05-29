# Calculate conceptual anchoring scores

Combines three sub-scores — salience, dimensional definition, and
cluster exemplar proximity — into a normalized anchoring score for each
concept descriptor identified in a correspondence analysis.

## Usage

``` r
calculate_anchoring_score(ca_result, cluster_assignments)
```

## Arguments

- ca_result:

  A `CA` object from
  [`run_correspondence_analysis()`](https://centrcanon.github.io/centrcanon/reference/run_correspondence_analysis.md).

- cluster_assignments:

  An integer vector of PAM cluster IDs, one per concept (i.e.
  `pam_result$clustering`).

## Value

A tibble with one row per concept and columns:

- concept:

  character. Concept / descriptor name.

- cluster:

  integer. PAM cluster ID.

- salience_raw:

  double. CA column inertia.

- dimensional_raw:

  double. Sum of contributions to CA dims 1 & 2.

- cluster_exemplar_raw:

  double. Proximity-weighted cos2 score.

- rank_salience:

  integer. Dense rank of `salience_raw`.

- rank_dimensional:

  integer. Dense rank of `dimensional_raw`.

- rank_exemplar:

  integer. Dense rank of `cluster_exemplar_raw`.

- combined_rank:

  double. Mean of the three ranks.

- anchoring_score:

  double. Normalized to \[0, 1\].

- percentile_rank:

  double. 0–100.

- anchoring_category:

  ordered factor.
  `"Peripheral Element" < "Supporting Element" < "Secondary Anchor" < "Primary Anchor"`.

- tier:

  ordered factor. From
  [`calculate_tier()`](https://centrcanon.github.io/centrcanon/reference/calculate_tier.md).

## Details

Sub-scores are equally weighted. All three are dense-ranked, summed, and
min-max normalized to produce `anchoring_score`.

## Examples

``` r
if (FALSE) { # \dontrun{
ct  <- prepare_contingency_table(edgelist)
ca  <- run_correspondence_analysis(ct)
pam <- run_pam_clustering(ca)
calculate_anchoring_score(ca, pam$clustering)
} # }
```
