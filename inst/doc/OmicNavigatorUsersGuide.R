### R code from vignette source 'OmicNavigatorUsersGuide.Rnw'

###################################################
### code chunk number 1: setup
###################################################
if (!interactive()) options(prompt = " ", continue = " ", width = 70)
# Create temporary directory to install study "vignetteExample"
local({
  .tmplib <- tempfile()
  dir.create(.tmplib)
  .libPaths(c(.tmplib, .libPaths()))
})


###################################################
### code chunk number 2: data
###################################################
data("RNAseq123", package = "OmicNavigator")
ls()


###################################################
### code chunk number 3: package
###################################################
library(OmicNavigator)


###################################################
### code chunk number 4: createStudy
###################################################
study <- createStudy(name = "vignetteExample",
                     description = "Bioc workflow package RNAseq123")


###################################################
### code chunk number 5: OmicNavigatorUsersGuide.Rnw:323-324
###################################################
head(basal.vs.lp)


###################################################
### code chunk number 6: OmicNavigatorUsersGuide.Rnw:355-359
###################################################
# Remove columns 2 and 3
basal.vs.lp.on <- basal.vs.lp[, -2:-3]
basal.vs.ml.on <- basal.vs.ml[, -2:-3]
head(basal.vs.ml.on)


###################################################
### code chunk number 7: OmicNavigatorUsersGuide.Rnw:379-385
###################################################
results <- list(
  main = list(
    basal.vs.lp = basal.vs.lp.on,
    basal.vs.ml = basal.vs.ml.on
  )
)


###################################################
### code chunk number 8: OmicNavigatorUsersGuide.Rnw:390-391
###################################################
study <- addResults(study, results)


###################################################
### code chunk number 9: OmicNavigatorUsersGuide.Rnw:415-416
###################################################
head(cam.BasalvsLP)


###################################################
### code chunk number 10: OmicNavigatorUsersGuide.Rnw:447-464
###################################################
# LP
cam.BasalvsLP.on <- data.frame(
  termID = row.names(cam.BasalvsLP),
  description = gsub("_", " ", tolower(row.names(cam.BasalvsLP))),
  nominal = cam.BasalvsLP$PValue,
  adjusted = cam.BasalvsLP$FDR,
  stringsAsFactors = FALSE
)
# ML
cam.BasalvsML.on <- data.frame(
  termID = row.names(cam.BasalvsML),
  description = gsub("_", " ", tolower(row.names(cam.BasalvsML))),
  nominal = cam.BasalvsML$PValue,
  adjusted = cam.BasalvsML$FDR,
  stringsAsFactors = FALSE
)
head(cam.BasalvsML.on)


###################################################
### code chunk number 11: OmicNavigatorUsersGuide.Rnw:474-482
###################################################
enrichments <- list(
  main = list(
    c2 = list(
       basal.vs.lp = cam.BasalvsLP.on,
       basal.vs.ml = cam.BasalvsML.on
    )
  )
)


###################################################
### code chunk number 12: OmicNavigatorUsersGuide.Rnw:487-488
###################################################
study <- addEnrichments(study, enrichments)


###################################################
### code chunk number 13: OmicNavigatorUsersGuide.Rnw:499-502
###################################################
models <- list(
  main = "limma+voom model of RNA-seq experiment of mouse mammary glands"
)


###################################################
### code chunk number 14: OmicNavigatorUsersGuide.Rnw:507-508
###################################################
study <- addModels(study, models)


###################################################
### code chunk number 15: OmicNavigatorUsersGuide.Rnw:524-530
###################################################
tests <- list(
  main = list(
    basal.vs.lp = "Which genes are DE between Basal and LP cells?",
    basal.vs.ml = "Which genes are DE between Basal and ML cells?"
  )
)


###################################################
### code chunk number 16: OmicNavigatorUsersGuide.Rnw:535-536
###################################################
study <- addTests(study, tests)


###################################################
### code chunk number 17: OmicNavigatorUsersGuide.Rnw:565-569
###################################################
basal.vs.lp[1:2, 1:6]
features <- list(
  main = basal.vs.lp[, 1:3]
)


###################################################
### code chunk number 18: OmicNavigatorUsersGuide.Rnw:574-575
###################################################
study <- addFeatures(study, features)


###################################################
### code chunk number 19: OmicNavigatorUsersGuide.Rnw:602-603
###################################################
Mm.c2


###################################################
### code chunk number 20: OmicNavigatorUsersGuide.Rnw:619-626
###################################################
annotations <- list(
  c2 = list(
    terms = Mm.c2,
    description = "Broad Institute's MSigDB c2 collection",
    featureID = "ENTREZID"
  )
)


###################################################
### code chunk number 21: OmicNavigatorUsersGuide.Rnw:635-636
###################################################
study <- addAnnotations(study, annotations)


