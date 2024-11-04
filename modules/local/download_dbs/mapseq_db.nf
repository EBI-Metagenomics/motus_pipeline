/*
 * Download MGnify mapseq DB
*/
process GET_MAPSEQ_DB {

    tag "${db_name}"
    label 'process_single'

    container ''

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