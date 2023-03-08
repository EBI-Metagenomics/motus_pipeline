/*
 * MAPseq 2.1.1
*/

process MAPSEQ {
    publishDir "${params.outdir}/taxonomy-summary/${otu_label}", mode: 'copy', pattern: "${sequence.baseName}_${mapseq_db.baseName}.mseq*"

    container 'quay.io/biocontainers/mapseq:2.1.1--ha34dc8c_0'

    memory '25 GB'
    cpus 8

    input:
        path sequence
        path mapseq_db
        path mapseq_taxonomy
        val otu_label
    output:
        path "${sequence.baseName}_${mapseq_db.baseName}.mseq", emit: mapseq_result

    script:
    """
    mapseq \
        $sequence \
        ${mapseq_db} \
        $mapseq_taxonomy \
        -nthreads ${task.cpus} \
        -tophits 80 \
        -topotus 40 \
        -outfmt 'simple' > ${sequence.baseName}_${mapseq_db.baseName}.mseq
    """
}