test_that("prepare_contingency_table produces correct row and column counts", {
  el <- make_edgelist()
  ct <- prepare_contingency_table(el)
  # Rows = unique groups
  expect_equal(nrow(ct), length(unique(el$group)))
  # Columns = unique descriptors across from and to
  all_desc <- unique(c(el$from, el$to))
  expect_equal(ncol(ct), length(all_desc))
})

test_that("prepare_contingency_table drops zero-sum rows and columns", {
  el <- tibble::tibble(
    group = c("A", "B"),
    from  = c("x", "x"),
    to    = c("y", "y")
  )
  ct <- prepare_contingency_table(el)
  expect_true(all(rowSums(ct) > 0))
  expect_true(all(colSums(ct) > 0))
})

test_that("prepare_contingency_table ignores NA and empty descriptors", {
  el <- tibble::tibble(
    group = c("A", "A"),
    from  = c("x", NA_character_),
    to    = c("y", "")
  )
  ct <- prepare_contingency_table(el)
  expect_false("" %in% colnames(ct))
  expect_false(any(is.na(colnames(ct))))
})

test_that("calculate_anchoring_score returns score in [0, 1]", {
  skip_if_not_installed("FactoMineR")
  skip_if_not_installed("cluster")
  fx     <- make_ca_pam()
  scores <- calculate_anchoring_score(fx$ca, fx$pam$clustering)
  expect_true(all(scores$anchoring_score >= 0))
  expect_true(all(scores$anchoring_score <= 1))
})

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

test_that("anchoring_category levels are correct and ordered", {
  skip_if_not_installed("FactoMineR")
  skip_if_not_installed("cluster")
  fx     <- make_ca_pam()
  scores <- calculate_anchoring_score(fx$ca, fx$pam$clustering)
  expect_s3_class(scores$anchoring_category, "ordered")
  expect_equal(
    levels(scores$anchoring_category),
    c("Peripheral Element", "Supporting Element",
      "Secondary Anchor", "Primary Anchor")
  )
})

test_that("tier column is an ordered factor", {
  skip_if_not_installed("FactoMineR")
  skip_if_not_installed("cluster")
  fx     <- make_ca_pam()
  scores <- calculate_anchoring_score(fx$ca, fx$pam$clustering)
  expect_s3_class(scores$tier, "ordered")
})
