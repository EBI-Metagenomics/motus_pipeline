/*
 * fastp
*/

process FASTP {
    publishDir "${params.output}/qc/fastp", mode: 'copy', pattern: "*html"
    publishDir "${params.output}/qc/fastp", mode: 'copy', pattern: "*json"
    publishDir "${params.output}/qc", mode: 'copy', pattern: "*fastq*"

    container 'quay.io/biocontainers/fastp:0.23.1--h79da9fb_0'
    cpus = 2

    input:
    val name
    path reads
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
    def input_reads = reads.size() == 1 ? "--in1 ${reads[0]}" : "--in1 ${reads[0]} \
                                                                 --in2 ${reads[1]} \
                                                                 --detect_adapter_for_pe"
    def output_reads = reads.size() == 1 ? "--out1 ${name}_fastp.fastq.gz" : "--out1 ${name}_fastp_1.fastq.gz \
                                                                              --out2 ${name}_fastp_2.fastq.gz"

    def polya_trim_param = polya_trim_param ? "-x ${polya_trim_param}" : ""
    def qualified_quality_phred = qualified_quality_phred ? "-q ${qualified_quality_phred}" : ""
    def length_filter = length_filter ? "-l ${length_filter}" : ""
    def unqualified_percent_limit = unqualified_percent_limit ? "-u ${unqualified_percent_limit}" : ""
    def merge = merged_reads ? "-m \
                                --merged_out ${name}_${merged_reads} \
                                --unpaired1 ${name}.unpaired_1.fastq.gz \
                                --unpaired2 ${name}.unpaired_2.fastq.gz" : ""
    def report_name = merged_reads ? "overlap" : "qc"

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
    ${unqualified_percent_limit} \
    """
}