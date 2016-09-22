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
#' @examples \dontrun{ops_biblio(pizza)}
ops_test <- function(x){
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
  df <- ops_rename(df) # dplyr
  df <- dplyr::bind_rows(df)
}
