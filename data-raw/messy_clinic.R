# One-off generator for data/05-prep2-messy-clinic.xlsx, the deliberately messy
# spreadsheet used in 05-prep2.qmd's spreadsheet exercise. Not part of the
# book build: no chapter sources or runs this script, and the book never
# depends on the openxlsx package. It's kept here purely so the asset is
# reproducible if it ever needs to be regenerated or tweaked. Run once,
# by hand, from the project root:
#
#   install.packages("openxlsx")
#   source("data-raw/messy_clinic.R")
#
# This overwrites data/05-prep2-messy-clinic.xlsx, which is the file actually
# read by chapters/05-prep2.qmd and is committed to the repo. Diff the
# result against the version already in the repo before committing an
# overwrite: the committed file has been hand-tuned since this script was
# last run, and an unreviewed overwrite would throw that away.

library(openxlsx)

wb <- createWorkbook()
addWorksheet(wb, "Visits")

## --- Table 1: patient visit log, with a merged sub-header over the two
## measurement columns, whole rows highlighted instead of a Smoker column,
## and inconsistent units on one patient's weight and height.
## Row 1: title, merged across the whole table width
## Row 2: "Measurements" merged across the Weight/Height columns
## Row 3: real column headers
## Rows 4-11: 8 fake patients

writeData(
  wb,
  "Visits",
  "Clinic Visit Log - Week 12",
  startCol = 1,
  startRow = 1
)
mergeCells(wb, "Visits", cols = 1:6, rows = 1)

writeData(wb, "Visits", "Measurements", startCol = 5, startRow = 2)
mergeCells(wb, "Visits", cols = 5:6, rows = 2)

headers <- c(
  "Patient ID",
  "Name",
  "Visit date",
  "Age",
  "Weight",
  "Height"
)
writeData(
  wb,
  "Visits",
  t(headers),
  startCol = 1,
  startRow = 3,
  colNames = FALSE
)

## Weight and height are text throughout, not just where the units are
## inconsistent: P06 is recorded in pounds and feet rather than kilograms
## and metres, and P02's height, 178, is centimetres sitting undistinguished
## among a column that's otherwise metres. Either one on its own is enough
## to make read_csv() treat the whole column as text.
patients <- data.frame(
  id = c("P01", "P02", "P03", "P04", "P05", "P06", "P07", "P08"),
  name = c(
    "A Ferreira",
    "B Okafor",
    "C Nilsson",
    "D Petrova",
    "E Marsh",
    "F Haddad",
    "G Lindqvist",
    "H Osei"
  ),
  visit_date = c(
    "03/03/2025",
    "03/03/2025",
    "04/03/2025",
    "04/03/2025",
    "05/03/2025",
    "05/03/2025",
    "06/03/2025",
    "06/03/2025"
  ),
  age = c(34, 61, 45, 29, 52, 38, 67, 41),
  weight = c("72", "88", "65", "59", "94", "195 lbs", "68", "81"),
  height = c("1.70", "178", "1.62", "1.65", "1.74", "6 ft", "1.58", "1.72"),
  stringsAsFactors = FALSE
)

writeData(wb, "Visits", patients, startCol = 1, startRow = 4, colNames = FALSE)

## Smoker status is carried by highlighting the whole row yellow, with no
## Smoker column at all. The only place that says what the colour means is
## the caption several rows below the table (row 13), disconnected from the
## table itself.
smoker_fill <- createStyle(fgFill = "#FFFF00")
is_smoker <- c(FALSE, TRUE, FALSE, TRUE, FALSE, TRUE, TRUE, FALSE)
for (i in seq_along(is_smoker)) {
  if (is_smoker[i]) {
    addStyle(
      wb,
      "Visits",
      style = smoker_fill,
      rows = 3 + i,
      cols = 1:6,
      gridExpand = TRUE
    )
  }
}

## A note in the margin, off to the side of the table, unrelated to any column
writeData(
  wb,
  "Visits",
  "call P05 back - missed last follow-up",
  startCol = 7,
  startRow = 8
)

## A blank spacer row, then the caption explaining the highlighting, then a
## second blank spacer row, then a second, unrelated small table on the
## same sheet.
writeData(wb, "Visits", "Highlighted are smokers", startCol = 1, startRow = 13)

writeData(wb, "Visits", "Follow-up schedule", startCol = 1, startRow = 15)
writeData(
  wb,
  "Visits",
  t(c("Patient ID", "Next visit")),
  startCol = 1,
  startRow = 16,
  colNames = FALSE
)
followups <- data.frame(
  id = c("P01", "P03", "P05", "P07"),
  next_visit = c("17/03/2025", "18/03/2025", "18/03/2025", "20/03/2025"),
  stringsAsFactors = FALSE
)
writeData(
  wb,
  "Visits",
  followups,
  startCol = 1,
  startRow = 17,
  colNames = FALSE
)

setColWidths(
  wb,
  "Visits",
  cols = 1:7,
  widths = c(10, 14, 12, 6, 9, 9, 30)
)

saveWorkbook(wb, "data/05-prep2-messy-clinic.xlsx", overwrite = TRUE)
cat("Saved data/05-prep2-messy-clinic.xlsx\n")
