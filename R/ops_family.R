#' @title DRAFT Retrieve patent family data
#'
#' @param x patent numbers in docdb format xx.xxxxx.xx, (character)
#' @param constitutents biblio, legal
#' @description Obtain the INPADOC patent family records using patent numbers.
#'   Patent family numbers can be retrieved as is or with the biblio and/or
#'   legal information (use c(biblio, legal))
#' @return a data.frame
#' @export
#'
#' @examples \dontrun{ops_family("EP.1000000.A1")}
# ops_family <- function(x, constitutents()){
#   family_url <- "http://ops.epo.org/rest-services/family/publication/docdb/" #note docdb here could break up
#   biblio <-
#   legal <-
#   biblio&legal <-
#
# }