#' Shared parameters for upset functions
#'
#' @name shared-upset
#'
#' @param anchor The primary testID to filter the results
#' @param mustTests The testIDs for which a featureID (or termID for enrichment)
#'   must pass the filters
#' @param notTests The testIDs for which a featureID (or termID for enrichment)
#'   must \bold{not} pass the filters. In other words, if a featureID passes the
#'   filter for a testID specified in notTests, that featureID is removed from
#'   the output
#' @param sigValue The numeric significance value to use as a cutoff for each
#'   column
#' @param operator The comparison operators for each column, e.g. \code{"<"}
#' @param column The columns to apply the filters
#' @param type Type of p-value: (\code{"nominal"} or \code{"adjusted"})
#' @param tests Restrict UpSet plot to only include these tests
#' @param legacy Use legacy code (for testing purposes only)
#'
#' @keywords internal
NULL

#' getResultsIntersection
#'
#' @inheritParams shared-upset
#' @inheritParams shared-get
#'
#' @return Returns a data frame with the results, similar to
#'   \code{\link{getResultsTable}}. Only rows that pass all the filters are
#'   included. The new column \code{Set_Membership} is a comma-separated field
#'   that includes the testIDs in which the featureID passed the filters.
#'
#' @seealso \code{\link{getResultsTable}}
#'
#' @export
getResultsIntersection <- function(
  study,
  modelID,
  anchor,
  mustTests,
  notTests,
  sigValue,
  operator,
  column
)
{
  results <- getResults(study, modelID = modelID)
  results <- list(results)
  names(results) <- modelID

  intersection <- getInferenceIntersection(
    Inference.Results = results,
    testCategory = modelID,
    anchor = anchor,
    mustTests = mustTests,
    notTests = notTests,
    sigValue = sigValue,
    operator = operator,
    column = column
  )

  # The column Set_Membership needs to go between the feature and result columns
  features <- getFeatures(study, modelID = modelID)
  if (isEmpty(features)) {
    intersectionTable <- intersection
    columns <- colnames(intersectionTable)
    nColumns <- length(columns)
    stopifnot(identical(columns[nColumns], "Set_Membership"))
    columnsOrder <- c(columns[1], columns[nColumns], columns[2:(nColumns - 1)])
  } else {
    intersectionTable <- merge(intersection, features, by = 1, sort = FALSE)
    columnsOrder <- union(c(colnames(features), "Set_Membership"),
                          colnames(intersection))
  }
  intersectionTable <- intersectionTable[, columnsOrder]

  return(intersectionTable)
}

