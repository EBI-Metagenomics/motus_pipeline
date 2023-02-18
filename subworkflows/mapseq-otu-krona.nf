/*
 * Classify with mapseq, convert mapseq2biom, generate krona plots
 */

include { MAPSEQ } from '../modules/mapseq'
include { MAPSEQ2BIOM } from '../modules/mapseq2biom'
include { KRONA } from '../modules/krona'

workflow MAPSEQ_OTU_KRONA {
    take:
        sequence
        mapseq_db
        mapseq_taxonomy
        otu_ref
        otu_label
    main:

        MAPSEQ(sequence, mapseq_db, mapseq_taxonomy)

        MAPSEQ2BIOM(
            MAPSEQ.out.mapseq_result,
            otu_ref,
            otu_label
        )

        KRONA(
            MAPSEQ2BIOM.out.mapseq2biom_txt
        )
}
