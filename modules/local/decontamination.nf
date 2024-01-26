/*
 * Host decontamination
*/
process DECONTAMINATION {

    label 'process_medium'
    tag "${meta.id} align to ${ref_fasta}"

    container 'quay.io/microbiome-informatics/bwamem2:2.2.1'

    input:
    tuple val(meta), path(reads), path(ref_fasta), path(ref_fasta_index)
    val align  // if true: align (include reads), else: decontaminate (exclude reads)

    output:
    tuple val(meta), path(ref_fasta), path("output/${meta.id}_sorted.bam"), path("output/${meta.id}_sorted.bam.bai"), emit: bam
    path "versions.yml"                                                                                             , emit: versions

    script:
    def input_reads = "";
    if ( reads.collect().size() == 1 ) {
        input_reads = "${reads[0]}";
    } else {
        if (reads[0].name.contains("_1")) {
            input_reads = "${reads[0]} ${reads[1]}"
        } else {
            input_reads = "${reads[1]} ${reads[0]}"
        }
    }

    def samtools_args = ""
    if ( align ) {
        samtools_args = task.ext.alignment_args
    } else {
        samtools_args = task.ext.decontamination_args
    }
    """
    mkdir -p output
    echo "mapping files to host genome"
    bwa-mem2 mem -M \
      -t ${task.cpus} \
      ${ref_fasta} \
      ${input_reads} | \
    samtools view -@ ${task.cpus} ${samtools_args} - | \
    samtools sort -@ ${task.cpus} -O bam - -o output/${meta.id}_sorted.bam

    echo "samtools index sorted bam"
    samtools index -@ ${task.cpus} output/${meta.id}_sorted.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bwa-mem2: \$(bwa-mem2 version 2> /dev/null)
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}
/*
 * Decontamination counts
 * # TODO: assess Qualimap to see tha bwa mapping results
*/
process DECONTAMINATION_REPORT {

    publishDir "${params.outdir}/qc/decontamination", mode: 'copy'

    label 'decontamination_report'

    container 'quay.io/microbiome-informatics/bwamem2:2.2.1'

    input:
    val mode
    path cleaned_reads

    output:
    path "decontamination_output_report.txt", emit: decontamination_report

    script:
    def input_f_reads = "";
    def input_r_reads = "";
    if ( mode == "paired" ) {
        if (cleaned_reads[0].name.contains('_1')) {
            input_f_reads = cleaned_reads[0]
            input_r_reads = cleaned_reads[1]
        } else if (cleaned_reads[1].name.contains('_1')) {
            input_f_reads = cleaned_reads[1]
            input_r_reads = cleaned_reads[0]
        }
        """
        zcat ${input_f_reads} | grep '@' | wc -l > decontamination_output_report.txt
        zcat ${input_r_reads} | grep '@' | wc -l >> decontamination_output_report.txt
        """
    } else if ( mode == "single" ) {
        """
        zcat ${cleaned_reads} | grep '@' | wc -l > decontamination_output_report.txt
        """
    } else {
        error "Invalid mode: ${mode}"
    }
}


/*
 * Download reference genome HG38
*/
process GET_REF_GENOME {

    publishDir "${params.databases}/", mode: 'copy'

    label 'decontamination_genome'

    publishDir "${params.databases}/${params.decontamination_indexes_folder}", mode: 'copy'

    container 'quay.io/microbiome-informatics/bwamem2:2.2.1'

    input:
    val db_name

    output:
    path "${db_name}", emit: db

    script:
    """
    wget "${params.download_ftp_path}/${db_name}.tar.gz"
    tar -xvzf "${db_name}.tar.gz"
    rm "${db_name}.tar.gz"
    """
}
