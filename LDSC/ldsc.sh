#!/bin/bash
#SBATCH --job-name=qc
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --time=12:00:00
#SBATCH --mem=16G
#SBATCH --account=sscm013902

module load apps/ldsc
module load lang/python/anaconda/2.7-2019.03.bioconda
cd /user/work/fh6520/infection_gwas_ldsc/munged
# Path to LDSC script
LDSC_SCRIPT="ldsc.py"

# Paths to reference and w-ld-chr directories
REF_LD_CHR="/user/work/fh6520/ldsc/eur_w_ld_chr/"
W_LD_CHR="/user/work/fh6520/ldsc/eur_w_ld_chr/"

# Output directory
OUTPUT_DIR="/user/work/fh6520/infection_gwas_ldsc/results/"

# Read GWAS list and perform LDSC for all pairs
while IFS= read -r gwas1; do
    while IFS= read -r gwas2; do
        if [ "$gwas1" != "$gwas2" ]; then
            echo "Running LDSC for $gwas1 and $gwas2"
            ldsc.py \
            --rg "$gwas1,$gwas2" \
            --ref-ld-chr "$REF_LD_CHR" \
            --w-ld-chr "$W_LD_CHR" \
            --out "${OUTPUT_DIR}${gwas1%.*}_${gwas2%.*}__results"
        fi
    done < "list.gwas"
done < "list.gwas"
