README
================
Paul Oldham
29 July 2016

opsrdev
=======

[![Travis-CI Build Status](https://travis-ci.org/poldham/opsrdev.svg?branch=master)](https://travis-ci.org/poldham/opsrdev)

This is the early development version of the opsr R package to access the [European Patent Office Open Patent Services API](http://www.epo.org/searching-for-patents/technical/espacenet/ops.html#tab1)

The main aim of the package is to provide access to the OPS service and, more importantly, to transform the data into data frames or the new tibbles (simpler data frames) that we can perform useful patent analysis with. There is still quite a way to go and if you would like to contribute feel welcome.

opsrdev is not on CRAN. To install it use:

``` r
devtools::install_github("poldham/opsrdev")
```

Walkthrough
-----------

Here is a quick walkthrough on how to use opsrdev. We will use the topic of drones as an example.

opsr uses r packages in the tidyverse as well as some additional packages. You don't need to worry about that but for this walkthrough we need to install or load the following.

``` r
install.packages("dplyr") #for chaining using %>% 
install.packages("readr") #to write the files
```

Load dplyr to use %&gt;% in interactive mode and opsrdev. 

``` r
library(opsrdev) # the opsr package
library(dplyr)
library(readr) 
```

OPS will allow us to make limited use of the service without authenticating, but they plan to turn that off in future. It is a good idea to register for the service [here](http://www.epo.org/searching-for-patents/technical/espacenet/ops.html#tab1), then create an App in the developer portal, go to MyApps and copy down the key and secret.

You may find it easiest to save the key and the secret in your environment using:

``` r
key <- "yourkey"
secret <- "yoursecret"
```

`ops_auth()` is a simple function

Authenticate (not needed for this walkthrough as the dataset is small but good practice)

``` r
ops_auth("yourkey", "yoursecret")
```

Test a query for the number of results with ops\_count()
--------------------------------------------------------

We can only fetch 2000 results at a time from the OPS service. So, we need to find out whether we have 2000 or more results.

### Get a Count for Patent Biblios (front pages)

Patent biblios include the title, abstract, applicant and inventor fields.

``` r
library(opsrdev)
ops_count("drones") # biblio search is the default for ops_count() and "biblio" does not need to be specified.
```

    ## [1] 294

### Get a Count for Titles

``` r
library(opsrdev)
ops_count("drones", "ti") # titles, all years
```

    ## [1] 68

### Get a Count for the Titles and Abstract

``` r
library(opsrdev)
ops_count("drones", "ta") # title and abstract, all years
```

    ## [1] 283

Use a shorter year range if you have too many results (over 2000). Note that the year is the publication year.

``` r
library(opsrdev)
ops_count("drones", "ta", start = 1990, end = 2015) # 1990 to 2015
```

    ## [1] 214

An example of over 2000 results would be for something slightly ridiculous like "dna" (the maximum that will be displayed appears to be 10,000 rather than the actual number of results which will be many more).

``` r
library(opsrdev)
ops_count("dna", "ta", start = 1990, end = 2015)
```

    ## [1] 10000

So, bear in mind that it is important to think about your search strategy. We will address how to deal with more than 2000 results at a time below.

Retrieve the data from OPS
--------------------------

In practice retrieving data from OPS is a multi-step process.

Step 1: Define how many results a query will return. Step 2: Generate URLs to retrieve the results (100 per url). Step 3: Fetch the results. Step 4: Transform into a data.frame (in future a tibble).

We will illustrate these steps and then show how they are combined.

### Step 2: Generate URLs

``` r
library(opsrdev)
tmp <- ops_urls(query = "drones", type = "ta", start = 1990, end = 2015)
```

    ## [1] 214

``` r
tmp
```

    ## [1] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Ddrones%20and%20pd%20within%20%221990%202015%22&Range=1-100"  
    ## [2] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Ddrones%20and%20pd%20within%20%221990%202015%22&Range=101-200"
    ## [3] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Ddrones%20and%20pd%20within%20%221990%202015%22&Range=201-300"

ops\_urls() takes a query, a type (ti for title, ta for title and abstract, bilio - the default) and start and end for year or date ranges (YYYYMMDD format).

### Step 3 Fetch the data (as JSON)

``` r
library(opsrdev)
tmp1 <- ops_iterate(tmp, service = "biblio", timer = 10)
tmp1
```

ops\_iterate uses lapply and a timer to fetch the data for each URL using GET (see ops\_get). ops\_iterate is a generic function that will work with a range of services (such as retrieving claims or descriptions based on patent numbers).

### Step 4 Transform into a data.frame

We normally want to view patent bibliographic information in a data frame (or in future the simplified tibble). Parsing the JSON data is the job of ops\_biblio().

``` r
library(opsrdev)
tmp2 <- ops_biblio(tmp1)
head(tmp2)
```

ops\_biblio uses the aggregate() function in its final step and this generates a warning.

Note that some issues require clarification in future work (notably the number of applicants/inventors per record). At present ops\_biblio appears to parse only one of the inventor or applicant names from a sequence. This therefore requires more work to capture and concatenate the names in a record. The same is true in the case of IPC/CPC codes where the sequence data requires preprocessing and concatenating to provide one field.

Pulling it together with ops\_fetch\_biblio
===========================================

ops\_fetch\_biblio() brings the above together into one function that will return a data frame straight from a query.

``` r
library(opsrdev)
drones <- ops_fetch_biblio(query = "drones", type = "ta", service = "biblio", start = 1990, end = 2015, timer = 10)
```

Note that at the moment this only works with the "biblio" service (the front page bibliographies rather than the numbers or other services). In future we will make this function generic.

If you see a warning or set of warnings such as:

`There were 50 or more warnings (use warnings() to see the first 50)`

This is expected behaviour arising from the use of `aggregate()` to generate the data frame. In RStudio preview (at the time of writing) you may see these warnings spelled out as:

`non-missing arguments, returning NAno non-missing arguments`

We will attempt to address this issue in future updates but it is expected behaviour at present.

``` r
View(drones)
```

We can then write the data to a file.

``` r
write_csv(drones, "drones.csv")
```

Retrieving more than 2000 results
---------------------------------

Bearing in mind that patent databases like the Lens and Patentscope allow you to download a data table with up to 10,000 results at a time, the OPS maximum of 2000 is rather frustrating. This will maybe change now that the USPTO is taking a lead with [open data services](http://www.uspto.gov/learning-and-resources/open-data-and-mobility). The 2,000 limit per query does however focus our attention on the important question of why we are seeking more than 2,000 records and whether we should refine the query.

Let's imagine that we are interested in the results of searches of patent titles and abstracts that contain the words pizza between 1990 and 2015. We can do this by specifying the start and end years. We could also specify this as start = 19900101 end = 20151231 for finer control. Note that the format is YYYYMMDD.

``` r
qtotal <- ops_count("pizza", "ta", start = 1990, end = 2015) # 2986
```

This generates 2,986 results between the specified period. We now need to break these into smaller chunks.

``` r
qtotal_1990_2000 <- ops_count("pizza", "ta", start = 1990, end = 2000) # 884
```

    ## [1] 884

``` r
qtotal_2001_2010 <- ops_count("pizza", "ta", start = 2001, end = 2010) # 1412
```

    ## [1] 1412

``` r
qtotal_2011_2015 <- ops_count("pizza", "ta", start = 2011, end = 2015) # 690
```

    ## [1] 690

We can see that it will take us three queries to arrive at the total number of results across the period (2000 to 2015 returned 2093 results which is too high).

We now have three sets of queries that will be needed to arrive to the 2986 results between 1990 and 2015. Each of these sets will need to be retrieved in smaller sets of 100 records at a time (the most that can be called at one time).

In practice this means that we will have to generate a set of URLs containing 100 items at a time. For example, to retrieve the 884 results between 1990 and 2000 we will need to use 9 URLs (884/100 = 8.84) and for 2001 to 2010 we will need 15 (14.12).

We can use ops\_urls to generate the necessary urls for us.

``` r
library(opsrdev)
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
urls_1990_2000 <- ops_urls("pizza", type = "ta", start = 1990, end = 2000) %>% print()
```

    ## [1] 884
    ## [1] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%221990%202000%22&Range=1-100"  
    ## [2] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%221990%202000%22&Range=101-200"
    ## [3] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%221990%202000%22&Range=201-300"
    ## [4] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%221990%202000%22&Range=301-400"
    ## [5] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%221990%202000%22&Range=401-500"
    ## [6] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%221990%202000%22&Range=501-600"
    ## [7] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%221990%202000%22&Range=601-700"
    ## [8] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%221990%202000%22&Range=701-800"
    ## [9] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%221990%202000%22&Range=801-900"

``` r
urls_2001_2010 <- ops_urls("pizza", "ta", start = 2001, end = 2010)  %>% print()
```

    ## [1] 1412
    ##  [1] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222001%202010%22&Range=1-100"    
    ##  [2] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222001%202010%22&Range=101-200"  
    ##  [3] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222001%202010%22&Range=201-300"  
    ##  [4] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222001%202010%22&Range=301-400"  
    ##  [5] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222001%202010%22&Range=401-500"  
    ##  [6] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222001%202010%22&Range=501-600"  
    ##  [7] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222001%202010%22&Range=601-700"  
    ##  [8] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222001%202010%22&Range=701-800"  
    ##  [9] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222001%202010%22&Range=801-900"  
    ## [10] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222001%202010%22&Range=901-1000" 
    ## [11] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222001%202010%22&Range=1001-1100"
    ## [12] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222001%202010%22&Range=1101-1200"
    ## [13] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222001%202010%22&Range=1201-1300"
    ## [14] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222001%202010%22&Range=1301-1400"
    ## [15] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222001%202010%22&Range=1401-1500"

``` r
urls_2011_2015 <- ops_urls("pizza", "ta", start = 2011, end = 2015) %>% print()
```

    ## [1] 690
    ## [1] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222011%202015%22&Range=1-100"  
    ## [2] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222011%202015%22&Range=101-200"
    ## [3] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222011%202015%22&Range=201-300"
    ## [4] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222011%202015%22&Range=301-400"
    ## [5] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222011%202015%22&Range=401-500"
    ## [6] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222011%202015%22&Range=501-600"
    ## [7] "http://ops.epo.org/3.1/rest-services/published-data/search/biblio/?q=ta%3Dpizza%20and%20pd%20within%20%222011%202015%22&Range=601-700"

We now have three sets of URLs, each specifying a range of 100 results upto the rounded maximum for the date range.

The final element is to create a `for loop` that will loop over each of our URLs and place them into an object where we can store the results and parse them. Thanks to this very useful [R-bloggers article on Accessing APIs from R by Christoph Waldhauser](http://www.r-bloggers.com/accessing-apis-from-r-and-a-little-r-programming/) we can do this quite easily. The key to this is:

1.  To create an empty holder to store the data we receive back from OPS that is the same length as our list of URLs. We will call that `ops_results`.
2.  Setting a sensible sleep time before each GET request is sent to OPS. To avoid violating the fair use charter and receiving a 403 (blocking message), the minimum value must be 6 seconds (to match the 10 calls per minute limit). But it may make sense to make this quite a lot longer and go and make a cup of tea while it runs.

``` r
ops_loop <- function(x, timer = 10) {
ops_results <- vector(mode = "list", length = length(x))
for(i in 1:length(ops_results)) {
  my_urls <- x[[i]]
  raw_results <- httr::GET(url = my_urls, httr::content_type("plain/text"), httr::accept("application/json"))
  content <- httr::content(raw_results)
  ops_results[[i]] <- content
  message("getting_data")
  Sys.sleep(time = timer)
}
return(ops_results)
}
```

Before we run this we need to authenticate as we will be retrieving more than a trivial number of results.

``` r
library(opsrdev)
ops_auth(key, secret)
```

Note that in addition to the restriction on the number of results per query, there is also a fair use restriction on the amount of data that is called (with a 2 gigabyte per week limit). Depending on the time of day there may be more pressure on the service than at others. You can check the status of the service before trying to retrieve multiple sets of data.

``` r
library(opsrdev)
ops_status()
```

    ## [1] 200
    ## [1] "idle (images=green:200, inpadoc=green:60, other=green:1000, retrieval=green:200, search=green:30)"

ops\_status provides two pieces of information. In the first line is your authentication status (200 means good). The second line shows the status of the different services (green is good, red is bad). It makes sense to run larger queries when the service is green as there is less likelihood of being booted from the system.

Note that the amount of data that comes back (54 MB for the first query) is not trivial if you plan on using OPS a lot.

``` r
pizza1 <- ops_loop(urls_1990_2000, timer = 20)
```

We can then run the second query

``` r
pizza2 <- ops_loop(urls_2001_2010, timer = 20)
```

``` r
pizza3 <- ops_loop(urls_2011_2015, timer = 20)
```

Once we have the data we can use `combine()` from dplyr to create one list of data for a call to process in `ops\_biblio()` to produce our complete data frame

``` r
library(dplyr)
complete <- combine(test, pizza2, pizza3) %>% 
  ops_biblio()
complete
```

Regularizing the publication number
===================================

At present the publication\_country, the publication\_number and publication\_kind are separate fields. It makes sense to unite them so they can be use for lookups with other database services.

``` r
library(dplyr)
complete <- unite(complete, publication_number_full, c(publication_country, publication_number, publication_kind), sep = "", remove = FALSE)
```
Round Up
===================================

`opsr` is presently at an early stage of development but progress is being made. The OPS service is not intended for large scale bulk downloads and it is quite easy to bump up against the service restrictions and receive a 403 message. But, OPS is a valuable source of free patent data and offers a range of other services (e.g. family and legal status) along with the ability to retrieve description and claims for some jurisdictions that are not available for free anywhere else. 