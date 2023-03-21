#!/usr/bin/env nextflow

/* Mainly used for testing */

include { MOTUS_DOWNLOAD_DB } from '../modules/motus'

workflow MOTUS_DB_DOWNLOAD_TEST {

    main:
        MOTUS_DOWNLOAD_DB()
    emit:
        motus_db = MOTUS_DOWNLOAD_DB.out.db
}
