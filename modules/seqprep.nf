/*
 * SeqPrep: overlap reads
*/

process SEQPREP {
    publishDir "${params.outdir}/qc/seqprep", mode: 'copy'
    label 'seqprep'
    container 'quay.io/biocontainers/seqprep:1.3.2--hed695b0_4'

    input:
        val name
        path reads
    output:
        path "${name}_merged.fastq.gz", emit: overlapped_reads
        path "${name}_forward_unmerged.fastq.gz", emit: forward_unmapped_reads
        path "${name}_reverse_unmerged.fastq.gz", emit: reverse_unmerged_reads

    script:
    def input_reads = "";
    if (reads[0].name.contains("_1")) {
        input_reads = "-f ${reads[0]} -r ${reads[1]}"
    } else {
        input_reads = "-f ${reads[1]} -r ${reads[0]}"
    }
    """
    SeqPrep \
    ${input_reads} \
    -1 ${name}_forward_unmerged.fastq.gz \
    -2 ${name}_reverse_unmerged.fastq.gz \
    -s ${name}_merged.fastq.gz
    
    """
}

process SEQPREP_REPORT {
    publishDir "${params.outdir}/qc/seqprep", mode: 'copy'
    label 'seqprep_report'
    // TODO change container
    container 'quay.io/openshifttest/base-alpine:1.2.0'

    input:
        path forward_unmapped_reads
        path reverse_unmerged_reads
        path merged_reads
    output:
        path "seqprep_output_report.txt", emit: overlapped_report

    script:
    """
    zcat ${forward_unmapped_reads} | grep '@' | wc -l > seqprep_output_report.txt
    zcat ${reverse_unmerged_reads} | grep '@' | wc -l >> seqprep_output_report.txt
    zcat ${merged_reads} | grep '@' | wc -l >> seqprep_output_report.txt
    """
}