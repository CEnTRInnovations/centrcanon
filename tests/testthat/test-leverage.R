test_that("calculate_leverage_score returns leverage_score in [0, 1]", {
  skip_if_not_installed("igraph")
  g      <- make_graph()
  result <- calculate_leverage_score(calculate_network_metrics(g))
  expect_true(all(result$leverage_score >= 0, na.rm = TRUE))
  expect_true(all(result$leverage_score <= 1, na.rm = TRUE))
})

test_that("calculate_leverage_score adds eigen_centrality column in [0, 1]", {
  skip_if_not_installed("igraph")
  g      <- make_graph()
  result <- calculate_leverage_score(calculate_network_metrics(g))
  expect_true("eigen_centrality" %in% names(result))
  expect_true(all(result$eigen_centrality >= 0, na.rm = TRUE))
  expect_true(all(result$eigen_centrality <= 1, na.rm = TRUE))
})

test_that("leverage_quadrant is a factor with exactly four levels", {
  skip_if_not_installed("igraph")
  g      <- make_graph()
  result <- calculate_leverage_score(calculate_network_metrics(g))
  expected_levels <- c(
    "Shared Foundation", "Connective Concept",
    "Community Voice", "Emerging Vocabulary"
  )
  expect_s3_class(result$leverage_quadrant, "factor")
  expect_equal(levels(result$leverage_quadrant), expected_levels)
})

test_that("leverage_score tier is an ordered factor", {
  skip_if_not_installed("igraph")
  g      <- make_graph()
  result <- calculate_leverage_score(calculate_network_metrics(g))
  expect_s3_class(result$tier, "ordered")
})

test_that("node_role column is NOT present (old API removed)", {
  skip_if_not_installed("igraph")
  g      <- make_graph()
  result <- calculate_leverage_score(calculate_network_metrics(g))
  expect_false("node_role" %in% names(result))
})

# --- classify_leverage_quadrant branch coverage ---
# Uses centrcanon::: to access the internal helper directly.
# Thresholds: degree_median = 0.5, eigen_median = 0.5

test_that("classify_leverage_quadrant: Shared Foundation (high degree, high eigen)", {
  result <- centrcanon:::classify_leverage_quadrant(
    degree = 0.8, eigen_centrality = 0.8,
    degree_median = 0.5, eigen_median = 0.5
  )
  expect_equal(result, "Shared Foundation")
})

test_that("classify_leverage_quadrant: Connective Concept (low degree, high eigen)", {
  result <- centrcanon:::classify_leverage_quadrant(
    degree = 0.2, eigen_centrality = 0.8,
    degree_median = 0.5, eigen_median = 0.5
  )
  expect_equal(result, "Connective Concept")
})

test_that("classify_leverage_quadrant: Community Voice (high degree, low eigen)", {
  result <- centrcanon:::classify_leverage_quadrant(
    degree = 0.8, eigen_centrality = 0.2,
    degree_median = 0.5, eigen_median = 0.5
  )
  expect_equal(result, "Community Voice")
})

test_that("classify_leverage_quadrant: Emerging Vocabulary (low degree, low eigen)", {
  result <- centrcanon:::classify_leverage_quadrant(
    degree = 0.2, eigen_centrality = 0.2,
    degree_median = 0.5, eigen_median = 0.5
  )
  expect_equal(result, "Emerging Vocabulary")
})

test_that("classify_leverage_quadrant: at-median boundary assigns to high quadrants", {
  # A node at exactly the median on both axes: degree >= median AND eigen >= median
  # -> Shared Foundation
  result <- centrcanon:::classify_leverage_quadrant(
    degree = 0.5, eigen_centrality = 0.5,
    degree_median = 0.5, eigen_median = 0.5
  )
  expect_equal(result, "Shared Foundation")
})

test_that("classify_leverage_quadrant: vectorized over multiple nodes", {
  result <- centrcanon:::classify_leverage_quadrant(
    degree           = c(0.8, 0.2, 0.8, 0.2),
    eigen_centrality = c(0.8, 0.8, 0.2, 0.2),
    degree_median    = 0.5,
    eigen_median     = 0.5
  )
  expect_equal(result, c(
    "Shared Foundation", "Connective Concept",
    "Community Voice", "Emerging Vocabulary"
  ))
})
