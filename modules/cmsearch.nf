/*
 * Infernal cmsearch 1.1.4
*/

process CMSEARCH {

    publishDir "${params.outdir}/cmsearch/", mode:'copy'

    label 'cmsearch'
    
    container 'quay.io/biocontainers/infernal:1.1.4--pl5321hec16e2b_1'

    input:
    path sequences
    file covariance_model_database

    output:
    path "${sequences.baseName}*.cmsearch_matches.tbl", emit: cmsearch

    script:
    """
    cmsearch \
    --cpu ${task.cpus} \
    --cut_ga \
    --noali \
    --hmmonly \
    -Z 1000 \
    -o /dev/null \
    --tblout ${sequences.baseName}.cmsearch_matches.tbl \
    ${covariance_model_database} \
    ${sequences}
    """
}

/*
 * Download MGnify Rfam DB
*/
process GET_CMSEARCH_DB {
    publishDir "${params.databases}/", mode: 'copy'

    label 'cmsearch_db'

    input:
        val db_name
    output:
        path "${db_name}/${params.ribosomal_model_path}", emit: ribo_db
        path "${db_name}/${params.other_model_path}", emit: other_db
        path "${db_name}/${params.ribosomal_claninfo_path}", emit: ribo_clan
        path "${db_name}/${params.other_claninfo_path}", emit: other_clan

    script:
    """
    wget "${params.download_ftp_path}/${db_name}.tar.gz"
    tar -xvzf "${db_name}.tar.gz"
    rm "${db_name}.tar.gz"
    """
}