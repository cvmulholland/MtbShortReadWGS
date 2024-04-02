#!/bin/bash

#SBATCH -p normal                               #partition/queue name
#SBATCH --job-name=rga_mapping_and_variants     #Job name
#SBATCH -n 1                                    #Run one node
#SBATCH --mem=16gb                              #Job memory
#SBATCH -t 12:00:00                             #Time limit hrs:min:sec
#SBATCH -o rga_mapping_and_variants_DATE.log  	#Standard output and error

/bin/date
/bin/hostname
echo "env" $CONDA_PREFIX
echo "job" $SLURM_JOB_NAME 
echo "id" $SLURM_JOBID

echo ""
echo "**reference guided assembly and variant calling with Pilon**"
echo "working dir" $(/bin/pwd)
echo "map genome to reference in list_mapping.txt:"
cat list_mapping.txt
echo ""

while read GENOME REFGENOME ; do #loop through genomes in list

REF=/path/to/refseq/${REFGENOME} #path to reference genome (excluding .fasta)

echo "*********************************************************************************************************"
echo "map" ${GENOME} "to" ${REFGENOME} 
head -n 1 ${REF}.fasta
echo ""

##run fastqc on raw data
fastqc -q ${GENOME}_R1_001.fastq.gz ${GENOME}_R2_001.fastq.gz

##remove adapters, trim reads and remove short reads
trimmomatic PE ${GENOME}_R1_001.fastq.gz ${GENOME}_R2_001.fastq.gz ${GENOME}_R1_trimmed_paired.fq.gz ${GENOME}_R1_trimmed_unpaired.fq.gz ${GENOME}_R2_trimmed_paired.fq.gz ${GENOME}_R2_trimmed_unpaired.fq.gz ILLUMINACLIP:/path/to/adapters_nextera.fasta:2:30:10 SLIDINGWINDOW:4:15 MINLEN:25

##run fastqc on trimmed reads
fastqc -q ${GENOME}_R1_trimmed_paired.fq.gz ${GENOME}_R2_trimmed_paired.fq.gz

##map to reference genome
bwa mem -M -t4 -v2 ${REF}.fasta ${GENOME}_R1_trimmed_paired.fq.gz ${GENOME}_R2_trimmed_paired.fq.gz > ${GENOME}.sam

##create sorted indexed bam file
samtools view -bhSu ${GENOME}.sam > ${GENOME}.view.bam
samtools sort ${GENOME}.view.bam -o ${GENOME}.sorted.bam
samtools index ${GENOME}.sorted.bam ${GENOME}.sorted.bam.bai

##remove duplicates and update read groups (required for GATK)
picard MarkDuplicates -INPUT ${GENOME}.sorted.bam -OUTPUT ${GENOME}.dedup.bam -METRICS_FILE ${GENOME}.dedup.txt -REMOVE_DUPLICATES true -ASSUME_SORTED true
picard AddOrReplaceReadGroups -INPUT ${GENOME}.dedup.bam -OUTPUT ${GENOME}.readgroups.bam -RGID ${GENOME} -RGLB ${GENOME} -RGPL ILLUMINA -RGPU NA -RGSM ${GENOME} -VALIDATION_STRINGENCY SILENT -SORT_ORDER coordinate
samtools index ${GENOME}.readgroups.bam

##indel realignment
module unload pilon/1.23/java.13
module load GenomeAnalysisTK/3.8-0/java.1.8.0_20
java -jar $(which GenomeAnalysisTK.jar) -T RealignerTargetCreator -I ${GENOME}.readgroups.bam -R ${REF}.fasta -o ${GENOME}.intervals
java -jar $(which GenomeAnalysisTK.jar) -T IndelRealigner -I ${GENOME}.readgroups.bam -R ${REF}.fasta -targetIntervals ${GENOME}.intervals -o ${GENOME}.final.bam

##mapping QC
module load qualimap/v2.2.1
qualimap bamqc -bam ${GENOME}.final.bam

##variant calling with Pilon
module unload qualimap/v2.2.1
module unload GenomeAnalysisTK/3.8-0/java.1.8.0_20
module load pilon/1.23/java.13
java -jar $(which pilon-1.23.jar) --genome ${REF}.fasta --frags ${GENOME}.final.bam --output ${GENOME}_pilon_dp5_q15_mq40 --variant --mindepth 5 --minqual 15 --minmq 40

echo $GENOME "to" $REFGENOME "done"
echo ""

done < list_mapping.txt

echo "*********************************************************************************************************"
echo "all done"
