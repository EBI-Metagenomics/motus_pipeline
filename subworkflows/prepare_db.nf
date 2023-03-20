/*
    ~~~~~~~~~~~~~~~~~~
     DBs
    ~~~~~~~~~~~~~~~~~~
*/
include { GET_MAPSEQ_DB as GET_MAPSEQ_DB_SSU } from '../modules/mapseq'
include { GET_MAPSEQ_DB as GET_MAPSEQ_DB_LSU } from '../modules/mapseq'
include { GET_CMSEARCH_DB } from '../modules/cmsearch'
include { GET_REF_GENOME } from '../modules/decontamination'

workflow DOWNLOAD_REFERENCE_GENOME {
    main:
        if (!(file("${params.databases}/${params.decontamination_indexes_folder}").exists())) {
            GET_REF_GENOME("${params.decontamination_indexes_folder}")
            ref_genome = GET_REF_GENOME.out.hg38 }
        else {
            ref_genome = channel.fromPath("${params.databases}/${params.decontamination_indexes_folder}") }
    emit:
        ref_genome
}


