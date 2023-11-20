# this script extracts the vcf files for parental lines involved in (Yuheng et al, 2021)


path_vcf_tar=/raid10/backups/octavius/nexus1.1/POOL_sites_vcfs.tar  # path to the tar file containing vcf files containing genotype information for all sites of all Drosophila nexus 1.1 strains
path_filereport=fixed_sites_panel/data/filereport_read_run_PRJNA720479_include_samplename.txt   # path to the file containing the sample names 

# 1. from the tar file, extract the vcf files for the parental lines, whose file names include the name of each parental line
# the names of parental lines are included in sample names in the last column (column name is sample_alias) of $path_filereport, which looks like the following snippet:
# study_accession	sample_accession	experiment_accession	run_accession	tax_id	scientific_name	fastq_ftp	sra_ftp	sample_alias
# PRJNA720479	SAMN18651930	SRX10548219	SRR14180007	7227	Drosophila melanogaster	ftp.sra.ebi.ac.uk/vol1/fastq/SRR141/007/SRR14180007/SRR14180007_1.fastq.gz;ftp.sra.ebi.ac.uk/vol1/fastq/SRR141/007/SRR14180007/SRR14180007_2.fastq.gz	ftp.sra.ebi.ac.uk/vol1/srr/SRR141/007/SRR14180007	SD54N_parent
# one example is to extract 'SD54N' as the name of parental line, from the sample name 'SD54N_parent'
# the following command extracts the vcf files for the parental lines, and save them in the folder 'fixed_sites_panel/data/parental_lines_vcfs'
mkdir -p fixed_sites_panel/data/parental_lines_vcfs
cat $path_filereport | awk -F'\t' 'NR>1{print $NF}' | awk -F'_' '{print $1}' | sort | uniq | while read line; do tar -xvf $path_vcf_tar -C fixed_sites_panel/data/parental_lines_vcfs --wildcards --no-anchored "*${line}*.vcf"; done
