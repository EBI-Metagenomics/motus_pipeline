/*
    ~~~~~~~~~~~~~~~~~~
     Input validation
    ~~~~~~~~~~~~~~~~~~
*/
sequence = channel.fromPath(params.mapseq_seq, checkIfExists: true)
mapseq_db = channel.fromPath(params.mapseq_db, checkIfExists: true)
mapseq_taxonomy = channel.fromPath(params.mapseq_taxonomy, checkIfExists: true)
otu_ref = channel.fromPath(params.otu_ref, checkIfExists: true)
otu_label = channel.value(params.otu_label)

/*
    ~~~~~~~~~~~~~~~~~~
     Steps
    ~~~~~~~~~~~~~~~~~~
*/
include { MAPSEQ_OTU_KRONA } from '../subworkflows/mapseq-otu-krona'

/*
    ~~~~~~~~~~~~~~~~~~
     Run workflow
    ~~~~~~~~~~~~~~~~~~
*/

workflow {
    MAPSEQ_OTU_KRONA(sequence, mapseq_db, mapseq_taxonomy, otu_ref, otu_label)
}