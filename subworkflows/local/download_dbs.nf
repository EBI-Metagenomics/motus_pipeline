/*
 * Download databases
 */

include { GET_REFERENCE_GENOME               } from '../../modules/local/download_dbs/reference_genome'
include { GET_RFAM_DB                        } from '../../modules/local/download_dbs/rfam_models'
include { GET_MAPSEQ_DB as GET_MAPSEQ_DB_LSU } from '../../modules/local/download_dbs/mapseq_db'
include { GET_MAPSEQ_DB as GET_MAPSEQ_DB_SSU } from '../../modules/local/download_dbs/mapseq_db'
include { MOTUS_DOWNLOADDB                   } from '../../modules/nf-core/motus/downloaddb'


workflow DOWNLOAD_DBS {
    main:
        
        // reference genome for decontamination
        ref_genome = file(params.reference_genome)
        
        // mOTUs db
        
        
    emit:
        reference_genome          = ref_genome
}