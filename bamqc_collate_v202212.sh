#!/bin/bash

#SBATCH -p quick					#partition/queue name
#SBATCH --job-name=bamqc_collate	#Job name
#SBATCH -n 1						#Run on one node
#SBATCH --mem=16gb					#Job memory
#SBATCH -t 00:30:00					#Time limit hrs:min:sec
#SBATCH -o bamqc_collate_DATE.log	#Standard output and error

/bin/date
/bin/hostname
echo "env" $CONDA_PREFIX
echo "job" $SLURM_JOB_NAME 
echo "id" $SLURM_JOBID

echo ""
echo "**collate qualimap bamqc***"
echo ""
echo "Genome"
echo "Number reads"
echo "Number mapped reads"
echo "Percentage reads mapped"
echo "Duplication rate"
echo "Mean insert size"
echo "Median insert size"
echo "Mean mapping quality"
echo "GC percentage"
echo "General error rate"
echo "Mean coverageData"
echo "Std coverageData"
echo "% with coverageData >= 5X"
echo "% with coverageData >= 10X"
echo "% with coverageData >= 20X"
echo "% with coverageData >= 30X"
echo ""

while read GENOME REF ; do #loop in input list

echo "----------------------------------------------------------------"

echo $GENOME
awk 'NR==20 {print $5}' ${GENOME}.final_stats/genome_results.txt
awk 'NR==21 {print $6}' ${GENOME}.final_stats/genome_results.txt
awk 'NR==21 {print $7}' ${GENOME}.final_stats/genome_results.txt
awk 'NR==32 {print $4}' ${GENOME}.final_stats/genome_results.txt
awk 'NR==37 {print $5}' ${GENOME}.final_stats/genome_results.txt
awk 'NR==39 {print $5}' ${GENOME}.final_stats/genome_results.txt
awk 'NR==44 {print $5}' ${GENOME}.final_stats/genome_results.txt
awk 'NR==55 {print $4}' ${GENOME}.final_stats/genome_results.txt
awk 'NR==60 {print $5}' ${GENOME}.final_stats/genome_results.txt
awk 'NR==71 {print $4}' ${GENOME}.final_stats/genome_results.txt
awk 'NR==72 {print $4}' ${GENOME}.final_stats/genome_results.txt
awk 'NR==78 {print $4}' ${GENOME}.final_stats/genome_results.txt
awk 'NR==83 {print $4}' ${GENOME}.final_stats/genome_results.txt
awk 'NR==93 {print $4}' ${GENOME}.final_stats/genome_results.txt
awk 'NR==103 {print $4}' ${GENOME}.final_stats/genome_results.txt

done < list_bamqc.txt

echo "----------------------------------------------------------------"
echo "all done"

exit 0
