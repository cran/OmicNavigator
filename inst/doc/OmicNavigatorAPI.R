### R code from vignette source 'OmicNavigatorAPI.Rnw'

###################################################
### code chunk number 1: setup
###################################################
if (!interactive()) options(prompt = " ", continue = " ", width = 70)


###################################################
### code chunk number 2: packages
###################################################
library(jsonlite)
library(OmicNavigator)


###################################################
### code chunk number 3: test-data
###################################################
.tmplib <- tempfile()
local({
  dir.create(.tmplib)
  .libPaths(c(.tmplib, .libPaths()))
  abc <- OmicNavigator:::testStudy(name = "ABC")
  plots <- OmicNavigator:::testPlots()
  abc <- addPlots(abc, plots)
  # Add a report file
  tmpReport <- tempfile(fileext = ".html")
  writeLines("<p>example</p>", tmpReport)
  abc <- addReports(abc, list(model_02 = tmpReport))
  OmicNavigator::installStudy(abc)
})


###################################################
### code chunk number 4: list-studies (eval = FALSE)
###################################################
## studies <- listStudies()


###################################################
### code chunk number 5: list-studies-hidden
###################################################
studies <- listStudies(libraries = .tmplib)


###################################################
### code chunk number 6: list-studies-json
###################################################
toJSON(studies, auto_unbox = TRUE, pretty = TRUE)


###################################################
### code chunk number 7: results-table
###################################################
resultsTable <- getResultsTable(
  study = "ABC",
  modelID = "model_01",
  testID = "test_01"
)
nrow(resultsTable)
toJSON(resultsTable[1:2, ], pretty = TRUE)


###################################################
### code chunk number 8: results-table-term
###################################################
resultsTableTerm <- getResultsTable(
  study = "ABC",
  modelID = "model_01",
  testID = "test_01",
  annotationID = "annotation_01",
  termID =  "term_01"
)
nrow(resultsTableTerm)
toJSON(resultsTableTerm[1:2, ], pretty = TRUE)


###################################################
### code chunk number 9: enrichments-table
###################################################
enrichmentsTable <- getEnrichmentsTable(
  study = "ABC",
  modelID = "model_01",
  annotationID = "annotation_01"
)
toJSON(enrichmentsTable[1:2, ], pretty = TRUE)


###################################################
### code chunk number 10: enrichments-table-adjusted
###################################################
enrichmentsTable <- getEnrichmentsTable(
  study = "ABC",
  modelID = "model_01",
  annotationID = "annotation_01",
  type = "adjusted"
)
toJSON(enrichmentsTable[1:2, ], pretty = TRUE)


###################################################
### code chunk number 11: enrichments-network
###################################################
enrichmentsNetwork <- getEnrichmentsNetwork(
  study = "ABC",
  modelID = "model_01",
  annotationID = "annotation_01"
)
enrichmentsNetworkMinimal <- list(
  tests = enrichmentsNetwork[["tests"]],
  nodes = enrichmentsNetwork[["nodes"]][1:3, ],
  links = enrichmentsNetwork[["links"]][1:3, ]
)
toJSON(enrichmentsNetworkMinimal, auto_unbox = TRUE, pretty = TRUE)


###################################################
### code chunk number 12: getNodeFeatures
###################################################
nodeFeatures <- getNodeFeatures(
  study = "ABC",
  annotationID = "annotation_01",
  termID = "term_01"
)
toJSON(nodeFeatures[1:4], pretty = TRUE)


###################################################
### code chunk number 13: getLinkFeatures
###################################################
linkFeatures <- getLinkFeatures(
  study = "ABC",
  annotationID = "annotation_01",
  termID1 = "term_01",
  termID2 = "term_03"
)
toJSON(linkFeatures[1:4], pretty = TRUE)


###################################################
### code chunk number 14: plotStudy-plotBase
###################################################
plotStudy(
  study = "ABC",
  modelID = "model_01",
  featureID = "feature_0001",
  plotID = "plotBase",
  testID = "test_01"
)


###################################################
### code chunk number 15: plotStudy-plotGg
###################################################
plotStudy(
  study = "ABC",
  modelID = "model_03",
  featureID = "feature_0001",
  plotID = "plotGg",
  testID = "test_01"
)


###################################################
### code chunk number 16: plotStudy-plotMultiFeature
###################################################
plotStudy(
  study = "ABC",
  modelID = "model_01",
  featureID = c("feature_0001", "feature_0002"),
  plotID = "plotMultiFeature",
  testID = "test_01"
)


###################################################
### code chunk number 17: plotStudy-plotMultiTest
###################################################
plotStudy(
  study = "ABC",
  modelID = "model_01",
  featureID = c("feature_0001", "feature_0002"),
  plotID = "plotMultiTestMf",
  testID = c("test_01", "test_02")
)


###################################################
### code chunk number 18: plotStudy-plotMultiModel
###################################################
modelID <- c("model_01", "model_02")
testID <- c("test_01", "test_02")

plotStudy(
  study = "ABC",
  modelID = modelID,
  featureID = c("feature_0002", "feature_0003", "feature_0004"),
  plotID = "multiModel_scatterplot",
  testID = testID
)


###################################################
### code chunk number 19: getResultsIntersection
###################################################
resultsIntersection <- getResultsIntersection(
  study = "ABC",
  modelID = "model_01",
  anchor = "test_01",
  mustTests = c("test_01", "test_02"),
  notTests = c(),
  sigValue = .5,
  operator = "<",
  column = "p_val"
)
toJSON(resultsIntersection[1:2, ], pretty = TRUE)


