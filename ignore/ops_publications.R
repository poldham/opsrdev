#' @title Search and retrieve patent numbers
#' @description Use a text query to retrieve patent numbers for use in other opsr functions such as retrieving biblios, family data, full texts, register or legal status information.
#' @param query. A CQL query.
#' @param type. character, ti (title), ta (title & abstract), biblio (default).
#' @param start - YYYY or YYYYMMDD, publication date.
#' @param end - YYYY or YYYYMMDD, publication date.
#' @details The basic workflow for OPS is to perform a text query, retrieve patent numbers and then gather other information (biblios, family data etc.). This function combines ops_urls, ops_count, ops_iterate and ops_numbers in one function.
#' @return A data.frame of patent numbers.
#' @export
#' @examples \dontrun{ops_urls(query = "pizza", type = "ta", start = 1990, end = 2000)}
# ops_publications <- function(query="", type = "NULL", start = NULL, end = NULL) {
#
#   #this works but not properly. There is no link between the date range urls and the urls that are generated at the end. Also, there is an issue of if the results are over 100 and under 2000. In that case the year needs to be used to break this up into chunks below 2000 (whether that can be automated through test calls remains to be seen)
#   published_url <- "http://ops.epo.org/3.1/rest-services/published-data/search?q="
#   if(type == "ti") {
#     query <- paste0("ti", "%3D", query)
#   }
#   if(type == "ta") {
#     query <- paste0("ta", "%3D", query)
#   }
#   if(type == "biblio") {
#     query <- paste0(query)
#   }
#   if(type == "NULL") {
#     query <- paste0(query)
#   }
#   if(is.numeric(start) | is.numeric(end)) {
#     within <- " and pd within " # note spaces
#     dates <- paste0("%22", start, "%20", end, "%22")
#     myquery <- httr::GET(paste0(published_url, query, RCurl::curlEscape(within), dates), httr::content_type("plain/text"), httr::accept("application/json"))
#     content <- httr::content(myquery) # these urls are not outputting below
#   }
#   if(is.null(start) | is.null(end)){
#     myquery <- httr::GET(paste0(published_url, query), httr::content_type("plain/text"), httr::accept("application/json"))
#     content <- httr::content(myquery)
#   }
#   # this is the counter
#   qtotal <- content$`ops:world-patent-data`$`ops:biblio-search`[[1]]
#   qtotal <- as.numeric(qtotal)
#   print(qtotal)
#   if(qtotal <= 100){
#     return(content)
#   }
#   if(qtotal > 100){ #may need if > 2000 and may also need if dates
#     # add in the url calculator and generator
#     number <- ceiling(qtotal/100)
#     #fails if do not specify type here, maybe needs an if statement for that case?
#     begin <- seq(1, qtotal, by = 100) #uses qtotal
#     finish <- seq(100, qtotal+100, by=100) # add 100 to fix recycling on unequal length.
#     chunk <- paste(begin, finish, sep = "-") # avoids using end with finish.
#     query <- query # why is this here (probably because of the note above, sho)
#     range <- paste0("&Range=", chunk)
#     urls <- paste0(published_url, query, range)
#     urls <- split(urls, ceiling(seq_along(urls)/20)) #from SO answer by Harlan
#     return(urls)
#   }
#   #query goes into GET in the iterator with the note on dates
# }
# #add iterator
# #add parse
