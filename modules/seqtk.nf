/*
 * seqtk 1.3
*/

process SEQTK {
    publishDir "${params.outdir}/", mode: 'copy'

    container 'quay.io/biocontainers/seqtk:1.3--h7132678_4'

    cpus 2

    input:
        val name
        path reads
    output:
        path "${name}.fasta", emit: sequence

    script:
    """
    seqtk seq -a ${reads} > ${name}.fasta
    """
}