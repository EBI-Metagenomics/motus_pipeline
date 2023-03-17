/*
    ~~~~~~~~~~~~~~~~~~
     Input validation
    ~~~~~~~~~~~~~~~~~~
*/
lsu_otu = channel.value(params.lsu_db_otu)
lsu_label = channel.value(params.lsu_label)
ssu_otu = channel.value(params.ssu_db_otu)
ssu_label = channel.value(params.ssu_label)

sequence = channel.fromPath('tests/modules/fixtures/test.SSU.fasta')
mapseq_table = channel.fromPath('tests/modules/fixtures/mapseq/output/test.SSU_silva-SSU.mseq')
/*
    ~~~~~~~~~~~~~~~~~~
     Steps
    ~~~~~~~~~~~~~~~~~~
*/

/*
    ~~~~~~~~~~~~~~~~~~
     DBs
    ~~~~~~~~~~~~~~~~~~
*/
include { PREPARE_DBS } from '../subworkflows/prepare_db'
include { MAPSEQ_OTU_KRONA as MAPSEQ_OTU_KRONA_SSU} from '../subworkflows/mapseq_otu_krona_swf'

/*
    ~~~~~~~~~~~~~~~~~~
     Run workflow
    ~~~~~~~~~~~~~~~~~~
*/

workflow PIPELINE {
    PREPARE_DBS()
    MAPSEQ_OTU_KRONA_SSU(
            mapseq_table,
            PREPARE_DBS.out.mapseq_db_ssu,
            ssu_otu,
            ssu_label
        )
}
