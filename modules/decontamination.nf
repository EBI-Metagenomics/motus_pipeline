/*
 * Host decontamination
*/
process DECONTAMINATION {

    container 'quay.io/microbiome-informatics/bwamem2:2.2.1'
    publishDir "results/qc", mode: 'copy'

    cpus 1
    memory '2 GB'

    input:
    path reads
    path reference_genome
    val ref_gen_name

    output:
    path "*_clean*.fastq.gz", emit: decontaminated_reads

    script:
    def input_reads = reads.size() == 1 ? "-f ${reads[0]}" : "-f ${reads[0]} -r ${reads[1]}"

    """
    map_host.sh -t ${task.cpus} \
    ${input_reads} \
    -c ${reference_genome}/${ref_gen_name} \
    -o output_decontamination
    """
}