#' @title Testing lapply alternative to the loop approach. Key issue is the sys.message
#'
#' @param x An OPS JSON response or something else at the moment
#'
#' @return A data frame
#' @export
#'
#' @examples \dontrun{ops_test(x)}
# ops_test <- function(x) {
#   if(class(x) == "response"){
#     df <- httr::content(x)
#   }
#   df <- rapply(x, as.character, classes = "character", deflt = as.integer(NA, how = "unlist")) %>%
#     plyr::ldply()
#   df <- dplyr::left_join(df, ops_dictionary, by = ".id") %>% #requires ops_dictionary to be available for renaming exercise
#     select(names, V1)
#   df$rows <- 1:nrow(df)
#   df <- tidyr::spread(df, names, V1)
#   # create a doc_no table
#   df_docno <- dplyr::select_(df, "meta_document_number")
#   df_docno <- tidyr::fill(df_docno, meta_document_number, .direction = "down") # fills correctly, point of weakness
#   df_docno <- tidyr::fill(df_docno, meta_document_number, .direction = "up") # fills correctly, point of weakness.
#   df$id <- df_docno$meta_document_number
#   if("ipc" %in% colnames(df)){
#     dplyr::select(df, -ipc)} else {df
#     }# drops the historic ipc7 column called ipc where present for consistency with newer data.
#   df <- lapply(df, dplyr::bind_rows, .id = "id")
#
#   }
