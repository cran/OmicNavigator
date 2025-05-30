# Test UpSet endpoints

# Setup ------------------------------------------------------------------------

source("tinytestSettings.R")
using(ttdo)

library(OmicNavigator)

testStudyName <- "ABC"
testStudyObj <- OmicNavigator:::testStudy(
  name = testStudyName,
  version = "0.3",
  nFeatures = 1000
)
testStudyObj <- addPlots(testStudyObj, OmicNavigator:::testPlots())
testModelName <- names(testStudyObj[["models"]])[1]
testTestsAll <- names(testStudyObj[["tests"]][[1]])
testTestName <- testTestsAll[1]
testAnnotationName <- names(testStudyObj[["annotations"]])[1]

tmplib <- tempfile()
dir.create(tmplib)
libOrig <- .libPaths()
.libPaths(c(tmplib, libOrig))
suppressMessages(installStudy(testStudyObj))

# getResultsIntersection -------------------------------------------------------

resultsIntersection <- getResultsIntersection(
  study = testStudyObj,
  modelID = testModelName,
  anchor = testTestName,
  mustTests = testTestsAll,
  notTests = c(),
  sigValue = .5,
  operator = "<",
  column = "p_val"
)

expect_true_xl(
  nrow(resultsIntersection) > 0
)

expect_true_xl(
  all(resultsIntersection[["p_val"]] < 0.5)
)

resultsIntersection <- getResultsIntersection(
  study = testStudyObj,
  modelID = testModelName,
  anchor = testTestName,
  mustTests = testTestsAll,
  notTests = c(),
  sigValue = 1.2,
  operator = ">",
  column = "beta"
)

expect_true_xl(
  nrow(resultsIntersection) > 0
)

expect_true_xl(
  all(resultsIntersection[["beta"]] > 1.2)
)

resultsIntersection <- getResultsIntersection(
  study = testStudyObj,
  modelID = testModelName,
  anchor = testTestName,
  mustTests = testTestsAll,
  notTests = c(),
  sigValue = c(.5, 1.2),
  operator = c("<", ">"),
  column = c("p_val", "beta")
)

expect_true_xl(
  nrow(resultsIntersection) > 0
)

expect_true_xl(
  all(resultsIntersection[["p_val"]] < 0.5)
)

expect_true_xl(
  all(resultsIntersection[["beta"]] > 1.2)
)

# notTests with a single filter
resultsIntersection <- getResultsIntersection(
  study = testStudyObj,
  modelID = testModelName,
  anchor = testTestName,
  mustTests = c(),
  notTests = testTestsAll[2],
  sigValue = .05,
  operator = "<",
  column = "p_val"
)

expect_true_xl(
  nrow(resultsIntersection) > 0
)

expect_true_xl(
  all(resultsIntersection[["p_val"]] < 0.05)
)

notTestsTable <- testStudyObj[["results"]][[testModelName]][[testTestsAll[2]]]
notTestsTableIntersected <- notTestsTable[notTestsTable[["customID"]] %in%
                                            resultsIntersection[["customID"]], ]
expect_true_xl(
  all(notTestsTableIntersected[["p_val"]] >= 0.05),
  info = "notTests features have the opposite of the applied filter"
)

# notTests with multiple filters
resultsIntersection <- getResultsIntersection(
  study = testStudyObj,
  modelID = testModelName,
  anchor = testTestName,
  mustTests = c(),
  notTests = testTestsAll[2],
  sigValue = c(0.05, 1.2),
  operator = c("<", ">"),
  column = c("p_val", "beta")
)

expect_true_xl(
  nrow(resultsIntersection) > 0
)

expect_true_xl(
  all(resultsIntersection[["p_val"]] < 0.05)
)

expect_true_xl(
  all(resultsIntersection[["beta"]] > 1.2)
)

notTestsTable <- testStudyObj[["results"]][[testModelName]][[testTestsAll[2]]]
notTestsTableIntersected <- notTestsTable[notTestsTable[["customID"]] %in%
                                            resultsIntersection[["customID"]], ]

expect_true_xl(
  all(notTestsTableIntersected[["p_val"]] >= 0.05),
  info = "notTests features included in the intersection results have the opposite of all the applied filters"
)

expect_true_xl(
  all(notTestsTableIntersected[["beta"]] <= 1.2),
  info = "notTests features included in the intersection results have the opposite of all the applied filters"
)

