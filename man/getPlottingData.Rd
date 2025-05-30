% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plots.R
\name{getPlottingData}
\alias{getPlottingData}
\title{Get plotting data from an OmicNavigator study}
\usage{
getPlottingData(study, modelID, featureID, testID = NULL, libraries = NULL)
}
\arguments{
\item{study}{An OmicNavigator study. Either an object of class \code{onStudy},
or the name of an installed study package.}

\item{modelID}{Filter by modelID}

\item{featureID}{Filter by featureID}

\item{testID}{Filter by testID}

\item{libraries}{The directories to search for installed study packages. If
left as \code{NULL} (the default), then
\code{\link[utils]{installed.packages}} will use the result of
\code{\link{.libPaths}}.}
}
\value{
Returns a list of at least 4 objects:

\item{\code{assays}}{A data frame that contains the assay measurements,
filtered to only include the row(s) corresponding to the input featureID(s)
(see \code{\link{getAssays}}). If multiple featureIDs are requested, the rows
are reordered to match the order of this input. The column order is
unchanged.}

\item{\code{samples}}{A data frame that contains the sample metadata for the
given modelID (see \code{\link{getSamples}}). The rows are reordered to match
the columns of the assays data frame.}

\item{\code{features}}{A data frame that contains the feature metadata,
filtered to only include the row(s) corresponding to the input featureID(s)
(see \code{\link{getFeatures}}). If multiple featureIDs are requested, the
rows are reordered to match the order of this input (and thus match the order
of the assays data frame).}

\item{\code{results}}{A data frame that contains the test results,
filtered to only include the row(s) corresponding to the input featureID(s).
If multiple featureIDs are requested, the rows are reordered to match the
order of this input. The column order is unchanged. If multiple testIDs are
provided, they are stored in a list object.}

\item{\code{mapping}}{A data frame that contains the featureID(s) from each
model. This is the filtered mapping object. This data frame is returned when multiple models are passed as arguments}

The data frame \code{results} is only returned if you pass a testID. By
default the app will always pass the currently selected testID.
}
\description{
Returns \code{assay}, \code{sample}, \code{feature}, and \code{result} data that may be used for
plotting. This function is called by \code{plotStudy()} and the output is passed to
custom plotting functions. It should be used directly when interactively
creating custom plotting functions.
}
\details{
The end-user should call this function and populate the first argument of
their custom plotting function with the output. When building functions, the
end-user should understand the category of plotting function they are creating
(e.g. \code{singleFeature} or \code{multiFeature}, see \code{\link[=addPlots]{addPlots()}}) and call
\code{getPlottingData()} accordingly.

Custom plots that accept data from multiple models and a single test
(\verb{plotType = c(‘multiModel’, ‘singleTest’)}; see \code{\link[=addPlots]{addPlots()}}) should be built
to accept output from \code{getPlottingData()} where \code{modelID} is vector of length
n and \code{testID} is a vector of length n, where n is the number of models.
Custom plots that accept data from multiple models and multiple tests
(\verb{plotType = c(‘multiModel’, ‘multiTest’)}) should be built to accept output
from \code{getPlottingData()} where \code{modelID} and \code{testID} vectors are length m,
where m is the total number of tests considered across all models (note that
\code{testID}s must be repeated across models for the plotting function to work in
the app). The index positions of these two vectors should correspond. That is,
\code{testID} position 1 should be found in the model specified by \code{modelID}
position 1, etc. See \code{\link[=addPlots]{addPlots()}} for information about the assignment of
\code{plotTypes} for your custom plots.
}
\seealso{
\code{\link{addPlots}}, \code{\link{plotStudy}}
}
