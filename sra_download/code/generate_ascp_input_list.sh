awk -F'\t' 'NR>1 { split($7, fastq_paths, ";"); for (i in fastq_paths) { gsub(/ftp.sra.ebi.ac.uk/, "", fastq_paths[i]); print fastq_paths[i] } }' filereport_read_run_PRJNA720479_tsv.txt > dmel_cold_rnaseq_fastq_list.txt