#' Find the Intersection of a list of tests.
#'
#' This function returns a table of results.
#'
#' @param anchor The primary test to filter from.
#' @param testCategory The test category
#' @param notTests The tests whose significant values will be removed. (The difference)
#' @param mustTests The tests whose significant values must be included. (The intersection)
#' @param sigValue The significance levels for each column.
#' @param operator The operators for each column.
#' @param column The columns to be thresheld.
#'
#' Note: The sigValue, operator, and column parameter vectors must be the same length.
#'
#' @return a table
#' @examples
#'  getInferenceIntersection(
#'    testCategory = "No Pretreatment Timecourse Differential Phosphorylation",
#'    sigValue = c(.05, .01),
#'    notTests = c(),
#'    anchor = "IKE",
#'    mustTests = c("FIN56"),
#'    operator = c("<", ">"),
#'    column = c("adj_P_Val", "adj_P_Val")
#'  )
#'
#' Changes made to original function:
#'   * Added Inference.Results as first argument
#'   * Changed `id` to be set to the name of the first column
#'   * Changed `<=` and `>=` to `<` and `>`, respectively, to match app UI
#'   * Reordered `anchor` test to start of tests using `union()`
#' @noRd
getInferenceIntersection <- function(
  Inference.Results,
  testCategory,
  anchor,
  mustTests,
  notTests,
  sigValue,
  operator = c("<"),
  column = c("adj_P_Val")
)
{
  # Initializing the master data frame to the anchor
  rv <- Inference.Results[[testCategory]][[anchor]]

  if (length(sigValue) != length(operator) || length(column) != length(operator)) {
    stop("The arguments sigValue, column, and operator must be the same length")
  }

  # Instantiate the set membership column. This will be filled out as you go. If
  # the protein site is significant in the study, then it will concatenate the
  # study to the set membership column.
  rv$Set_Membership <- anchor
  tests <- names(Inference.Results[[testCategory]])
  tests <- union(anchor, tests)

  # Calculate Intersection
  for (i in 1:length(tests)) {
    isNotTest <- tests[i] %in% notTests
    temp <- Inference.Results[[testCategory]][[tests[i]]]
    id <- colnames(temp)[1]
    fTemp <- data.frame(temp[, id])
    if (isNotTest) {
      fTemp <- cbind(fTemp, 0)
    } else {
      fTemp <- cbind(fTemp, 1)
    }
    for (k in 1:length(operator)) {
      sigCol <- c(temp[, column[k]])
      if (operator[k] == "<") {
        sigCol <- as.numeric(sigCol < sigValue[k])
      } else if (operator[k] == ">") {
        sigCol <- as.numeric(sigCol > sigValue[k])
      } else if (operator[k] == "|>|") {
        sigCol <- as.numeric(abs(sigCol) > sigValue[k])
      } else if (operator[k] == "|<|") {
        sigCol <- as.numeric(abs(sigCol) < sigValue[k])
      }
      if (isNotTest) {
        # notTests should "pass" if they meet any of the filters. That way when
        # they are filtered out below, any featureID that meets any of the
        # filters is removed from the final results.
        fTemp[, 2] <- as.integer(fTemp[, 2] | sigCol)
      } else {
        fTemp[, 2] <- as.integer(fTemp[, 2] & sigCol)
      }
    }
    fTemp <- fTemp[fTemp[, 2] == 1, ]
    temp <- temp[temp[, id] %in% fTemp[, 1], ]
    if (tests[i] %in% mustTests || tests[i] == anchor) {
      rv <- rv[rv[, id] %in% temp[, id], ]
      if (nrow(rv) == 0) {return(rv)}
      if (tests[i] != anchor) {
        rv$Set_Membership <- paste(rv$Set_Membership, tests[i], sep = " , ")
      }
    } else if (tests[i] %in% notTests) {
      rv <- rv[!rv[, id] %in% temp[, id], ]
      if (nrow(rv) == 0) {return(rv)}
    } else {
      rv[which(is.element(rv$id, temp[, id])), "Set_Membership"] <-
        paste(rv[which(is.element(rv$id, temp[, id])), "Set_Membership"], tests[i], sep = " , ")
    }
  }
  # Returning the master data frame.
  return(rv)
}

#' getEnrichmentsIntersection
#'
#' @inheritParams shared-upset
#' @inheritParams shared-get
#'
#' @return Returns a data frame with the enrichments, similar to
#'   \code{\link{getEnrichmentsTable}}. Only rows that pass all the filters are
#'   included.
#'
#' @seealso \code{\link{getEnrichmentsTable}}
#'
#' @export
getEnrichmentsIntersection <- function(
  study,
  modelID,
  annotationID,
  mustTests,
  notTests,
  sigValue,
  operator,
  type
)
{
  if (type == "nominal") {
    Enrichment.Results <- formatEnrichmentResults(study, modelID, annotationID, type)
    Enrichment.Results.Adjusted <- NULL
  } else if (type == "adjusted") {
    Enrichment.Results <- NULL
    Enrichment.Results.Adjusted <- formatEnrichmentResults(study, modelID, annotationID, type)
  } else {
    stop(sprintf("Argument `type` must be \"nominal\" or \"adjusted\", not \"%s\"",
                 type))
  }

  intersection <- getEnrichmentIntersection(
    Enrichment.Results = Enrichment.Results,
    Enrichment.Results.Adjusted = Enrichment.Results.Adjusted,
    testCategory = modelID,
    mustTests = mustTests,
    notTests = notTests,
    sigValue = sigValue,
    annotation = annotationID,
    operator = operator,
    pValType = type
  )

  return(intersection)
}

