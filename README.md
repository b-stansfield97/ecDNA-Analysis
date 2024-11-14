# ecDNA-Analysis
Shell script for automated ecDNA analysis using Amplicon Architect and Amplicon Classifier in AWS. 

### Preprocessing
The shell script takes co-ordinate sorted BAM files as the input. 

samtools sort {BAM file} 

FASTQ files were aligned the the HG38 reference genome using BWA -mem
