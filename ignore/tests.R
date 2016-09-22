
#---auth---#
testauth <- ops_auth(key, secret)
#Expect 200

#---iterate---#
test_iterate_ft <- iterate(threepubs, service = "fulltext", type = "fulltext")
#list of 3

test_iterate_claims <- iterate(threepubs, service = "fulltext", type = "claims")
#list of 3

test_urls <- iterate(three_urls, service = "numbers")
#list of 3

#---test biblio---#

test_biblio <- ops_biblio(pizza_epodoc)
#requires a response object
#fails as can't find ops_rename.

#---test biblio---#
#create test. check it is useful in the first place.

#---test ops_count---#

test_count <- ops_count("pizza", start = 1990, end = 2000)
#return numeric (but watch for error codes)

#---ops_family---#

#create test

#---ops_filter---#

#create test

#---ops_fulltext---#

test_ft <- ops_fulltext("WO0000034", type = "fulltext", timer = 20)
#expect list of 1

test_desc <- ops_fulltext("WO0000034", type = "description", timer = 20)
#expect list of 1

test_claims <- ops_fulltext("WO0000034", type = "claims", timer = 20)
#expect list of 1

#---test get---#
testget <- lapply(three_urls, ops_get)
#Expect list length 3 665.3 kb

#---ops_multi_biblio---#

test_multibib <- ops_multi_biblio(content)
#says object 'meta_document_number' not found

multi_biblio_test <- ops_multi_biblio(ops_biblios)
# works OK creates warnings on NAs.

#---ops_numbers---#

testnumbers <- ops_numbers(testget)
# expect df nrow 300

#---ops_numbers_new---#

#---ops_urls---#
urls <- ops_urls(query = "pizza", type = "ti", start = 1990, end = 2000)
#return vector of urls with ti and prints count
urls <- ops_urls(query = "pizza", type = "ta", start = 1990, end = 2000)
#return vector of urls with ta and prints count
urls <- ops_urls(query = "pizza", start = 1990, end = 2000)
#return vector of urls with no entry and prints count