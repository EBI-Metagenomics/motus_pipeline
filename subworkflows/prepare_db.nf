/*
    ~~~~~~~~~~~~~~~~~~
     DBs
    ~~~~~~~~~~~~~~~~~~
*/
include { GET_MAPSEQ_DB as GET_MAPSEQ_DB_SSU } from '../modules/mapseq'
include { GET_MAPSEQ_DB as GET_MAPSEQ_DB_LSU } from '../modules/mapseq'

workflow PREPARE_DBS {

    main:
        if (!(file("${params.databases}/${params.silva_ssu_db_name}").exists())) {
            GET_MAPSEQ_DB_SSU("${params.silva_ssu_db_name}")
            mapseq_db_ssu = GET_MAPSEQ_DB_SSU.out }
        else {
            mapseq_db_ssu = channel.fromPath("${params.databases}/${params.silva_ssu_db_name}") }

        if (!(file("${params.databases}/${params.silva_lsu_db_name}").exists())) {
            GET_MAPSEQ_DB_LSU("${params.silva_lsu_db_name}")
            mapseq_db_lsu = GET_MAPSEQ_DB_LSU.out }
        else {
            mapseq_db_lsu = channel.fromPath("${params.databases}/${params.silva_lsu_db_name}") }

    emit:
        mapseq_db_ssu
        mapseq_db_lsu
}
