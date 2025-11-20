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

# Set executable permissions and create symlinks for easy access
RUN chmod +x /app/digenome /app/run_digenome.sh && \
    ln -s /app/digenome /usr/local/bin/digenome && \
    ln -s /app/run_digenome.sh /usr/local/bin/run_digenome

# Set working directory to /app for Nextflow compatibility
WORKDIR /app

# Add /app to PATH so scripts can be called without absolute paths
ENV PATH="/app:${PATH}"

# Use bash as entrypoint for Nextflow compatibility
# This allows direct execution of scripts without full paths
ENTRYPOINT ["/bin/bash", "-c"]

# Default command shows help when run without arguments  
CMD ["run_digenome.sh --help"]