#' Authenticate with Open Patent Services (OPS).
#'
#' The European Patent Office Open Patent Services (OPS) requires
#' authentication. First, register for a free account at
#' \url{http://www.epo.org/searching-for-patents/technical/espacenet/ops.html#tab1}.
#' Then obtain a key and secret by creating an App under My Apps in the top
#' right of the API Console for your account. Then copy the key and secret and either paste into ops_auth (quoted) or store in the environment as key and secret.
#' @param key Alphanumeric provided by OPS (quoted).
#' @param secret Alphanumeric secret provided by OPS (quoted).
#' @export
#' @return 200 if authenticated, 400 if not. See error messages for information.
#' @examples \dontrun{ops_auth(key, secret)}
#' @importFrom httr POST
#' @importFrom RCurl base64
ops_auth <- function(key, secret){
    code <- paste0(key, ":", secret)
    auth_enc <- base64(code, TRUE, "character")
    heads <- c(auth_enc, "application/x-www-form-urlencoded")
    names(heads) <- c("Authorization", "content-type")
    auth <- httr::POST(url = "https://ops.epo.org/3.1/auth/accesstoken", httr::add_headers(heads),
    body = "grant_type=client_credentials")
    print(auth$status)
}
