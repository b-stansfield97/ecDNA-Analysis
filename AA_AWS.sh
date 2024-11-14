#!/bin/bash

# Enable debugging to print each command before execution
set -x

# Define the number of threads to use
THREADS={thread number}

source {path to conda.sh}
conda activate ampsuite

# Define S3 bucket paths
S3_BUCKET_OUTPUT={path to S3 bucket where results are stored}
S3_BUCKET_INPUT={path to S3 bucket where input BAM files are stored}
AA_PATH={path/AmpliconSuite-pipeline.py}
LOCAL_PATH={local EC2 path where BAM files are stored}

# Generate ecDNA_BAM_files.txt with only the file names
aws s3 ls "$S3_BUCKET_INPUT" --recursive | grep '.bam$' | awk '{print $4}' | sed 's|^ecDNA_bams/||' > "$LOCAL_PATH/ecDNA_BAM_files.txt"
echo "BAM list generated..."
cat "$LOCAL_PATH/ecDNA_BAM_files.txt"

# Loop through each BAM file listed in ecDNA_BAM_files.txt
while read -r BAM_FILE; do
    echo "Processing $BAM_FILE"

    # Define sample name for BAM
    SAMPLE_NAME=$(basename "$BAM_FILE" .bam)
    
    # Download BAM file and its index from S3
    aws s3 cp "$S3_BUCKET_INPUT$BAM_FILE" "$LOCAL_PATH/${SAMPLE_NAME}.bam" 
    samtools index -@"$THREADS" "$LOCAL_PATH/${SAMPLE_NAME}.bam"

    # Create a directory for each sample’s results
    SAMPLE_OUTPUT_DIR="$LOCAL_PATH/$SAMPLE_NAME"
    mkdir -p "$SAMPLE_OUTPUT_DIR"

    # Run AmpliconArchitect with specified parameters
    python3 "$AA_PATH" \
        -s "$SAMPLE_NAME" \
        -t "$THREADS" \
        --downsample -1 \
        --ref GRCh38 \
        --bam "$LOCAL_PATH/${SAMPLE_NAME}.bam" \
        -o "$SAMPLE_OUTPUT_DIR" \
        --AA_runmode FULL \
        --run_AA \
        --run_AC

    # Upload results to S3
    aws s3 cp "$SAMPLE_OUTPUT_DIR" "$S3_BUCKET_OUTPUT$SAMPLE_NAME/" --recursive

    # Clean up local files to save space
    rm -rf "$SAMPLE_OUTPUT_DIR"
    rm "$LOCAL_PATH/${SAMPLE_NAME}.bam"
    rm "$LOCAL_PATH/${SAMPLE_NAME}.bam.bai"

    echo "Completed processing $SAMPLE_NAME"
done < "$LOCAL_PATH/ecDNA_BAM_files.txt"

echo "All samples processed."
