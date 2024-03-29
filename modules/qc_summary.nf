/*
 * qc_stats for fasta or fastq file (was named MGRAST_base.py)
*/
process QC_STATS {

    publishDir "${params.outdir}/qc", mode: 'copy'

    container 'quay.io/biocontainers/biopython:1.75'

    label 'qc_summary'

    input:
    path sequence

    output:
    path "statistics", emit: qc_statistics

    script:
    """
    qc_summary.py -i ${sequence} --output-dir "statistics"
    """
}
