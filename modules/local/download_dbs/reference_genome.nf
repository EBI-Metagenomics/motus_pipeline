/*
 * Download reference genome, default: HG38
*/
process GET_REFERENCE_GENOME {

    tag "${db_name}"
    label 'process_single'

    container ''
    
    input:
    val db_name

    output:
    path "${db_name}", emit: reference_genome_folder

    script:
    """
    wget "${params.download_ftp_path}/${db_name}.tar.gz"
    tar -xvzf "${db_name}.tar.gz"
    rm "${db_name}.tar.gz"
    """
}