#!/bin/bash
set -e

if [ "$#" -eq 0 ] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "🧬 Digenome Analysis Tool"
    echo "========================"
    echo "Usage: <BAM_FILE> [digenome_options] [-- --csv [filename]]"
    echo ""
    echo "Examples:"
    echo "  docker run --rm digenome:latest treated.sorted.bam"
    echo "  docker run --rm -v \$(pwd):/data digenome:latest /data/sample.bam"
    echo "  docker run --rm -v \$(pwd):/data digenome:latest /data/sample.bam -- --csv"
    echo ""
    echo "Built-in samples: treated.sorted.bam, wt.sorted.bam"
    exit 0
fi

# Parse arguments
BAM_FILE="$1"
shift
DIGENOME_OPTS=()
CSV_OUTPUT=false
CSV_FILE=""
PARSING_OUTPUT=false

for arg in "$@"; do
    if [[ "$arg" == "--" ]]; then
        PARSING_OUTPUT=true
        continue
    fi
    if [ "$PARSING_OUTPUT" = true ]; then
        if [[ "$arg" == "--csv" ]]; then
            CSV_OUTPUT=true
        elif [ "$CSV_OUTPUT" = true ] && [ -z "$CSV_FILE" ]; then
            CSV_FILE="$arg"
        fi
    else
        DIGENOME_OPTS+=("$arg")
    fi
done

# Check BAM file
if [ ! -f "$BAM_FILE" ]; then
    echo "❌ BAM file '$BAM_FILE' not found!"
    exit 1
fi

# Run digenome and capture output if CSV needed
if [ "$CSV_OUTPUT" = true ]; then
    OUTPUT=$(/app/digenome "$BAM_FILE" "${DIGENOME_OPTS[@]}")
    
    # Auto-generate CSV filename if not provided
    if [ -z "$CSV_FILE" ]; then
        BAM_BASENAME=$(basename "$BAM_FILE" .bam)
        CSV_FILE="${BAM_BASENAME}.csv"
    fi
    
    # Determine output directory
    if [ -d "/data" ] && [ -w "/data" ]; then
        CSV_PATH="/data/$CSV_FILE"
    else
        CSV_PATH="$CSV_FILE"
    fi
    
    # Create CSV
    echo "chromosome,position,forward_reads,reverse_reads,forward_total,reverse_total,forward_ratio,reverse_ratio,cleavage_score" > "$CSV_PATH"
    echo "$OUTPUT" | awk -F"\t" 'BEGIN{OFS=","} {
        split($1, pos, ":");
        print pos[1], pos[2], $2, $3, $4, $5, $6, $7, $8
    }' >> "$CSV_PATH"
    
    SITE_COUNT=$(echo "$OUTPUT" | wc -l)
    echo "✅ CSV saved: $CSV_FILE ($SITE_COUNT sites)"
    echo "$OUTPUT"
else
    exec /app/digenome "$BAM_FILE" "${DIGENOME_OPTS[@]}"
fi