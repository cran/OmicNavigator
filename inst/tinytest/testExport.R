# Test exportStudy()

# Setup ------------------------------------------------------------------------

source("tinytestSettings.R")
using(ttdo)

library(OmicNavigator)

testStudyName <- "ABC"
testStudyObj <- OmicNavigator:::testStudy(name = testStudyName)
testStudyObj <- addPlots(testStudyObj, OmicNavigator:::testPlots())
minimalStudyObj <- OmicNavigator:::testStudyMinimal()
minimalStudyName <- minimalStudyObj[["name"]]

tmplib <- tempfile()
dir.create(tmplib)
tmplibSpace <- file.path(tempdir(), "a space")
dir.create(tmplibSpace)
tmplibQuote <- file.path(tempdir(), "project's results")
dir.create(tmplibQuote)

# Export with special encoding description ------------------------------------

specialDesc <- "β‐catenin and neural cell adhesion molecule (NCAM)"
specialTestStudyObj <- OmicNavigator:::testStudy(name = "ABCspecial",
                                                 description = specialDesc)

specialPath <- exportStudy(specialTestStudyObj, type = "package", path = tmplib)
observed <- read.dcf(file.path(specialPath, "DESCRIPTION"), fields = "Description")
expect_identical_xl(as.character(observed), specialDesc,
                    info = "Export special character in description field")

# Export as package directory --------------------------------------------------

observed <- exportStudy(testStudyObj, type = "package", path = tmplib)
expected <- file.path(tmplib, OmicNavigator:::studyToPkg(testStudyName))
expect_identical_xl(observed, expected, info = "Export as package directory")
expect_true_xl(dir.exists(expected))

# Export to a directory with a space
observed <- exportStudy(testStudyObj, type = "package", path = tmplibSpace)
expected <- file.path(tmplibSpace, OmicNavigator:::studyToPkg(testStudyName))
expect_identical_xl(observed, expected,
                    info = "Export as package directory to path with a space")
expect_true_xl(dir.exists(expected))

# Export to a directory with a single quote
observed <- exportStudy(testStudyObj, type = "package", path = tmplibQuote)
expected <- file.path(tmplibQuote, OmicNavigator:::studyToPkg(testStudyName))
expect_identical_xl(observed, expected,
                    info = "Export as package directory to path with a quote")
expect_true_xl(dir.exists(expected))

# Export minimal study
observed <- exportStudy(minimalStudyObj, type = "package", path = tmplib)
expected <- file.path(tmplib, OmicNavigator:::studyToPkg(minimalStudyName))
expect_identical_xl(observed, expected,
                    info = "Export minimal study as package directory")
expect_true_xl(dir.exists(expected))

# Export as package tarball ----------------------------------------------------

# These tests fail on all CRAN macOS machines and most CRAN Linux machines. I
# have no idea why. They also fail in GitHub Actions. The call to `R CMD build`
# looks fine, so I don't know what more I could do on my end to fix the failed
# tarball creation. They are only tested locally when running
# tinytest::test_all() or tinytest::run_test_file()

if (at_home()) {
  tarball <- exportStudy(testStudyObj, type = "tarball", path = tmplib)
  expect_true_xl(file.exists(tarball))
  expect_true_xl(startsWith(tarball, tmplib))
  directoryname <- file.path(tmplib, OmicNavigator:::studyToPkg(testStudyName))
  expect_false_xl(dir.exists(directoryname))

  # Confirm tarball is overwritten when re-exported
  modtimeOriginal <- file.mtime(tarball)
  tarball <- exportStudy(testStudyObj, type = "tarball", path = tmplib)
  modtimeReexport <- file.mtime(tarball)
  expect_true_xl(
    modtimeReexport > modtimeOriginal,
    info = "Confirm tarball is overwritten when re-exported"
  )

  # Export to a directory with a space
  tarball <- exportStudy(testStudyObj, type = "tarball", path = tmplibSpace)
  expect_true_xl(file.exists(tarball))
  expect_true_xl(startsWith(tarball, tmplibSpace))
  directoryname <- file.path(tmplibSpace, OmicNavigator:::studyToPkg(testStudyName))
  expect_false_xl(dir.exists(directoryname))

  # Export to a directory with a single quote
  tarball <- exportStudy(testStudyObj, type = "tarball", path = tmplibQuote)
  expect_true_xl(file.exists(tarball))
  expect_true_xl(startsWith(tarball, tmplibQuote))
  directoryname <- file.path(tmplibQuote, OmicNavigator:::studyToPkg(testStudyName))
  expect_false_xl(dir.exists(directoryname))

  # Export minimal study
  expect_message_xl(
    tarball <- exportStudy(minimalStudyObj, type = "tarball", path = tmplib),
    "Note: No maintainer email was specified. Using the placeholder: "
  )
  expect_true_xl(file.exists(tarball))
  expect_true_xl(startsWith(tarball, tmplib))
  directoryname <- file.path(tmplib, OmicNavigator:::studyToPkg(minimalStudyName))
  expect_false_xl(dir.exists(directoryname))

  # Return warning message if package fails to build
  pkgDir <- tempfile(pattern = OmicNavigator:::getPrefix())
  dir.create(pkgDir, showWarnings = FALSE, recursive = TRUE)
  # Use invalid package name to trigger build failure
  writeLines("Package: 1pkg", con = file.path(pkgDir, "DESCRIPTION"))

  expect_warning_xl(
    OmicNavigator:::buildPkg(pkgDir),
    "Malformed package name",
    info = "Return warning message for failed package build"
  )

  # Fix the problematic package name
  writeLines("Package: onepkg", con = file.path(pkgDir, "DESCRIPTION"))

  expect_silent_xl(
    tarball <- OmicNavigator:::buildPkg(pkgDir)
  )

  unlink(pkgDir, recursive = TRUE, force = TRUE)
  file.remove(tarball)
}

