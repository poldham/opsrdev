#' @title Create a data frame of results from JSON numbers Open Patent Services
#' @description A JSON formatted response from the European Patent Office Open
#'   Patent Services (OPS)
#' @param data A JSON formatted response object from the OPS Numbers service.
#' @param espacenet Add a link to the espacenet database Default is TRUE.
#' @param google Add a link to the google_patents database. Default is TRUE.
#' @param lens Add a link to the lens database. Default is TRUE.
#' @param patentscope Add a link to the WIPO patentscope database. Default is TRUE.
#' @return A dataframe of results from Open Patent Services.
#' @details Arguments are provided to create hyperlinks from a variety of free
#'   patent databases. Note that coverage varies between databases and, with the
#'   exception of espacenet, it should not be expected that all hyperlinks will
#'   lead to the documents. The epodoc format as used here is effectively the
#'   straight application number minus the kind code.
#' @importFrom dplyr select
#' @importFrom dplyr left_join
#' @importFrom dplyr bind_cols
#' @importFrom httr content
#' @importFrom magrittr %>%
#' @importFrom reshape2 melt
#' @importFrom tidyr unite
#' @export
#' @examples \dontrun{ops_numbers(pizza) #type response}
#' @examples \dontrun{ops_numbers(pizza, espacenet = TRUE, lens = TRUE) # type response}# need list examples for testing
ops_numbers <- function(data, espacenet = FALSE, lens = FALSE, patentscope = FALSE, google = FALSE) {
  # insert the query text for a number search here
if(class(data) == "response"){ # needs to be something different here.
content <- httr::content(data)
results <- reshape2::melt(content)
family_id <- dplyr::filter(results, L3 == "@family-id") %>%
  dplyr::rename(family_id = value, id = L2, set = L1)  %>%
  dplyr::select(family_id)
document_id_type <- dplyr::filter(results, L4 == "@document-id-type") %>%
  dplyr::rename(document_id_type = value, id = L2, set = L1) %>%
  dplyr::select(document_id_type)
country <- dplyr::filter(results, L4 == "country")  %>%
  dplyr::rename(country = value, id = L2, set = L1)  %>%
  dplyr::select(country)
country$country <- as.character(country$country)
doc_number <- dplyr::filter(results, L4 == "doc-number") %>%
  dplyr::rename(doc_number = value, id = L2, set = L1)  %>%
  dplyr::select(doc_number)
kind <- dplyr::filter(results, L4 == "kind") %>%
  dplyr::rename(kind = value, id = L2, set = L1)  %>%
  dplyr::select(kind, id, set)
# removed soft bracket, convert to data frame
df <- dplyr::bind_cols(family_id, document_id_type, country, doc_number, kind) %>%
  tidyr::unite(., epodoc, c(country, doc_number), sep = "", remove = FALSE) %>% #problem here with country doc number
  tidyr::unite(docdb, c(country, doc_number, kind), sep = ".", remove = FALSE) %>%
  tidyr::unite(publication_number, c(epodoc, kind), sep = "", remove = FALSE)
}
#---melt approach --- find more efficient route#
if(class(content) == "list"){
  results <- reshape2::melt(content)
  family_id <- dplyr::filter(results, L3 == "@family-id") %>%
    dplyr::rename(family_id = value, id = L2, set = L1)  %>%
    dplyr::select(family_id)
  document_id_type <- dplyr::filter(results, L4 == "@document-id-type") %>%
    dplyr::rename(document_id_type = value, id = L2, set = L1) %>%
    dplyr::select(document_id_type)
  country <- dplyr::filter(results, L4 == "country")  %>%
    dplyr::rename(country = value, id = L2, set = L1)  %>%
    dplyr::select(country)
  country$country <- as.character(country$country)
  doc_number <- dplyr::filter(results, L4 == "doc-number") %>%
    dplyr::rename(doc_number = value, id = L2, set = L1)  %>%
    dplyr::select(doc_number)
  kind <- dplyr::filter(results, L4 == "kind") %>%
    dplyr::rename(kind = value, id = L2, set = L1)  %>%
    dplyr::select(kind, id, set)
  # removed soft bracket, convert to data frame
  df <- dplyr::bind_cols(family_id, document_id_type, country, doc_number, kind) %>%
    tidyr::unite(., epodoc, c(country, doc_number), sep = "", remove = FALSE) %>% #problem here with country doc number
    tidyr::unite(docdb, c(country, doc_number, kind), sep = ".", remove = FALSE) %>%
    tidyr::unite(publication_number, c(epodoc, kind), sep = "", remove = FALSE)
}
results <- reshape2::melt(content)
  family_id <- dplyr::filter(results, L3 == "@family-id") %>%
    dplyr::rename(family_id = value, id = L2, set = L1)  %>%
    dplyr::select(family_id)
  document_id_type <- dplyr::filter(results, L4 == "@document-id-type") %>%
    dplyr::rename(document_id_type = value, id = L2, set = L1) %>%
    dplyr::select(document_id_type)
  country <- dplyr::filter(results, L4 == "country")  %>%
    dplyr::rename(country = value, id = L2, set = L1)  %>%
    dplyr::select(country)
  country$country <- as.character(country$country)
  doc_number <- dplyr::filter(results, L4 == "doc-number") %>%
    dplyr::rename(doc_number = value, id = L2, set = L1)  %>%
    dplyr::select(doc_number)
  kind <- dplyr::filter(results, L4 == "kind") %>%
    dplyr::rename(kind = value, id = L2, set = L1)  %>%
    dplyr::select(kind, id, set)
# removed soft bracket, convert to data frame
  df <- dplyr::bind_cols(family_id, document_id_type, country, doc_number, kind) %>%
    tidyr::unite(., epodoc, c(country, doc_number), sep = "", remove = FALSE) %>% #problem here with country doc number
    tidyr::unite(docdb, c(country, doc_number, kind), sep = ".", remove = FALSE) %>%
    tidyr::unite(publication_number, c(epodoc, kind), sep = "", remove = FALSE)
  # add urls
if(espacenet == TRUE){
  e_df <- dplyr::select(df, publication_number)
  e_df$e_url <- "http://worldwide.espacenet.com/searchResults?submitted=true&locale=en_EP&DB=EPODOC&ST=advanced&TI=&AB=&PN="
  e_df <- tidyr::unite(e_df, "espacenet", c(e_url, publication_number), sep = "", remove = FALSE) %>%
    dplyr::select(., espacenet, publication_number)
  df <- dplyr::left_join(df, e_df, by = "publication_number")
} else {df}
if(google == TRUE){
    g_df <- dplyr::select(df, publication_number)
    g_df$g_url <- "https://patents.google.com/patent/"
    g_df <- tidyr::unite(g_df, "google_patents", c(g_url, publication_number), sep = "", remove = FALSE) %>%
      dplyr::select(., google_patents, publication_number)
    df <- dplyr::left_join(df, g_df, by = "publication_number")
  } else {df}
if(lens == TRUE){
  l_df <- dplyr::select(df, publication_number)
  l_df$l_url <- "https://www.lens.org/lens/search?n=10&q="
  l_df <- tidyr::unite(l_df, "lens", c(l_url, publication_number), sep = "", remove = FALSE) %>%
    dplyr::select(., lens, publication_number)
  df <- dplyr::left_join(df, l_df, by = "publication_number")
} else {df}
if(patentscope == TRUE){
 w_df <- dplyr::select(df, epodoc, publication_number)
 w_df$w_url <- "https://patentscope.wipo.int/search/en/detail.jsf?docId="
 w_df <- tidyr::unite(w_df, "patentscope", c(w_url, epodoc), sep = "", remove = FALSE) %>%
   dplyr::select(., patentscope, publication_number)
 df <- dplyr::left_join(df, w_df, by = "publication_number")
} else {df}
  # add country_name
df$country_name <- ops_country(df, col = "country")
  # add fulltext available logical column --- use ops_filter here
ft <- c("AT", "CA", "CH", "EP", "ES", "GB", "WO")
full_text <- as.data.frame(df$country %in% ft)
full_text$full_text <- full_text$`df$country %in% ft`
full_text$`df$country %in% ft` <- NULL
df <- cbind(df, full_text)
}

# the full text available logical column is not working correctly - should it be rbind and not cbind in the final line

#develop a test for this.