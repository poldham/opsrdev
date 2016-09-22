#' @title Obtain patent numbers from Open Patent Services
#' @description Retrieve a set of patent numbers for a query from OPS. Mainly
#'   useful for obtaining sample data or for generating numbers for use in POST
#'   requests.
#' @param query A quoted query
#' @param type - character, ti (title), ta (title & abstract), biblio (default)
#' @param start - YYYY or YYYYMMDD, publication date.
#' @param end - YYYY or YYYYMMDD, publication date.
#' @param range - specify as unquoted 1-100. Default is 25. Max is 100.
#' @return A dataframe.
#' @importFrom dplyr %>%
#' @importFrom httr content
#' @importFrom tidyr unite
#' @importFrom dplyr select
#' @export
#' @examples \dontrun{ops_numbers("pizza")}
ops_numbers_new <- function(query="", type = "NULL", start = NULL, end = NULL, range = NULL){
  baseurl <- "http://ops.epo.org/3.1/rest-services/published-data/search?q="
if(type == "ti") {
  query <- paste0("ti", "%3D", query)
}
if(type == "ta") {
  query <- paste0("ta", "%3D", query)
}
if(type == "biblio") {
  query <- paste0(query)
}
if(type == "NULL") {
  query <- paste0(query)
}
if(is.numeric(start) | is.numeric(end)) {
  within <- " and pd within " # note spaces
  dates <- paste0("%22", start, "%20", end, "%22") # neater solution?
  myquery <- httr::GET(paste0(baseurl, query, RCurl::curlEscape(within), dates), httr::content_type("plain/text"), httr::accept("application/json"))
  content <- httr::content(myquery)} else {
    myquery <- httr::GET(paste0(baseurl, query), httr::content_type("plain/text"), httr::accept("application/json"))
    }
    # extract the data fields into lists
    content <- httr::content(myquery)
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
    # transform the data to useful numbers. Make sure format is correct  for different format types.
    df <- tidyr::unite(df, epodoc_format, c(country, docnumber), sep = "", remove = FALSE) %>%
      tidyr::unite(docdb_format, c(country, docnumber, kind), sep = ".", remove = FALSE) %>%
      tidyr::unite(publication_number, c(country, docnumber, kind), sep = "", remove = FALSE)
  }
