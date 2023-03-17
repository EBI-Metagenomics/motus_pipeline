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
        val otu_label
    output:
        path "${sequence.baseName}.mseq", emit: mapseq_result

    script:
    """
    mapseq \
        ${sequence} \
        ${mapseq_db}/${params.ssu_db_fasta} \
        ${mapseq_db}/${params.ssu_db_tax} \
        -nthreads ${task.cpus} \
        -tophits 80 \
        -topotus 40 \
        -outfmt 'simple' > ${sequence.baseName}.mseq
    """
}

/*
 * Download MGnify mapseq DB
*/
process GET_MAPSEQ_DB_SSU {

    publishDir "${params.databases}/", mode: 'copy', pattern: "silva_ssu-20200130"
    label 'mapseq_db'

    output:
        path "*", emit: db

    script:
    """
    wget ${params.download_ftp_path}/${params.silva_ssu_db_name}
    tar -xvzf ${params.silva_ssu_db_name}
    rm ${params.silva_ssu_db_name}
    """
}