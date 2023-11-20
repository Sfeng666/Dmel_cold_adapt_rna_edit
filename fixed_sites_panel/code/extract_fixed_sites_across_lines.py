# This script extract sites that have the same allele fixed across all extracted parental lines from above vcf.gz files
import os
import gzip
from optparse import OptionParser

# each vcf.gz has the same genomic sites of a parental line
# each row is a site, and each column is a field of the site
# the vcf.gz files have a header like this: CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	GENOTYPE
# more detailed explanation for the headers can be found here: http://www.johnpool.net/vcf_header_info.txt
# sites to be extracted should meet the following criteria:
# 1) the site is homozygous (same genotype) in any given parental line, which means the first segment in column 10 is either '0/0' (homozygous at the reference allele 'REF') or '1/1' (homozygous at the alternative allele 'ALT'); and
# 2) the genotype of the site is the same across all parental lines (i.e., vcf.gz files); and
# 3) the genotype of the site is not missing in any parental lines, which means column 6 must not be '.'; and
# 4) the sites must meet the filtering criterion, which means column 7 must not be 'LowQual'.
# the output file is a standard VCF 4.2 format without headers that begins with '###'

### help & usage ### 
usage = "usage: %prog [options] args"
description = "extract sites that have the same allele fixed across all extracted parental lines"
version = '%prog 11.20.2023'
parser = OptionParser(usage=usage,version=version, description = description)
parser.add_option("--path_parental_vcfs",
                    action="store",
                    dest="path_parental_vcfs",
                    help="path to the directory that include site information of all parental lines (.vcf.gz)",
                    metavar = 'PATH')
parser.add_option("--path_out_vcf",
                    action="store",
                    dest="path_out_vcf",
                    help="path to the output VCF file that include sites fixed across all parental lines (.vcf)",
                    metavar = 'PATH')                                                                 
(options, args) = parser.parse_args()

# Get the values of the command line options
path_parental_vcfs = options.path_parental_vcfs
path_out_vcf = options.path_out_vcf

# # arguments for test only
# path_parental_vcfs = '/raid10/boqin/data/dmel_cold_tolerance/SNP/parental_lines_vcfs'
# path_out_vcf = 'fixed_sites_panel/data/fixed_sites_panel.vcf'

# Define a function to get all file paths under a directory
def get_file_paths(directory_path):
    file_paths = []
    for root, _, files in os.walk(directory_path):
        for file in files:
            file_paths.append(os.path.join(root, file))
    return file_paths

# define a function to compare genotype site-by-site across all parental lines
def compare_site_genotype(file_paths, path_out_vcf):
    file_handles = [gzip.open(file, 'rt') for file in file_paths]

    with open(path_out_vcf, 'a') as out:
        header = ['#CHROM', 'POS', 'ID', 'REF', 'ALT', 'QUAL', 'FILTER', 'INFO', 'FORMAT', 'GENOTYPE']  # Read header from each file
        out.write('\t'.join(header) + '\n')    # write the same input header to the output file

        while True:
            lines = [file.readline().strip() for file in file_handles]  # Read one line from each file
            lines_split = [line.split('\t') for line in lines]  # Split columns by tab
            if any(lines):  # Check if at least one file still has lines
                if all(lines):  # Check if all files have non-empty lines

                    qual = [line[5] for line in lines_split]  # Extract QUAL column
                    if '.' in qual: # filter sites that have missing genotype in any parental line
                        continue

                    filter = [line[6] for line in lines_split]  # Extract FILTER column
                    if 'LowQual' in filter: # filter sites that have LowQual in any parental line
                        continue

                    genotypes = [line[9].split(':')[0].split('/') for line in lines_split]  # Extract GENOTYPE column
                    if list(genotype for genotype in genotypes if len(set(genotype)) == 2) != []: # filter sites that are heterozygous in any parental line
                        continue

                    alleles = [line[4:6] for line in lines_split]  # Extract REF and ALT column (refernce and alternative alleles)
                    fixed_alleles = [alleles[i][int(list(set(genotypes[i]))[0])] for i in range(len(genotypes))]   # generate a list of alleles that are fixed across all parental lines, using genotype number as the index on alleles
                    if len(set(fixed_alleles)) == 1: # extract sites that are fixed on the same allele across all parental lines
                        # keep writing the site information to the output file in VCF 4.2 format during the loop, instead of write them all at once after the loop
                        # this is to save memory, because the output file can be very large
                        # the output file is a standard VCF 4.2 format with header
                        # the header is the same as the header of the input files
                        # the output file is saved as 'fixed_sites_panel/data/sites_parental_lines.txt'
                        out.write('\t'.join(lines_split[0][:3] + ['.', list(set(fixed_alleles))[0], '.', '.', '.', '.', '.']) + '\n')
                else:
                    print("Number of lines in files differs.")
                    break
            else:
                break

    # Close all file handles
    for file_handle in file_handles:
        file_handle.close()

# get all file paths of .vcf.gz files under the directory
file_paths = get_file_paths(path_parental_vcfs)

# extract fixed sites across all parental lines with the function defined above
compare_site_genotype(file_paths, path_out_vcf)