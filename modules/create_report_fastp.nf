/*
 * fastp json parser to report number of reads after every filtering
*/
process FASTP_REPORT {

    publishDir "results/qc", mode: 'copy'

    cpus 1
    memory '1 GB'

    input:
    path fastp_qc
    path fastp_overlap

    output:
    path "qc_report", emit: qc_report

    script:
    """
    fastp_parse.py --qc-json ${fastp_qc} --overlap-json ${fastp_overlap} -o "qc_report"
    """
}
