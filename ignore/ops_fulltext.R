#' @title Obtain Full Text of Patent Documents (contains lapply fetch)
#' @description For jurisdictions where full text is
#' available (EP, WO, AT, CA, CH, GB, ES) retrieve the patent description and or
#' claims for one or more patent documents.
#' @param query. A character vector containing patent numbers
#' @param type. The type of full text search to perform. fulltext - check availability and
#'   format of full text elements. description - retrieve the description.
#'   claims - retrieve the claims.
#' @details This function takes one or more patent numbers (must be EP, WO, AT,
#'   CA, CH, GB, ES). Note that a call to claims or description for multiple
#'   documents may bring back a large volume of data and should be used
#'   sparingly in terms of the OPS fair use quota.
#' @return JSON response containing a list with results
#' @export
#' @importFrom httr GET
#' @importFrom httr content_type
#' @importFrom httr accept
#' @importFrom httr content
#' @importFrom pbapply pblapply
#' @examples \dontrun{fulltext <- ops_fulltext(query="WO0000034", type = "fulltext")}
#' @examples \dontrun{description <- ops_fulltext(query="WO0000034", type = "description")}
#' @examples \dontrun{claims <- ops_fulltext(query="WO0000034", type = "claims")}
#' @details \dontrun{pub_number <- c("WO0000034", "WO0000035", "WO0005967", "WO0007448", "EA001153", "WO0011959", "WO0035291", "WO0042857", "WO0046766", "WO0057710")}
' {"((claims_multi <- lapply(pub_number, ops_fulltext, type="claims"))"}
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
