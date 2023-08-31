library(MungeSumstats)
library(tidyverse)
files <- list.files("/Volumes/infection_GWAS/rsid_added/", full.names = T)
files2 <- list.files("/Volumes/infection_GWAS/tabix_indexed/") %>%
  str_remove(".bgz")
files <- str_subset(files, paste(files2, collapse = "|"), negate = T)

pull_and_run <- function(x) {
name <- basename(x) 
d <- MungeSumstats::read_sumstats(x, standardise_headers = T)
write_sumstats(d, save_path = paste0("/Users/fh6520/infection_gwas/", name),
               tabix_index = T,
               write_vcf = F,
               nThread = 4
                
)


tmp_dir <- tempdir()
files <- list.files(tmp_dir, full.names = T, pattern = "^file")
files
file.remove(files)
gc()
}


map(files, pull_and_run)


# find . -type f -exec sh -c 'if ! lsof `readlink -f {}` > /dev/null; then echo `basename {}`; fi' \; | tr '\n' '\0' | rsync -P --remove-source-files -avz --from0 --files-from=- ./  /Volumes/infection_GWAS/tabix_indexed