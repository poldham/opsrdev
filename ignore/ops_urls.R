#' Generate URLs to search OPS biblios
#'
#' This function generates a set of URLs with a maximum of 100 results per URL for searching either OPS titles, titles & abstracts, biblios (default) and/or date ranges (publication date). See Details.
#' @param query - character
#' @param type - character, ti (title), ta (title & abstract), biblio (default)
#' @param start - YYYY or YYYYMMDD, publication date.
#' @param end - YYYY or YYYYMMDD, publication date
#' @return prints the total number of results for a query and creates a character vector with urls for that range.
#' @details The OPS service permits a maximum of 100 records per URL and an absolute hard maximum of 2000 results per set of URLs. This means that to retrieve a complete set of data for a query a set of URLs must be generated calling upto 100 results in sequence (1-100, 101-200 etc.) upto the maximum of 2000 per query. The query will fail if more than 2000 results are included. ops_urls generates the urls and splits them into a list divided into groups of urls with ranges under 2000. That list can then be used with ops_iterate (to fetch the patent numbers) and ops_parse or run as one with ops_publications.
#'
#' ops_urls() will print the number of results for a given query and year range and create a vector of URLS. Where there are large numbers of results (over 2000) start by using ops_count() to work out the total number of results for a query and then use it to work out year ranges under 2000 results for input into the start and end arguments of ops_urls().
#'
#' @export
#' @examples \dontrun{urls <- ops_urls(query = "pizza", type = "ti", start = 1990, end = 2000)}
ops_urls <- function(query="", type = "NULL", start = NULL, end = NULL) {
  # add in different services to this as arguments. Note that published URL is presently for the biblio search.
  published_url <- "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q="
    # use for published service "http://ops.epo.org/3.1/rest-services/published-data/search?q="
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
    dates <- paste0("%22", start, "%20", end, "%22")
    myquery <- httr::GET(paste0(published_url, query, RCurl::curlEscape(within), dates), httr::content_type("plain/text"), httr::accept("application/json"))
    content <- httr::content(myquery)
  }
  if(is.null(start) | is.null(end)){
    myquery <- httr::GET(paste0(published_url, query), httr::content_type("plain/text"), httr::accept("application/json"))
    content <- httr::content(myquery)
  }
  qtotal <- content$`ops:world-patent-data`$`ops:biblio-search`[[1]]
  qtotal <- as.numeric(qtotal)
  print(qtotal)
  if(qtotal <= 100){
    return(content)
  }
  if(qtotal > 100){
    # add in the url calculator and generator
    number <- ceiling(qtotal/100) # what does number do as not used?
    begin <- seq(1, qtotal, by = 100) #uses qtotal
    finish <- seq(100, qtotal+100, by=100) # add 100 to fix recycling on unequal length.
    chunk <- paste(begin, finish, sep = "-") # avoids end with finish.
    query <- query # why is this here?
    range <- paste0("&Range=", chunk)
    urls <- paste0(published_url, query, range)
    urls <- split(urls, ceiling(seq_along(urls)/20)) #from SO answer by Harlan
    return(urls)
  }
}