# notTests with multiple filters - edge case where notTest passes one but not
# both filters. In order to be test this very explicitly, I artificially create
# the situation. Have to make sure the edge case feature passes the anchor and
# then only passes one of the two filters in the notTest.
testStudyObjEdge <- testStudyObj
# Sort the results table first to be able to select by index
t1order <- order(testStudyObjEdge[["results"]][[testModelName]][[testTestsAll[1]]][[1]])
t2order <- order(testStudyObjEdge[["results"]][[testModelName]][[testTestsAll[2]]][[1]])
testStudyObjEdge[["results"]][[testModelName]][[testTestsAll[1]]] <-
  testStudyObjEdge[["results"]][[testModelName]][[testTestsAll[1]]][t1order, ]
testStudyObjEdge[["results"]][[testModelName]][[testTestsAll[2]]] <-
  testStudyObjEdge[["results"]][[testModelName]][[testTestsAll[2]]][t2order, ]
stopifnot(identical(
  testStudyObjEdge[["results"]][[testModelName]][[testTestsAll[1]]][, 1],
  testStudyObjEdge[["results"]][[testModelName]][[testTestsAll[2]]][, 1]
))
featuresToRemove <- testStudyObjEdge[["results"]][[testModelName]][[testTestsAll[1]]][1:2, 1]
# They both have to pass the filters in the anchor test
testStudyObjEdge[["results"]][[testModelName]][[testTestsAll[1]]][1:2, "p_val"] <- 0.01
testStudyObjEdge[["results"]][[testModelName]][[testTestsAll[1]]][1:2, "beta"] <- 2
# In notTest, first feature passes p_val but not beta
testStudyObjEdge[["results"]][[testModelName]][[testTestsAll[2]]][1, "p_val"] <- 0.049
testStudyObjEdge[["results"]][[testModelName]][[testTestsAll[2]]][1, "beta"] <- 1.1
# # In notTest, second feature passes beta but not p_val
testStudyObjEdge[["results"]][[testModelName]][[testTestsAll[2]]][2, "p_val"] <- 0.051
testStudyObjEdge[["results"]][[testModelName]][[testTestsAll[2]]][2, "beta"] <- 1.3

resultsIntersection <- getResultsIntersection(
  study = testStudyObjEdge,
  modelID = testModelName,
  anchor = testTestName,
  mustTests = c(),
  notTests = testTestsAll[2],
  sigValue = c(0.05, 1.2),
  operator = c("<", ">"),
  column = c("p_val", "beta")
)

expect_true_xl(
  nrow(resultsIntersection) > 0
)

expect_true_xl(
  all(resultsIntersection[["p_val"]] < 0.05)
)

expect_true_xl(
  all(resultsIntersection[["beta"]] > 1.2)
)

notTestsTable <- testStudyObj[["results"]][[testModelName]][[testTestsAll[2]]]
notTestsTableIntersected <- notTestsTable[notTestsTable[["customID"]] %in%
                                            resultsIntersection[["customID"]], ]

expect_true_xl(
  all(notTestsTableIntersected[["p_val"]] >= 0.05),
  info = "notTests features included in the intersection results have the opposite of all the applied filters"
)

expect_true_xl(
  all(notTestsTableIntersected[["beta"]] <= 1.2),
  info = "notTests features included in the intersection results have the opposite of all the applied filters"
)

expect_false_xl(
  any(featuresToRemove %in% resultsIntersection[["customID"]])
)

# Confirm it works when there is only one test per model
testStudyObjSingle <- testStudyObj
testStudyObjSingle[["results"]][["model_03"]] <-
  testStudyObjSingle[["results"]][["model_03"]][1]

resultsIntersection <- getResultsIntersection(
  study = testStudyObjSingle,
  modelID = "model_03",
  anchor = testTestName,
  mustTests = testTestName,
  notTests = c(),
  sigValue = .5,
  operator = "<",
  column = "p_val"
)

expect_true_xl(
  nrow(resultsIntersection) > 0
)

expect_identical_xl(
  unique(resultsIntersection[, "Set_Membership"]),
  testTestName
)

resultsIntersection <- getResultsIntersection(
  study = testStudyName,
  modelID = testModelName,
  anchor = testTestName,
  mustTests = testTestsAll,
  notTests = c(),
  sigValue = c(.5, 1.2),
  operator = c("<", ">"),
  column = c("p_val", "beta")
)

