#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(argparser, quietly = TRUE)
  library(magrittr, quietly = TRUE)
})

arg_parser(
  description = 'Extract metadata of a specific target based on the results of "commoncrawl.org"

Examples:

$ ./cc.R --list                                      # list indices
$ ./cc.R --domain github.com                         # defaults to most recent index
$ ./cc.R --domain github.com --out /tmp/gh.json      # specify an oputput file
$ ./cc.R --index CC-MAIN-2018-34 --domain github.com # specify which index'
) %>%
  add_argument(
    arg = "--domain",
    help = "domain which will be crawled",
    type = "character",
    short = "-d",
    default = NA_character_
  ) %>%
  add_argument(
    arg = "--out",
    help = "specify an output file (default: domain.json)",
    type = "character",
    short = "-o",
    default = NA_character_
  ) %>%
  add_argument(
    arg = "--list",
    help = "list all available indexes",
    short = "-l",
    flag = TRUE
  ) %>%
  add_argument(
    arg = "--index",
    help = "use a specific index file",
    type = "character",
    short = "-i",
    default = NA_character_
  ) -> parser

opts <- parse_args(parser)

if ((is.na(opts$domain)) & (!opts$list)) {
  print(parser)
  quit(save="no", 1)
}

suppressPackageStartupMessages({
  library(xml2, quietly = TRUE)
  library(httr, quietly = TRUE)
  library(rvest, quietly = TRUE)
  library(lubridate, quietly = TRUE)
  library(jsonlite, quietly = TRUE)
  library(tidyverse, quietly = TRUE)
})

cache_dir <- path.expand("~/.cc.R")

#' Setup the cache directory
#'
#' @md
#' @return nothing
setup_cache <- function() {
  if (!dir.exists(cache_dir)) dir.create(path.expand(cache_dir))
}

#' Refresh the CC crawl index cache
#'
#' Possible side-effect of writing to the cache dir
#'
#' @md
#' @return data frame (`month`/`year`/`path`)
refresh_index_cache <- function() {

  pg <- xml2::read_html("http://index.commoncrawl.org/")

  rvest::html_nodes(pg, xpath = ".//td[1]/*/a") %>%
    rvest::html_attr("href") -> idx_paths

  rvest::html_nodes(pg, xpath = ".//td[2]") %>%
    rvest::html_text(trim=TRUE) %>%
    str_replace(" Index", "") %>%
    str_split(" ") %>%
    purrr::map(set_names, c("month", "year")) %>%
    map_df(as.list) %>%
    mutate(path = idx_paths) -> idx

  readr::write_rds(idx, file.path(cache_dir, "indexes.rds"))

}

#' Fetch cached or current CC crawl index paths
#'
#' @md
#' @return data frame (`month`/`year`/`path`)
fetch_indexes <- function() {

  if (!file.exists(file.path(cache_dir, "indexes.rds"))) {
    return(refresh_index_cache())
  }

  idx <- readr::read_rds(file.path(cache_dir, "indexes.rds"))

  dplyr::filter(
    idx,
    month == as.character(lubridate::month(Sys.Date(), abbr=FALSE, label=TRUE)),
    year == lubridate::year(Sys.Date())
  ) %>%
    nrow() -> has_this_month

  if ((!has_this_month) & (lubridate::day(Sys.Date()) > 25)) {
    return(refresh_index_cache())
  } else {
    return(idx)
  }

}

#' Retrieve domain CDX metadata from CC index
#'
#' @md
#' @param domain domain name
#' @param index CC index file
#' @param page API page #
#' @return data frame (CDX)
get_data <- function(domain, index, page) {

  httr::GET(
    url = file.path("http://index.commoncrawl.org", glue::glue("{index}-index")),
    query = list(
      url = glue::glue("*.{domain}"),
      output = "json",
      page = page
    )
  ) -> res

  httr::stop_for_status(res)

  httr::content(res, as="raw", encoding="UTF-8") %>%
    rawConnection() -> rcon

  on.exit(close(rcon), add=TRUE)

  out <- jsonlite::stream_in(rcon, verbose = FALSE)

  out

}

#' Grab all the URL data from the CC for a given index and omain
#'
#' @md
#' @param domain domain name
#' @param index CC index file
#' @return data frame (CDX)
crawl_index <- function(domain, index) {

  httr::GET(
    url = file.path("http://index.commoncrawl.org", glue::glue("{index}-index")),
    query = list(
      url = glue::glue("*.{domain}"),
      output = "json",
      showNumPages = TRUE
    )
  ) -> res

  httr::stop_for_status(res)

  meta <- httr::content(res, as="text", encoding="UTF-8")
  meta <- jsonlite::fromJSON(meta)

  purrr::map_df(
    0:(meta$pages-1), get_data, domain=domain, index=index
  ) %>%
    tbl_df() -> out

}

#' List the available CC crawl indices
#'
#' Side-effect of output to stdout
#'
#' @md
#' @return indices (invisibly)
list_indexes <- function() {
  dplyr::select(fetch_indexes(), year, month, path) %>%
    data.frame() -> tmp
  print(tmp[nrow(tmp):1,], row.names = FALSE, quote = FALSE)
  invisible(tmp)
}

setup_cache()

if (opts$list) { # just list the indexes (will prime, cache and auto-update)
  list_indexes()
} else if (!is.na(opts$index)) { # use a specific index
  idx <- fetch_indexes()
  if (!(gsub("^/", "", opts$index) %in% gsub("^/", "", idx$path))) {
    stop("Index does not exist", call.=FALSE)
  }
  out <- crawl_index(opts$domain, opts$index)
  where <-  if (is.na(opts$out)) stdout() else file(path.expand(opts$out))
  jsonlite::stream_out(out, where, verbose=FALSE)
} else { # use latest index
  idx <- fetch_indexes()
  out <- crawl_index(opts$domain, idx$path[1])
  where <-  if (is.na(opts$out)) stdout() else file(path.expand(opts$out))
  jsonlite::stream_out(out, where, verbose=FALSE)
}

quit(save="no", status=0)
