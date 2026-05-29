test_that("calculate_integration_score returns score in [0, 1]", {
  skip_if_not_installed("igraph")
  g      <- make_graph()
  result <- calculate_integration_score(calculate_network_metrics(g))
  expect_true(all(result$integration_score >= 0, na.rm = TRUE))
  expect_true(all(result$integration_score <= 1, na.rm = TRUE))
})

test_that("calculate_integration_score adds the expected columns", {
  skip_if_not_installed("igraph")
  g      <- make_graph()
  result <- calculate_integration_score(calculate_network_metrics(g))
  new_cols <- c(
    "betweenness_scaled", "cflow_scaled", "crossclique_scaled",
    "rank_betweenness", "rank_cflow", "rank_crossclique",
    "rank_sum", "integration_score", "tier"
  )
  expect_true(all(new_cols %in% names(result)))
})

test_that("integration_score tier is an ordered factor", {
  skip_if_not_installed("igraph")
  g      <- make_graph()
  result <- calculate_integration_score(calculate_network_metrics(g))
  expect_s3_class(result$tier, "ordered")
})

test_that("calculate_network_metrics returns finite values for all four derived metrics", {
  skip_if_not_installed("igraph")
  g       <- make_graph()
  metrics <- calculate_network_metrics(g)
  expect_true(all(is.finite(metrics$crossclique)))
  expect_true(all(is.finite(metrics$cflow)))
  expect_true(all(is.finite(metrics$cbet)))
  expect_true(all(is.finite(metrics$katz)))
})

test_that("integration pipeline handles a disconnected graph", {
  skip_if_not_installed("igraph")
  g <- make_disconnected_graph()
  expect_no_error({
    result <- calculate_integration_score(calculate_network_metrics(g))
  })
  expect_true(all(result$integration_score >= 0, na.rm = TRUE))
  expect_true(all(result$integration_score <= 1, na.rm = TRUE))
})