expect_true_xl(
  nrow(resultsIntersection) > 0
)

expect_true_xl(
  inherits(resultsIntersection, "data.frame")
)

resultsTable <- getResultsTable(
  study = testStudyName,
  modelID = testModelName,
  testID = testTestName
)

# getResultsIntersection() should add the column Set_Membership between the
# feature metadata variable columns and the results columns
expect_identical_xl(
  colnames(resultsIntersection),
  c(
    colnames(getFeatures(testStudyName, modelID = testModelName)),
    "Set_Membership",
    colnames(getResults(testStudyName, modelID = testModelName, testID = testTestName))[-1]
  )
)

# getResultsIntersection() should return filtered data in the same order that it
# is received.
resultsIntersection <- getResultsIntersection(
  study = testStudyName,
  modelID = testModelName,
  anchor = testTestName,
  mustTests = c(),
  notTests = c(),
  sigValue = .5,
  operator = "<",
  column = "p_val"
)

resultsTable <- getResultsTable(
  study = testStudyName,
  modelID = testModelName,
  testID = testTestName
)
resultsFiltered <- resultsTable[resultsTable[["p_val"]] < 0.5, ]

expect_identical_xl(
  resultsIntersection[[1]],
  resultsFiltered[[1]],
  info = "getResultsIntersection() should not reorder the featureIDs"
)

# Multiple filters should be combined as AND gates. The tests below compare the
# results of an intersection with 2 filters with the results from the 2 filters
# applied separately.

# Multiple filters, only anchor testID
resultsIntersectionMultiple <- getResultsIntersection(
  study = testStudyName,
  modelID = testModelName,
  anchor = testTestName,
  mustTests = c(),
  notTests = c(),
  sigValue = c(.05, 1.2),
  operator = c("<", ">"),
  column = c("p_val", "beta")
)

resultsIntersectionFilter1 <- getResultsIntersection(
  study = testStudyName,
  modelID = testModelName,
  anchor = testTestName,
  mustTests = c(),
  notTests = c(),
  sigValue = c(.05),
  operator = c("<"),
  column = c("p_val")
)

resultsIntersectionFilter2 <- getResultsIntersection(
  study = testStudyName,
  modelID = testModelName,
  anchor = testTestName,
  mustTests = c(),
  notTests = c(),
  sigValue = c(1.2),
  operator = c(">"),
  column = c("beta")
)

expect_identical_xl(
  sort(resultsIntersectionMultiple[["customID"]]),
  sort(intersect(resultsIntersectionFilter1[["customID"]],
                 resultsIntersectionFilter2[["customID"]])),
  info = "Multiple filters with only anchor testID"
)

# Multiple filters, mustTests
resultsIntersectionMultiple <- getResultsIntersection(
  study = testStudyName,
  modelID = testModelName,
  anchor = testTestName,
  mustTests = testTestsAll[2],
  notTests = c(),
  sigValue = c(.05, 1.2),
  operator = c("<", ">"),
  column = c("p_val", "beta")
)

resultsIntersectionFilter1 <- getResultsIntersection(
  study = testStudyName,
  modelID = testModelName,
  anchor = testTestName,
  mustTests = testTestsAll[2],
  notTests = c(),
  sigValue = c(.05),
  operator = c("<"),
  column = c("p_val")
)

resultsIntersectionFilter2 <- getResultsIntersection(
  study = testStudyName,
  modelID = testModelName,
  anchor = testTestName,
  mustTests = testTestsAll[2],
  notTests = c(),
  sigValue = c(1.2),
  operator = c(">"),
  column = c("beta")
)

expect_identical_xl(
  sort(resultsIntersectionMultiple[["customID"]]),
  sort(intersect(resultsIntersectionFilter1[["customID"]],
                 resultsIntersectionFilter2[["customID"]])),
  info = "Multiple filters with mustTests"
)

# Multiple filters, notTests
resultsIntersectionMultiple <- getResultsIntersection(
  study = testStudyName,
  modelID = testModelName,
  anchor = testTestName,
  mustTests = c(),
  notTests = testTestsAll[2],
  sigValue = c(.05, 1.2),
  operator = c("<", ">"),
  column = c("p_val", "beta")
)

