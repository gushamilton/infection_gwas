import_tabix_by_SNP <- function(SNPs,
                                     name,
                                     type = "ref",
                                     location = "/Volumes/infection_gwas/tabix_indexed/") {
  
  
  if(!exists("snp_list")) {
    snp_list <- read_tsv("data/snp_chrom_pos.tsv.gz")
  }
  
  z <- snp_list %>%
    filter(SNP %in% SNPs)
  
  loc = paste(paste0(z$chrom,":", z$pos,"-", z$pos), collapse = " ")
  bring_in <- function(x) {
    d <- as_tibble(
      read.table(
        text=system(paste0("tabix ",
                           location,
                           x,
                           " ", 
                           loc), intern = T), sep = "\t")
    ) 
  }
  d <- map_dfr(name, bring_in)
  
  if (type == "ref") {
    colnames(d) = c("name", "SNP", "chrom", "pos", "other_allele", "effect_allele", "id", "cohort", "model", "pval", "eaf", "cases_n", "cases_ref", "cases_het", "cases_alt", "controls_n", "controls_ref", "controls_het", "controls_alt", "beta", "se", "mac")
    
  }
  if (type == "outcome") {
    colnames(d) = c("name", "SNP", "chrom.outcome", "pos.outcome", "other_allele.outcome", "effect_allele.outcome", "outcome", "cohort", "model", "pval.outcome", "eaf.outcome", "cases_n", "cases_ref", "cases_het", "cases_alt", "controls_n", "controls_ref", "controls_het", "controls_alt", "beta.outcome", "se.outcome", "mac")
    d <- d %>%
      mutate(id.outcome = outcome)
  }
  if (type == "exposure") {
    colnames(d) = c("name", "SNP", "chrom.exposure", "pos.exposure", "other_allele.exposure", "effect_allele.exposure", "exposure", "cohort", "model", "pval.exposure", "eaf.exposure", "cases_n", "cases_ref", "cases_het", "cases_alt", "controls_n", "controls_ref", "controls_het", "controls_alt", "beta.exposure", "se.exposure", "mac")
    d <- d %>%
      mutate(id.exposure = exposure)
  }
  return(d)
}

