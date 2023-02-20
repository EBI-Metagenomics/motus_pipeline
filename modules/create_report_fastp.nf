/*
 * fastp json parser to report number of reads after every filtering
*/
process FASTP_REPORT {

    publishDir "results/qc", mode: 'copy'
    container 'python:3.7.9-slim-buster'

    cpus 1
    memory '300 MB'

    input:
    path fastp_qc
    path fastp_overlap

    output:
    path "qc_summary", emit: qc_report

    script:
    """
    fastp_parse.py --qc-json ${fastp_qc} --overlap-json ${fastp_overlap} -o "qc_summary"
    """
}
