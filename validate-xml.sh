#!/bin/bash

# Parallel XML Validation Script using Jing
# Uses background processes instead of xargs for better reliability

set -e

# Configuration
SCHEMA_FILE="odd/out/tillich-briefe.rng"
XML_DIR="data/editions"
JING_JAR="lib/jing.jar"
JING_URL="https://repo1.maven.org/maven2/com/thaiopensource/jing/20091111/jing-20091111.jar"
REPORT_FILE="validation-report.txt"
PARALLEL_JOBS=${PARALLEL_JOBS:-4}

# Check if running in non-interactive mode
INTERACTIVE=true
if [ "$1" = "--no-interactive" ] || [ "$CI" = "true" ] || [ "$GITHUB_ACTIONS" = "true" ]; then
    INTERACTIVE=false
fi

# Download Jing if not present
if [ ! -f "$JING_JAR" ]; then
    echo "Downloading Jing RelaxNG validator..."
    if command -v wget >/dev/null 2>&1; then
        wget -q -O "$JING_JAR" "$JING_URL"
    elif command -v curl >/dev/null 2>&1; then
        curl -sL -o "$JING_JAR" "$JING_URL"
    else
        echo "Error: Neither wget nor curl available"
        exit 1
    fi
    echo "Jing downloaded"
fi

# Validate required files exist
if [ ! -f "$SCHEMA_FILE" ]; then
    echo "Error: Schema file not found: $SCHEMA_FILE"
    exit 1
fi

if [ ! -d "$XML_DIR" ]; then
    echo "Error: XML directory not found: $XML_DIR"
    exit 1
fi

# Count total files
total_files=$(find "$XML_DIR" -name "*.xml" -type f | wc -l)
echo "Found $total_files XML files to validate"
echo "Schema: $SCHEMA_FILE"
echo "Using $PARALLEL_JOBS parallel processes"

# Test with one file first
echo "Testing with one file..."
test_file=$(find "$XML_DIR" -name "*.xml" -type f | head -1)
echo "Test file: $test_file"

if java -jar "$JING_JAR" "$SCHEMA_FILE" "$test_file" >/dev/null 2>&1; then
    echo "Test file is VALID"
else
    echo "Test file is INVALID"
    echo "Error details:"
    java -jar "$JING_JAR" "$SCHEMA_FILE" "$test_file" 2>&1 | head -3
    exit 1
fi

# Ask user if they want to continue (only in interactive mode)
if [ "$INTERACTIVE" = true ]; then
    echo ""
    read -p "Continue with full validation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Exiting..."
        exit 0
    fi
else
    echo "Running in non-interactive mode, proceeding with validation..."
fi

# Start timing
start_time=$(date +%s)

echo "Starting parallel validation..."

# Create temporary directory for results
temp_dir=$(mktemp -d)
trap "rm -rf $temp_dir" EXIT

# Initialize report file
cat > "$REPORT_FILE" << EOF
XML Validation Report
=====================
Date: $(date)
Schema: $SCHEMA_FILE
Total files: $total_files

EOF

# Function to validate a batch of files
validate_batch() {
    local batch_id="$1"
    local batch_file="$2"
    local results_file="$temp_dir/results_$batch_id"
    
    while IFS= read -r xml_file; do
        if java -jar "$JING_JAR" "$SCHEMA_FILE" "$xml_file" >/dev/null 2>&1; then
            echo "VALID:$xml_file" >> "$results_file"
        else
            echo "INVALID:$xml_file" >> "$results_file"
            # Get error details
            error_details=$(java -jar "$JING_JAR" "$SCHEMA_FILE" "$xml_file" 2>&1 | head -1)
            echo "ERROR:$xml_file:$error_details" >> "$results_file"
        fi
    done < "$batch_file"
    
    echo "BATCH_DONE:$batch_id" >> "$results_file"
}

# Create file batches
batch_size=$(( (total_files + PARALLEL_JOBS - 1) / PARALLEL_JOBS ))
echo "Processing files in batches of $batch_size"

