/*
 * fastp json parser to report number of reads after every filtering
*/
process FASTP_REPORT {

    publishDir "${params.outdir}/qc", mode: 'copy'
    container 'python:3.8'
    label 'fastp_report'

    input:
    path fastp_jsons
    val mode

    output:
    path "qc_summary", emit: qc_report

    script:
    def inputs = ""
    if (mode == "paired") {
        if (fastp_jsons[0].name.contains('.qc.')) {
            inputs = "--qc-json ${fastp_jsons[0]} --overlap-json ${fastp_jsons[1]} "
        }
        else {
            inputs = "--qc-json ${fastp_jsons[1]} --overlap-json ${fastp_jsons[0]} "
        }
    }
    else {
        inputs = "--qc-json ${fastp_jsons[0]} "
    }

    """
    fastp_parse.py ${inputs} -o "qc_summary"
    """
}
