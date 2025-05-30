% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add.R
\name{addModels}
\alias{addModels}
\title{Add models}
\usage{
addModels(study, models, reset = FALSE)
}
\arguments{
\item{study}{An OmicNavigator study created with \code{\link{createStudy}}}

\item{models}{The models analyzed in the study. The input is a named list.
The names correspond to the names of the models. The elements correspond to
the descriptions of the models. Alternatively, instead of a single
character string, you can provide a list of metadata fields about each
model. The field "description" will be used to derive the tooltip displayed
in the app.}

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
Add models
}
\examples{
  study <- createStudy("example")
  models <- list(
    model_01 = "Name of first model",
    model_02 = "Name of second model"
  )
  study <- addModels(study, models)

  # Alternative: provide additional metadata about each model
  models <- list(
    model_01 = list(
      description = "Name of first model",
      data_type = "transcriptomics"
    ),
    model_02 = list(
      description = "Name of second model",
      data_type = "proteomics"
    )
  )

}
