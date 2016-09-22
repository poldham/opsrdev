#' @title internal Parse return from the numbers service from melt into data.frame
#' @description This is used internally to convert the results of a call to ops_publications containing more than 100 results into a data.frame. The input in ops_publications is a data.frame from reshape2.
#' @param results a data.frame
#' @export
#' @return a data frame
#'
#' @examples \dontrun{parse_numbers_results(results)}
parse_numbers_results_ <- function(results){
family_id <- dplyr::filter(results, L7 == "@family-id") %>%
    dplyr::rename(family_id = value, id = L2, set = L1) %>%
    dplyr::select(family_id)
document_id_type <- dplyr::filter(results, L8 == "@document-id-type") %>%
    dplyr::rename(document_id_type = value, id = L2, set = L1) %>%
    dplyr::select(document_id_type)
country <- dplyr::filter(results, L8 == "country") %>%
    dplyr::rename(country = value, id = L2, set = L1) %>%
    dplyr::select(country)
country$country <- as.character(country$country)
doc_number <- dplyr::filter(results, L8 == "doc-number") %>%
    dplyr::rename(doc_number = value, id = L2, set = L1) %>%
    dplyr::select(doc_number)
kind <- dplyr::filter(results, L8 == "kind") %>%
    dplyr::rename(kind = value, id = L2, set = L1) %>%
    dplyr::select(kind, id, set)
df <- dplyr::bind_cols(family_id, document_id_type, country, doc_number, kind) %>%
    tidyr::unite(., epodoc, c(country, doc_number), sep = "", remove = FALSE) %>%
    tidyr::unite(docdb, c(country, doc_number, kind), sep = ".", remove = FALSE) %>%
    tidyr::unite(publication_number, c(epodoc, kind), sep = "", remove = FALSE)
#  ops_country(data = df, col = "country") to add
}
