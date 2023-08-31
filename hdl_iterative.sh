#!/bin/bash

# Generating indices from 2 to 127 (126 indices in total)
file_indices=($(seq 2 127))

# Original R script template
r_script_template=$(cat <<EOL
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
  res.HDL\$estimates.df %>%
    as_tibble() %>%
    mutate(GWAS_2 = basename(x))
}

d <- map_dfr(files, run_hdl) %>%
  mutate(GWAS_1 = basename(files[1]))

write_tsv(d, paste0("/user/work/fh6520/infection_gwas_ldsc/HDL/results/HDL_results_",files[1], ".tsv"))

ld_path <- "/user/work/fh6520/infection_gwas_ldsc/HDL/ref/UKB_imputed_hapmap2_SVD_eigen99_extraction/"

d <- map_dfr(files, run_hdl) %>%
  mutate(GWAS_1 = basename(files[1]))

write_tsv(d, paste0("/user/work/fh6520/infection_gwas_ldsc/HDL/results/hapmap2_HDL_results_",files[1], ".tsv"))
EOL
)

# Loop through file indices and generate R script versions and Slurm job scripts
for index in "${file_indices[@]}"; do
  r_script=$(echo "$r_script_template" | sed "s/files\[1\]/files\[$index\]/g")
  
  slurm_script=$(cat <<EOL
#!/bin/bash
#SBATCH --job-name=HDL
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --time=24:00:00
#SBATCH --mem=8G
#SBATCH --account=sscm013902

module load lang/r  # Load R module
cd /user/work/fh6520/infection_gwas_ldsc/LDSC

Rscript script_$index.R  # Run R script
EOL
)
  
  echo "$r_script" > "script_${index}.R"
  echo "$slurm_script" > "slurm_script_${index}.sh"
  
  chmod +x "slurm_script_${index}.sh"
done


