# download dbsnp151 from UCSC
# http://hgdownload.cse.ucsc.edu/goldenPath/hg38/database/

wget http://hgdownload.cse.ucsc.edu/goldenPath/hg38/database/snp151.txt.gz


#  that's it!
zcat snp151.txt.gz |  cut -f 2,4,5,9,10 | awk '{split($5, alleles, "/"); for (i = 1; i <= length(alleles); i++) print $1":"$2":"$4":"alleles[i]"\t"$3}' | gzip > list_rsids_topmed.txt.gz

#  this file is so big we need to split it:

split -C 1000M list_rsids_topmed.txt

#  Now to confirm get all snps, go to GWAS folder, cut the first column of every gwas and paste into a single file

zcat gwas | cut -f 1 > list_top_med_snps_in_gwas


# now run this across all files.
for f in *; do
awk 'FNR==NR{a[$1]=$2 FS $3;next} $1 in a {print $0, a[$1]}'  $f ../list_top_med_snps >> topmed_rsid_in_gwas;
done