/*
 * Cmsearch and deoverlap-cmsearch
 */

include { CMSEARCH } from '../modules/cmsearch'
include { CMSEARCH_DEOVERLAP } from '../modules/cmsearch_deoverlap'
include { EASEL_EXTRACT_BY_COORD } from '../modules/easel'
include { EXTRACT_MODELS } from '../modules/extract_coords'

/* FIXME: rename this - the current name doesn't reflect the modue functionatily */
process RETURN_FILES {

    publishDir(
        "${params.outdir}/cmsearch/",
        mode: 'copy'
    )

    container 'quay.io/biocontainers/infernal:1.1.4--pl5321hec16e2b_1'

    stageInMode 'copy'

    input:
    val name
    file cmsearch
    file deoverlap

    output:
    file "${name}_matched_seqs_with_coords.tbl"
    file "${name}_matched_seqs_with_coords_deoverlap.tbl"

    script:
    """
    head -n 1 ${cmsearch} > "${name}_matched_seqs_with_coords.tbl"
    grep -v '^#' ${cmsearch} | grep . >> "${name}_matched_seqs_with_coords.tbl"

    head -n 1 ${cmsearch} > "${name}_matched_seqs_with_coords_deoverlap.tbl"
    cat ${deoverlap} >> "${name}_matched_seqs_with_coords_deoverlap.tbl"
    """
}

workflow CMSEARCH_SUBWF {
    take:
        name
        sequences
        covariance_model_database
        clan_information
    main:
        // chunk sequences
        sequence_chunks_ch = sequences.splitFasta(
            by: 100000,
            file: true
        )
        // cat models

        CMSEARCH(sequence_chunks_ch, covariance_model_database.first())

        CMSEARCH_DEOVERLAP(clan_information.first(), CMSEARCH.out.cmsearch)

        // cat cmsearch
        cmsearch_result = CMSEARCH.out.cmsearch.collectFile(name: "cmsearch.tbl", newLine: true)

        // cat deoverlapped
        cmsearch_result_deoverlapped = CMSEARCH_DEOVERLAP.out.cmsearch_deoverlap.collectFile(name: "deoverlapped.tbl")

        EASEL_EXTRACT_BY_COORD(sequences, cmsearch_result_deoverlapped)

        EXTRACT_MODELS(name, EASEL_EXTRACT_BY_COORD.out.models_fasta)

        RETURN_FILES(name, cmsearch_result, cmsearch_result_deoverlapped)
    emit:
        cmsearch_lsu_fasta = EXTRACT_MODELS.out.lsu_fasta
        cmsearch_ssu_fasta = EXTRACT_MODELS.out.ssu_fasta
        seq_cat = EXTRACT_MODELS.out.seq_cat_folder
}
