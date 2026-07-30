# gtsummary tables are built on gt, and gt's LaTeX output fails to compile when
# nested inside a callout ("LaTeX Error: Not in outer par mode"). Every chapter's
# Solutions section is a collapsed callout, so any gtsummary table shown there
# breaks the PDF build. Confirmed still present with gt 1.3.0 / gtsummary 2.5.1 /
# Quarto 1.8.25.
#
# Registering our own knit_print method for gtsummary objects sends LaTeX output
# through as_kable_extra(), which compiles anywhere, and leaves HTML output on
# gtsummary's normal gt path. Doing it here rather than at each call site is the
# point: the workaround stays out of the code students read, so a chapter just
# prints a table and it works in both formats. An earlier version of this file
# exported a print_gtsummary() helper that had to be piped onto each table, which
# meant a student copying a solution hit "could not find function".
#
# Sourced from the hidden setup chunk of every chapter that loads gtsummary
# (W1, W2, W3, W5), so PDF tables look the same throughout the book rather than
# switching engine from chapter to chapter.
registerS3method(
  "knit_print", "gtsummary",
  function(x, ...) {
    if (knitr::is_latex_output()) {
      knitr::knit_print(gtsummary::as_kable_extra(x), ...)
    } else {
      knitr::knit_print(gtsummary::as_gt(x), ...)
    }
  },
  envir = asNamespace("knitr")
)
