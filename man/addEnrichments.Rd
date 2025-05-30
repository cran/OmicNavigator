% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add.R
\name{addEnrichments}
\alias{addEnrichments}
\title{Add enrichment results}
\usage{
addEnrichments(study, enrichments, reset = FALSE)
}
\arguments{
\item{study}{An OmicNavigator study created with \code{\link{createStudy}}}

\item{enrichments}{The enrichment results from each model. The input is a
nested named list. The names of the list correspond to the model names.
Each list element should be a list of the annotation databases tested
(\code{\link{addAnnotations}}). The names of the list correspond to the
annotation databases. Each list element should be another list of tests
(\code{\link{addTests}}). The names correspond to the tests performed. Each
of these elements should be a data frame with enrichment results. Each
table must contain the following columns: "termID", "description",
"nominal" (the nominal statistics), and "adjusted" (the statistics after
adjusting for multiple testing). Any additional columns are ignored.}

\item{reset}{Reset the data prior to adding the new data (default:
\code{FALSE}). The default is to add to or modify any previously added data
(if it exists). Setting \code{reset = TRUE} enables you to remove existing
data you no longer want to include in the study.}
}
\value{
Returns the original \code{onStudy} object passed to the argument
\code{study}, but modified to include the newly added data
}
\description{
Add enrichment results
}
