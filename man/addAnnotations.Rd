% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add.R
\name{addAnnotations}
\alias{addAnnotations}
\title{Add annotations}
\usage{
addAnnotations(study, annotations, reset = FALSE)
}
\arguments{
\item{study}{An OmicNavigator study created with \code{\link{createStudy}}}

\item{annotations}{The annotations used for the enrichment analyses. The
input is a nested list. The top-level list contains one entry per
annotation database, e.g. reactome. The names correspond to the name of
each annotation database. Each of these elements should be a list that
contains more information about each annotation database. Specifically the
sublist should contain 1) \code{description}, a character vector that
describes the resource, 2) \code{featureID}, the name of the column in the
features table that was used for the enrichment analysis, and 3) \code{terms},
a list of annotation terms. The names of \code{terms} sublist correspond to
the name of the annotation terms. Each of the annotation terms should be a
character vector of featureIDs.}

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
Add annotations
}
