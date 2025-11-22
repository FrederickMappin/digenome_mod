# Digenome standalone for Docker





## Purpose:

Digenome-seq is an in vitro nuclease-digested whole-genome sequencing to profile genome-wide nuclease off-target effects in cells. This in vitro digest yields sequence reads with the same 5' ends at cleavage sites that can be computationally identified by Digenome program.

In order to make the standalone useable within docker we use a helper script.

BAM_FILE - Your input file \
-G       - Overhang (positive for 5', negative for 3') \
-q       - Minimum mapping quality score \
--csv    - Output format option
FILE_CSV - Name of output csv



```
run_digenome.sh file.bam -G 3 -q 30 --csv file.csv
```

Citation info: Kim D. et al. Digenome-seq: genome-wide profiling of CRISPR-Cas9 off-target effects in human cells. Nature Methods 12, 237-243 (2015).


http://www.rgenome.net/digenome/
