test_that("calculate_leverage_score returns score in [0, 1]", {
  skip_if_not_installed("igraph")
  g      <- make_graph()
  result <- calculate_leverage_score(calculate_network_metrics(g))
  expect_true(all(result$leverage_score >= 0, na.rm = TRUE))
  expect_true(all(result$leverage_score <= 1, na.rm = TRUE))
})

test_that("node_role is a factor with all eleven levels", {
  skip_if_not_installed("igraph")
  g      <- make_graph()
  result <- calculate_leverage_score(calculate_network_metrics(g))
  expected_levels <- c(
    "Core Keystone", "Supporting Keystone",
    "Beacon", "Steward", "Aqueduct", "Hybrid",
    "Sage", "Weaver", "Messenger",
    "Leaning", "Non-Key"
  )
  expect_equal(levels(result$node_role), expected_levels)
})

test_that("leverage_score tier is an ordered factor", {
  skip_if_not_installed("igraph")
  g      <- make_graph()
  result <- calculate_leverage_score(calculate_network_metrics(g))
  expect_s3_class(result$tier, "ordered")
})

# --- classify_node_role branch coverage ---
# Uses centrcanon::: to access the internal helper directly.

test_that("classify_node_role: Core Keystone (all >= q90)", {
  q25 <- c(eigen = 0.1, cbet = 0.1, katz = 0.1)
  q75 <- c(eigen = 0.5, cbet = 0.5, katz = 0.5)
  q90 <- c(eigen = 0.8, cbet = 0.8, katz = 0.8)
  expect_equal(
    centrcanon:::classify_node_role(0.9, 0.9, 0.9, q25, q75, q90),
    "Core Keystone"
  )
})

test_that("classify_node_role: Non-Key (all <= q25)", {
  q25 <- c(eigen = 0.3, cbet = 0.3, katz = 0.3)
  q75 <- c(eigen = 0.7, cbet = 0.7, katz = 0.7)
  q90 <- c(eigen = 0.9, cbet = 0.9, katz = 0.9)
  expect_equal(
    centrcanon:::classify_node_role(0.1, 0.1, 0.1, q25, q75, q90),
    "Non-Key"
  )
})

test_that("classify_node_role: Leaning (none high, none low)", {
  q25 <- c(eigen = 0.2, cbet = 0.2, katz = 0.2)
  q75 <- c(eigen = 0.8, cbet = 0.8, katz = 0.8)
  q90 <- c(eigen = 0.9, cbet = 0.9, katz = 0.9)
  expect_equal(
    centrcanon:::classify_node_role(0.5, 0.5, 0.5, q25, q75, q90),
    "Leaning"
  )
})

test_that("classify_node_role: Sage (eigen high only)", {
  q25 <- c(eigen = 0.1, cbet = 0.1, katz = 0.1)
  q75 <- c(eigen = 0.7, cbet = 0.7, katz = 0.7)
  q90 <- c(eigen = 0.9, cbet = 0.9, katz = 0.9)
  expect_equal(
    centrcanon:::classify_node_role(0.8, 0.3, 0.3, q25, q75, q90),
    "Sage"
  )
})

test_that("classify_node_role: Weaver (cbet high only)", {
  q25 <- c(eigen = 0.1, cbet = 0.1, katz = 0.1)
  q75 <- c(eigen = 0.7, cbet = 0.7, katz = 0.7)
  q90 <- c(eigen = 0.9, cbet = 0.9, katz = 0.9)
  expect_equal(
    centrcanon:::classify_node_role(0.3, 0.8, 0.3, q25, q75, q90),
    "Weaver"
  )
})

test_that("classify_node_role: Messenger (katz high only)", {
  q25 <- c(eigen = 0.1, cbet = 0.1, katz = 0.1)
  q75 <- c(eigen = 0.7, cbet = 0.7, katz = 0.7)
  q90 <- c(eigen = 0.9, cbet = 0.9, katz = 0.9)
  expect_equal(
    centrcanon:::classify_node_role(0.3, 0.3, 0.8, q25, q75, q90),
    "Messenger"
  )
})

test_that("classify_node_role: Beacon (eigen + katz high)", {
  q25 <- c(eigen = 0.1, cbet = 0.1, katz = 0.1)
  q75 <- c(eigen = 0.7, cbet = 0.7, katz = 0.7)
  q90 <- c(eigen = 0.9, cbet = 0.9, katz = 0.9)
  expect_equal(
    centrcanon:::classify_node_role(0.8, 0.3, 0.8, q25, q75, q90),
    "Beacon"
  )
})
