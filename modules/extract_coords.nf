/*
 * Extract models from cmsearched fasta
*/

process EXTRACT_MODELS {

    publishDir "${params.outdir}/cmsearch/", mode:'copy'
    
    label 'extract_coords'
    
    container 'quay.io/biocontainers/biopython:1.75'

    input:
    val name
    path sequences

    output:
    path "sequence-categorisation/"
    path "sequence-categorisation/${name}_SSU.fasta", optional: true, emit: ssu_fasta
    path "sequence-categorisation/${name}_LSU.fasta", optional: true, emit: lsu_fasta

    script:
    """
    get_subunits.py -i ${sequences} -n $name
    """
}
