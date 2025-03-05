/*
 * Download databases
 */

include { GET_REFERENCE_GENOME               } from '../../modules/local/download_dbs/reference_genome'
include { GET_RFAM_DB                        } from '../../modules/local/download_dbs/rfam_models'
include { GET_MAPSEQ_DB as GET_MAPSEQ_DB_LSU } from '../../modules/local/download_dbs/mapseq_db'
include { GET_MAPSEQ_DB as GET_MAPSEQ_DB_SSU } from '../../modules/local/download_dbs/mapseq_db'
include { MOTUS_DOWNLOADDB                   } from '../../modules/nf-core/downloaddb'


workflow DOWNLOAD_DBS {
    main:
        
        // reference genome for decontamination
        ref_genome_folder = channel.fromPath("${params.databases}/${params.decontamination_indexes_folder}");
        if !(ref_genome_folder.exists()) {
            GET_REFERENCE_GENOME("${params.decontamination_indexes_folder}");
            ref_genome_folder = GET_REF_GENOME.out.reference_genome_folder;
        }
        
        // mOTUs db
        motus_db_folder = channel.fromPath("${params.motus_db_path}");
        if !(motus_db_folder.exists()) {
            MOTUS_DOWNLOADDB();
            motus_db_folder = MOTUS_DOWNLOAD_DB.db;
            
        // RFAM
        cmsearch_ribo_db    = channel.fromPath("${params.ribosomal_model_file}");
        cmsearch_ribo_clan  = channel.fromPath("${params.ribosomal_claninfo_file}");
        cmsearch_other_db   = channel.fromPath("${params.other_model_file}")
        cmsearch_other_clan = channel.fromPath("${params.other_claninfo_file}");
        if !(cmsearch_ribo_db.exists() AND cmsearch_ribo_clan.exists() AND cmsearch_other_db.exists() AND cmsearch_other_clan.exists()) {
            GET_RFAM_DB("${params.cmsearch_db_name}");
            cmsearch_ribo_db = GET_CMSEARCH_DB.out.ribo_db;
            cmsearch_ribo_clan = GET_CMSEARCH_DB.out.ribo_clan;
            cmsearch_other_db = GET_CMSEARCH_DB.out.other_db;
            cmsearch_other_clan = GET_CMSEARCH_DB.out.other_clan;
        }
        
        // LSU
        lsu_db = channel.fromPath("${params.lsu_db}");
        if !(lsu_db.exists()) {
            GET_MAPSEQ_DB_LSU(${params.silva_lsu_db_name})
            lsu_db = GET_MAPSEQ_DB_LSU.out.db
        }
        // SSU
        ssu_db = channel.fromPath("${params.ssu_db}");
        if !(ssu_db.exists()) {
            GET_MAPSEQ_DB_SSU(${params.silva_ssu_db_name})
            ssu_db = GET_MAPSEQ_DB_SSU.out.db
        }
        
    emit:
        ref_genome          = ref_genome_folder
        motus_db_folder     = motus_db_folder
        cmsearch_ribo_db    = cmsearch_ribo_db
        cmsearch_ribo_clan  = cmsearch_ribo_clan
        cmsearch_other_db   = cmsearch_other_db
        cmsearch_other_clan = cmsearch_other_clan
        lsu_db              = lsu_db
        ssu_db              = ssu_db 
}