###################################################
### code chunk number 20: getEnrichmentsIntersection
###################################################
enrichmentsIntersection <- getEnrichmentsIntersection(
  study = "ABC",
  modelID = "model_01",
  annotationID = "annotation_01",
  mustTests = c("test_01", "test_02"),
  notTests = c(),
  sigValue = .5,
  operator = "<",
  type = "nominal"
)
toJSON(enrichmentsIntersection[1:2, ], pretty = TRUE)


###################################################
### code chunk number 21: getResultsUpset
###################################################
resultsUpset <- getResultsUpset(
  study = "ABC",
  modelID = "model_01",
  sigValue = .5,
  operator = "<",
  column = "p_val"
)


###################################################
### code chunk number 22: getEnrichmentsUpset
###################################################
enrichmentsUpset <- getEnrichmentsUpset(
  study = "ABC",
  modelID = "model_01",
  annotationID = "annotation_02",
  sigValue = .05,
  operator = "<",
  type = "nominal"
)


###################################################
### code chunk number 23: getUpsetCols
###################################################
upsetCols <- getUpsetCols(
  study = "ABC",
  modelID = "model_01"
)
toJSON(upsetCols, auto_unbox = TRUE, pretty = TRUE)


###################################################
### code chunk number 24: metaFeatures-table
###################################################
metaFeaturesTable <- getMetaFeaturesTable(
  study = "ABC",
  modelID = "model_01",
  featureID = "feature_0001"
)
toJSON(metaFeaturesTable[1:2, ], pretty = TRUE)


###################################################
### code chunk number 25: getBarcodeData
###################################################
barcodeData <- getBarcodeData(
  study = "ABC",
  modelID = "model_01",
  testID = "test_01",
  annotationID = "annotation_02",
  termID = "term_05"
)
toJSON(barcodeData, auto_unbox = TRUE, pretty = TRUE)


###################################################
### code chunk number 26: getReportLink-URL
###################################################
reportLink <- getReportLink(
  study = "ABC",
  modelID = "model_01"
)
toJSON(reportLink, auto_unbox = TRUE, pretty = TRUE)


###################################################
### code chunk number 27: getReportLink-file
###################################################
reportLink <- getReportLink(
  study = "ABC",
  modelID = "model_02"
)
toJSON(reportLink, auto_unbox = TRUE, pretty = TRUE)


###################################################
### code chunk number 28: getResultsLinkouts
###################################################
resultsLinkouts <- getResultsLinkouts(
  study = "ABC",
  modelID = "model_01"
)
toJSON(resultsLinkouts, auto_unbox = TRUE, pretty = 2)


###################################################
### code chunk number 29: getEnrichmentsLinkouts
###################################################
enrichmentsLinkouts <- getEnrichmentsLinkouts(
  study = "ABC",
  annotationID = "annotation_01"
)
toJSON(enrichmentsLinkouts, auto_unbox = TRUE, pretty = 2)


###################################################
### code chunk number 30: getEnrichmentsLinkouts-2
###################################################
enrichmentsLinkouts <- getEnrichmentsLinkouts(
  study = "ABC",
  annotationID = "annotation_03"
)
toJSON(enrichmentsLinkouts, auto_unbox = TRUE, pretty = TRUE)


###################################################
### code chunk number 31: getMetaFeaturesLinkouts
###################################################
metaFeaturesLinkouts <- getMetaFeaturesLinkouts(
  study = "ABC",
  modelID = "model_01"
)
toJSON(metaFeaturesLinkouts, auto_unbox = TRUE, pretty = 2)


###################################################
### code chunk number 32: getFavicons
###################################################
resultsFavicons <- getFavicons(linkouts = resultsLinkouts)
toJSON(resultsFavicons, auto_unbox = TRUE, pretty = 2)
enrichmentsFavicons <- getFavicons(linkouts = enrichmentsLinkouts)
toJSON(enrichmentsFavicons, auto_unbox = TRUE, pretty = 2)


###################################################
### code chunk number 33: unavailable-data
###################################################
toJSON(getResultsTable(study = "ABC", modelID = "?", testID = "?"))
toJSON(getEnrichmentsTable(study = "ABC", modelID = "?", annotationID = "?"))
toJSON(getEnrichmentsNetwork(study = "ABC", modelID = "?", annotationID = "?"))
toJSON(getNodeFeatures(study = "ABC", annotationID = "?", termID = "?"))
toJSON(getLinkFeatures(study = "ABC", annotationID = "?", termID1 = "?",
                       termID2 = "?"))
toJSON(getUpsetCols(study = "ABC", modelID = "?"))
toJSON(getMetaFeaturesTable(study = "ABC", modelID = "?", featureID = "?"))
toJSON(getBarcodeData(study = "ABC", modelID = "?", testID = "?",
                      annotationID = "?", termID = "?"))
# Elements that have a value defined for the special modelID "default" will
# return this value if the modelID cannot be found. Otherwise an empty array
# would have been returned.
toJSON(getReportLink(study = "ABC", modelID = "?"),
       auto_unbox = TRUE, pretty = TRUE)
toJSON(getResultsLinkouts(study = "ABC", modelID = "?"),
       auto_unbox = TRUE, pretty = 2)
toJSON(getEnrichmentsLinkouts(study = "ABC", annotationID = "?"))


###################################################
### code chunk number 34: getPackageVersion
###################################################
toJSON(getPackageVersion(), auto_unbox = TRUE)


