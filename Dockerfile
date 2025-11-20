# Minimal Docker image for digenome executable
FROM ubuntu:22.04

# Metadata labels
LABEL version="1.0"
LABEL description="Digenome-seq standalone v1.0 (Apr 2 2020) - CRISPR off-target analysis tool"

# Set working directory
WORKDIR /app

# Install only essential runtime dependencies and clean up in single layer
RUN apt-get update && apt-get install -y \
    libc6 \
    libgcc-s1 \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Copy essential files
COPY digenome /app/digenome
COPY run_digenome_container.sh /app/run_digenome.sh
COPY treated.sorted.bam /app/treated.sorted.bam  
COPY wt.sorted.bam /app/wt.sorted.bam

# Set executable permissions
RUN chmod +x /app/digenome /app/run_digenome.sh

# Set the runner as entrypoint
ENTRYPOINT ["/app/run_digenome.sh"]