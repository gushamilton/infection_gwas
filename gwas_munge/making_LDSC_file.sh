mkdir -p LDSC  # Create the LDSC folder if it doesn't exist

# source activate ldsc3

for gzfile in *.gz;do
zcat "$gzfile" | tail -n +2 | awk 'BEGIN {OFS="\t"; print "SNP", "A1", "A2", "N", "Z", "P"} {print $2, $6, $5, $12+$16, $20/$21, $10}' | gzip > "LDSC/${gzfile%.gz}_processed.txt.gz"; 
done
cd LDSC


# get w_hm3_snplist from LDSC
# now run the LDSC_prep_r_script