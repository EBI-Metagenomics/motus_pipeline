/*
 * Download MGnify Rfam DB
*/
process GET_RFAM_DB {
    
    tag "${db_name}"
    label 'process_single'

    container ''

    input:
    val db_name

    output:
    path "${db_name}/${params.ribosomal_model_path}", emit: ribo_db
    path "${db_name}/${params.other_model_path}/*.cm", emit: other_db
    path "${db_name}/${params.ribosomal_claninfo_path}", emit: ribo_clan
    path "${db_name}/${params.other_claninfo_path}", emit: other_clan

    script:
    """
    wget "${params.download_ftp_path}/${db_name}.tar.gz"
    tar -xvzf "${db_name}.tar.gz"
    rm "${db_name}.tar.gz"
    """
}