#' @title Search and retrieve bibliographic patent data from OPS
#' @description Use to search and retrieve bibliographic data from OPS and create a data.frame with the results. Use ops_count to establish the total number of results and year limits. Will not presently retrieve over 2000 results.
#' @param query A search query (quoted).
#' @param type Select from ti (title), ta (title and abstract), quoted.
#' @param service Limited to "biblio"
#' @param start The year or date to start with.
#' @param end The year or date to end with.
#' @param timer The number of seconds between each call for 100 results (numeric)
#' @details A warning may be generated that "There were 50 or more warnings...". This is expected behaviour and arises from the use of aggregate() in ops_biblio inside this function.
#' @return A data frame
#' @export
#' @importFrom dplyr %>%
#' @examples \dontrun{drones <- ops_fetch_biblio(query = "drones", type = "ta", service = "biblio", start = 1990, end = 2015, timer = 10)}
ops_fetch_biblio <- function(query, type, service, start, end, timer){
  ops_urls(query, type, start, end) %>%
    ops_iterate(service, timer) %>%
    ops_biblio()
} #doesnt work on say 1990,1991 on three results. Weird.