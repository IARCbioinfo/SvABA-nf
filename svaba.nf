#!/usr/bin/env nextflow

// Copyright (C) 2018 IARC/WHO

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


params.help = null
params.config	= null
params.cpu = 1
params.mem = 4
params.svaba = "svaba"
params.input_folder = null
params.correspondance = null
params.ref = null
params.dbsnp = ""

log.info ""
log.info "----------------------------------------------------------------"
log.info "            Structural variants calling with SvABA              "
log.info "----------------------------------------------------------------"
log.info "Copyright (C) IARC/WHO"
log.info "This program comes with ABSOLUTELY NO WARRANTY; for details see LICENSE"
log.info "This is free software, and you are welcome to redistribute it"
log.info "under certain conditions; see LICENSE for details."
log.info "--------------------------------------------------------"
if (params.help) {
    log.info "--------------------------------------------------------"
    log.info "                     USAGE                              "
    log.info "--------------------------------------------------------"
    log.info ""
    log.info "------------------- svaba-nf----------------------------"
    log.info ""
    log.info "nextflow run svaba.nf --input_folder path/to/input/ --ref path/to/ref/ --dbsnp path/to/dbsnp_indel.vcf --correspondance corr.txt"
    log.info ""
    log.info "Mandatory arguments:"
    log.info "--input_folder         PATH        Folder containing  bam files"
    log.info "--correspondance       FILE        File containing correspondence between path to normal and path to tumor bams for each patient  "
    log.info "--ref                  PATH        Path to reference fasta file (should be indexed) "
    log.info ""
    log.info "Optional arguments:"
    log.info "--cpu                  INTEGER     Number of cpu to use (default=1)"
    log.info "--config               FILE        Use custom configuration file"
    log.info "--mem                  INTEGER     Size of memory used in GB (default=4)"
    log.info "--output_folder				 PATH				 Path to output folder (default=.)"
    log.info "--svaba                PATH        SvABA installation dir (default=svaba)"
    log.info "--dbsnp                FILE        dbSNP file available at: https://data.broadinstitute.org/snowman/dbsnp_indel.vcf"
    log.info ""
    log.info "Flags:"
    log.info "--help                             Display this message"
    log.info ""
    exit 0
}

assert (params.input_folder != null) : "please provide the --input_folder option"
assert (params.correspondance != null) : "please provide the --correspondance option"
assert (params.ref != null) : "please provide the --ref option"

correspondance = file(params.correspondance)
bams = Channel.fromPath(correspondance).splitCsv(header: true, sep: '\t', strip: true)
                .map{row -> [ row.ID, file(params.input_folder + "/" +row.tumor), file(params.input_folder + "/" +row.tumor+'.bai'),
                              file(params.input_folder + "/" +row.normal), file(params.input_folder + "/" +row.normal+'.bai')]}

if (params.dbsnp == "") { dbsnp_par="" } else { dbsnp_par="-D" }

fasta_ref = file(params.ref)
fasta_ref_fai = file( params.ref+'.fai' )
fasta_ref_sa = file( params.ref+'.sa' )
fasta_ref_bwt = file( params.ref+'.bwt' )
fasta_ref_ann = file( params.ref+'.ann' )
fasta_ref_amb = file( params.ref+'.amb' )
fasta_ref_pac = file( params.ref+'.pac' )
fasta_ref_alt = file( params.ref+'.alt' )

process svaba {
		 cpus params.cpu
     memory params.mem+'G'
     tag { sampleID }

     publishDir params.output_folder, mode: 'copy'

     input :
     set val(sampleID),file(tumorBam),file(tumorBai),file(normalBam),file(normalBai) from bams
     file fasta_ref
     file fasta_ref_fai
     file fasta_ref_sa = file( params.ref+'.sa' )
     file fasta_ref_bwt = file( params.ref+'.bwt' )
     file fasta_ref_ann = file( params.ref+'.ann' )
     file fasta_ref_amb = file( params.ref+'.amb' )
     file fasta_ref_pac = file( params.ref+'.pac' )
     file fasta_ref_alt = file( params.ref+'.alt' )

     output:
     file "${sampleID}*.vcf" into vcf
     file "${sampleID}.alignments.txt.gz" into alignments

     shell :
     '''
     !{params.svaba} run -t !{tumorBam} -n !{normalBam} -p !{params.cpu} !{dbsnp_par} !{params.dbsnp} -a somatic_run -G !{fasta_ref}
     mv somatic_run.alignments.txt.gz !{sampleID}.alignments.txt.gz
     mv somatic_run.svaba.somatic.sv.vcf !{sampleID}.somatic.sv.vcf
     mv somatic_run.svaba.somatic.indel.vcf !{sampleID}.somatic.indel.vcf
     mv somatic_run.svaba.germline.indel.vcf !{sampleID}.germline.indel.vcf
     mv somatic_run.svaba.germline.sv.vcf !{sampleID}.germline.sv.vcf
     '''
}
