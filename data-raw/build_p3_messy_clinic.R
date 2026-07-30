# One-off generator for data/p3_messy_clinic.xlsx, the deliberately messy
# spreadsheet used in P3's Block 1 exercise. Not part of the book build:
# no chapter sources or runs this script, and the book never depends on
# the openxlsx package. It's kept here purely so the asset is
# reproducible if it ever needs to be regenerated or tweaked. Run once,
# by hand, from the project root:
#
#   install.packages("openxlsx")
#   source("data-raw/build_p3_messy_clinic.R")
#
# This overwrites data/p3_messy_clinic.xlsx, which is the file actually
# read by chapters/p3.qmd and is committed to the repo.

library(openxlsx)

wb <- createWorkbook()
addWorksheet(wb, "Visits")

## --- Table 1: patient visit log, with a merged sub-header over two columns
## Row 1: title, merged across the whole table width
## Row 2: "Vitals" merged across the Weight/Height columns
## Row 3: real column headers
## Rows 4-11: 8 fake patients

writeData(wb, "Visits", "Clinic Visit Log - Week 12", startCol = 1, startRow = 1)
mergeCells(wb, "Visits", cols = 1:7, rows = 1)

writeData(wb, "Visits", "Vitals", startCol = 5, startRow = 2)
mergeCells(wb, "Visits", cols = 5:6, rows = 2)

headers <- c("Patient ID", "Name", "Visit date", "Age", "Weight", "Height", "Smoker")
writeData(wb, "Visits", t(headers), startCol = 1, startRow = 3, colNames = FALSE)

patients <- data.frame(
  id = c("P01", "P02", "P03", "P04", "P05", "P06", "P07", "P08"),
  name = c("A. Ferreira", "B. Okafor", "C. Nilsson", "D. Petrova",
           "E. Marsh", "F. Haddad", "G. Lindqvist", "H. Osei"),
  visit_date = c("03/03/2025", "03/03/2025", "04/03/2025", "04/03/2025",
                 "05/03/2025", "05/03/2025", "06/03/2025", "06/03/2025"),
  age = c(34, 61, 45, 29, 52, 38, 67, 41),
  weight = c("72kg", "88kg", "65kg", "59kg", "94kg", "77kg", "68kg", "81kg"),
  height = c("1.70m", "1.78m", "1.62m", "1.65m", "1.74m", "1.80m", "1.58m", "1.72m"),
  stringsAsFactors = FALSE
)

writeData(wb, "Visits", patients, startCol = 1, startRow = 4, colNames = FALSE)

## Smoker status encoded by cell colour only, no text in the column at all
smoker_fill <- createStyle(fgFill = "#F4A6A6")
non_smoker_fill <- createStyle(fgFill = "#A9D9A9")
is_smoker <- c(TRUE, FALSE, TRUE, FALSE, TRUE, FALSE, FALSE, TRUE)
for (i in seq_along(is_smoker)) {
  addStyle(wb, "Visits",
    style = if (is_smoker[i]) smoker_fill else non_smoker_fill,
    rows = 3 + i, cols = 7, gridExpand = TRUE)
}

## A note in the margin, off to the side of the table, unrelated to any column
writeData(wb, "Visits", "call P05 back - missed last follow-up",
  startCol = 9, startRow = 8)

## A blank spacer row, then a second, unrelated small table on the same sheet
writeData(wb, "Visits", "Follow-up schedule", startCol = 1, startRow = 13)
writeData(wb, "Visits", t(c("Patient ID", "Next visit")), startCol = 1, startRow = 14,
  colNames = FALSE)
followups <- data.frame(
  id = c("P01", "P03", "P05", "P07"),
  next_visit = c("17/03/2025", "18/03/2025", "18/03/2025", "20/03/2025"),
  stringsAsFactors = FALSE
)
writeData(wb, "Visits", followups, startCol = 1, startRow = 15, colNames = FALSE)

setColWidths(wb, "Visits", cols = 1:9, widths = c(10, 14, 12, 6, 9, 9, 9, 2, 30))

saveWorkbook(wb, "data/p3_messy_clinic.xlsx", overwrite = TRUE)
cat("Saved data/p3_messy_clinic.xlsx\n")
