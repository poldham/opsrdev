#' @title Search and retrieve patent numbers
#' @description Use a text query to retrieve patent numbers for use in other opsr functions such as retrieving biblios, family data, full texts, register or legal status information.
#' @param query A CQL query.
#' @param type character, ti (title), ta (title & abstract), biblio (default).
#' @param start - YYYY or YYYYMMDD, publication date.
#' @param end - YYYY or YYYYMMDD, publication date.
#' @details The basic workflow for OPS is to perform a text query, retrieve patent numbers and then gather other information (biblios, family data etc.). This function combines ops_urls, ops_count, ops_iterate, ops_numbers and ops_country in one function.
#' @return A data.frame of patent numbers.
#' @export
#' @examples \dontrun{more_pizza <- ops_publications(query = "pizza", type = "ta", start = 1990, end = 2000)}
ops_publications <- function(query="", type = "NULL", start = NULL, end = NULL) {
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
  if(is.null(start) | is.null(end)){
    myquery <- httr::GET(paste0(published_url, query), httr::content_type("plain/text"), httr::accept("application/json"))
    content <- httr::content(myquery)
  }
  # this is the counter
  qtotal <- content$`ops:world-patent-data`$`ops:biblio-search`[[1]]
  qtotal <- as.numeric(qtotal)
  print(qtotal)
  if(qtotal <= 100){
    content <- httr::content(myquery)
    results <- content$`ops:world-patent-data`$`ops:biblio-search`$`ops:search-result`$`ops:publication-reference`
    familyid <- lapply(results, "[", 2)
    document_id <- sapply(results, "[", 3)  #make nested lists below 3 accessible. replace sapply with vapply.
    country <- lapply(document_id, "[", 2)
    docnumber <- lapply(document_id, "[", 3)
    kind <- lapply(document_id, "[", 4)
    # unlist the data into vectors. try bind_rows now?
    familyid <- unlist(do.call(cbind, familyid))
    country <- unlist(do.call(cbind, country))
    docnumber <- unlist(do.call(cbind, docnumber))
    kind <- unlist(do.call(cbind, kind))
    # combine into a data.frame
    df <- data.frame(familyid, country, docnumber, kind, stringsAsFactors = FALSE)
    # transform the data to useful numbers. Make sure format is correct here for the different types.
    df <- tidyr::unite(df, epodoc_format, c(country, docnumber), sep = "", remove = FALSE) %>%
      tidyr::unite(docdb_format, c(country, docnumber, kind), sep = ".", remove = FALSE) %>%
      tidyr::unite(publication_number, c(country, docnumber, kind), sep = "", remove = FALSE)
    #return(content)
  } #works to here
  if(qtotal <= 2000){ # removed >100 as that is not helpful
    # add in the url calculator and generator
    number <- ceiling(qtotal/100)
    #fails if do not specify type here, maybe needs an if statement for that case?
    begin <- seq(1, qtotal, by = 100) #uses qtotal
    finish <- seq(100, qtotal+100, by=100) # add 100 to fix recycling on unequal length.
    chunk <- paste(begin, finish, sep = "-") # avoids using end with finish.
    query <- query # why is this here (probably because of the note above, sho). Just changed to my query
    range <- paste0("&Range=", chunk)
    urls <- paste0(published_url, query, RCurl::curlEscape(within), dates, range) # added within and dates. Seems to work
    urls <- split(urls, ceiling(seq_along(urls)/20)) #from SO answer by Harlan
    #return(urls)
     content <- lapply(urls[[1]], ops_get) #adding here. ops outputs a lits down to ops:publication-reference as results.
#testing to here and ok, is list of lists needing melting
results <- reshape2::melt(content)
family_id <- dplyr::filter(results, L3 == "@family-id") %>%
  dplyr::rename(family_id = value, id = L2, set = L1)  %>%
  dplyr::select(family_id)
document_id_type <- dplyr::filter(results, L4 == "@document-id-type") %>%
  dplyr::rename(document_id_type = value, id = L2, set = L1) %>%
  dplyr::select(document_id_type)
country <- dplyr::filter(results, L4 == "country")  %>%
  dplyr::rename(country = value, id = L2, set = L1)  %>%
  dplyr::select(country)
country$country <- as.character(country$country)
doc_number <- dplyr::filter(results, L4 == "doc-number") %>%
  dplyr::rename(doc_number = value, id = L2, set = L1)  %>%
  dplyr::select(doc_number)
kind <- dplyr::filter(results, L4 == "kind") %>%
  dplyr::rename(kind = value, id = L2, set = L1)  %>%
  dplyr::select(kind, id, set)
df <- dplyr::bind_cols(family_id, document_id_type, country, doc_number, kind) %>%
  tidyr::unite(., epodoc, c(country, doc_number), sep = "", remove = FALSE) %>% #problem here with country doc number
  tidyr::unite(docdb, c(country, doc_number, kind), sep = ".", remove = FALSE) %>%
  tidyr::unite(publication_number, c(epodoc, kind), sep = "", remove = FALSE)
ops_country(data = df, col = "country")
  } #that works just fine.
# cases where qtotal is over 2000
# if(is.numeric(start) | is.numeric(end) & (qtotal < 2000)) {
#   print("warning... over 2000 results, try narrowing the data range")
#   }

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
#}
  # as above but also take the dates and divide them into year chunks under 2000. To test that could just create my own here
  # make sure that the dates go into the query as they are not present above.
  #query goes into GET in the iterator with the note on dates
#} #add iterator #add parse
