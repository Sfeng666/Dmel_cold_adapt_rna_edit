# High-speed download of RNA-seq data from SRA archive

----
This program downloads RNA-seq data (.fastq) from EBI-ENA (European Nucleotide Archive). We use the downloader [aspera](https://anaconda.org/hcc/aspera-cli) for its high-speed feature.

## Code by steps
1. Install aspera using Conda
2. Generate a [filereport](data/dmel_cold_rnaseq_fastq_list.txt) from [EBI-ENA](https://www.ebi.ac.uk/ena/browser/home), for extracting the SRA information under a given bio-project
3. Extract the FTP paths to fastq files into the [input list for aspera downloading](data/dmel_cold_rnaseq_fastq_list.txt), using [generate_ascp_input_list.sh](code/generate_ascp_input_list.sh)
4. Download all files, by running [ascp_download.sh](code/ascp_download.sh)