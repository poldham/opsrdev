#' @title Retrieve bibliographic information using patent numbers
#' @description Use this function to fetch patent front pages 'biblios' from OPS
#'   by posting a list of publication numbers using httr::POST.
#' @param x a character vector containing patent numbers produced by
#'   ops_numbers(), epodoc column preferred.
#' @details epodoc format appears to capture more data than docdb but
#'   experimentation may be needed.
#' @return a JSON format response
#' @export
#' @importFrom httr content_type
#' @importFrom httr accept
#' @importFrom httr accept
#' @importFrom httr POST
#' @examples \dontrun{x <- more_pizza$epodoc}
#' @examples \dontrun{biblios <- ops_post(x)}
ops_post <- function(x){
  POST("http://ops.epo.org/3.1/rest-services/published-data/publication/epodoc/biblio", content_type("plain/text"), accept("application/json"), body = x)
}