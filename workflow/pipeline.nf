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

// mapseq
lsu_otu = channel.value(params.lsu_db_otu)
lsu_label = channel.value(params.lsu_label)
ssu_otu = channel.value(params.ssu_db_otu)
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
include { DOWNLOAD_REFERENCE_GENOME } from '../subworkflows/prepare_db'

/*
    ~~~~~~~~~~~~~~~~~~
     Run workflow
    ~~~~~~~~~~~~~~~~~~
*/
workflow PIPELINE {
    PREPARE_DBS()
    covariance_model_database_ribo = PREPARE_DBS.out.cmsearch_ribo_db
    covariance_model_database_other = PREPARE_DBS.out.cmsearch_other_db
    covariance_model_database = covariance_model_database_ribo.concat(covariance_model_database_other)

    covariance_clan_ribo = PREPARE_DBS.out.cmsearch_ribo_clan
    covariance_clan_other = PREPARE_DBS.out.cmsearch_other_clan
    clan = covariance_clan_ribo.concat(covariance_clan_other)
    clan_information = clan.collectFile(name: "clan.info")

    if (params.reference_genome) {
        ref_genome = channel.fromPath("${params.reference_genome}")
    }
    else {
        DOWNLOAD_REFERENCE_GENOME()
        ref_genome = DOWNLOAD_REFERENCE_GENOME.out.ref_genome
    }
    QC(
        name,
        chosen_reads,
        mode,
        ref_genome,
        min_length,
        polya_trim,
        qualified_quality_phred,
        unqualified_percent_limit,
    )
    
    MOTUS(name, QC.out.merged_reads, motus_db)

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
