#' Parse Bibliographic Patent Data
#'
#' Takes the content of a POST biblio request in JSON format. Extracts the content, tidies the data, renames the fields using ops_rename(), aggregates and outputs a tidy data.frame. Output will display a warning arising from the use of aggregate().
#' @param x = a JSON formatted response from a POST request to OPS containing bibliographic patent data.
#'
#' @return data frame
#' @importFrom plyr ldply
#' @importFrom stringr str_replace
#' @importFrom tidyr spread
#' @importFrom tidyr separate
#' @importFrom magrittr %>%
#' @importFrom stats aggregate
#' @export
#' @examples \dontrun{ops_biblio(x)}
ops_biblio <- function(x){
  pcontent <- httr::content(x)
  p <- pcontent$`ops:world-patent-data`$`exchange-documents`
  df <- p$`exchange-document`
  docnumber <- as.data.frame(sapply(df, "[[", "@doc-number")) # replace with tapply/vapply
  docnumber$docnumber <- docnumber$`sapply(df, "[[", "@doc-number")`
  names(df) <- docnumber$docnumber
  df <- rapply(df, as.character, classes = "character", deflt = as.integer(NA, how = "unlist")) %>%
    plyr::ldply()
  df$.id <- stringr::str_replace(df$.id, "[.]", "_")
  df <- tidyr::separate(df, .id, c("docnumber", "field"), sep = "_")
  df$rows <- 1:nrow(df)
  df <- tidyr::spread(df, field, V1)
  df <- ops_rename(df) # NEEDS FIXING HERE.
  df <- aggregate(x=df[c("docnumber","rows","meta_country","meta_document_number","meta_family_id","meta_kind", "meta_status", "meta_system","abstract_lang","abstract","application_id","application_id_type","application_id_country","application_date","application_number","application_id_kind", "ipc", "ipc_sequence","ipc_text","title_language","title","applicant_format","applicant_sequence","applicant","inventor_format","inventor_sequence","inventor","cpc_sequence","cpc_class","classification_office","classification_scheme","cpc_value","cpc_country","cpc_group","cpc_section","cpc_subclass","cpc_subgroup","priority_kind","priority_sequence","priority_type","priority_date","priority_number","publication_id_type","publication_id_country","publication_id_date","publication_id_number","publication_id_kind", "cited_by", "cited_phase", "cited_sequence", "cited_category", "cited_npl_number", "cited_npl_text", "cited_patent_number_type", "cited_patent_number", "cited_patent_document_id_type", "cited_country", "cited_patent_document_date", "cited_patent_document_number", "cited_patent_kind")], by=list(id=df$docnumber), min, na.rm = TRUE)
}
