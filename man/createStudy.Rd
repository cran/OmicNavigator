% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add.R
\name{createStudy}
\alias{createStudy}
\title{Create a study}
\usage{
createStudy(
  name,
  description = name,
  samples = list(),
  features = list(),
  models = list(),
  assays = list(),
  tests = list(),
  annotations = list(),
  results = list(),
  enrichments = list(),
  metaFeatures = list(),
  plots = list(),
  mapping = list(),
  barcodes = list(),
  reports = list(),
  resultsLinkouts = list(),
  enrichmentsLinkouts = list(),
  metaFeaturesLinkouts = list(),
  version = NULL,
  maintainer = NULL,
  maintainerEmail = NULL,
  studyMeta = list()
)
}
\arguments{
\item{name}{Name of the study}

\item{description}{Description of the study}

\item{samples}{The metadata variables that describe the samples in the study.
The input object is a named list of data frames (one per model). The first
column of each data frame is used as the sampleID, so it must contain
unique values. To share a data frame across multiple models, use the
modelID "default".}

\item{features}{The metadata variables that describe the features in the
study. The input object is a list of data frames (one per model). The first
column of each data frame is used as the featureID, so it must contain
unique values. To share a data frame across multiple models, use the
modelID "default". All columns will be coerced to character strings.}

\item{models}{The models analyzed in the study. The input is a named list.
The names correspond to the names of the models. The elements correspond to
the descriptions of the models. Alternatively, instead of a single
character string, you can provide a list of metadata fields about each
model. The field "description" will be used to derive the tooltip displayed
in the app.}

\item{assays}{The assays from the study. The input object is a list of data
frames (one per model). The row names should correspond to the featureIDs
(\code{\link{addFeatures}}). The column names should correspond to the
sampleIDs (\code{\link{addSamples}}). The data frame should only contain
numeric values. To share a data frame across multiple models, use the
modelID "default".}

\item{tests}{The tests from the study. The input object is a list of lists.
Each element of the top-level list is a model. The names should be the
modelIDs. For each modelID, each element of the nested list is a test. The
names should be the testIDs. The value should be a single character string
describing the testID. To share tests across multiple models, use the
modelID "default". Instead of a single character string, you can provide a
list of metadata fields about each test. The field "description" will be
used to derive the tooltip displayed in the app.}

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

\item{results}{The inference results from each model. The input is a
nested named list. The names of the list correspond to the model names.
Each element in the list should be a list of data frames with inference
results, one for each test. In each data frame, the featureID must be in
the first column, and all other columns must be numeric.}

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

\item{metaFeatures}{The metadata variables that describe the meta-features in
the study. The input object is a list of data frames (one per model). The
first column of each data frame is used as the featureID, so it must
contain the same IDs as the corresponding features data frame
(\code{\link{addFeatures}}). To share a data frame across multiple models,
use the modelID "default". All columns will be coerced to character
strings.}

\item{plots}{A nested list containing custom plotting functions and plot
metadata. The input object is a 3-level nested list. The first, or
top-level list element name(s) must match the study \code{modelID}(s). The second,
or mid-level list element name(s) must match the names of the plotting
function(s) defined in the current R session (see Details below for
function construction requirements). The third, or bottom-level list
provides metadata to categorize, display, and support each plot. The
accepted fields are \code{displayName}, \code{description}, \code{plotType}, \code{models}, and
\code{packages.} \code{displayName} sets the plot name in the app and the \code{description}
field will display as a tool tip when hovering over plotting dropdown
menus. The \code{plotType} field is a character vector that categorizes the plot
by 1) the number of features it supports (“\code{singleFeature}” or
“\code{multiFeature}”), 2) the number of test results used by the plotting
function (“\code{singleTest}”, “\code{multiTest}”), 3) if data from one or more models is
used (add “\code{multiModel}” to specify that data from two or more models are
used in the plot; otherwise the plot is assumed to reference only data
within the model specified by the top-level list element name), and 4) if
the plot is interactive (add “\code{plotly}” to specify interactive plots built
using the plotly package; otherwise the plot is assumed to be static).
e.g., \verb{plotType = c("multiFeature", "multiTest",”plotly”)}. If you do not
specify the \code{plotType} the plot will be designated as \code{plotType = c("singleFeature", "singleTest")}. The \code{models} field is an optional
character vector that specifies the models that should be used by the app
when invoking your custom plotting function. This field is set to ‘all’ by
default and is only used when \code{plotType} includes “\code{multiModel}”. If this field
is not included the app will assume all models in the study should be used
with your plotting function. If the plotting function requires additional
packages beyond those attached by default to a fresh R session, these must
be defined in the element \code{packages}.}