###################################################
### code chunk number 22: OmicNavigatorUsersGuide.Rnw:659-660
###################################################
head(basal.vs.lp.on)


###################################################
### code chunk number 23: OmicNavigatorUsersGuide.Rnw:703-713
###################################################
barcodes <- list(
  main = list(
    statistic = "t",
    logFoldChange = "logFC",
    labelStat = "abs(t)",
    featureDisplay = "SYMBOL"
  )
)

study <- addBarcodes(study, barcodes)


###################################################
### code chunk number 24: install
###################################################
installStudy(study)


###################################################
### code chunk number 25: export (eval = FALSE)
###################################################
## exportStudy(study)


###################################################
### code chunk number 26: install-tarball (eval = FALSE)
###################################################
## install.packages("ONstudyvignetteExample_0.0.0.9000.tar.gz",
##                  repos = NULL)


###################################################
### code chunk number 27: startApp (eval = FALSE)
###################################################
## startApp()


###################################################
### code chunk number 28: OmicNavigatorUsersGuide.Rnw:790-793
###################################################
head(samplenames)
table(group)
table(lane)


###################################################
### code chunk number 29: OmicNavigatorUsersGuide.Rnw:798-800
###################################################
samplesTable <- data.frame(name = samplenames, group, lane)
head(samplesTable)


###################################################
### code chunk number 30: OmicNavigatorUsersGuide.Rnw:806-808
###################################################
samples <- list(main = samplesTable)
study <- addSamples(study, samples)


###################################################
### code chunk number 31: OmicNavigatorUsersGuide.Rnw:838-839
###################################################
lcpm[1:3, 1:3]


###################################################
### code chunk number 32: OmicNavigatorUsersGuide.Rnw:845-847
###################################################
assays <- list(main = as.data.frame(lcpm))
study <- addAssays(study, assays)


###################################################
### code chunk number 33: OmicNavigatorUsersGuide.Rnw:859-862 (eval = FALSE)
###################################################
## nameOfPlot <- function(x) {
##   # Your custom plotting code
## }


###################################################
### code chunk number 34: OmicNavigatorUsersGuide.Rnw:898-900
###################################################
plottingData <- getPlottingData(study, modelID = "main", featureID = "12767")
plottingData


###################################################
### code chunk number 35: cellTypeBox
###################################################
boxplot(as.numeric(plottingData$assays[1, ]) ~ plottingData$samples$group,
        col = c("pink", "purple", "gold"),
        xlab = "Cell type", ylab = "Gene expression",
        main = plottingData$features$SYMBOL)


###################################################
### code chunk number 36: OmicNavigatorUsersGuide.Rnw:918-924
###################################################
cellTypeBox <- function(plottingData) {
  boxplot(as.numeric(plottingData$assays[1, ]) ~ plottingData$samples$group,
          col = c("pink", "purple", "gold"),
          xlab = "Cell type", ylab = "Gene expression",
          main = plottingData$features$SYMBOL)
}


###################################################
### code chunk number 37: cellTypeBoxGg
###################################################
library(ggplot2)
ggDataFrame <- cbind(plottingData$samples,
                     feature = as.numeric(plottingData$assays))
head(ggDataFrame, 3)
ggplot(ggDataFrame, aes(x = group, y = feature, fill = group)) +
  geom_boxplot() +
  scale_fill_manual("Cell type", values = c("pink", "purple", "gold")) +
  labs(x = "Cell type", y = "Gene expression",
       title = plottingData$features$SYMBOL)


###################################################
### code chunk number 38: OmicNavigatorUsersGuide.Rnw:954-964
###################################################
cellTypeBoxGg <- function(plottingData) {
  ggDataFrame <- cbind(plottingData$samples,
                       feature = as.numeric(plottingData$assays))

  ggplot(ggDataFrame, aes(x = .data$group, y = .data$feature, fill = .data$group)) +
    geom_boxplot() +
    scale_fill_manual("Cell type", values = c("pink", "purple", "gold")) +
    labs(x = "Cell type", y = "Gene expression",
         title = plottingData$features$SYMBOL)
}


###################################################
### code chunk number 39: multiFeature
###################################################
twoFeatures <- getPlottingData(study, modelID = "main",
                               featureID = c("12767", "13603"))
twoFeatures
plotPca <- function(x) {
  if (nrow(x[["assays"]]) < 2) {
    stop("This plotting function requires at least 2 features")
  }
  pca <- stats::prcomp(t(x[["assays"]]), scale. = TRUE)$x
  plot(pca[, 1], pca[, 2], col = as.factor(x$samples$group),
       xlab = "PC 1", ylab = "PC 2", main = "PCA")
  text(pca[, 1], pca[, 2], labels = x$samples$group, pos = 2, cex = 0.5)
}
plotPca(twoFeatures)


