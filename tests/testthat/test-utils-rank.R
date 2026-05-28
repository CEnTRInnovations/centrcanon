test_that("minmax_scale scales to [0, 1]", {
  result <- minmax_scale(c(1, 2, 3, 4, 5))
  expect_equal(min(result), 0)
  expect_equal(max(result), 1)
})

test_that("minmax_scale returns 0.5 for constant input", {
  result <- minmax_scale(rep(3, 5))
  expect_equal(result, rep(0.5, 5))
})

test_that("minmax_scale output length matches input length", {
  x <- c(10, 20, 30)
  expect_length(minmax_scale(x), 3L)
})

test_that("calculate_entropy returns 1 for uniform distribution", {
  result <- calculate_entropy(c(1, 1, 1, 1))
  expect_equal(result, 1, tolerance = 1e-10)
})

test_that("calculate_entropy returns 0 for single-element input", {
  expect_equal(calculate_entropy(42), 0)
})

test_that("calculate_entropy returns value in [0, 1]", {
  result <- calculate_entropy(c(10, 2, 1))
  expect_gte(result, 0)
  expect_lte(result, 1)
})

test_that("dense_rank_normalize output is in [0, 1]", {
  result <- dense_rank_normalize(c(3, 1, 4, 1, 5))
  expect_gte(min(result), 0)
  expect_lte(max(result), 1)
})

test_that("dense_rank_normalize gives tied values the same rank", {
  result <- dense_rank_normalize(c(1, 1, 2))
  expect_equal(result[1], result[2])
})
