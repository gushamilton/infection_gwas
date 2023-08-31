for file in *.gz;
do join -1 2 -2 1 merged_snps.tsv <(zcat $file) | gzip > rsid_added/$file;
done