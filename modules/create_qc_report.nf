/*
 * fastp json parser to report number of reads after every filtering
*/
process QC_REPORT {

    publishDir "${params.outdir}/qc", mode: 'copy'

    container 'quay.io/biocontainers/python:3.9--1'

    label 'report'

    input:
    val mode
    path filtering_fastp_json
    path seqprep_counts

    output:
    path "qc_summary", emit: qc_report

    script:
    def inputs = ""
    if (mode == "paired") {
        inputs = "--qc-json ${filtering_fastp_json} --overlap-counts ${seqprep_counts}"
    }
    else {
        inputs = "--qc-json ${filtering_fastp_json} "
    }

    """
    collect_counts.py ${inputs} -o "qc_summary"
    """
}
