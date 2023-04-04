/*
 * fastp
*/

process FASTP {

    publishDir "${params.outdir}/qc/fastp", mode: 'copy', pattern: "*html"
    publishDir "${params.outdir}/qc/fastp", mode: 'copy', pattern: "*json"
    publishDir "${params.outdir}/qc", mode: 'copy', pattern: "*fastq*"

    container 'quay.io/biocontainers/fastp:0.23.1--h79da9fb_0'
    label 'fastp'

    input:
    val name
    file(reads)
    val mode
    val merged_reads
    val length_filter
    val polya_trim_param
    val qualified_quality_phred
    val unqualified_percent_limit

    output:
    path "${name}_fastp*.fastq.gz", optional: true, emit: output_reads
    path "*_fastp.json", emit: json
    path "*_fastp.html", emit: html
    path "*_merged*", optional: true, emit: overlapped_reads

    script:
    /* Handle the input reads */
    def input_reads = "";
    def output_reads = "";
    def report_name = "qc";

    if ( mode == "single" ) {
        input_reads = "--in1 ${reads}";
        output_reads = "--out1 ${name}_fastp.fastq.gz";
    }

    if ( mode == "paired" ) {
        input_reads = "--in1 ${reads[0]} --in2 ${reads[1]} --detect_adapter_for_pe";
        output_reads = "--out1 ${name}_fastp_1.fastq.gz --out2 ${name}_fastp_2.fastq.gz";
    }

    /* Optional parameters */
    def args = ""
    if ( merged_reads ) {
        args += " -m --merged_out ${name}_${merged_reads}" +
        " --unpaired1 ${name}.unpaired_1.fastq.gz " +
        " --unpaired2 ${name}.unpaired_2.fastq.gz"
        report_name = "overlap"
    }
    args += length_filter ? " -l ${length_filter}" : "";
    args += polya_trim_param ? " -x ${polya_trim_param}" : "";
    args += qualified_quality_phred ? " -q ${qualified_quality_phred}" : "";
    args += unqualified_percent_limit ? " -u ${unqualified_percent_limit}" : "";

    """
    fastp -w ${task.cpus} \
    ${input_reads} \
    ${output_reads} \
    --json ${name}_${report_name}_fastp.json \
    --html ${name}_${report_name}_fastp.html \
    ${args}
    """
}
