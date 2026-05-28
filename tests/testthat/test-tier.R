test_that("calculate_tier returns an ordered factor", {
  result <- calculate_tier(c(0.1, 0.3, 0.5, 0.7, 0.9))
  expect_s3_class(result, "ordered")
  expect_equal(levels(result), c("Low", "Medium", "High", "Very High"))
})

test_that("calculate_tier level ordering is Low < Medium < High < Very High", {
  result <- calculate_tier(c(0.05, 0.45, 0.65, 0.95))
  expect_true(result[1] < result[2])
  expect_true(result[2] < result[3])
  expect_true(result[3] < result[4])
})

test_that("calculate_tier handles NA values without error", {
  expect_no_error(calculate_tier(c(0.1, NA, 0.5, 0.9)))
})

test_that("calculate_tier produces exactly four levels", {
  result <- calculate_tier(seq(0, 1, by = 0.1))
  expect_equal(nlevels(result), 4L)
})

test_that("calculate_tier assigns all scores to a level", {
  scores <- c(0.1, 0.3, 0.5, 0.7, 0.9)
  result <- calculate_tier(scores)
  expect_false(anyNA(result))
})
