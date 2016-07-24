#' Check OPS Authentication and Throttle Status
#'
#' Search query to test status of response. Loook for 200. If other rerun
#' authentication or use ops_throttle for detailed status. If 403 check fair
#' usage in headers. Throttle data indicates the status of a particular service at a particular time. If a query fails it may be because a service is under heavy load.
#' @param x unquoted character x to run the function.
#' @return numeric, 200 = all good, other = problem. For the throttle green is good, scores lower than 100 mean a service is busy.
#' @export
#' @examples ops_status()
#' @importFrom magrittr %>%
ops_status <- function(x = NULL){
  httr::GET("http://ops.epo.org/3.1/rest-services/published-data/search?q=ti%3Dpizza", httr::content_type("plain/text"), httr::accept("application/json"))$status %>%
    print()
  httr::GET("http://ops.epo.org/3.1/rest-services/published-data/search?q=ti%3Dpizza", httr::content_type("plain/text"), httr::accept("application/json"))$headers$`x-throttling-control` %>%
    print()
}
