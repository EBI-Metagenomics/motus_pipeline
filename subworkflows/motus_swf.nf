/*
 * mOTUs with pre-download DB
 */

include { DOWNLOAD_MOTUS_DB } from '../subworkflows/prepare_db'
include { MOTUS } from '../modules/motus'

workflow MOTUS_SUBWF {
    take:
        reads
    main:
        if (params.motus_db){
            motus_db = channel.fromPath(params.motus_db, checkIfExists: true)
        }
        else {
            DOWNLOAD_MOTUS_DB()
            motus_db = DOWNLOAD_MOTUS_DB.out.motus_db
        }
        MOTUS(reads, motus_db)
    emit:
        motus_tsv = MOTUS.out.motus_result_cleaned
}