#' Find the Intersection of a list of tests.
#'
#' @param testCategory The test category
#' @param notTests The tests whose significant values will be removed. (The difference)
#' @param mustTests The tests whose significant values must be included. (The intersection)
#' @param sigValue The significance levels
#' @param annotation The annotation
#' @param operator The operators
#' @param pValType nominal or adjusted
#' Note: The sigValue and operator parameter vectors must be the same length.
#'
#' @return a table
#' @examples
#'  getEnrichmentIntersection(
#'    "No Pretreatment Timecourse Differential Phosphorylation",
#'    sigValue = c(.05),
#'    notTests = c(),
#'    annotation = "GOSLIM",
#'    mustTests = c("IKE", "FIN56")
#'  )
#'
#' Changes made to original function:
#'   * Added arguments Enrichment.Results and Enrichment.Results.Adjusted
#'   * Changed `<=` and `>=` to `<` and `>`, respectively, to match app UI
#'
#' @noRd
getEnrichmentIntersection <- function(
  Enrichment.Results,
  Enrichment.Results.Adjusted,
  testCategory,
  mustTests,
  notTests,
  sigValue,
  annotation,
  operator = c("<"),
  pValType = "nominal"
)
{
  if (length(sigValue) != length(operator)) {
    stop("The arguments sigValue and operator must be the same length")
  }

  # Generate Master Data Frame
  if (pValType == "nominal") {
    rv <- Enrichment.Results[[testCategory]][[annotation]]
    data <- Enrichment.Results[[testCategory]][[annotation]]
    tests <- names(Enrichment.Results[[testCategory]][[annotation]])
  } else {
    rv <- Enrichment.Results.Adjusted[[testCategory]][[annotation]]
    data <- Enrichment.Results.Adjusted[[testCategory]][[annotation]]
    tests <- names(Enrichment.Results.Adjusted[[testCategory]][[annotation]])
  }

  # Calculate Intersection
  for (i in 2:length(tests)) {
    filteredColumn <- data[, c(1, i)]
    for (k in 1:length(operator)) {
      if (tests[i] %in% mustTests || tests[i] %in% notTests) {
        if (operator[k] == "<") {
          filteredColumn <- filteredColumn[filteredColumn[[tests[i]]] < sigValue[k], ]
        } else if (operator[k] == ">") {
          filteredColumn <- filteredColumn[filteredColumn[[tests[i]]] > sigValue[k], ]
        }
      }
    }
    if (tests[i] %in% mustTests) {
      rv <- rv[rv[, 1] %in% filteredColumn[, 1], ]
    } else if (tests[i] %in% notTests) {
      rv <- rv[!rv[, 1] %in% filteredColumn[, 1], ]
    }
    if (length(row.names(rv)) == 0) {
      return(rv)
    }
  }

  # Returning the master data frame.
  return(rv)
}

