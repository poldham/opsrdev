#' @title Process Multiple Lists of OPS Bibliographic Data
#'
#' @description Use this function to process lists containing multiple lists of
#'   bibliographic data from OPS into a single data frame. Typically, the object
#'   will contain the results of multiple calls to OPS for bibliographic data in
#'   chunks of 100 records (see ops_urls()). For example, 10 calls will generate
#'   a single list containing 10 list objects each containing 100 records. For
#'   single lists of 100 records use ops_biblio().
#' @details The function uses rapply and later aggregate. Note that aggregate
#'   will generate a warning. The use of fill() from tidyr is a temporary
#'   measure and is a likely source of weakness in the code. Note that in order
#'   to produce data.frames with an equal number of columns across all years the
#'   `ipc` column for the historic IPC7 classification is dropped where present.
#' @param x A list of lists containing bibliographic data from OPS
#' @return a data.frame
#' @importFrom plyr ldply
#' @importFrom stringr str_replace
#' @importFrom tidyr spread
#' @importFrom tidyr separate
#' @importFrom magrittr %>%
#' @importFrom stats aggregate
#' @export
#' @examples \dontrun{ops_multi_biblio(ops_biblios)}
ops_multi_biblio <- function(x){
  if(class(x) == "response"){
  df <- httr::content(x)
  return(df)
  }
  df <- rapply(x, as.character, classes = "character", deflt = as.integer(NA, how = "unlist")) %>%
    plyr::ldply()
  df <- dplyr::left_join(df, ops_dictionary, by = ".id") %>% #requires ops_dictionary to be available for renaming exercise
    select(names, V1)
  df$rows <- 1:nrow(df)
  df <- tidyr::spread(df, names, V1)
# create a doc_no table
  df_docno <- dplyr::select_(df, "meta_document_number")
  df_docno <- tidyr::fill(df_docno, meta_document_number, .direction = "down") # fills correctly, point of weakness
  df_docno <- tidyr::fill(df_docno, meta_document_number, .direction = "up") # fills correctly, point of weakness.
  df$id <- df_docno$meta_document_number
  if("ipc" %in% colnames(df)){
    dplyr::select(df, -ipc)} else {df
    }# drops the historic ipc7 column called ipc where present for consistency with newer data.

  #there is more than one possibility for the field names here... so will need an if based on criteri. The difference is the presence of cited
  df <- aggregate(x=df[c("abstract", "abstract_language", "applicant", "applicant_format", "applicant_sequence", "application_country", "application_date", "application_id", "application_kind", "application_number", "application_type", "cited_by", "cited_category", "cited_literature_number", "cited_literature_text", "cited_office", "cited_patent_count", "cited_patent_country", "cited_patent_date", "cited_patent_document_id_type", "cited_patent_kind", "cited_patent_number", "cited_patent_number_type", "cited_phase", "cited_sequence", "classification_office", "classification_scheme", "classification_symbol", "classification_value", "cpc_class", "cpc_group", "cpc_section", "cpc_sequence", "cpc_subclass", "cpc_subgroup", "inventor", "inventor_format", "inventor_sequence", "ipc_sequence", "ipc_text", "meta_country", "meta_document_number", "meta_family_id", "meta_kind", "meta_system", "ops_meta_name", "ops_meta_value", "priority_date", "priority_kind", "priority_number", "priority_sequence", "priority_type", "publication_country", "publication_date", "publication_kind", "publication_number", "publication_type", "query", "query_range_begin", "query_range_end", "query_syntax", "title", "title_language", "total_result_count", "xmlns", "xmlns_ops", "xmlns_xlink")], by=list(id=df$id), min, na.rm = TRUE)
}
