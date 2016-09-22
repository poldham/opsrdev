#' @title Filter data frame for countries in OPS with Full Text availability
#' @description OPS presently includes patent full texts for documents published by Austria (AT), Canada (CA), the European Patent Office (EP), Great Britain (GB), the Patent Cooperation Treaty (WO) and Spain (ES). These are the only countries with full text. Queries to ops_fulltext() that include other countries will fail. This function takes a list of country codes or patent numbers containing country codes and filters them for jurisdictions with full text access.
#' @param data A data.frame containing a column "country" or "publication_country" with two letter country and patent office codes (e.g. EP, WO).
#' @return a data.frame
#' @export
#' @importFrom dplyr filter
#' @examples \dontrun{ops_filter(data)}
ops_filter <- function(data) {
  tmp <- names(data) %in% "country"
  if("TRUE" %in% tmp == TRUE){
    data <- filter(data, country == "AT" | country == "CA" | country == "CH" | country == "EP" | country == "ES" | country == "GB" | country == "WO")
    return(data)
  } else {
    tmp1 <- names(data) %in% "publication_country"
  }
  if("TRUE" %in% tmp1 == TRUE){
    data <- filter(data, publication_country == "AT" | publication_country == "CA" | publication_country == "CH" | publication_country == "EP" | publication_country == "ES" | publication_country == "GB" | publication_country == "WO")
    return(data)
  }
}
# the above works by testing the column names for country or publication_country, then using the presence of TRUE as a basis for filter. This could be better to account for different possibilities (it has to be a published document to be retrieved by fulltext so no point in using the priority country or the application country as will generate a stop at OPS if not present). But, it should be extended to cases where publication numbers begin with one of country codes on the list for full text (that would be the third test in the list). Also, is the use of filter rather than filter_ satisfactory in a function?