#' getResultsUpset
#'
#' @inheritParams shared-upset
#' @inheritParams shared-get
#'
#' @return Invisibly returns the output from \code{\link[UpSetR]{upset}}
#'
#' @export
getResultsUpset <- function(
  study,
  modelID,
  sigValue,
  operator,
  column,
  legacy = FALSE
)
{
  if (!requireNamespace("UpSetR", quietly = TRUE)) {
    stop("Install the package \"UpSetR\" to run getResultsUpset()")
  }

  results <- getResults(study, modelID = modelID)

  if (legacy) {
    results <- list(results)
    names(results) <- modelID
    resultsUpset <- InferenceUpsetPlot(
      Inference.Results = results,
      testCategory = modelID,
      sigValue = sigValue,
      operator = operator,
      column = column
    )

    return(resultsUpset)
  }

  stopifnot(
    is.numeric(sigValue),
    is.character(operator),
    is.character(column),
    length(sigValue) == length(operator),
    length(operator) == length(column),
    operator %in% c(">", "<", "|>|", "|<|")
  )

  # Only keep results which have the required columns
  resultsHasColumns <- function(x) all(column %in% colnames(x))
  results <- Filter(resultsHasColumns, results)
  # Exit early with warning if none of the results tables has the columns
  if (isEmpty(results)) {
    warning(
      sprintf("None of the results table for modelID \"%s\" had the column(s): %s",
      modelID, paste(column, collapse = ", "))
    )
    return(NULL)
  }

  # Convert to keyed data tables
  toDataTable <- function(x) data.table::as.data.table(x, key = column)
  resultsDt <- Map(toDataTable, results)

  # Filter rows. First construct the filtering expression as a character, and
  # then evaluate it inside of the data table.
  filterExpression <- ifelse(
    operator %in% c("|>|", "|<|"),
    sprintf("abs(%s) %s %f", column, gsub("|", "", operator, fixed = TRUE), sigValue),
    sprintf("%s %s %f", column, operator, sigValue)
  )
  filterExpression <- paste(filterExpression, collapse = " & ")
  applyFilterExpression <- function(x) {
    x[eval(parse(text = filterExpression, keep.source = FALSE)), 1]
  }
  # [.data.table returns a 1-column dt, not a vector like [.data.frame
  # https://rdatatable.gitlab.io/data.table/articles/datatable-faq.html#j-num
  listOfDts <- Map(applyFilterExpression, resultsDt)
  # Convert to character vectors
  listOfSets <- Map(function(x) as.character(x[[1]]), listOfDts)
  allEmpty <- all(vapply(listOfSets, isEmpty, logical(1)))
  if (allEmpty) {
    stop("There were no features remaining after applying the filters.")
  }

  # UpSet plot
  upsetInput <- UpSetR::fromList(listOfSets)
  upsetOutput <- UpSetR::upset(
    upsetInput,
    nsets = length(listOfSets),
    nintersects = 30,
    sets.bar.color = "#56B4E9",
    order.by = "freq",
    # To enable empty intersections, set it to any non-NULL value. The
    # documentation uses "on", so that is the safest option.
    empty.intersections = NULL,
    text.scale = c( # see ?upset
      2.0, # intersection size title
      2.0, # intersection size tick labels
      2.0, # set size title
      2.0, # set size tick labels
      1.5, # set names
      1.2  # numbers above bars
    )
  )
  print(upsetOutput, newpage = FALSE)
  return(invisible(upsetOutput))
}

