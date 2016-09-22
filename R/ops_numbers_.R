#' (internal) Process list from ops_publications to data.frame
#' @description Process a list from a call to ops_publications (the numbers service) into a data.frame. Used internally in ops_publications.
#' @param content A list generated from a call to OPS using ops_publications.
#'
#' @return a data frame
#' @export
#' @importFrom tidyr unite
#' @examples \dontrun{ops_numbers(pizza)}
ops_numbers_ <- function(content){
  results <- content$`ops:world-patent-data`$`ops:biblio-search`$`ops:search-result`$`ops:publication-reference`
  familyid <- lapply(results, "[", 2)
  document_id <- sapply(results, "[", 3)  #make nested lists below 3 accessible. replace sapply with vapply.
  country <- lapply(document_id, "[", 2)
  docnumber <- lapply(document_id, "[", 3)
  kind <- lapply(document_id, "[", 4)
  # unlist the data into vectors. try bind_rows now?
  familyid <- unlist(do.call(cbind, familyid))
  country <- unlist(do.call(cbind, country))
  docnumber <- unlist(do.call(cbind, docnumber))
  kind <- unlist(do.call(cbind, kind))
  # combine into a data.frame
  df <- data.frame(familyid, country, docnumber, kind, stringsAsFactors = FALSE)
  # transform the data to useful numbers. Make sure format is correct here for the different types.
  df <- tidyr::unite(df, epodoc_format, c(country, docnumber), sep = "", remove = FALSE) %>%
    tidyr::unite(docdb_format, c(country, docnumber, kind), sep = ".", remove = FALSE) %>%
    tidyr::unite(publication_number, c(country, docnumber, kind), sep = "", remove = FALSE)
  return(df)
}
