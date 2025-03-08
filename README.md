# ecDNA-Analysis
Shell script for automated ecDNA analysis using Amplicon Architect and Amplicon Classifier in AWS. \
The script will automatically pull BAM files from the designated S3 Bucket run the workflow and return the output to the designated S3 bucket

# Pipeline input
co-ordinated sorted BAM files that were aligned to the hg38/hg19 reference genome using BWA -mem \
To sort bamfiles before running the shell script execute

```bash
samtools sort {BAM file} 
```
