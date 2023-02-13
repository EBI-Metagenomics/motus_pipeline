/*
 * qc_stats for fasta or fastq file (was named MGRAST_base.py)
*/
process QC_STATS {

    publishDir "results/qc", mode: 'copy'

    cpus 1
    memory '200 MB'

    input:
    path sequence

    output:
    path "qc-statistics", emit: qc_statistics

    script:
    """
    qc_summary.py -i ${sequence} --output-dir "qc-statistics"
    """
}
