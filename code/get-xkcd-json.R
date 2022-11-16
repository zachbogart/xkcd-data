#' Get XKCD JSON data
#' Version: 2022-11-15
#' 
#' Notes:
#' - Pinging the JSON API to get info on XKCD comics
#' - See https://xkcd.com/about/
#'

# Imports 
library(tidyverse)
library(here)
library(httr)
library(jsonlite)

# get the recent comic number
res <- httr::GET("https://xkcd.com/info.0.json")
recentComic <- tibble(json = list(content(res))) %>% 
    unnest_wider(json) %>% 
    pull(num)

# define tibble of comic numbers
comicNumbers <- tibble(num = 1:recentComic)

cat(paste(recentComic, "comics"))

# go get all the comics
resComics <- purrr::pmap(comicNumbers, ~with(list(...), {
    # fancy printing to see progress
    cat(".")
    if (num %% 50 == 0 || num == recentComic) { cat(paste(num, "\n")) }
    return(
        GET(paste0("https://xkcd.com/", num ,"/info.0.json"))
    )
}))

# convert responses to list
listComics <- resComics %>% 
    keep(~status_code(.) == 200) %>% # there is no comic 404
    map(~content(.))

# export the results
exportPath <- here("outputs/xkcd-comics.json")
listComics %>% write_json(exportPath, 
    pretty = T,
    auto_unbox = T
)

