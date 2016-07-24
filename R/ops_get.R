#' @title Obtain a set of urls from ops_publications
#' @description Used in conjunction with ops_iterate. Given a set of urls convert to a get request to retrieve the data from OPS. When the response is received extract the content to create a list.
#' @param url . A single url or vector of urls
#' @return A list.
#' @export
#' @examples \dontrun{lapply(three_urls, ops_get)}
ops_get <- function(url){
  myquery <- httr::GET(paste0(url), httr::content_type("plain/text"), httr::accept("application/json"))
  content <- httr::content(myquery) #required or raw return
  # results <- content$`ops:world-patent-data`$`ops:biblio-search`$`ops:search-result`$`ops:publication-reference`

  #testing to access list at right level
  #will need expanding to inherit the service from the parent function.
  # if(length(url) > 1){
  #   content <- lapply(myquery, httr::content)
  #   return(content)
    #results <- unlist(content, recursive = FALSE) # need to access the content at the level above first to use in melt
  # }
  }


