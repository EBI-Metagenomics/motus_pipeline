include { validateParameters; paramsHelp; paramsSummaryLog; fromSamplesheet; paramsSummaryMap } from 'plugin/nf-validation'

def summary_params = paramsSummaryMap(workflow)

// Print help message, supply typical command line usage for the pipeline
if (params.help) {
   log.info paramsHelp("nextflow run main.nf --samplesheet input.csv")
   exit 0
}

validateParameters()

log.info paramsSummaryLog(workflow)

if (params.help) {
   log.info paramsHelp("nextflow run ebi-metagenomics/motus_pipeline --help")
   exit 0
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

ch_multiqc_config                     = Channel.fromPath("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
ch_multiqc_custom_config              = params.multiqc_config ? Channel.fromPath( params.multiqc_config, checkIfExists: true ) : Channel.empty()
ch_multiqc_logo                       = params.multiqc_logo   ? Channel.fromPath( params.multiqc_logo, checkIfExists: true ) : Channel.fromPath("$projectDir/assets/mgnify_logo.png")
ch_multiqc_custom_methods_description = params.multiqc_methods_description ? file(params.multiqc_methods_description, checkIfExists: true) : file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    MODULES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { BWAMEM2DECONTNOBAMS } from '../modules/ebi-metagenomics/bwamem2decontnobams'
include { MOTUS_PROFILE       } from '../modules/nf-core/motus/profile'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     Subworkflows
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { DOWNLOAD_DBS                                  } from '../subworkflows/local/download_dbs'
include { READS_QC                                      } from '../subworkflows/ebi-metagenomics/reads_qc'
include { RRNA_EXTRACTION as RRNA_EXTRACTION            } from '../subworkflows/ebi-metagenomics/rrna_extraction/main'
include { RRNA_EXTRACTION as OTHER_RNA_EXTRACTION       } from '../subworkflows/ebi-metagenomics/rrna_extraction/main'
include { MAPSEQ_OTU_KRONA as MAPSEQ_OTU_KRONA_SSU      } from '../subworkflows/ebi-metagenomics/mapseq_otu_krona/main'
include { MAPSEQ_OTU_KRONA as MAPSEQ_OTU_KRONA_LSU      } from '../subworkflows/ebi-metagenomics/mapseq_otu_krona/main'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     Run workflow
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
workflow MOTUS_PIPELINE {
    // ---- combine data for reads ---- //
    groupReads = { meta, fq1, fq2 ->
        if (fq2 == []) {
            return tuple(meta + [single_end: true], [fq1])
        }
        else {
            return tuple(meta + [single_end: false], [fq1, fq2])
        }
    }
    input_reads = Channel.fromSamplesheet("samplesheet", header: true, sep: ',').map(groupReads)   // [ meta, [raw_reads] ]

    // Check DBs and download not existing
    DOWNLOAD_DBS()
    
    // Decontaminate reads
    BWAMEM2DECONTNOBAMS(input_reads, DOWNLOAD_DBS.out.reference_genome)

}