#!/bin/bash

# Generating indices from 2 to 127 (126 indices in total)
file_indices=($(seq 1 127))

# Original R script template
r_script_template=$(cat <<EOL
library(tidyverse)
library(HDL)
files <- list.files() %>%
  str_subset("gz")
ld_path <- "/user/work/fh6520/infection_gwas_ldsc/HDL/ref/UKB_imputed_SVD_eigen99_extraction"
#ld_path <- "/user/work/fh6520/infection_gwas_ldsc/HDL/ref/UKB_imputed_hapmap2_SVD_eigen99_extraction/"

gwas1 <- files[%INDEX1%]
gwas2 <- files[%INDEX2%]

df.1 <- as.data.frame(read_tsv(gwas1))
df.2 <- as.data.frame(read_tsv(gwas2))
res.HDL <- HDL.rg(df.1, df.2, ld_path)
d <- res.HDL[[4]] %>%
   as_tibble() %>%
    mutate(GWAS_1 = basename(gwas1)) %>%
    mutate(GWAS_2 = basename(gwas2)) %>%
    mutate(estimate_type = c("H2_g1", "H2_g2", "g_covr", "rg"))

write_tsv(d, paste0("/user/work/fh6520/infection_gwas_ldsc/HDL/results/HDL_results_", basename(gwas1), "_", basename(gwas2), ".tsv"))


ld_path <- "/user/work/fh6520/infection_gwas_ldsc/HDL/ref/UKB_imputed_hapmap2_SVD_eigen99_extraction/"
res.HDL <- HDL.rg(df.1, df.2, ld_path)
d2 <- res.HDL[[4]] %>%
   as_tibble() %>%
    mutate(GWAS_1 = basename(gwas1)) %>%
    mutate(GWAS_2 = basename(gwas2)) %>%
    mutate(estimate_type = c("H2_g1", "H2_g2", "g_covr", "rg"))

write_tsv(d2, paste0("/user/work/fh6520/infection_gwas_ldsc/HDL/results/hapmap2_HDL_results_", basename(gwas1), "_", basename(gwas2), ".tsv"))

EOL
)

# Loop through file indices and generate R script versions and Slurm job scripts
for index1 in "${file_indices[@]}"; do
  for index2 in "${file_indices[@]}"; do
    if [ "$index1" -lt "$index2" ]; then  # Avoid duplicates and self-matching
      r_script=$(echo "$r_script_template" | sed "s/%INDEX1%/$index1/g; s/%INDEX2%/$index2/g")
      
      slurm_script=$(cat <<EOL
#!/bin/bash
#SBATCH --job-name=HDL_${index1}_${index2}
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=00:45:00
#SBATCH --mem=8G
#SBATCH --account=sscm013902

module load lang/r  # Load R module
cd /user/work/fh6520/infection_gwas_ldsc/LDSC

Rscript /user/work/fh6520/infection_gwas_ldsc/HDL/scripts/script_${index1}_${index2}.R  # Run R script
EOL
)
      
      echo "$r_script" > "script_${index1}_${index2}.R"
      echo "$slurm_script" > "slurm_script_${index1}_${index2}.sh"
      
      chmod +x "slurm_script_${index1}_${index2}.sh"
    fi
  done
done