resultsIntersectionFilter1 <- getResultsIntersection(
  study = testStudyName,
  modelID = testModelName,
  anchor = testTestName,
  mustTests = c(),
  notTests = testTestsAll[2],
  sigValue = c(.05),
  operator = c("<"),
  column = c("p_val")
)

resultsIntersectionFilter2 <- getResultsIntersection(
  study = testStudyName,
  modelID = testModelName,
  anchor = testTestName,
  mustTests = c(),
  notTests = testTestsAll[2],
  sigValue = c(1.2),
  operator = c(">"),
  column = c("beta")
)

expect_identical_xl(
  sort(resultsIntersectionMultiple[["customID"]]),
  sort(intersect(resultsIntersectionFilter1[["customID"]],
                 resultsIntersectionFilter2[["customID"]])),
  info = "Multiple filters with notTests"
)

# getEnrichmentsIntersection ---------------------------------------------------

enrichmentsIntersection <- getEnrichmentsIntersection(
  study = testStudyObj,
  modelID = testModelName,
  annotationID = testAnnotationName,
  mustTests = testTestsAll,
  notTests = c(),
  sigValue = .05,
  operator = "<",
  type = "nominal"
)

expect_true_xl(
  nrow(enrichmentsIntersection) > 0
)

for (i in seq_along(testTestsAll)) {
  expect_true_xl(
    all(enrichmentsIntersection[[testTestsAll[i]]] < 0.05)
  )
}

enrichmentsIntersection <- getEnrichmentsIntersection(
  study = testStudyObj,
  modelID = testModelName,
  annotationID = testAnnotationName,
  mustTests = testTestsAll,
  notTests = c(),
  sigValue = c(.05, .02),
  operator = c("<", ">"),
  type = "nominal"
)

expect_true_xl(
  nrow(enrichmentsIntersection) > 0
)

for (i in seq_along(testTestsAll)) {
  expect_true_xl(
    all(enrichmentsIntersection[[testTestsAll[i]]] < 0.05)
  )
  expect_true_xl(
    all(enrichmentsIntersection[[testTestsAll[i]]] > 0.02)
  )
}

enrichmentsIntersection <- getEnrichmentsIntersection(
  study = testStudyName,
  modelID = testModelName,
  annotationID = testAnnotationName,
  mustTests = testTestsAll,
  notTests = c(),
  sigValue = c(.05, .02),
  operator = c("<", ">"),
  type = "adjusted"
)

expect_true_xl(
  nrow(enrichmentsIntersection) > 0
)

for (i in seq_along(testTestsAll)) {
  expect_true_xl(
    all(enrichmentsIntersection[[testTestsAll[i]]] < 0.05)
  )
  expect_true_xl(
    all(enrichmentsIntersection[[testTestsAll[i]]] > 0.02)
  )
}

expect_true_xl(
  inherits(enrichmentsIntersection, "data.frame")
)

expect_error_xl(
  enrichmentsIntersection <- getEnrichmentsIntersection(
    study = testStudyName,
    modelID = testModelName,
    annotationID = testAnnotationName,
    mustTests = testTestsAll,
    notTests = c(),
    sigValue = c(.05, .02),
    operator = c("<", ">"),
    type = "wrong"
  ),
  "wrong"
)

# getEnrichmentsIntersection() should return filtered data in the same order
# that it is received.
enrichmentsIntersection <- getEnrichmentsIntersection(
  study = testStudyName,
  modelID = testModelName,
  annotationID = testAnnotationName,
  mustTests = testTestName,
  notTests = c(),
  sigValue = c(.05),
  operator = c("<"),
  type = "nominal"
)

enrichmentsTable <- getEnrichmentsTable(
  study = testStudyName,
  modelID = testModelName,
  annotationID = testAnnotationName
)

enrichmentsFiltered <- enrichmentsTable[enrichmentsTable[[testTestName]] < 0.05, ]

expect_identical_xl(
  enrichmentsIntersection[, 1],
  enrichmentsFiltered[, 1],
  info = "getEnrichmentsIntersection() should not reorder the termIDs"
)

# getResultsUpset --------------------------------------------------------------

# getResultsUpset() uses data.table internally. Confirm it doesn't modify the
# existing object.
resultsUpset <- getResultsUpset(
  study = testStudyObj,
  modelID = testModelName,
  sigValue = .5,
  operator = "<",
  column = "p_val"
)

