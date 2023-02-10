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

motus_db = channel.fromPath(params.motus_db, checkIfExists: true)

covariance_model_database_ribo = channel.fromPath(params.covariance_model_database_ribo, checkIfExists: true)
covariance_model_database_other = channel.fromPath(params.covariance_model_database_other, checkIfExists: true)
clan_information = channel.fromPath(params.clan_information, checkIfExists: true)
sequences = channel.fromPath(params.sequences, checkIfExists: true)

lsu_db = channel.fromPath(params.lsu_db, checkIfExists: true)
lsu_tax = channel.fromPath(params.lsu_tax, checkIfExists: true)
lsu_otu = channel.fromPath(params.lsu_otu, checkIfExists: true)
lsu_label = channel.value(params.lsu_label)

ssu_db = channel.fromPath(params.ssu_db, checkIfExists: true)
ssu_tax = channel.fromPath(params.ssu_tax, checkIfExists: true)
ssu_otu = channel.fromPath(params.ssu_otu, checkIfExists: true)
ssu_label = channel.value(params.ssu_label)

/*
    ~~~~~~~~~~~~~~~~~~
     Steps
    ~~~~~~~~~~~~~~~~~~
*/
include { QC } from '../subworkflows/qc'
include { MAPSEQ_OTU_KRONA as MAPSEQ_OTU_KRONA_LSU} from '../subworkflows/mapseq-otu-krona'
include { MAPSEQ_OTU_KRONA as MAPSEQ_OTU_KRONA_SSU} from '../subworkflows/mapseq-otu-krona'
include { CMSEARCH_SUBWF } from '../subworkflows/cmsearch-subwf'
include { MOTUS } from '../modules/mOTUs'
/*
    ~~~~~~~~~~~~~~~~~~
     Run workflow
    ~~~~~~~~~~~~~~~~~~
*/
/*
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

    MOTUS(QC.out.merged_reads, motus_db)
    // covariance_model_database = covariance_model_database_ribo.concat(covariance_model_database_other)
    // CMSEARCH_SUBWF(sequences, covariance_model_database, clan_information)
    //LSU
    // MAPSEQ_OTU_KRONA(CMSEARCH_SUBWF.out.lsu_fasta, lsu_db, lsu_tax, lsu_otu, lsu_label)
    //SSU
    // MAPSEQ_OTU_KRONA(CMSEARCH_SUBWF.out.ssu_fasta, ssu_db, ssu_tax, ssu_otu, ssu_label)
}
*/


workflow PIPELINE {

    covariance_model_database = covariance_model_database_ribo.concat(covariance_model_database_other)
    CMSEARCH_SUBWF(sequences, covariance_model_database, clan_information)
    MAPSEQ_OTU_KRONA_LSU(CMSEARCH_SUBWF.out.cmsearch_lsu_fasta.first(), lsu_db, lsu_tax, lsu_otu, lsu_label)
    MAPSEQ_OTU_KRONA_SSU(CMSEARCH_SUBWF.out.cmsearch_ssu_fasta.first(), ssu_db, ssu_tax, ssu_otu, ssu_label)
}
