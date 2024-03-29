/*
    ~~~~~~~~~~~~~~~~~~
     Input validation
    ~~~~~~~~~~~~~~~~~~
*/
sample_name = channel.value(params.sample_name)
mode = channel.value(params.mode)

if ( params.reads_accession ) {
    // The "mode" is also required but not needed to pull the reads //
    chosen_reads = channel.empty()
} else {
    if ( params.mode == "paired" ) {
        chosen_reads = channel.fromFilePairs(["${params.paired_end_forward}", "${params.paired_end_reverse}"], checkIfExists: true).map { it[1] }
    }
    else if ( params.mode == "single" ) {
        chosen_reads = channel.fromPath("${params.single_end}", checkIfExists: true)
    }
}

if ( params.reads_accession && (params.paired_end_forward || params.paired_end_reverse || params.single_end) ) {
    exit 1, "If --reads_accession is provided, paired_end_forward, paired_end_reverse and single_end are invalid."
}

/*
    ~~~~~~~~~~~~~~~~~~
     Steps
    ~~~~~~~~~~~~~~~~~~
*/
include { QC } from '../subworkflows/qc_swf'
include { MAPSEQ_OTU_KRONA as MAPSEQ_OTU_KRONA_LSU} from '../subworkflows/mapseq_otu_krona_swf'
include { MAPSEQ_OTU_KRONA as MAPSEQ_OTU_KRONA_SSU} from '../subworkflows/mapseq_otu_krona_swf'
include { CMSEARCH_SUBWF } from '../subworkflows/cmsearch_swf'
include { FETCHTOOL } from '../modules/fetchtool'
include { MOTUS } from '../modules/motus'
include { MULTIQC } from '../modules/multiqc'

/*
    ~~~~~~~~~~~~~~~~~~
     DBs
    ~~~~~~~~~~~~~~~~~~
*/
include { DOWNLOAD_MOTUS_DB } from '../subworkflows/prepare_dbs'
include { DOWNLOAD_REFERENCE_GENOME } from '../subworkflows/prepare_dbs'
include { DOWNLOAD_RFAM } from '../subworkflows/prepare_dbs'
include { DOWNLOAD_MAPSEQ_SSU } from '../subworkflows/prepare_dbs'
include { DOWNLOAD_MAPSEQ_LSU } from '../subworkflows/prepare_dbs'
/*
    ~~~~~~~~~~~~~~~~~~
     Run workflow
    ~~~~~~~~~~~~~~~~~~
*/
workflow PIPELINE {

    if ( params.reads_accession ) {
        // Sorting this is required to guarantee the order for
        // pair end reads
        FETCHTOOL(params.reads_accession)
        chosen_reads = FETCHTOOL.out.reads
    }

    if ( params.reference_genome && params.reference_genome_name ) {
        ref_genome = channel.fromPath("${params.reference_genome}")
        ref_genome_name = channel.value("${params.reference_genome_name}")
    } else {
        DOWNLOAD_REFERENCE_GENOME()
        ref_genome = DOWNLOAD_REFERENCE_GENOME.out.ref_genome
        ref_genome_name = channel.value("${params.decontamination_reference_index}")
    }

    QC(
        sample_name,
        chosen_reads,
        mode,
        ref_genome,
        ref_genome_name
    )

    // mOTUs
    if (params.motus_db) {
        motus_db = channel.fromPath("${params.motus_db}")
    }
    else {
        DOWNLOAD_MOTUS_DB()
        motus_db = DOWNLOAD_MOTUS_DB.out.motus_db
    }

    MOTUS(QC.out.merged_reads, motus_db)

    // CMSEARCH prepare DBs
    if (params.rfam_ribo_models && params.rfam_other_models && params.rfam_ribo_clan && params.rfam_other_clan) {
        covariance_model_database_ribo = channel.fromPath("${params.rfam_ribo_models}")
        covariance_model_database_other = channel.fromPath("${params.rfam_other_models}")
        covariance_clan_ribo = channel.fromPath("${params.rfam_ribo_clan}")
        covariance_clan_other = channel.fromPath("${params.rfam_other_clan}")
    }
    else {
        DOWNLOAD_RFAM()
        covariance_model_database_ribo = DOWNLOAD_RFAM.out.cmsearch_ribo_db
        covariance_model_database_other = DOWNLOAD_RFAM.out.cmsearch_other_db_cat
        covariance_clan_ribo = DOWNLOAD_RFAM.out.cmsearch_ribo_clan
        covariance_clan_other = DOWNLOAD_RFAM.out.cmsearch_other_clan
    }
    covariance_cat_models = covariance_model_database_ribo.concat(covariance_model_database_other) \
        .collectFile(name: "models.cm", newLine: true)

    clan_info = covariance_clan_ribo.concat(covariance_clan_other) \
        .collectFile(name: "clan.info")

    // CMSEARCH
    CMSEARCH_SUBWF(
        sample_name,
        QC.out.sequence,
        covariance_cat_models,
        clan_info
    )

    // MAPSEQ LSU
    if (CMSEARCH_SUBWF.out.cmsearch_lsu_fasta) {
        if (params.lsu_db) {
            mapseq_lsu = channel.fromPath("${params.lsu_db}")
        }
        else {
            DOWNLOAD_MAPSEQ_LSU()
            mapseq_lsu = DOWNLOAD_MAPSEQ_LSU.out.mapseq_db_lsu
        }
        MAPSEQ_OTU_KRONA_LSU(
            CMSEARCH_SUBWF.out.cmsearch_lsu_fasta,
            mapseq_lsu,
            channel.value(params.lsu_db_otu),
            channel.value(params.lsu_db_fasta),
            channel.value(params.lsu_db_tax),
            channel.value(params.lsu_label)
        )
    }
    // MAPSEQ SSU
    if (CMSEARCH_SUBWF.out.cmsearch_ssu_fasta) {
        if (params.ssu_db) {
            mapseq_ssu = channel.fromPath("${params.ssu_db}")
        }
        else {
            DOWNLOAD_MAPSEQ_SSU()
            mapseq_ssu = DOWNLOAD_MAPSEQ_SSU.out.mapseq_db_ssu
        }
        MAPSEQ_OTU_KRONA_SSU(
            CMSEARCH_SUBWF.out.cmsearch_ssu_fasta,
            mapseq_ssu,
            channel.value(params.ssu_db_otu),
            channel.value(params.ssu_db_fasta),
            channel.value(params.ssu_db_tax),
            channel.value(params.ssu_label)
        )
    }

    MULTIQC(
        QC.out.fastp_json,
        MOTUS.out.motus_log
    )
}
