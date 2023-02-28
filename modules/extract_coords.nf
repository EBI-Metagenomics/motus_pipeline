/*
 * Extract models from cmsearched fasta
*/

process EXTRACT_MODELS {

    publishDir 'results/cmsearch/', mode:'copy'
    container 'quay.io/biocontainers/biopython:1.75'

    memory '300 MB'
    cpus 1

    input:
        val name
        path sequences

    output:
        path "sequence-categorisation/", emit: sequence_categorisation
        path "sequence-categorisation/${name}_SSU.fasta", optional: true, emit: ssu_fasta
        path "sequence-categorisation/${name}_LSU.fasta", optional: true, emit: lsu_fasta

    script:
        """
        get_subunits.py -i ${sequences} -n $name
        """
}
