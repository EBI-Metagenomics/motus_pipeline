/*
 * Cmsearch and deoverlap-cmsearch
 */

include { CMSEARCH } from '../modules/cmsearch'
include { CMSEARCH_DEOVERLAP } from '../modules/cmsearch_deoverlap'
include { EASEL } from '../modules/easel'

workflow CMSEARCH_SUBWF {
    take:
        sequences
        covariance_model_database
        clan_information
    main:
        // chunk sequences

        // cat models
        covariance_cat_models = covariance_model_database.collectFile(name: "models.cm", newLine: true)

        CMSEARCH(sequences, covariance_cat_models.first())

        CMSEARCH_DEOVERLAP(clan_information, CMSEARCH.out.cmsearch)

        // cat cmsearch
        cmsearch_result = CMSEARCH.out.cmsearch.collect()

        // cat deoverlapped
        cmsearch_result_deoverlapped = CMSEARCH_DEOVERLAP.out.cmsearch_deoverlap.collect()

        EASEL(sequences, cmsearch_result_deoverlapped)
}

