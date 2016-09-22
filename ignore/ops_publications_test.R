#' @title Search and retrieve patent numbers
#' @description Use a text query to retrieve patent numbers for use in other opsr functions such as retrieving biblios, family data, full texts, register or legal status information.
#' @param query A CQL query.
#' @param type character, ti (title), ta (title & abstract), biblio (default).
#' @param start - YYYY or YYYYMMDD, publication date.
#' @param end - YYYY or YYYYMMDD, publication date.
#' @details The basic workflow for OPS is to perform a text query, retrieve patent numbers and then gather other information (biblios, family data etc.). This function combines ops_urls, ops_count, ops_iterate and ops_numbers in one function.
#' @return A data.frame of patent numbers.
#' @export
#' @examples \dontrun{more_pizza <- ops_publications(query = "pizza", type = "ta", start = 1990, end = 2000)}
ops_publications_test <- function(query="", type = "NULL", start = NULL, end = NULL) {
  published_url <- "http://ops.epo.org/3.1/rest-services/published-data/search?q="
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
    content <- httr::content(myquery) # these urls are not outputting below
  }
# works to here with test <- ops_publications_test("pizza", "biblio", start = 1990, end = 1995) 453 results
  if(is.null(start) | is.null(end)){
    myquery <- httr::GET(paste0(published_url, query), httr::content_type("plain/text"), httr::accept("application/json"))
    content <- httr::content(myquery)
  }
  # this is the counter
  qtotal <- content$`ops:world-patent-data`$`ops:biblio-search`[[1]]
  qtotal <- as.numeric(qtotal)
  print(qtotal)
  if(qtotal <= 100){
    return(content)
  } #returns list on t1 <- ops_publications_test(query = "pizza", type = "ti", start = 1990, end = 1991) 72 results
  if(qtotal <= 2000){ # removed >100 as that is not helpful
    # add in the url calculator and generator
    number <- ceiling(qtotal/100)
    #fails if do not specify type here, maybe needs an if statement for that case?
    begin <- seq(1, qtotal, by = 100) #uses qtotal
    finish <- seq(100, qtotal+100, by=100) # add 100 to fix recycling on unequal length.
    chunk <- paste(begin, finish, sep = "-") # avoids using end with finish.
    query <- myquery # why is this here (probably because of the note above, sho). Just changed to my query
    range <- paste0("&Range=", chunk)
    urls <- paste0(published_url, query, RCurl::curlEscape(within), dates, range) # added within and dates. Seems to work
    urls <- split(urls, ceiling(seq_along(urls)/20)) #from SO answer by Harlan
  } # is the problem here.
  if(is.numeric(start) | is.numeric(end) & (qtotal < 2000)) {
    print("warning... over 2000 results, try narrowing the data range")
  }
  tmp <- lapply(urls[[1]], ops_get) #uses ops_get
  df <- ops_number(tmp)
}

    # number <- ceiling(qtotal/100)
    # begin <- seq(1, qtotal, by = 100) #uses qtotal
    # finish <- seq(100, qtotal+100, by=100) # add 100 to fix recycling on unequal length.
    # chunk <- paste(begin, finish, sep = "-") # avoids using end with finish.
    # query <- query # why is this here (probably because of the note above, sho). Just changed to my query
    # range <- paste0("&Range=", chunk)
    # urls <- paste0(published_url, query, RCurl::curlEscape(within), dates, range) # added within and dates. Seems to work
    # urls <- split(urls, ceiling(seq_along(urls)/20)) #from SO answer by Harlan
    # return(urls)
#  }
  # as above but also take the dates and divide them into year chunks under 2000. To test that could just create my own here
  # make sure that the dates go into the query as they are not present above.
  #query goes into GET in the iterator with the note on dates
#}
#add iterator
#add parse