/*
 * fastp
*/

process FASTP {
    publishDir "${params.outdir}/qc/fastp", mode: 'copy', pattern: "*html"
    publishDir "${params.outdir}/qc/fastp", mode: 'copy', pattern: "*json"
    publishDir "${params.outdir}/qc", mode: 'copy', pattern: "*fastq*"

    container 'quay.io/biocontainers/fastp:0.23.1--h79da9fb_0'
    cpus = 8

    input:
    val name
    path reads
    val mode
    val merged_reads
    val length_filter
    val polya_trim_param
    val qualified_quality_phred
    val unqualified_percent_limit

    output:
    path "*_fastp*.fastq.gz", optional: true, emit: output_reads
    path "*_fastp.*.json", emit: json
    path "*_fastp.*.html", emit: html
    path "*_merged*", optional: true, emit: overlapped_reads

    script:

    def input_reads = ""
    if (mode == 'single') {
        input_reads = "--in1 ${reads[0]}"
    }
    if (mode == 'paired') {
        if (reads[0].contains('_1.fastq')) {
            input_reads = "--in1 ${reads[0]} --in2 ${reads[1]} --detect_adapter_for_pe"
        } else {
            input_reads = "--in1 ${reads[1]} --in2 ${reads[0]} --detect_adapter_for_pe"
        }
    }

    def output_reads = ""
    if (mode == 'single') {
         output_reads = "--out1 ${name}_fastp.fastq.gz" }
    if (mode == 'paired') {
        output_reads = "--out1 ${name}_fastp_1.fastq.gz --out2 ${name}_fastp_2.fastq.gz"
    }

    def polya_trim_param = polya_trim_param ? "-x ${polya_trim_param}" : ""
    def qualified_quality_phred = qualified_quality_phred ? "-q ${qualified_quality_phred}" : ""
    def length_filter = length_filter ? "-l ${length_filter}" : ""
    def unqualified_percent_limit = unqualified_percent_limit ? "-u ${unqualified_percent_limit}" : ""
    def report_name = merged_reads ? "overlap" : "qc"

    def merge = ""
        if (merged_reads) {
            merge = "-m --merged_out ${name}_${merged_reads} --unpaired1 ${name}.unpaired_1.fastq.gz --unpaired2 ${name}.unpaired_2.fastq.gz" }

    """
    fastp -w ${task.cpus} \
    ${input_reads} \
    --json ${name}_fastp.${report_name}.json \
    --html ${name}_fastp.${report_name}.html \
    ${merge} \
    ${output_reads} \
    ${length_filter} \
    ${polya_trim_param} \
    ${qualified_quality_phred} \
    ${unqualified_percent_limit}
    """
}
