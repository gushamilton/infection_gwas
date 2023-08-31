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
    bi_allelic_filter = F
    
)
gc()
return(m)
}

m2 <- map_dfr(1:12, pull_and_generate_biallelic_snps)
rm(split_d)


 m2 %>%
   select(SNP, Name =NAME) %>%
   write_tsv("/Users/fh6520/gwas/merged_snps.tsv.gz")





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
# name <- str_replace(name, "tsv", "vcf")
# write_sumstats(m2, save_path = paste0("/Users/fh6520/gwas/vcf/", name),
#                tabix_index = T,
#                write_vcf = T
#                )

# rm(m2)

gc()
tmp_dir <- tempdir()
files <- list.files(tmp_dir, full.names = T, pattern = "^file")
files
file.remove(files)
}

master_function("/Users/fh6520/Downloads/eur_30_enterobacteriaceae.tsv.gz")
 d <- vroom::vroom("/Users/fh6520/gwas/merged_snps.tsv.gz")
d %>%
  distinct()
