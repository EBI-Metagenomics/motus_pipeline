/*
    ~~~~~~~~~~~~~~~~~~
     Input validation
    ~~~~~~~~~~~~~~~~~~
*/
name = channel.value(params.name)

paired_reads = channel.empty()
single_end_reads = file("EMPTY")

// TODO: I haven't tested this /
if ( params.mode == "paired" ) {
    paired_reads = channel.fromFilePairs('/my/data/SRR*_{1,2}.fastq', checkIfExists: true).map { it[1] }
} else if ( params.mode == "single" ) {
    single_end_reads = channel.fromPath("${params.reads}/${params.name}*.fastq.gz", checkIfExists: true)
}


mode = channel.value(params.mode)

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
include { QC } from '../subworkflows/qc_swf'
include { MAPSEQ_OTU_KRONA as MAPSEQ_OTU_KRONA_LSU} from '../subworkflows/mapseq_otu_krona_swf'
include { MAPSEQ_OTU_KRONA as MAPSEQ_OTU_KRONA_SSU} from '../subworkflows/mapseq_otu_krona_swf'
include { CMSEARCH_SUBWF } from '../subworkflows/cmsearch_swf'

include { MOTUS } from '../modules/motus'

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
        mode,
        min_length,
        polya_trim,
        qualified_quality_phred,
        unqualified_percent_limit,
        reference_genome,
        reference_genome_name)

    MOTUS(QC.out.merged_reads, motus_db)

    covariance_model_database = covariance_model_database_ribo.concat(covariance_model_database_other)
    CMSEARCH_SUBWF(name, QC.out.sequence, covariance_model_database, clan_information)

    if (CMSEARCH_SUBWF.out.cmsearch_lsu_fasta) {
        MAPSEQ_OTU_KRONA_LSU(CMSEARCH_SUBWF.out.cmsearch_lsu_fasta, lsu_db, lsu_tax, lsu_otu, lsu_label)
    }
    if (CMSEARCH_SUBWF.out.cmsearch_ssu_fasta) {
        MAPSEQ_OTU_KRONA_SSU(CMSEARCH_SUBWF.out.cmsearch_ssu_fasta, ssu_db, ssu_tax, ssu_otu, ssu_label)
    }
}
*/


workflow PIPELINE {

    QC(
        name,
        raw_reads,
        mode,
        min_length,
        polya_trim,
        qualified_quality_phred,
        unqualified_percent_limit,
        reference_genome,
        reference_genome_name
    )
}

