# this script extracts the vcf files for parental lines involved in (Yuheng et al, 2021)


path_vcf_tar=/raid10/backups/octavius/nexus1.1/POOL_sites_vcfs.tar  # path to the tar file containing vcf files containing genotype information for all sites of all Drosophila nexus 1.1 strains
path_vcf_parental=/raid10/boqin/data/dmel_cold_tolerance/SNP/parental_lines_vcfs  # path to the folder containing the vcf files for parental lines
path_filereport=fixed_sites_panel/data/filereport_read_run_PRJNA720479_include_samplename.txt   # path to the file containing the sample names 
path_log=fixed_sites_panel/data/log_prep_sites_vcf_parental_lines.txt  # path to the log file
path_script_fixed_sites=fixed_sites_panel/code/extract_fixed_sites_from_vcf.py  # path to the python script that extracts fixed sites from vcf files
path_vcf_fixed=fixed_sites_panel/data/fixed_sites_panel.vcf  # path to vcf file containing the fixed sites for parental lines (maintained as .vcf only for using 'bcftools consensus' later, only useful information is the first four column)
path_ref_genome=/raid10/Tiago/PigmCages/scripts/alignment_software/dmel_ref/DmelRef.fasta # path to the reference genome sequence (release 5)
path_ref_genome_mutated=fixed_sites_panel/data/DmelRef_mutated_at_fixed_sites.fasta  # path to the reference genome sequence (release 5) mutated with the fixed alterinative alleles


# 1. from the tar file, extract the vcf files for the parental lines, whose file names include the name of each parental line
# the names of parental lines are included in sample names in the last column (column name is sample_alias) of $path_filereport, which looks like the following snippet:
# study_accession	sample_accession	experiment_accession	run_accession	tax_id	scientific_name	fastq_ftp	sra_ftp	sample_alias
# PRJNA720479	SAMN18651930	SRX10548219	SRR14180007	7227	Drosophila melanogaster	ftp.sra.ebi.ac.uk/vol1/fastq/SRR141/007/SRR14180007/SRR14180007_1.fastq.gz;ftp.sra.ebi.ac.uk/vol1/fastq/SRR141/007/SRR14180007/SRR14180007_2.fastq.gz	ftp.sra.ebi.ac.uk/vol1/srr/SRR141/007/SRR14180007	SD54N_parent
# one example is to extract 'SD54N' as the name of parental line, from the sample name 'SD54N_parent'
# the following command extracts the vcf files for the parental lines, and save them in the folder 'fixed_sites_panel/data/parental_lines_vcfs'
mkdir -p $path_vcf_parental
echo "Decompression starts at: $(date)" > $path_log
cat $path_filereport | awk -F'\t' 'NR>1{print $NF}' | awk -F'_' '{print $1}' | sort | uniq | while read line; do tar -xvf $path_vcf_tar -C $path_vcf_parental --strip-components=1 --wildcards --no-anchored "*${line}_sites.vcf.gz"; done >> $path_log 2>&1 &
echo "Decompression ends at: $(date)" >> $path_log

# 2. extract sites that have the same genotype fixed across all extracted parental lines from above vcf.gz files
echo "Extracting sites starts at: $(date)" >> $path_log
python $path_script_fixed_sites $path_vcf_parental $path_vcf_fixed >> $path_log 2>&1 &
echo "Extracting sites ends at: $(date)" >> $path_log

# 3. mutate the reference genome sequence (release 5) with the fixed sites, if fixed at alternative alleles
# use 'bcftools concensus'
echo "Mutating reference genome starts at: $(date)" >> $path_log
bcftools consensus -f $path_ref_genome -o $path_ref_genome_mutated $path_vcf_fixed >> $path_log 2>&1 &
echo "Mutating reference genome ends at: $(date)" >> $path_log

