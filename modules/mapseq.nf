/*
 * MAPseq 2.1.1
*/
process MAPSEQ {
    publishDir "${params.outdir}/taxonomy-summary/${otu_label}", mode: 'copy', pattern: "${sequence.baseName}_${mapseq_db.baseName}.mseq*"

    container 'quay.io/biocontainers/mapseq:2.1.1--ha34dc8c_0'
    label 'mapseq'

    input:
        path sequence
        path mapseq_db
        val db_fasta
        val db_tax
        val otu_label
    output:
        path "${sequence.baseName}.mseq", emit: mapseq_result

    script:
    """
    mapseq \
        ${sequence} \
        ${mapseq_db}/${db_fasta} \
        ${mapseq_db}/${db_tax} \
        -nthreads ${task.cpus} \
        -tophits 80 \
        -topotus 40 \
        -outfmt 'simple' > ${sequence.baseName}.mseq
    """
}

/*
 * Download MGnify mapseq DB
*/
process GET_MAPSEQ_DB {
    publishDir "${params.databases}/", mode: 'copy', pattern: "${db_name}"

    label 'mapseq_db'

    input:
        val db_name
    output:
        path "*", emit: db

    script:
    """
    wget "${params.download_ftp_path}/${db_name}.tar.gz"
    tar -xvzf "${db_name}.tar.gz"
    rm "${db_name}.tar.gz"
    """
}