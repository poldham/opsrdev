#' @title Rename Patent Lens Columns
#' @description Convert Lens database column names from sentence case to lower
#'   case, replace spaces with underscores, shorten names with brackets and
#'   shorten classification names.
#' @param data a raw data.frame of patent results from the lens.
#' @return a data frame with lower case names and underscores in place of
#'   spaces.
#' @details Uses tolower from base to convert all names to lower and then uses
#'dplyr rename_ to rename each column
#' @export
#' @importFrom dplyr rename_
#' @examples \dontrun{rename_lens(data)}
rename_lens <- function(data) {
  names(data) <- tolower(names(data)) #converts all cols to lowercase
  dplyr::rename_(data, publication_number = "`publication number`",
    publication_date = "`publication date`",
    publication_year = "`publication year`",
    application_number = "`application number`",
    application_date = "`application date`",
    priority_numbers = "`priority numbers`",
    full_text = "`full text`",
    cited_count = "`cited count`",
    simple_family_size = "`simple family size`",
    extended_family_size = "`extended family size`",
    sequence_count = "`sequence count`",
    cpc = "`cpc classifications`",
    ipc = "`ipcr classifications`",
    us_classification = "`us classifications`",
    pubmed_id = "`pubmed id(s)`",
    doi = "`doi(s)`",
    npl = "`non-patent citations`",
    country = "jurisdiction")
}
#  original column names are sentence case. The first line of the function converts all to lower case and rename follows from there. The code also replaces col names with brackets.