expect_identical_xl(
  class(testStudyObj[["results"]][[1]][[1]]),
  "data.frame",
  info = "Internal data.table use should not modify existing object"
)

resultsUpsetLegacy <- getResultsUpset(
  study = testStudyName,
  modelID = testModelName,
  sigValue = .5,
  operator = "<",
  column = "p_val",
  legacy = TRUE
)

# Should have the same intersection sizes. The legacy data has the featureID in
# the first column, but not the new data, so refer to the columns by name.
expect_equal_xl(
  sum(resultsUpset[["New_data"]][["test_01"]]),
  sum(resultsUpsetLegacy[["New_data"]][["test_01"]])
)

expect_equal_xl(
  sum(resultsUpset[["New_data"]][["test_02"]]),
  sum(resultsUpsetLegacy[["New_data"]][["test_02"]])
)

expect_equal_xl(
  sum(resultsUpset[["New_data"]][["test_01"]] & resultsUpset[["New_data"]][["test_02"]]),
  sum(resultsUpsetLegacy[["New_data"]][["test_01"]] & resultsUpsetLegacy[["New_data"]][["test_02"]])
)

# More than one filter
resultsUpsetTwo <- getResultsUpset(
  study = testStudyName,
  modelID = testModelName,
  sigValue = c(.5, 1),
  operator = c("<", ">"),
  column = c("p_val", "beta")
)

resultsUpsetTwoLegacy <- getResultsUpset(
  study = testStudyName,
  modelID = testModelName,
  sigValue = c(.5, 1),
  operator = c("<", ">"),
  column = c("p_val", "beta"),
  legacy = TRUE
)

expect_equal_xl(
  sum(resultsUpsetTwo[["New_data"]][["test_01"]]),
  sum(resultsUpsetTwoLegacy[["New_data"]][["test_01"]])
)

expect_equal_xl(
  sum(resultsUpsetTwo[["New_data"]][["test_02"]]),
  sum(resultsUpsetTwoLegacy[["New_data"]][["test_02"]])
)

expect_equal_xl(
  sum(resultsUpsetTwo[["New_data"]][["test_01"]] & resultsUpsetTwo[["New_data"]][["test_01"]]),
  sum(resultsUpsetTwoLegacy[["New_data"]][["test_01"]] & resultsUpsetTwoLegacy[["New_data"]][["test_01"]])
)

# Expect error when filters remove all features. The error message is displayed
# to the user during an interactive session with the app.
expect_error_xl(
  getResultsUpset(
    study = testStudyName,
    modelID = testModelName,
    sigValue = c(0, 0),
    operator = c("<", ">"),
    column = c("beta", "beta")
  ),
  "There were no features remaining after applying the filters."
)

# Results table with differing number of features
testStudyObjDiffFeatures <- testStudyObj
testStudyObjDiffFeatures[["results"]][[1]][[1]] <-
  testStudyObjDiffFeatures[["results"]][[1]][[1]][-1, ]

resultsUpsetDiffFeatures <- getResultsUpset(
  study = testStudyObjDiffFeatures,
  modelID = testModelName,
  sigValue = .5,
  operator = "<",
  column = "p_val"
)

expect_error_xl(
  getResultsUpset(
    study = testStudyObjDiffFeatures,
    modelID = testModelName,
    sigValue = .5,
    operator = "<",
    column = "p_val",
    legacy = TRUE
  )
)

# Filters using absolute values
resultsUpsetAbs <- getResultsUpset(
  study = testStudyName,
  modelID = testModelName,
  sigValue = c(.5),
  operator = c("|<|"),
  column = c("beta")
)

resultsUpsetAbsLegacy <- getResultsUpset(
  study = testStudyName,
  modelID = testModelName,
  sigValue = c(.5),
  operator = c("|<|"),
  column = c("beta"),
  legacy = TRUE
)

expect_equal_xl(
  sum(resultsUpsetAbs[["New_data"]][["test_01"]]),
  sum(resultsUpsetAbsLegacy[["New_data"]][["test_01"]])
)

expect_equal_xl(
  sum(resultsUpsetAbs[["New_data"]][["test_02"]]),
  sum(resultsUpsetAbsLegacy[["New_data"]][["test_02"]])
)