\item{mapping}{Feature IDs from models. The input object is a list of named
data frames. For each data frame, column names indicate model names while
rows indicate featureIDs per model. Features with same index position across
columns are treated as mapped across models. For each model, feature IDs must
match feature IDs available in the results object of the respective model.
1:N relationships are allowed.

Mapping list elements are required to be named as 'default' or after a model
name as provided in addModels(). If a single data frame is provided, this
list element is recommended to be named 'default'. For multiple list
elements, each with its own data frame, list elements should be named after
model name(s) (a single element may still be  named 'default'). In that case,
when navigating in ON front-end (FE), mapping element related to the selected
model in the FE will be used in multimodel plots. If a selected model in FE
does not have a corresponding mapping list element, it may still use the
mapping list element called 'default' if this is available.

E.g., if in a study there are models "transcriptomics" and "proteomics" and
the user wants to create a plot based on data from both, a mapping list
should be provided with addMapping(). In this case, the mapping list element
may be named 'default'. This should contain a data frame with column names
'transcriptomics' and 'proteomics', where feature IDs that map across models
are found in the same row.}

\item{barcodes}{The metadata variables that describe the barcode plot.
The input object is a list of lists (one per model). Each sublist must
contain the element \code{statistic}, which is the column name in the
results table to use to construct the barcode plot. Each sublist may
additionally contain any of the following optional elements:
\enumerate{
\item \code{absolute} - Should the statistic be converted to its absolute
value (default is \code{TRUE}).
\item \code{logFoldChange} - The column name in the results table that contains
the log fold change values.
\item \code{labelStat} - The x-axis label to describe the statistic.
\item \code{labelLow} - The left-side label to describe low values of the statistic.
\item \code{labelHigh} - The right-side label to describe high values of the statistic.
\item \code{featureDisplay} - The feature variable to use to label the barcode plot
on hover.
To share metadata across multiple models, use the modelID "default".
}}

\item{reports}{The analysis report(s) that explain how the study results were
generated. The input object is a list of character vectors (one per model).
Each element should be either a URL or a path to a file on your computer.
If it is a path to a file, this file will be included in the exported study
package. To share a report across multiple models, use the modelID
"default".}

\item{resultsLinkouts}{The URL patterns that describe linkouts to external
resources (see Details below). The input object is a nested named list. The
names of the list correspond to the model names. Each element of the list
is a named list of character vectors. The names of this nested list must
correspond to the column names of the matching features table. To share
linkouts across multiple models, use the modelID "default".}

\item{enrichmentsLinkouts}{The URL patterns that describe linkouts to
external resources (see Details below). The input object is a named list.
The names of the list correspond to the annotation names. Each element of
the list is a character vector of linkouts for that annotationID.}

\item{metaFeaturesLinkouts}{The URL patterns that describe linkouts to external
resources (see Details below). The input object is a nested named list. The
names of the list correspond to the model names. Each element of the list
is a named list of character vectors. The names of this nested list must
correspond to the column names of the matching metaFeatures table (\code{\link{addMetaFeatures}}). To share
linkouts across multiple models, use the modelID "default".}

\item{version}{(Optional) Include a version number to track the updates to
your study package. If you export the study to a package, the version is
used as the package version.}

\item{maintainer}{(Optional) Include the name of the study package's
maintainer}

\item{maintainerEmail}{(Optional) Include the email of the study package's
maintainer}

\item{studyMeta}{(Optional) Define metadata about your study. The input is a
list of key:value pairs. See below for more details.}
}
\value{
Returns a new OmicNavigator study object, which is a named nested
list with class \code{onStudy}
}
\description{
Create a new OmicNavigator study.
}
\details{
You can add metadata to describe your study by passing a named list to to the
argument \code{studyMeta}. The names of the list cannot contain spaces or
colons, and they can't start with \code{#} or \code{-}. The values of each
list should be a single value. Also, your metadata fields cannot use any of
the
\href{https://gist.github.com/jdblischak/f9d946327c9991fb57dde1e6f2bff1c2}{reserved
fields for R's DESCRIPTION file}.
}
\examples{

study <- createStudy(name = "ABC",
                     description = "An analysis of ABC")

# Define a version and study metadata
study <- createStudy(name = "ABC",
                     description = "An analysis of ABC",
                     version = "0.1.0",
                     maintainer = "My Name",
                     maintainerEmail = "me@email.com",
                     studyMeta = list(department = "immunology",
                                      organism = "Mus musculus"))

}
\seealso{
\code{\link{addSamples}},
\code{\link{addFeatures}},
\code{\link{addModels}},
\code{\link{addAssays}},
\code{\link{addTests}},
\code{\link{addAnnotations}},
\code{\link{addResults}},
\code{\link{addEnrichments}},
\code{\link{addMetaFeatures}},
\code{\link{addPlots}},
\code{\link{addMapping}},
\code{\link{addBarcodes}},
\code{\link{addReports}},
\code{\link{addResultsLinkouts}},
\code{\link{addEnrichmentsLinkouts}},
\code{\link{addMetaFeaturesLinkouts}},
\code{\link{exportStudy}},
\code{\link{installStudy}}
}
