/*
 * Extract models from cmsearched fasta
*/

process EXTRACT_MODELS {

    publishDir 'results/cmsearch/', mode:'copy'

    memory '1 GB'
    cpus 1

    input:
        path sequences

    output:
        path "sequence-categorisation/"
        path "sequence-categorisation/SSU.fasta", optional: true, emit: ssu_fasta
        path "sequence-categorisation/LSU.fasta", optional: true, emit: lsu_fasta

    script:
        """
        get_subunits.py -i ${sequences}
        """
}
