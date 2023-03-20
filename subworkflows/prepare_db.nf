/*
    ~~~~~~~~~~~~~~~~~~
     DBs
    ~~~~~~~~~~~~~~~~~~
*/
include { GET_MAPSEQ_DB as GET_MAPSEQ_DB_SSU } from '../modules/mapseq'
include { GET_MAPSEQ_DB as GET_MAPSEQ_DB_LSU } from '../modules/mapseq'
include { GET_CMSEARCH_DB } from '../modules/cmsearch'

workflow PREPARE_DBS {

    main:
        // mapseq SSU
        if (!(file("${params.databases}/${params.silva_ssu_db_name}").exists())) {
            GET_MAPSEQ_DB_SSU("${params.silva_ssu_db_name}")
            mapseq_db_ssu = GET_MAPSEQ_DB_SSU.out }
        else {
            mapseq_db_ssu = channel.fromPath("${params.databases}/${params.silva_ssu_db_name}") }

        // mapseq LSU
        if (!(file("${params.databases}/${params.silva_lsu_db_name}").exists())) {
            GET_MAPSEQ_DB_LSU("${params.silva_lsu_db_name}")
            mapseq_db_lsu = GET_MAPSEQ_DB_LSU.out }
        else {
            mapseq_db_lsu = channel.fromPath("${params.databases}/${params.silva_lsu_db_name}") }

        // Rfam
        if (!(file("${params.databases}/${params.cmsearch_db_name}").exists())) {
            GET_CMSEARCH_DB("${params.cmsearch_db_name}")
            cmsearch_ribo_db = GET_CMSEARCH_DB.out.ribo_db
            cmsearch_ribo_clan = GET_CMSEARCH_DB.out.ribo_clan
            cmsearch_other_db = GET_CMSEARCH_DB.out.other_db
            cmsearch_other_clan = GET_CMSEARCH_DB.out.other_clan
            }
        else {
            cmsearch_ribo_db = channel.fromPath("${params.databases}/${params.cmsearch_db_name}/${params.ribosomal_model_path}")
            cmsearch_ribo_clan = channel.fromPath("${params.databases}/${params.cmsearch_db_name}/${params.ribosomal_claninfo_path}")
            cmsearch_other_db = channel.fromPath("${params.databases}/${params.cmsearch_db_name}/${params.other_model_path}")
            cmsearch_other_clan = channel.fromPath("${params.databases}/${params.cmsearch_db_name}/${params.other_claninfo_path}")
            }
    emit:
        mapseq_db_ssu
        mapseq_db_lsu
        cmsearch_ribo_db
        cmsearch_ribo_clan
        cmsearch_other_db
        cmsearch_other_clan
}
