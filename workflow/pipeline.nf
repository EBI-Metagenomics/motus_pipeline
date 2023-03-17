/*
    ~~~~~~~~~~~~~~~~~~
     Input validation
    ~~~~~~~~~~~~~~~~~~
*/
name = channel.value(params.name)
reads = channel.fromPath(params.reads)
mode = channel.value(params.mode)

if ( params.mode == "paired" ) {
    chosen_reads = channel.fromFilePairs("${params.reads}/${params.name}*_{1,2}.fastq*", checkIfExists: true).map { it[1] }
} else if ( params.mode == "single" ) {
    chosen_reads = channel.fromPath("${params.reads}/${params.name}*.fastq*", checkIfExists: true)
}

// fastp filtering
min_length = channel.value(params.min_length)
polya_trim = channel.value(params.polya_trim)
qualified_quality_phred = channel.value(params.qualified_quality_phred)
unqualified_percent_limit = channel.value(params.unqualified_percent_limit)

motus_db = channel.fromPath(params.motus_db, checkIfExists: true)

covariance_model_database_ribo = channel.fromPath(params.covariance_model_database_ribo, checkIfExists: true)
covariance_model_database_other = channel.fromPath(params.covariance_model_database_other, checkIfExists: true)
clan_information = channel.fromPath(params.clan_information, checkIfExists: true)

// mapseq
lsu_otu = channel.fromPath(params.lsu_db_otu, checkIfExists: true)
lsu_label = channel.value(params.lsu_label)
ssu_otu = channel.fromPath(params.ssu_db_otu, checkIfExists: true)
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
     DBs
    ~~~~~~~~~~~~~~~~~~
*/
include { PREPARE_DBS } from '../subworkflows/prepare_db'

/*
    ~~~~~~~~~~~~~~~~~~
     Run workflow
    ~~~~~~~~~~~~~~~~~~
*/
workflow PIPELINE {
    PREPARE_DBS()

    QC(
        name,
        chosen_reads,
        mode,
        min_length,
        polya_trim,
        qualified_quality_phred,
        unqualified_percent_limit,
    )
    
    MOTUS(name, QC.out.merged_reads, motus_db)
    
    covariance_model_database = covariance_model_database_ribo.concat(covariance_model_database_other)
    
    CMSEARCH_SUBWF(
        name,
        QC.out.sequence,
        covariance_model_database,
        clan_information
    )
    
    if (CMSEARCH_SUBWF.out.cmsearch_lsu_fasta) {
        MAPSEQ_OTU_KRONA_LSU(
            CMSEARCH_SUBWF.out.cmsearch_lsu_fasta,
            PREPARE_DBS.out.mapseq_db_lsu,
            lsu_otu,
            lsu_label
        )
    }
    
    if (CMSEARCH_SUBWF.out.cmsearch_ssu_fasta) {
        MAPSEQ_OTU_KRONA_SSU(
            CMSEARCH_SUBWF.out.cmsearch_ssu_fasta,
            PREPARE_DBS.out.mapseq_db_ssu,
            ssu_otu,
            ssu_label
        )
    }
}
