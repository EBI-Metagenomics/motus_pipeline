/*
    ~~~~~~~~~~~~~~~~~~
     Input validation
    ~~~~~~~~~~~~~~~~~~
*/
name = channel.value(params.name)
raw_reads = channel.fromPath("${params.reads}/${params.name}*.fastq.gz", checkIfExists: true)

min_length = channel.value(params.min_length)
polya_trim = channel.value(params.polya_trim)
qualified_quality_phred = channel.value(params.qualified_quality_phred)
unqualified_percent_limit = channel.value(params.unqualified_percent_limit)
reference_genome = channel.fromPath(params.reference_genome, checkIfExists: true)
reference_genome_name = channel.value(params.reference_genome_name)
/*
    ~~~~~~~~~~~~~~~~~~
     Steps
    ~~~~~~~~~~~~~~~~~~
*/
include { QC } from '../subworkflows/qc'
include { MAPSEQ_OTU_KRONA } from '../subworkflows/mapseq-otu-krona'
include { CMSEARCH_SUBWF } from '../subworkflows/cmsearch-subwf'

/*
    ~~~~~~~~~~~~~~~~~~
     Run workflow
    ~~~~~~~~~~~~~~~~~~
*/

workflow PIPELINE {

    QC(
        name,
        raw_reads,
        min_length,
        polya_trim,
        qualified_quality_phred,
        unqualified_percent_limit,
        reference_genome,
        reference_genome_name)

    // FASTQ_TO_FASTA(QC.out.merged_reads)

    // MOTUS

    // CMSEARCH_SUBWF(sequences, covariance_model_database, clan_information)
    //LSU
    // MAPSEQ_OTU_KRONA(sequence, mapseq_db, mapseq_taxonomy, otu_ref, otu_label)
    //SSU
    // MAPSEQ_OTU_KRONA(sequence, mapseq_db, mapseq_taxonomy, otu_ref, otu_label)
}