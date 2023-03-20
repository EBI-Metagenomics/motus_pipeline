/*
    ~~~~~~~~~~~~~~~~~~
     Input validation
    ~~~~~~~~~~~~~~~~~~
*/
name = channel.value("test")
sequence = channel.fromPath('tests/modules/fixtures/mapseq/test.SSU.fasta')

/*
    ~~~~~~~~~~~~~~~~~~
     Steps
    ~~~~~~~~~~~~~~~~~~
*/
include { CMSEARCH_SUBWF } from '../subworkflows/cmsearch_swf'
/*
    ~~~~~~~~~~~~~~~~~~
     DBs
    ~~~~~~~~~~~~~~~~~~
*/
include { PREPARE_DBS } from '../subworkflows/prepare_db'

/*
    ~~~~~~~~~~~~~~~~~~
     Run workflow
    ~~~~~~~~~~~~~~~~~~
*/

workflow PIPELINE {
    PREPARE_DBS()
    covariance_model_database_ribo = PREPARE_DBS.out.cmsearch_ribo_db
    covariance_model_database_other = PREPARE_DBS.out.cmsearch_other_db
    covariance_model_database = covariance_model_database_ribo.concat(covariance_model_database_other)

    covariance_clan_ribo = PREPARE_DBS.out.cmsearch_ribo_clan
    covariance_clan_other = PREPARE_DBS.out.cmsearch_other_clan
    clan = covariance_clan_ribo.concat(covariance_clan_other)
    clan_information = clan.collectFile(name: "clan.info")

    CMSEARCH_SUBWF(
        name,
        sequence,
        covariance_model_database,
        clan_information
    )
}
