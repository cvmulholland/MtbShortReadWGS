#!/bin/bash

#SBATCH -p normal								#partition/queue name
#SBATCH --job-name=rga_variants_pilon_extract	#Job name
#SBATCH -n 1									#Run on one node
#SBATCH --mem=16gb								#Job memory
#SBATCH -t 12:00:00								#Time limit hrs:min:sec
#SBATCH -o rga_variants_pilon_extract_DATE.log	#Standard output and error

/bin/date
/bin/hostname
echo "env" $CONDA_PREFIX
echo "job" $SLURM_JOB_NAME 
echo "id" $SLURM_JOBID

echo ""
echo "**extract pilon variants***"
echo "var.vcf = awk '{ if (\$10=="1/1" || \$10=="0/1") print }' GENOME_pilon_dp5_q15_mq40.vcf >> GENOME_pilon_dp5_q15_mq40_var.vcf"
echo "var_dp5.vcf = awk '{ if (\$1!~"#" && \$7!~"LowCov") print }' GENOME_pilon_dp5_q15_mq40_var.vcf >> GENOME_pilon_dp5_q15_mq40_var_dp5.vcf"
echo "del.vcf = awk '{ if (\$7=="Del") print }' GENOME_pilon_dp5_q15_mq40.vcf >> GENOME_pilon_dp5_q15_mq40_del.vcf"
echo "working dir" $(/bin/pwd)
echo ""
echo ""
echo "All variants (1/1,0/1)"
echo "All non-Amb variants (1/1)"
echo "All Amb variants (0/1)"
echo "All non-LowCov variants (1/1,0/1)"
echo "All LowCov variants (1/1,0/1)"
echo "All Del sites"
echo "Del sites (non Amb, non-LowCov)"
echo "Variants PASS"
echo "Variants Amb (non-LowCov)"
echo "Variants Del (non LowCov)"
echo "Variants Del;Amb (non LowCov)"
echo "Variants LowCov"
echo ""

while read GENOME ; do #loop through genomes in input list

echo "----------------------------------------------------------------"
echo $GENOME

#extract all variant sites
awk '{ if ($1 ~ /^##/) print }' ${GENOME}_pilon_dp5_q15_mq40.vcf > ${GENOME}_pilon_dp5_q15_mq40_var.vcf #add header
echo "##EXTRACT=awk '{ if (\$10=="1/1" || \$10=="0/1") print }'" >> ${GENOME}_pilon_dp5_q15_mq40_var.vcf #add extraction info
awk '{ if ($1 ~ /^#CHROM/) print }' ${GENOME}_pilon_dp5_q15_mq40.vcf >> ${GENOME}_pilon_dp5_q15_mq40_var.vcf #column info
awk '{ if ($10=="1/1" || $10=="0/1") print }' ${GENOME}_pilon_dp5_q15_mq40.vcf >> ${GENOME}_pilon_dp5_q15_mq40_var.vcf #extract all variants (PASS/amb/del/lowcov)

##extract variant sites >5X
awk '{ if ($1 ~ /^##/) print }' ${GENOME}_pilon_dp5_q15_mq40.vcf > ${GENOME}_pilon_dp5_q15_mq40_var_dp5.vcf #add header
echo "##EXTRACT=awk '{ if (\$1!~"#" && \$7!~"LowCov") print }'" >> ${GENOME}_pilon_dp5_q15_mq40_var_dp5.vcf #add extraction info
awk '{ if ($1 ~ /^#CHROM/) print }' ${GENOME}_pilon_dp5_q15_mq40.vcf >> ${GENOME}_pilon_dp5_q15_mq40_var_dp5.vcf #column info
awk '{ if ($1!~"#" && $7!~"LowCov") print }' ${GENOME}_pilon_dp5_q15_mq40_var.vcf >> ${GENOME}_pilon_dp5_q15_mq40_var_dp5.vcf #extract non-LowCov variants

#extract del sites
awk '{ if ($1 ~ /^##/) print }' ${GENOME}_pilon_dp5_q15_mq40.vcf > ${GENOME}_pilon_dp5_q15_mq40_del.vcf #add header
echo "##EXTRACT=awk '{ if (\$7=="Del") print }'" >> ${GENOME}_pilon_dp5_q15_mq40_del.vcf #add extraction info
awk '{ if ($1 ~ /^#CHROM/) print }' ${GENOME}_pilon_dp5_q15_mq40.vcf >> ${GENOME}_pilon_dp5_q15_mq40_del.vcf #column info
awk '{ if ($7=="Del") print }' ${GENOME}_pilon_dp5_q15_mq40.vcf >> ${GENOME}_pilon_dp5_q15_mq40_del.vcf #extract del sites

##count variant sites
awk '{ if ($10=="1/1" || $10=="0/1") print }' ${GENOME}_pilon_dp5_q15_mq40.vcf | wc -l
awk '{ if ($10=="1/1") print }' ${GENOME}_pilon_dp5_q15_mq40.vcf | wc -l
awk '{ if ($10=="0/1") print }' ${GENOME}_pilon_dp5_q15_mq40.vcf | wc -l
awk '{ if ($1!~"#" && $7!~"LowCov") print }' ${GENOME}_pilon_dp5_q15_mq40_var.vcf | wc -l
awk '{ if ($1!~"#" && $7~"LowCov") print }' ${GENOME}_pilon_dp5_q15_mq40_var.vcf | wc -l
awk '{ if ($7~"Del") print }' ${GENOME}_pilon_dp5_q15_mq40.vcf | wc -l
awk '{ if ($7=="Del") print }' ${GENOME}_pilon_dp5_q15_mq40.vcf | wc -l
awk '{ if ($7=="PASS") print }' ${GENOME}_pilon_dp5_q15_mq40_var.vcf | wc -l
awk '{ if ($7=="Amb") print }' ${GENOME}_pilon_dp5_q15_mq40_var.vcf | wc -l
awk '{ if ($7=="Del") print }' ${GENOME}_pilon_dp5_q15_mq40_var.vcf | wc -l
awk '{ if ($7~"Amb" && $7~"Del" && $7!~"LowCov") print }' ${GENOME}_pilon_dp5_q15_mq40_var.vcf | wc -l
awk '{ if ($7~"LowCov") print }' ${GENOME}_pilon_dp5_q15_mq40_var.vcf | wc -l
echo ""

done < list_variants.txt

echo "----------------------------------------------------------------"
echo "all done"

exit 0
