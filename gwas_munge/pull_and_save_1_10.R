library(MungeSumstats)
library(tidyverse)
# Need to have the GRCh38 SNPs also
# BiocManager::install("SNPlocs.Hsapiens.dbSNP155.GRCh38")
gc()
master_function <- function(path) {
  name <- basename(path)
  d <- data.table::fread(path) %>%
    filter(Chr != 23)
  
  # Too big so split into 10 equally sized datasets
  
  split_d <- split(d, factor(sort(rank(row.names(d))%%12)))
  
  pull_and_generate_biallelic_snps <- function(x){
    m <- format_sumstats(
      path = split_d[[x]],
      return_data = T,
      rmv_chr = c("X", "Y", "MT"),
      ref_genome = "GRCh38",
      dbSNP = 155,
      bi_allelic_filter = F,
      nThread = 4
      
    )
    gc()
    return(m)
  }
  
  m2 <- map_dfr(1:12, pull_and_generate_biallelic_snps)
  rm(split_d)
  m2 <- m2 %>%
    mutate(N = NUM_CASES + NUM_CONTROLS)
  
  m2 %>%
    mutate(Z = BETA/SE) %>%
    select(SNP, A1, A2, N, Z) %>%
    write_tsv(paste0("/Users/fh6520/gwas/ldsc/", name))
  
  write_sumstats(m2,
                 save_path = paste0("/Users/fh6520/gwas/with_rsid/", name),
                 tabix_index = T
  )
  
  
  # m <- format_sumstats(
  #   path = m2,
  #   return_data = T,
  #   rmv_chr = c("X", "Y", "MT"),
  #   ref_genome = "GRCh38",
  #   dbSNP = 155,
  #   bi_allelic_filter = T,
  #   save_path = paste0("/Users/fh6520/gwas/biallelic_only/", name), save_format = "LDSC",
  #   tabix_index = T
  #   
  #   
  # )
  name <- str_replace(name, "tsv", "vcf")
  write_sumstats(m2, save_path = paste0("/Users/fh6520/gwas/vcf/", name),
                 tabix_index = T,
                 write_vcf = T
  )
  
  rm(m2)
  
  gc()
  tmp_dir <- tempdir()
  files <- list.files(tmp_dir, full.names = T, pattern = "^file")
  files
  file.remove(files)
}

list.files("/Volumes/infection_GWAS/raw_from_oxford/", full.names = T)
files <- list.files("/Volumes/infection_GWAS/raw_from_oxford/", full.names = T)
map(files[1:10], master_function)
