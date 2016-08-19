#' @title Convert two letter patent country codes to country names
#' @description This function converts two letter country and patent office
#'   codes to country and office names. It converts the column and adds a
#'   `country_name` column with the full country name.
#' @param data A data.frame containing a country column to
#' @param col a column named "country" containing two letter country codes
#' @return A data.frame
#' @export
#' @references The base country list is imported from the countrycode package
#'   (on CRAN) in the countrycode_data.csv file
#'   \url{https://github.com/vincentarelbundock/countrycode/raw/master/data/countrycode_data.csv}.
#'   That file is reproduced and modified with entries in the iso2c field for
#'   regional patent offices from WIPO standard St.3
#'   \url{http://www.wipo.int/pct/guide/en/gdvol1/annexes/annexk/ax_k.pdf}.
#'   Continent and region fields are assigned to patent at present.
#' @importFrom dplyr select_
#' @importFrom dplyr filter
#' @examples \dontrun{ops_country(data = pizza_numbers, col = "country")}
ops_country <- function(data, col){
  src <- select_(data, col)
  tmp <- select_(countrycode_data, "country_name", "iso2c")
  tmp$status <- countrycode_data$iso2c %in% src$country
  res <- filter(tmp, status == TRUE) #iso2c for by-y
  res$status <- NULL
  data <- merge(data, res, by.x = "country", by.y = "iso2c")
  #print(data) intrusive and dropped.
  }
#note, the specification of country in the last line could vary between datasets e.g as publication_country, priority_country, application_country. So a better solution is needed here as this only works where there is a column called country.

#problem that the code is producing a lot of extra columns with . in them as a join. So the code needs more work. It may be that not specifying dplyr for filter was causing the problem.

#original working code for reference
#tmp <- dplyr::select_(countrycode_data, "country_name", "iso2c")
#tmp$status <- countrycode_data$iso2c %in% pizza_numbers$country
#res <- filter(tmp, status == TRUE)
#test <- merge(pizza_numbers, res, by.x = "country", by.y = "iso2c")
