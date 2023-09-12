pacman::p_load(tidyverse,vroom,TwoSampleMR,data.table)
f <- list.files("/Volumes/infection_gwas/tabix_indexed/") %>%
  str_subset("tbi", negate = T)


data <- 
  
  
  
  

snps <- read_tsv("https://github.com/gushamilton/il6-sepsis/raw/main/data/harmonised_data_final.tsv") %>%
  select(contains("exposure"), SNP) %>%
  filter(exposure == "cisIL6R") %>%
  distinct()

outcomes <- import_tabix_by_SNP(SNPs = snps$SNP,
                    name = f[1:3],
                    type = "outcome")

res <- mr(d, method ="mr_ivw")

res %>%
  as_tibble() %>%
  arrange(b) %>%
  filter(str_detect(outcome, "AUREU")) %>%
  ggforestplot::forestplot(name = outcome,
                           estimate = b,
                           se = se)


import_tabix_by_SNP("")

import_tabix_by_SNP(SNPs = "rs2228145",
                         name = f[1:3],
                         type = "outcome")



bmi_e <- fread("https://portals.broadinstitute.org/collaboration/giant/images/1/15/SNP_gwas_mc_merge_nogc.tbl.uniq.gz") 

bmi_exposure <- bmi_e %>%
  rename(pval.exposure = p) %>%
  filter(pval.exposure < 5e-8) %>%
  as_tibble() %>%
  mutate(effect_allele.exposure = A1,
         other_allele.exposure = A2,
         eaf.exposure = Freq1.Hapmap,
         beta.exposure = b,
         se.exposure = se,
         pval.exposure,
         exposure = "BMI") %>%
  clump_data()


bmi_outcomes <- import_tabix_by_SNP(SNPs = bmi_exposure$SNP,
                    name = f[1:126],
                    type = "outcome")

dat <- harmonise_data(bmi_exposure, bmi_outcomes)
dat_small <- dat %>%
  filter(cases_n >1000)
res_bmi <- mr(dat_small, method = "mr_ivw")
res_bmi %>% as_tibble() %>%
  arrange(b) %>%
  ggforestplot::forestplot(name = outcome,
                           estimate = b,
                           se = se)
