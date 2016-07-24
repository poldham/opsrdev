#' @title Count the number of results from a search query.
#' @description Retrieves counts of results from OPS by type (title, title and abstract, biblio = default) and publication date range. Use this function to gain an idea of the total number of results for a search and to use date ranges to limit the results to below the 2,000 limit. The use ops_urls to generate the urls to fetch the data with ops_iterate (and process with service functions such as ops_biblio).
#' @param query character or combinations using CQL
#' @param type Patent document sections. title = "ti", title and abstract = "ta", biblio(front page) = "biblio", default = biblio (NULL)
#' @param start use unquoted YYYYMMDD or YYYY
#' @param end as for start
#' @details The function presently retrieves data only on the publication date, not application or priority dates.
#' @return numeric count of results in OPS by search type (document sections) and date ranges.
#' @examples
#' \dontrun{ops_count("pizza", start = 1990, end = 2000)} # search the biblio (front page) across year range
#' \dontrun{ops_count("pizza", type = "ta")} # search titles and abstracts across all years
#' \dontrun{ops_count("pizza", type = "ti", start = 19900101, end = 20151231)} # search titles between years
#' @export
#' @importFrom httr GET
#' @importFrom httr content_type
#' @importFrom httr accept
#' @importFrom httr content
ops_count <- function(query = "", type = "NULL", start = NULL, end = NULL) {
  baseurl <- "http://ops.epo.org/3.1/rest-services/published-data/search/?q="
  #what else could this count?
  #needs publishedurl and any other urls for the sources
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
  if(is.numeric(start) | is.numeric(end)){
    within <- " and pd within "
    dates <- paste0("%22", start, "%20", end, "%22")
    myquery <- httr::GET(paste0(baseurl, query, RCurl::curlEscape(within), dates), httr::content_type("plain/text"), httr::accept("application/json"))
    content <- httr::content(myquery)
    qtotal <- content$`ops:world-patent-data`$`ops:biblio-search`[[1]]
    qtotal <- as.numeric(qtotal)
    print(qtotal)
  } else {
    myquery <- httr::GET(paste0(baseurl, query), httr::content_type("plain/text"), httr::accept("application/json"))
    content <- httr::content(myquery)
    qtotal <- content$`ops:world-patent-data`$`ops:biblio-search`[[1]]
    qtotal <- as.numeric(qtotal)
    print(qtotal)
  }
}
