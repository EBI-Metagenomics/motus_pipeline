/*
    ~~~~~~~~~~~~~~~~~~
     DBs
    ~~~~~~~~~~~~~~~~~~
*/
include { GET_MAPSEQ_DB as GET_MAPSEQ_DB_SSU } from '../modules/mapseq'
include { GET_MAPSEQ_DB as GET_MAPSEQ_DB_LSU } from '../modules/mapseq'
include { GET_CMSEARCH_DB } from '../modules/cmsearch'
include { GET_REF_GENOME } from '../modules/decontamination'
include { MOTUS_DOWNLOAD_DB } from '../modules/motus'


workflow DOWNLOAD_MOTUS_DB {
    main:
        // mOTUs
        pre_loaded = file("${params.databases}/${params.motus_db_name}");
        if (pre_loaded.exists()) {
            motus_db = pre_loaded;
        } else {
            MOTUS_DOWNLOAD_DB();
            motus_db = MOTUS_DOWNLOAD_DB.out;
        }
    emit:
        motus_db
}

workflow DOWNLOAD_REFERENCE_GENOME {
    main:
        ref_genome = file("${params.databases}/${params.decontamination_indexes_folder}");
        if ( ref_genome.exists() ) {
            ref_genome = file("${params.databases}/${params.decontamination_indexes_folder}");
         } else {
            GET_REF_GENOME("${params.decontamination_indexes_folder}");
            ref_genome = GET_REF_GENOME.out.db;
        }
    emit:
        ref_genome
}

workflow DOWNLOAD_MAPSEQ_SSU {
    main:
        // mapseq SSU
        pre_loaded = file("${params.databases}/${params.silva_ssu_db_name}");
        if ( pre_loaded.exists() ) {
            mapseq_db_ssu = pre_loaded;
        } else {
            GET_MAPSEQ_DB_SSU("${params.silva_ssu_db_name}");
            mapseq_db_ssu = GET_MAPSEQ_DB_SSU.out;
        }
    emit:
        mapseq_db_ssu
}

workflow DOWNLOAD_MAPSEQ_LSU {
    main:
        // mapseq LSU
        mapseq_db_lsu = file("${params.databases}/${params.silva_lsu_db_name}");
        if (mapseq_db_lsu.exists()) {
            mapseq_db_lsu = file("${params.databases}/${params.silva_lsu_db_name}");
        } else {
            GET_MAPSEQ_DB_LSU("${params.silva_lsu_db_name}");
            mapseq_db_lsu = GET_MAPSEQ_DB_LSU.out;
        }
    emit:
        mapseq_db_lsu
}

workflow DOWNLOAD_RFAM {
    main:
        // Rfam
        db_folder = file("${params.databases}/${params.cmsearch_db_name}");
        if ( db_folder.exists() ) {
            cmsearch_ribo_db = channel.fromPath("${params.databases}/${params.cmsearch_db_name}/${params.ribosomal_model_path}", checkIfExists: true);
            cmsearch_ribo_clan = channel.fromPath("${params.databases}/${params.cmsearch_db_name}/${params.ribosomal_claninfo_path}", checkIfExists: true);
            cmsearch_other_db = channel.fromPath("${params.databases}/${params.cmsearch_db_name}/${params.other_model_path}/*.cm", checkIfExists: true);
            cmsearch_other_clan = channel.fromPath("${params.databases}/${params.cmsearch_db_name}/${params.other_claninfo_path}", checkIfExists: true);
        } else {
            GET_CMSEARCH_DB("${params.cmsearch_db_name}");
            cmsearch_ribo_db = GET_CMSEARCH_DB.out.ribo_db;
            cmsearch_ribo_clan = GET_CMSEARCH_DB.out.ribo_clan;
            cmsearch_other_db = GET_CMSEARCH_DB.out.other_db.filter(~/.*.cm/);
            cmsearch_other_clan = GET_CMSEARCH_DB.out.other_clan;
        }
    emit:
        cmsearch_ribo_db
        cmsearch_ribo_clan
        cmsearch_other_db
        cmsearch_other_clan
}