#' Creates a static Upset plot
#'
#' @param testCategory The test category
#' @param sigValue The significance levels for each column.
#' @param operator The operators for each column.
#' @param column The columns to be thresheld.
#' Note: The sigValue, operator, and column parameter vectors must be the same length.
#'
#' @return An SVG
#' @examples
#'  InferenceUpsetPlot(
#'    testCategory = "No Pretreatment Timecourse Differential Phosphorylation",
#'    sigValue = c(.05),
#'    operator = c("<"),
#'    column = c("adj_P_Val")
#'  )
#'
#' Changes made to original function:
#'   * Added Inference.Results as first argument
#'   * Changed `id` to be set to the name of the first column
#'   * Changed `<=` and `>=` to `<` and `>`, respectively, to match app UI
#'   * Set `newpage = FALSE` when printing to avoid blank page
#'   * Invisibly return the output from UpSetR::upset()
#'   * Reduce nintersects from default of 40 to 30
#'   * Stop displaying empty intersections (due to poor performance with many sets)
#'
#' @noRd
InferenceUpsetPlot <- function(
  Inference.Results,
  testCategory,
  sigValue,
  operator = c("<"),
  column = c("adj_P_Val")
)
{
  if (length(sigValue) != length(operator) || length(column) != length(operator)) {
    stop("The arguments sigValue, column, and operator must be the same length")
  }

  # Create list of variables from parameter strings
  tests <- names(Inference.Results[[testCategory]])
  testsUsed <- tests
  # if ("id_mult" %in% colnames(Inference.Results[[testCategory]][[tests[1]]])) {id <- "id_mult"}
  # else{id <- "id"}
  id <- colnames(Inference.Results[[testCategory]][[tests[1]]])[1]

  # Create the master data frame
  data <- data.frame(
    matrix(
      ncol = length(tests) + 1,
      nrow = length(Inference.Results[[testCategory]][[tests[1]]][[id]])
    )
  )
  colnames(data) <- c("Identifier", tests)
  data[, 1] = as.character(Inference.Results[[testCategory]][[tests[1]]][[id]])
  data = data[order(data[, 1]), ]

  for (i in 1:length(tests)) {
    mat <- Inference.Results[[testCategory]][[tests[i]]][[id]]
    for (k in 1:length(operator)) {
      sigCol <- as.numeric(Inference.Results[[testCategory]][[tests[i]]][[column[k]]])
      if (operator[k] == "<") {
        sigCol <- as.numeric(sigCol < sigValue[k])
      } else if (operator[k] == ">") {
        sigCol <- as.numeric(sigCol > sigValue[k])
      } else if (operator[k] == "|<|") {
        sigCol <- as.numeric(abs(sigCol) < sigValue[k])
      } else if (operator[k] == "|>|") {
        sigCol <- as.numeric(abs(sigCol) > sigValue[k])
      }
      if (sum(sigCol) == 0) {
        testsUsed <- testsUsed[testsUsed != tests[i]]
      }
      mat <- cbind.data.frame(mat, sigCol)
      if (k > 1) {
        mat[, 2] <- as.integer(mat[, 2] & mat[, 3])
        mat <- mat[, -3]
      }
    }
    # This function assumes that all the tests have the same id_mults;
    # therefore, we can order them so they are in the same order and match up
    # when lined up. Each file must contain the same exact id_mults for this to
    # work.
    mat <- mat[order(mat[, 1]), ]
    data[, i + 1] <- as.numeric(mat[, 2])
  }
  if (length(testsUsed) <= 1) {return(NULL)}

  # Create the upset plot.
  rv <- UpSetR::upset(
    data,
    nintersects = 30,
    sets = testsUsed,
    sets.bar.color = "#56B4E9",
    order.by = "freq",
    empty.intersections = NULL
  )
  #rv <- upset(data,point.size = 1.1, line.size = 0.4, sets = testsUsed, sets.bar.color = "#56B4E9", order.by = "freq", empty.intersections = "on")
  print(rv, newpage = FALSE)
  return(invisible(rv))
}

#' getEnrichmentsUpset
#'
#' @inheritParams shared-upset
#' @inheritParams shared-get
#'
#' @return No return value. This function is called for the side effect of
#'   creating an UpSet plot.
#'
#' @export
getEnrichmentsUpset <- function(
  study,
  modelID,
  annotationID,
  sigValue,
  operator,
  type,
  tests = NULL
)
{
  if (!requireNamespace("UpSetR", quietly = TRUE)) {
    stop("Install the package \"UpSetR\" to run getEnrichmentsUpset()")
  }

  if (type == "nominal") {
    Enrichment.Results <- formatEnrichmentResults(study, modelID, annotationID, type)
    Enrichment.Results.Adjusted <- NULL
  } else if (type == "adjusted") {
    Enrichment.Results <- NULL
    Enrichment.Results.Adjusted <- formatEnrichmentResults(study, modelID, annotationID, type)
  } else {
    stop(sprintf("Argument `type` must be \"nominal\" or \"adjusted\", not \"%s\"",
                 type))
  }

  enrichmentsUpset <- EnrichmentUpsetPlot(
    Enrichment.Results = Enrichment.Results,
    Enrichment.Results.Adjusted = Enrichment.Results.Adjusted,
    testCategory = modelID,
    annotation = annotationID,
    sigValue = sigValue,
    operator = operator,
    pValType = type,
    tests = tests
  )

  return(enrichmentsUpset)
}

