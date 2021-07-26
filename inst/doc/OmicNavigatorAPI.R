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
toJSON(resultsTable[1:2, ], pretty = TRUE)


###################################################
### code chunk number 8: enrichments-table
###################################################
enrichmentsTable <- getEnrichmentsTable(
  study = "ABC",
  modelID = "model_01",
  annotationID = "annotation_01"
)
toJSON(enrichmentsTable[1:2, ], pretty = TRUE)


###################################################
### code chunk number 9: enrichments-table-adjusted
###################################################
enrichmentsTable <- getEnrichmentsTable(
  study = "ABC",
  modelID = "model_01",
  annotationID = "annotation_01",
  type = "adjusted"
)
toJSON(enrichmentsTable[1:2, ], pretty = TRUE)


###################################################
### code chunk number 10: enrichments-network
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
### code chunk number 11: getNodeFeatures
###################################################
nodeFeatures <- getNodeFeatures(
  study = "ABC",
  annotationID = "annotation_01",
  termID = "term_01"
)
toJSON(nodeFeatures[1:4], pretty = TRUE)


###################################################
### code chunk number 12: getLinkFeatures
###################################################
linkFeatures <- getLinkFeatures(
  study = "ABC",
  annotationID = "annotation_01",
  termID1 = "term_01",
  termID2 = "term_03"
)
toJSON(linkFeatures[1:4], pretty = TRUE)


###################################################
### code chunk number 13: plotStudy-plotBase
###################################################
plotStudy(
  study = "ABC",
  modelID = "model_01",
  featureID = "feature_0001",
  plotID = "plotBase"
)


###################################################
### code chunk number 14: plotStudy-plotGg
###################################################
plotStudy(
  study = "ABC",
  modelID = "model_03",
  featureID = "feature_0001",
  plotID = "plotGg"
)


###################################################
### code chunk number 15: plotStudy-plotMultiFeature
###################################################
plotStudy(
  study = "ABC",
  modelID = "model_01",
  featureID = c("feature_0001", "feature_0002"),
  plotID = "plotMultiFeature"
)


###################################################
### code chunk number 16: getResultsIntersection
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
### code chunk number 17: getEnrichmentsIntersection
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
### code chunk number 18: getResultsUpset
###################################################
resultsUpset <- getResultsUpset(
  study = "ABC",
  modelID = "model_01",
  sigValue = .5,
  operator = "<",
  column = "p_val"
)


###################################################
### code chunk number 19: getEnrichmentsUpset
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
### code chunk number 20: getUpsetCols
###################################################
upsetCols <- getUpsetCols(
  study = "ABC",
  modelID = "model_01"
)
toJSON(upsetCols, auto_unbox = TRUE, pretty = TRUE)


###################################################
### code chunk number 21: metaFeatures-table
###################################################
metaFeaturesTable <- getMetaFeaturesTable(
  study = "ABC",
  modelID = "model_01",
  featureID = "feature_0001"
)
toJSON(metaFeaturesTable[1:2, ], pretty = TRUE)


###################################################
### code chunk number 22: getBarcodeData
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
### code chunk number 23: getReportLink-URL
###################################################
reportLink <- getReportLink(
  study = "ABC",
  modelID = "model_01"
)
toJSON(reportLink, auto_unbox = TRUE, pretty = TRUE)


###################################################
### code chunk number 24: getReportLink-file
###################################################
reportLink <- getReportLink(
  study = "ABC",
  modelID = "model_02"
)
toJSON(reportLink, auto_unbox = TRUE, pretty = TRUE)


###################################################
### code chunk number 25: getResultsLinkouts
###################################################
resultsLinkouts <- getResultsLinkouts(
  study = "ABC",
  modelID = "model_01"
)
toJSON(resultsLinkouts, auto_unbox = TRUE, pretty = 2)


###################################################
### code chunk number 26: getEnrichmentsLinkouts
###################################################
enrichmentsLinkouts <- getEnrichmentsLinkouts(
  study = "ABC",
  annotationID = "annotation_01"
)
toJSON(enrichmentsLinkouts, auto_unbox = TRUE, pretty = 2)


###################################################
### code chunk number 27: getEnrichmentsLinkouts-2
###################################################
enrichmentsLinkouts <- getEnrichmentsLinkouts(
  study = "ABC",
  annotationID = "annotation_03"
)
toJSON(enrichmentsLinkouts, auto_unbox = TRUE, pretty = TRUE)


###################################################
### code chunk number 28: getMetaFeaturesLinkouts
###################################################
metaFeaturesLinkouts <- getMetaFeaturesLinkouts(
  study = "ABC",
  modelID = "model_01"
)
toJSON(metaFeaturesLinkouts, auto_unbox = TRUE, pretty = 2)


###################################################
### code chunk number 29: getFavicons
###################################################
resultsFavicons <- getFavicons(linkouts = resultsLinkouts)
toJSON(resultsFavicons, auto_unbox = TRUE, pretty = 2)
enrichmentsFavicons <- getFavicons(linkouts = enrichmentsLinkouts)
toJSON(enrichmentsFavicons, auto_unbox = TRUE, pretty = 2)


###################################################
### code chunk number 30: unavailable-data
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
### code chunk number 31: getPackageVersion
###################################################
toJSON(getPackageVersion(), auto_unbox = TRUE)


