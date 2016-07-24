#' @title retrieve full text using patent numbers
#' @description For jurisdictions where full text is available. This is
#'   presently limited to Austria (AT), Canada (CA), the European Patent Office
#'   (EP), Great Britain (GB), the Patent Cooperation Treaty (WO), Spain (ES)
#'   and Switzerland (CH).
#' @param query A patent number or character vector containing patent numbers.
#' @param type Description, claims, or fulltext (availability). See details
#' @param timer Set the time delay between calls to OPS in seconds.
#' @return A list.
#' @details Setting type "fulltext" will simply retrieve information on the
#'   availability of fulltext elements for a given record. description will
#'   retrieve the available descriptions. claims will retrieve the available
#'   claims. Note that the function filters the countries to thise with full
#'   text availability (otherwise the query will fail). To identify documents
#'   inside full text availability use the patent family service to link from
#'   numbers outside fulltext (e.g. US) to those inside fulltext (e.g. EP or
#'   WO). Retrieval of multiple segments (biblio, description, claims) is
#'   supported by OPS but not yet in this function. Be cautious when using the
#'   arguments (e.g. description) as they will pull back a lot of data affecting
#'   your quota.
#' @export
#' @examples \dontrun{ops_fulltext("WO0000034", type = "fulltext", timer = 20)}
#' @examples \dontrun{ops_fulltext("WO0000034", type = "description", timer = 20)}
#' @examples \dontrun{ops_fulltext("WO0000034", type = "claims", timer = 20)}
ops_fulltext <- function(query = "", type = "", timer = 30){
  # call ops_filter first to search only relevant names
  # --- ops_filter call
  #ops_filter <- function(x)
  #x <- dplyr::filter(x, publication_country == "EP" | publication_country == "WO" | publication_country == "AT" | publicati#on_country == "CA" | publication_country == "CH" | publication_country == "GB" | publication_country == "ES")
  #
  # --- end ops filter call
  # Generate URLS
  baseurl <- "http://ops.epo.org/3.1/rest-services/published-data/publication/epodoc/"
  query <- query # vector of numbers to get ft, description or claims for.
  if(type == "fulltext"){
    url <- paste0(baseurl, query, "/fulltext")
  }
  if(type == "description"){
    url <- paste0(baseurl, query, "/description")
  }
  if(type == "claims"){
    url <- paste0(baseurl, query, "/claims")
  }
  #if(length(query) > 1){ # this is working the problem is that the sys sleep is not working.
  # out <- pbapply::pblapply(query, ops_fulltext, type=type)
  # Sys.sleep(10)
  # return(out)
  #
  #} # needs an if else statement and then positioning
  if(length(query) == 1){
    myquery <- httr::GET(paste0(url), httr::content_type("plain/text"), httr::accept("application/json"))
  }
  myquery <- httr::content(myquery)

}