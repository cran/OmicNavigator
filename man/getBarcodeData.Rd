% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/app.R
\name{getBarcodeData}
\alias{getBarcodeData}
\title{Get data for barcode and violin plots}
\usage{
getBarcodeData(study, modelID, testID, annotationID, termID)
}
\arguments{
\item{study}{An OmicNavigator study. Either an object of class \code{onStudy},
or the name of an installed study package.}

\item{modelID}{Filter by modelID}

\item{testID}{Filter by testID}

\item{annotationID}{Filter by annotationID}

\item{termID}{Filter by termID}
}
\value{
A list with the following components:

\item{data}{Data frame with the differential statistics to plot}
\item{highest}{(numeric) The largest differential statistic, rounded up to
the next integer}
\item{lowest}{(numeric) The lowest differential statistic, rounded down to the next integer}
\item{labelStat}{(character) The x-axis label to describe the differential
statistic}
\item{labelLow}{(character) The vertical axis label on the left to describe
smaller values (default is "Low")}
\item{labelHigh}{(character) The vertical axis label on the right to
describe larger values (default is "High")}
}
\description{
Get data for barcode and violin plots
}
\seealso{
\code{\link{addBarcodes}}, \code{\link{getBarcodes}}
}
