#' @title Convert OPS biblio names in Rows from JSON format to sane names (internal function)
#' @description Used internally. Assumes a data.frame with two columns. Column 1 contains JSON strings as rows to be renamed. Column 2 contains the data. The function replaces Column 1 row content with the dictionary entry in `ops_dictionary` using dplyr::left_join(). To convert column names (rather than row names) use ops_rename(). Note check consistency between ops_dictionary and ops_rename.
#' @param x a dataframe with row names to be converted from JSON to sane text.
#' @details calls ops_dictionary to convert OPS JSON strings to normal names. ops_dictionary must be available for this to work.
#' @return a data.frame with column 1 rows renamed.
#' @export
#' @importFrom dplyr left_join
#' @importFrom dplyr select
#' @examples \dontrun{ops_biblio_rename(df)}
ops_biblio_rename <- function(x) {
  load(ops_dictionary)
  df <- dplyr::left_join(x, ops_dictionary, by = ".id") %>% #requires ops_dictionary to be available for renaming exercise
    dplyr::select(names, 2) # changed from V1 to make more generic
}
