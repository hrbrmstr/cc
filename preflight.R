#!/usr/bin/env Rscript

if (!require("pacman")) install.packages("pacman")
pacman::p_load(argparser, magrittr, xml2, httr, rvest, lubridate, jsonlite, tidyverse)

Sys.chmod("cc.R", "755")
