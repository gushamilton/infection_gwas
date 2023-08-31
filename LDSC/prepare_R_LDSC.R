library(tidyverse)
files_to_process <- list.files() %>%
  str_subset("gz")
f <- read_tsv("w_hm3_snplist")
bring_in <- function(x) {
name <- basename(x)
read_tsv(x) %>%
  inner_join(f) %>%
  write_tsv(paste0("munged/", x))
}

map(files_to_process, bring_in)