# Split files into batches
batch_num=0
current_batch_size=0
current_batch_file="$temp_dir/batch_$batch_num"

find "$XML_DIR" -name "*.xml" -type f | while read -r xml_file; do
    echo "$xml_file" >> "$current_batch_file"
    current_batch_size=$((current_batch_size + 1))
    
    if [ $current_batch_size -eq $batch_size ]; then
        batch_num=$((batch_num + 1))
        current_batch_size=0
        current_batch_file="$temp_dir/batch_$batch_num"
    fi
done

# Start parallel validation processes
pids=()
for batch_file in "$temp_dir"/batch_*; do
    if [ -f "$batch_file" ]; then
        batch_id=$(basename "$batch_file")
        validate_batch "$batch_id" "$batch_file" &
        pids+=($!)
    fi
done

echo "Started ${#pids[@]} parallel validation processes"

# Monitor progress
processed=0
while [ $processed -lt $total_files ]; do
    sleep 2
    
    # Count processed files
    new_processed=$(find "$temp_dir" -name "results_*" -exec cat {} \; 2>/dev/null | grep -c "^VALID:\|^INVALID:" || echo "0")
    
    if [ $new_processed -gt $processed ]; then
        processed=$new_processed
        echo "Progress: $processed/$total_files"
    fi
done

# Wait for all processes to complete
for pid in "${pids[@]}"; do
    wait "$pid"
done

echo "All validation processes completed"

# Collect results
valid_count=0
invalid_count=0
invalid_files=()

for results_file in "$temp_dir"/results_*; do
    if [ -f "$results_file" ]; then
        while IFS= read -r line; do
            if [[ $line == VALID:* ]]; then
                valid_count=$((valid_count + 1))
            elif [[ $line == INVALID:* ]]; then
                invalid_count=$((invalid_count + 1))
                file=${line#INVALID:}
                invalid_files+=("$file")
                echo "INVALID: $file"
                
                # Write to report file
                echo "INVALID: $file" >> "$REPORT_FILE"
                
                # Get error details
                error_line=$(grep "^ERROR:$file:" "$results_file" | head -1 || echo "")
                if [ -n "$error_line" ]; then
                    error_msg=${error_line#ERROR:$file:}
                    echo "Error: $error_msg" >> "$REPORT_FILE"
                fi
                echo "" >> "$REPORT_FILE"
            fi
        done < "$results_file"
    fi
done

# Calculate duration
end_time=$(date +%s)
duration=$((end_time - start_time))

# Write summary to report file
cat >> "$REPORT_FILE" << EOF
VALIDATION SUMMARY
==================
Total files:     $total_files
Valid files:     $valid_count
Invalid files:   $invalid_count
Duration:        ${duration}s
Performance:     $((total_files / (duration > 0 ? duration : 1))) files/second

Note: RelaxNG structure validation completed
Warning: Schematron rules not validated (requires Saxon)
EOF

# Summary report to console
echo ""
echo "VALIDATION SUMMARY"
echo "================================"
echo "Total files:     $total_files"
echo "Valid files:     $valid_count"
echo "Invalid files:   $invalid_count"
echo "Duration:        ${duration}s"
echo "Performance:     $((total_files / (duration > 0 ? duration : 1))) files/second"
echo "================================"

# Show invalid files if any
if [ $invalid_count -gt 0 ]; then
    echo ""
    echo "INVALID FILES:"
    for file in "${invalid_files[@]:0:10}"; do
        echo "  $file"
    done
    if [ ${#invalid_files[@]} -gt 10 ]; then
        echo "  ... and $((${#invalid_files[@]} - 10)) more files"
    fi
    echo ""
    echo "Detailed report written to: $REPORT_FILE"
    echo ""
    echo "Note: RelaxNG structure validation completed"
    echo "Warning: Schematron rules not validated"
    exit 1
else
    echo ""
    echo "All files are valid!"
    echo "Report written to: $REPORT_FILE"
    echo "RelaxNG structure validation: PASSED"
    echo "Warning: Schematron rules not validated"
fi