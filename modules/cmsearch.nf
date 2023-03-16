/*
 * Infernal cmsearch 1.1.4
*/

process CMSEARCH {

    publishDir "${params.outdir}/cmsearch/", mode:'copy'

    label 'cmsearch'
    
    container 'quay.io/biocontainers/infernal:1.1.4--pl5321hec16e2b_1'

    memory '24 GB'
    cpus 4

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
