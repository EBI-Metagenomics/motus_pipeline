/*
    ~~~~~~~~~~~~~~~~~~
     Input validation
    ~~~~~~~~~~~~~~~~~~
*/
name = channel.value("test")
sequence = channel.fromPath('tests/modules/fixtures/mapseq/test.SSU.fasta')
mode = channel.value("paired")
chosen_reads = channel.fromPath("tests/modules/fixtures/fastp/paired_end/example*.fastq*", checkIfExists: true)

min_length = channel.value(params.min_length)
polya_trim = channel.value(params.polya_trim)
qualified_quality_phred = channel.value(params.qualified_quality_phred)
unqualified_percent_limit = channel.value(params.unqualified_percent_limit)

/*
    ~~~~~~~~~~~~~~~~~~
     Steps
    ~~~~~~~~~~~~~~~~~~
*/
include { QC } from '../subworkflows/qc_swf'
include { DECONTAMINATION } from '../modules/decontamination'
/*
    ~~~~~~~~~~~~~~~~~~
     DBs
    ~~~~~~~~~~~~~~~~~~
*/
include { DOWNLOAD_REFERENCE_GENOME } from '../subworkflows/prepare_db'

/*
    ~~~~~~~~~~~~~~~~~~
     Run workflow
    ~~~~~~~~~~~~~~~~~~
*/

workflow PIPELINE {
    if (params.reference_genome) {
        ref_genome = channel.fromPath("${params.reference_genome}")
    }
    else {
        DOWNLOAD_REFERENCE_GENOME()
        ref_genome = DOWNLOAD_REFERENCE_GENOME.out.ref_genome
    }

    DECONTAMINATION(
        chosen_reads,
        ref_genome,
        mode,
        name
    )
}
