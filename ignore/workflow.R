workflow

1. authenticate
2. search to gain sense of counts (search parameters).
3. refine by year to meet the 2000 limit (automation somewhere here)
4. generate the urls
5. retrieve the data
6. retrive numbers and request biblio or other data.

WORKINGS TO MAKE OPS_PUBLICATIONS WORK

1. ops_publications - presently creates only urls. Note that creates as a list and need to select the first element of the list[[1]] . Fix that.
2. test_nine_urls <- lapply(test_ops_publications[[1]], ops_get) - use ops_get in lapply to fetch the data.
3. test_ops_numbers <- ops_numbers(test_nine_urls). Parse the data.
