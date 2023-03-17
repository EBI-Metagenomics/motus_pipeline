/*
    ~~~~~~~~~~~~~~~~~~
     Input validation
    ~~~~~~~~~~~~~~~~~~
*/
ssu_label = channel.value(params.ssu_label)
lsu_label = channel.value(params.lsu_label)
sequence = channel.fromPath('tests/modules/fixtures/test.SSU.fasta')
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
include { MAPSEQ } from '../modules/mapseq'

/*
    ~~~~~~~~~~~~~~~~~~
     Run workflow
    ~~~~~~~~~~~~~~~~~~
*/

workflow PIPELINE {
    PREPARE_DBS()

    MAPSEQ(sequence, PREPARE_DBS.out.mapseq_db_ssu, ssu_label)
}
