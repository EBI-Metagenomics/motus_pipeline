/*
 * seqtk 1.3
*/

process SEQTK {
    publishDir "${params.output}/", mode: 'copy'

    container 'quay.io/biocontainers/seqtk:1.3--h7132678_4'

    cpus 2

    input:
        path reads
    output:
        path "*.fasta", emit: sequence

    script:
    """
    seqtk seq -a ${reads} > ${reads.baseName}.fasta
    """
}