###################################################
### code chunk number 40: multiTest
###################################################
multiTests <- getPlottingData(study, modelID = "main",
                              featureID = row.names(study$assays$main),
                              testID = c("basal.vs.lp", "basal.vs.ml"))

plotMultiTestMf <- function(x) {
    df <- data.frame(lapply(x$results, `[`, 2))
    colnames(df)<- names(x$results)

    plot(df$basal.vs.lp ~ df$basal.vs.ml,
         xlab = paste0("log FC ", colnames(df)[2]),
         ylab = paste0("log FC ", colnames(df)[3]))
    abline(v=0, h = 0, col="grey")
}
plotMultiTestMf(multiTests)


###################################################
### code chunk number 41: OmicNavigatorUsersGuide.Rnw:1034-1057
###################################################
plots <- list(
  main = list(
    cellTypeBox = list(
      displayName = "Expression by cell type",
      plotType = "singleFeature"
    ),
    cellTypeBoxGg = list(
      displayName = "Expression by cell type (ggplot2)",
      plotType = "singleFeature",
      packages = c("ggplot2")
    ),
    plotPca = list(
      displayName = "PCA",
      plotType = "multiFeature",
      packages = c("stats")
    ),
    plotMultiTestMf = list(
      displayName = "scatterplot",
      plotType = c("multiTest", "multiFeature")
    )
  )
)
study <- addPlots(study, plots = plots)


###################################################
### code chunk number 42: plotStudy1
###################################################
plotStudy(study, modelID = "main", featureID = "21390",
          plotID = "cellTypeBox")


###################################################
### code chunk number 43: plotStudy2
###################################################
plotStudy(study, modelID = "main", featureID = "21390",
          plotID = "cellTypeBoxGg")


###################################################
### code chunk number 44: plotStudy3
###################################################
plotStudy(study, modelID = "main", featureID = c("21390", "19216"),
          plotID = "plotPca")


###################################################
### code chunk number 45: OmicNavigatorUsersGuide.Rnw:1180-1181
###################################################
reportUrl = "https://bioconductor.org/packages/release/workflows/vignettes/RNAseq123/inst/doc/limmaWorkflow.html"


###################################################
### code chunk number 46: OmicNavigatorUsersGuide.Rnw:1188-1191
###################################################
reports <- list(
  main = reportUrl
)


###################################################
### code chunk number 47: OmicNavigatorUsersGuide.Rnw:1196-1197
###################################################
study <- addReports(study, reports)


###################################################
### code chunk number 48: resultsLinkouts
###################################################
resultsLinkouts <- list(
  default = list(
    ENTREZID = "https://www.ncbi.nlm.nih.gov/gene/"
  )
)


###################################################
### code chunk number 49: addResultsLinkouts
###################################################
study <- addResultsLinkouts(study, resultsLinkouts)


###################################################
### code chunk number 50: enrichmentsLinkouts
###################################################
enrichmentsLinkouts <- list(
  c2 = "https://www.gsea-msigdb.org/gsea/msigdb/cards/"
)


###################################################
### code chunk number 51: addEnrichmentsLinkouts
###################################################
study <- addEnrichmentsLinkouts(study, enrichmentsLinkouts)


###################################################
### code chunk number 52: OmicNavigatorUsersGuide.Rnw:1309-1310
###################################################
str(getFeatures(study))


###################################################
### code chunk number 53: OmicNavigatorUsersGuide.Rnw:1317-1318
###################################################
str(getFeatures(study, modelID = "main"))


###################################################
### code chunk number 54: OmicNavigatorUsersGuide.Rnw:1326-1329
###################################################
str(getResults(study))
str(getResults(study, modelID = "main"))
str(getResults(study, modelID = "main", testID = "basal.vs.lp"))


###################################################
### code chunk number 55: OmicNavigatorUsersGuide.Rnw:1337-1338
###################################################
str(getFeatures("vignetteExample", modelID = "main"))


###################################################
### code chunk number 56: OmicNavigatorUsersGuide.Rnw:1364-1366
###################################################
studyWithDefault <- addFeatures(study, list(default = basal.vs.lp[, 1:3]))
str(getFeatures(studyWithDefault, modelID = "modelThatDoesntExistYet"))


###################################################
### code chunk number 57: package-option-prefix (eval = FALSE)
###################################################
## options(OmicNavigator.prefix = "OmicNavigatorStudy")


###################################################
### code chunk number 58: theme
###################################################
op <- par(bg = "#e0e1e2", fg = "#2e2e2e", no.readonly = TRUE)
boxplot(mpg ~ cyl, data = mtcars, col = c("#ff4400", "#2c3b78", "#4cd2d5"))
par(op)


###################################################
### code chunk number 59: session-information
###################################################
utils::toLatex(utils::sessionInfo())


