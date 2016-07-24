#' @title iterate - internal (this works for WHAT?)
#' @description Used internally to send calls to OPS
#' @param data A query consisting of either urls for use with the numbers service or patent numbers for use with the fulltext service. See details.
#' @param service Character, select from "numbers"(to retrieve numbers from a text query) or "fulltext" to use a vector of numbers.
#' @param type The type of search for "fulltext" only. either "fulltext", "description" or "claims".
#' @param timer The delay before sending each request
#' @return a JSON response object for use in other functions
#' @export
#' @importFrom pbapply pblapply
#' @examples \dontrun{threepubs <- c("WO0000034", "WO0000035", "WO0005967")
#' ft <- iterate(threepubs, service = "fulltext", type = "fulltext")
#' ft <- iterate(threepubs, type = "claims")}
#' @examples \dontrun{pub_number <- c("WO0000034", "WO0000035", "WO0005967", "WO0007448", "EA001153", "WO0011959", "WO0035291", "WO0042857", "WO0046766", "WO0057710")
#'ft <- iterate(pub_number, type = "claims")}
#' @examples \dontrun{pizza_numbers <- iterate(pizza$[[[1]], service = "numbers")} # note that select first item in list
#' @examples \dontrun {three <- iterate(three_urls, service = "numbers")}
ops_iterate <- function(data, service = "", type = NULL, timer = 20){
  if(service == "numbers"){
  out <- pbapply::pblapply(data, ops_get)
  Sys.sleep(timer)
  return(out)
  }
  if(service == "biblio"){
  out <- pbapply::pblapply(data, ops_get)
  Sys.sleep(timer)
  return(out)
  }
  #if(service == "claims"){}
  #if(service == "description"){}
  if(service == "fulltext"){
    out <- pbapply::pblapply(data, ops_fulltext, type = type) #note was opsr:: before, and I have removed.,
    #ops_status() #note is set to pizza at the moment. To try.
    Sys.sleep(timer)
    return(out)
    }
}

#maybe try the iterators package
# This works fine with the claims. Note that it takes ops_fulltext as its function. So, it enters a pub number, runs ops_fulltext on that number and returns the results.

#In the case of ops_publications, it generates urls that need to go into a GET query and then get sent to the serves. So, the equivalent here would be a set of GET queries from ops_publications as the input. Or take the urls, input them into get_ops (containing the urls). But that may need a loop?

# claims_multi <- lapply(pub_number, ops_fulltext, type#="claims")