expect_equal_xl(
  sum(resultsUpsetAbs[["New_data"]][["test_01"]] & resultsUpsetAbs[["New_data"]][["test_01"]]),
  sum(resultsUpsetAbsLegacy[["New_data"]][["test_01"]] & resultsUpsetAbsLegacy[["New_data"]][["test_01"]])
)

resultsUpsetAbsTwo <- getResultsUpset(
  study = testStudyName,
  modelID = testModelName,
  sigValue = c(.5, 1),
  operator = c("<", "|>|"),
  column = c("p_val", "beta")
)

resultsUpsetAbsTwoLegacy <- getResultsUpset(
  study = testStudyName,
  modelID = testModelName,
  sigValue = c(.5, 1),
  operator = c("<", "|>|"),
  column = c("p_val", "beta"),
  legacy = TRUE
)

expect_equal_xl(
  sum(resultsUpsetAbsTwo[["New_data"]][["test_01"]]),
  sum(resultsUpsetAbsTwoLegacy[["New_data"]][["test_01"]])
)

expect_equal_xl(
  sum(resultsUpsetAbsTwo[["New_data"]][["test_02"]]),
  sum(resultsUpsetAbsTwoLegacy[["New_data"]][["test_02"]])
)

expect_equal_xl(
  sum(resultsUpsetAbsTwo[["New_data"]][["test_01"]] & resultsUpsetAbsTwo[["New_data"]][["test_01"]]),
  sum(resultsUpsetAbsTwoLegacy[["New_data"]][["test_01"]] & resultsUpsetAbsTwoLegacy[["New_data"]][["test_01"]])
)


# getEnrichmentsUpset ----------------------------------------------------------

enrichmentsUpset <- getEnrichmentsUpset(
  study = testStudyObj,
  modelID = testModelName,
  annotationID = testAnnotationName,
  sigValue = .03,
  operator = "<",
  type = "nominal"
)

enrichmentsUpset <- getEnrichmentsUpset(
  study = testStudyObj,
  modelID = testModelName,
  annotationID = "annotation_02",
  sigValue = .04,
  operator = "<",
  type = "nominal"
)

enrichmentsUpset <- getEnrichmentsUpset(
  study = testStudyName,
  modelID = testModelName,
  annotationID = testAnnotationName,
  sigValue = .05,
  operator = "<",
  type = "adjusted"
)

enrichmentsUpset <- getEnrichmentsUpset(
  study = testStudyName,
  modelID = testModelName,
  annotationID = "annotation_02",
  sigValue = .05,
  operator = "<",
  type = "adjusted"
)

expect_error_xl(
  enrichmentsUpset <- getEnrichmentsUpset(
    study = testStudyName,
    modelID = testModelName,
    annotationID = "annotation_02",
    sigValue = .05,
    operator = "<",
    type = "wrong"
  ),
  "wrong"
)

# Test new argument `tests`. The tests aren't ideal because my example created
# study created with testTests() only has 2 tests.

enrichmentsUpset <- getEnrichmentsUpset(
  study = testStudyObj,
  modelID = testModelName,
  annotationID = "annotation_02",
  sigValue = .04,
  operator = "<",
  type = "nominal",
  tests = testTestsAll
)

enrichmentsUpset <- getEnrichmentsUpset(
  study = testStudyName,
  modelID = testModelName,
  annotationID = "annotation_02",
  sigValue = .05,
  operator = "<",
  type = "adjusted",
  tests = testTestsAll
)

expect_error_xl(
  enrichmentsUpset <- getEnrichmentsUpset(
    study = testStudyName,
    modelID = testModelName,
    annotationID = "annotation_02",
    sigValue = .05,
    operator = "<",
    type = "adjusted",
    tests = testTestsAll[1]
  ),
  "UpSet plot requires two or more tests to subset"
)

# getUpsetCols -----------------------------------------------------------------

upsetCols <- getUpsetCols(
  study = testStudyName,
  modelID = testModelName
)

expect_identical_xl(
  upsetCols,
  c("beta", "p_val")
)

expect_identical_xl(
  getUpsetCols(study = testStudyName, modelID = "non-existent-model"),
  character()
)

# Teardown ---------------------------------------------------------------------

unlink(tmplib, recursive = TRUE, force = TRUE)
.libPaths(libOrig)
