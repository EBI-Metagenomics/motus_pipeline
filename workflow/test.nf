/*
    ~~~~~~~~~~~~~~~~~~
     Input validation
    ~~~~~~~~~~~~~~~~~~
*/
name = channel.value(params.name)
sequence = channel.fromPath("${params.sequence}", checkIfExists: true)
/*
    ~~~~~~~~~~~~~~~~~~
     Steps
    ~~~~~~~~~~~~~~~~~~
*/
include { QC } from '../subworkflows/qc_swf'
include { MAPSEQ_OTU_KRONA as MAPSEQ_OTU_KRONA_LSU} from '../subworkflows/mapseq_otu_krona_swf'
include { MAPSEQ_OTU_KRONA as MAPSEQ_OTU_KRONA_SSU} from '../subworkflows/mapseq_otu_krona_swf'
include { CMSEARCH_SUBWF } from '../subworkflows/cmsearch_swf'
include { MOTUS_SUBWF } from '../subworkflows/motus_swf'
/*
    ~~~~~~~~~~~~~~~~~~
     DBs
    ~~~~~~~~~~~~~~~~~~
*/
include { DOWNLOAD_REFERENCE_GENOME } from '../subworkflows/prepare_dbs'
include { DOWNLOAD_RFAM } from '../subworkflows/prepare_dbs'
include { DOWNLOAD_MAPSEQ_SSU } from '../subworkflows/prepare_dbs'
include { DOWNLOAD_MAPSEQ_LSU } from '../subworkflows/prepare_dbs'
/*
    ~~~~~~~~~~~~~~~~~~
     Run workflow
    ~~~~~~~~~~~~~~~~~~
*/
workflow PIPELINE {

    // RNA prediction
    if (params.rfam_ribo_models && params.rfam_other_models && params.rfam_ribo_clan && params.rfam_other_clan)
    {
        covariance_model_database_ribo = channel.fromPath("${params.rfam_ribo_models}")
        covariance_model_database_other = channel.fromPath("${params.rfam_other_models}")
        covariance_clan_ribo = channel.fromPath("${params.rfam_ribo_clan}")
        covariance_clan_other = channel.fromPath("${params.rfam_other_clan}")
    }
    else {
        DOWNLOAD_RFAM()
        covariance_model_database_ribo = DOWNLOAD_RFAM.out.cmsearch_ribo_db
        covariance_model_database_other = DOWNLOAD_RFAM.out.cmsearch_other_db
        covariance_clan_ribo = DOWNLOAD_RFAM.out.cmsearch_ribo_clan
        covariance_clan_other = DOWNLOAD_RFAM.out.cmsearch_other_clan
    }
    covariance_model_database = covariance_model_database_ribo.concat(covariance_model_database_other)
    clan_info_channel = covariance_clan_ribo.concat(covariance_clan_other)
    clan_info = clan_info_channel.collectFile(name: "clan.info")

    CMSEARCH_SUBWF(
        name,
        sequence,
        covariance_model_database,
        clan_info
    )
}
