process MULTIQC {

    publishDir "${params.outdir}/qc/multiqc", mode: 'copy'

    container 'quay.io/biocontainers/multiqc:1.14--pyhdfd78af_0'

    input:
    path fastp_json
    path motus_log, name: "motus.log"

    output:
    path "multiqc_report.html", emit: multiqc_report
    path "multiqc_data", emit: multiqc_data

    script:
    """
    multiqc --module fastp --module motus .
    """
}
