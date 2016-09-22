# the if and else is not working properly, otherwise seems ok. maybe I need else if

ops_new_biblio <- function(x){
  library(dplyr)
  df <- httr::content(x)
  # if(class(x) == "response"){
  #   x <- httr::content(x)
  #   return(x)
  # }
  df <- rapply(df, as.character, classes = "character", deflt = as.integer(NA, how = "unlist")) %>%
    plyr::ldply()
  df <- dplyr::left_join(df, ops_dictionary, by = ".id") %>% #requires ops_dictionary to be available for renaming exercise
    select(names, V1)
# there is a not found issue in 13 places
# df <- filter(df, V1 == "not found) then what (use %in%)
  df$rows <- 1:nrow(df)
  df <- tidyr::spread(df, names, V1)
  # create a doc_no table
  df_docno <- dplyr::select_(df, "meta_document_number")
    df_docno <- tidyr::fill(df_docno, meta_document_number, .direction = "down") # fills correctly, point of weakness
  df_docno <- tidyr::fill(df_docno, meta_document_number, .direction = "up") # fills correctly, point of weakness.
  df$id <- df_docno$meta_document_number
  if("ipc" %in% colnames(df)){
    dplyr::select(df, -ipc)} else {df
    }
  if("rows" %in% colnames(df)){ # fudge using rows
    df <- aggregate(x=df[c("rows", "abstract", "abstract_language", "applicant", "applicant_format", "applicant_sequence", "application_country", "application_date", "application_id", "application_kind", "application_number",    "application_type", "classification_office", "classification_scheme", "classification_value", "cpc_class", "cpc_group", "cpc_section", "cpc_sequence", "cpc_subclass", "cpc_subgroup", "inventor", "inventor_format", "inventor_sequence", "ipc_sequence", "ipc_text", "meta_country", "meta_document_number", "meta_family_id", "meta_kind", "meta_status", "meta_system", "ops_meta_name", "ops_meta_value", "priority_date", "priority_kind", "priority_number", "priority_sequence", "priority_type", "publication_country", "publication_date", "publication_kind", "publication_number", "publication_type", "title", "title_language", "xmlns", "xmlns_ops", "xmlns_xlink", "id" )], by=list(id=df$id), min, na.rm = TRUE)} else {df}
# if("cited_by" %in% colnames(df)){
#   df <- aggregate(x=df[c("abstract", "abstract_language", "applicant", "applicant_format", "applicant_sequence", "application_country", "application_date", "application_id", "application_kind", "application_number", "application_type", "cited_by", "cited_category", "cited_literature_number", "cited_literature_text", "cited_office", "cited_patent_count", "cited_patent_country", "cited_patent_date", "cited_patent_document_id_type", "cited_patent_kind", "cited_patent_number", "cited_patent_number_type", "cited_phase", "cited_sequence", "classification_office", "classification_scheme", "classification_symbol", "classification_value", "cpc_class", "cpc_group", "cpc_section", "cpc_sequence", "cpc_subclass", "cpc_subgroup", "inventor", "inventor_format", "inventor_sequence", "ipc_sequence", "ipc_text", "meta_country", "meta_document_number", "meta_family_id", "meta_kind", "meta_system", "ops_meta_name", "ops_meta_value", "priority_date", "priority_kind", "priority_number", "priority_sequence", "priority_type", "publication_country", "publication_date", "publication_kind", "publication_number", "publication_type", "query", "query_range_begin", "query_range_end", "query_syntax", "title", "title_language", "total_result_count", "xmlns", "xmlns_ops", "xmlns_xlink")], by=list(id=df$id), min, na.rm = TRUE)
# } else {df}
}
# # drops the historic ipc7 column called ipc where present for consistency with newer data.
#   df <- aggregate(x=df[c("abstract", "abstract_language", "applicant", "applicant_format", "applicant_sequence", "application_country", "application_date", "application_id", "application_kind", "application_number", "application_type", "cited_by", "cited_category", "cited_literature_number", "cited_literature_text", "cited_office", "cited_patent_count", "cited_patent_country", "cited_patent_date", "cited_patent_document_id_type", "cited_patent_kind", "cited_patent_number", "cited_patent_number_type", "cited_phase", "cited_sequence", "classification_office", "classification_scheme", "classification_symbol", "classification_value", "cpc_class", "cpc_group", "cpc_section", "cpc_sequence", "cpc_subclass", "cpc_subgroup", "inventor", "inventor_format", "inventor_sequence", "ipc_sequence", "ipc_text", "meta_country", "meta_document_number", "meta_family_id", "meta_kind", "meta_system", "ops_meta_name", "ops_meta_value", "priority_date", "priority_kind", "priority_number", "priority_sequence", "priority_type", "publication_country", "publication_date", "publication_kind", "publication_number", "publication_type", "query", "query_range_begin", "query_range_end", "query_syntax", "title", "title_language", "total_result_count", "xmlns", "xmlns_ops", "xmlns_xlink")], by=list(id=df$id), min, na.rm = TRUE)
# }