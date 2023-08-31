library(tidyverse)
library(HDL)
files <- list.files() %>%
  str_subset("gz")
ld_path <- "/user/work/fh6520/infection_gwas_ldsc/HDL/ref/UKB_imputed_SVD_eigen99_extraction"
# ld_path <- "/user/work/fh6520/infection_gwas_ldsc/HDL/ref/UKB_imputed_hapmap2_SVD_eigen99_extraction/"


files <- files %>%
  str_subset(files[1], negate = T)


df.1 <- as.data.frame(read_tsv(files[1]))
run_hdl <- function(x) {
df.2 <- as.data.frame(read_tsv(x))

res.HDL <- HDL.rg(df.1, df.2, ld_path)
res.HDL$estimates.df %>%
  as_tibble() %>%
  mutate(GWAS_2 = basename(x))
}

d <- map_dfr(files[2], run_hdl) %>%
  mutate(GWAS_1 = basename(files[1]))

write_tsv(d, paste0("HDL_results_",files[1], ".tsv"))

ld_path <- "/user/work/fh6520/infection_gwas_ldsc/HDL/ref/UKB_imputed_hapmap2_SVD_eigen99_extraction/"


d <- map_dfr(files, run_hdl) %>%
  mutate(GWAS_1 = basename(files[1]))

write_tsv(d, paste0("hapmap2_HDL_results_",files[1], ".tsv"))

df.2 <- as.data.frame(read_tsv(files[3]))