# Check package metadata -------------------------------------------------------

suppressMessages(installStudy(testStudyObj, library = tmplib))
studyMetadata <- listStudies(libraries = tmplib)

expect_identical_xl(
  studyMetadata[[1]][["name"]],
  testStudyObj[["name"]]
)

expect_identical_xl(
  studyMetadata[[1]][["package"]][["Description"]],
  sprintf("The OmicNavigator data package for the study \"%s\"",
          testStudyObj[["description"]]),
  info = "Default package description when description==name"
)

expect_identical_xl(
  studyMetadata[[1]][["package"]][["Version"]],
  "0.0.0.9000",
  info = "Default package version used when version=NULL"
)

expect_identical_xl(
  studyMetadata[[1]][["package"]][["Maintainer"]],
  "Unknown <unknown@unknown>",
  info = "Default package maintainer"
)

expect_identical_xl(
  studyMetadata[[1]][["package"]][["department"]],
  "immunology",
  info = "Custom study metadata passed via studyMeta"
)

expect_identical_xl(
  studyMetadata[[1]][["package"]][["organism"]],
  "Mus musculus",
  info = "Custom study metadata passed via studyMeta"
)

updatedStudyObj <- testStudyObj
updatedStudyObj[["description"]] <- "A custom description"
updatedStudyObj[["version"]] <- "1.0.0"
updatedStudyObj[["maintainer"]] <- "My Name"
updatedStudyObj[["maintainerEmail"]] <- "me@email.com"

suppressMessages(installStudy(updatedStudyObj, library = tmplib))
studyMetadata <- listStudies(libraries = tmplib)

expect_identical_xl(
  studyMetadata[[1]][["name"]],
  updatedStudyObj[["name"]]
)

expect_identical_xl(
  studyMetadata[[1]][["package"]][["Description"]],
  updatedStudyObj[["description"]]
)

expect_identical_xl(
  studyMetadata[[1]][["package"]][["Version"]],
  updatedStudyObj[["version"]]
)

expect_identical_xl(
  studyMetadata[[1]][["package"]][["Maintainer"]],
  sprintf("%s <%s>", updatedStudyObj[["maintainer"]],
          updatedStudyObj[["maintainerEmail"]])
)

# Remove installed study -------------------------------------------------------

studyToRemoveName <- "remove"
studyToRemove <- OmicNavigator:::testStudy(name = studyToRemoveName)
suppressMessages(installStudy(studyToRemove, library = tmplib))
studyToRemoveDir <- file.path(tmplib, OmicNavigator:::studyToPkg(studyToRemoveName))

expect_true_xl(dir.exists(studyToRemoveDir))

expect_message_xl(
  removeStudy(studyToRemove, library = tmplib),
  studyToRemoveName
)

expect_false_xl(dir.exists(studyToRemoveDir))

# Error handling
expect_error_xl(
  removeStudy(removeStudyName, library = "xyz"),
  "This directory does not exist: xyz"
)

expect_error_xl(
  removeStudy(1),
  "Argument `study` must be a string or an onStudy object"
)

expect_error_xl(
  removeStudy("nonExistent"),
  "Couldn't find"
)

# Teardown ---------------------------------------------------------------------

unlink(c(tmplib, tmplibSpace, tmplibQuote), recursive = TRUE, force = TRUE)