#' Creates a static Upset plot
#'
#' @param testCategory The test category
#' @param sigValue The significance values
#' @param annotation The annotation
#' @param operator The operators
#' @param pValType nominal or adjusted
#' @param tests The tests
#' Note: The sigValue and operator parameter vectors must be the same length.
#'
#' @return An SVG
#' @examples
#'  EnrichmentUpsetPlot(
#'    "No Pretreatment Timecourse Differential Phosphorylation",
#'    annotation = "GOSLIM",
#'    c(.05)
#'  )
#'
#' Changes made to original function:
#'   * Added arguments Enrichment.Results and Enrichment.Results.Adjusted
#'   * Passed `na.rm = TRUE` to sum() to handle missing values
#'   * Changed `<=` and `>=` to `<` and `>`, respectively, to match app UI
#'   * Added tests parameter and respective subset functionality
#'   * Removed colsUsed variable and replaced with tests
#'   * Set `newpage = FALSE` when printing to avoid blank page
#'   * Reduce nintersects from default of 40 to 30
#'   * Stop displaying empty intersections (due to poor performance with many sets)
#'
#' @noRd
EnrichmentUpsetPlot <- function(
  Enrichment.Results,
  Enrichment.Results.Adjusted,
  testCategory,
  annotation,
  sigValue,
  operator = c("<"),
  pValType = "nominal",
  tests = NULL
)
{
  if (length(sigValue) != length(operator)) {
    stop("The arguments sigValue and operator must be the same length")
  }
  if (!is.null(tests) && length(tests) < 2) {
    stop("UpSet plot requires two or more tests to subset")
  }

  if (pValType == "nominal") {
    Identifier <- Enrichment.Results[[testCategory]][[annotation]][, 1]
    data <- Enrichment.Results[[testCategory]][[annotation]][, names(Enrichment.Results[[testCategory]][[annotation]])]
  } else {
    Identifier <- Enrichment.Results.Adjusted[[testCategory]][[annotation]][, 1]
    data <- Enrichment.Results.Adjusted[[testCategory]][[annotation]][, names(Enrichment.Results.Adjusted[[testCategory]][[annotation]])]
  }
  if (is.null(tests)) {
    tests = colnames(data)
  }

  for (i in 1:ncol(data)) {
    if (colnames(data)[i] %in% tests) {
      temp <- data.frame(data[, 1])
      temp$newCol <- 1
      for (j in 1:length(operator)) {
        sigCol <- data[, i]
        if (operator[j] == "<") {
          sigCol <- as.numeric(sigCol < sigValue[j])
        } else if (operator[j] == ">") {
          sigCol <- as.numeric(sigCol > sigValue[j])
        }
        temp <- cbind(temp, sigCol)
        temp[, 2] <- as.integer(temp[, 2] & temp[, 3])
        temp <- temp[, -3]
      }
      if (sum(temp[, 2], na.rm = TRUE) == 0) {
        tests <- tests[tests != colnames(data)[i]]
      }
      data[, i] <- temp[, 2]
    }
  }
  if (length(tests) < 2) {
    stop("Not enough significant elements to create upset plot")
  }

  data <- cbind(Identifier, data)

  # Create the upset plot.
  rv <- UpSetR::upset(
    data,
    nintersects = 30,
    sets = tests,
    sets.bar.color = "#56B4E9",
    order.by = "freq",
    empty.intersections = NULL
  )

  print(rv, newpage = FALSE)
  invisible();
}

# Format enrichment table as if it was in PhosphoProt Enrichment.Results objects
formatEnrichmentResults <- function(study, modelID, annotationID, type) {
  enrichmentsTable <- getEnrichmentsTable(study, modelID, annotationID, type)
  Enrichment.Results <- vector("list", 1)
  names(Enrichment.Results) <- modelID
  Enrichment.Results[[1]] <- vector("list", 1)
  names(Enrichment.Results[[1]]) <- annotationID
  Enrichment.Results[[1]][[1]] <- enrichmentsTable
  return(Enrichment.Results)
}

#' getUpsetCols
#'
#' Determine the common columns across all tests of a model that are available
#' for filtering with UpSet.
#'
#' @inheritParams shared-get
#'
#' @return Returns a character vector with the names of the common columns
#'
#' @export
getUpsetCols <- function(
  study,
  modelID
)
{
  results <- getResults(study, modelID = modelID)
  if (isEmpty(results)) return(character())
  colsAll <- lapply(results, function(x) colnames(x[, -1, drop = FALSE]))
  colsCommon <- Reduce(intersect, colsAll)
  return(colsCommon)
}
