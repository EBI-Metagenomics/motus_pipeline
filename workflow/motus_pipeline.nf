/*
    ~~~~~~~~~~~~~~~~~~
     Input validation
    ~~~~~~~~~~~~~~~~~~
*/
include { validateParameters; paramsHelp; paramsSummaryLog; fromSamplesheet; paramsSummaryMap } from 'plugin/nf-validation'

def summary_params = paramsSummaryMap(workflow)

// Print help message, supply typical command line usage for the pipeline
if (params.help) {
   log.info paramsHelp("nextflow run my_pipeline --input input_file.csv")
   exit 0
}

validateParameters()

log.info paramsSummaryLog(workflow)

if (params.help) {
   log.info paramsHelp("nextflow run ebi-metagenomics/motus-pipeline --help")
   exit 0
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
    groupReads = { meta, fq1, fq2 ->
        if (fq2 == []) {
            return tuple(meta, 'single', [fq1])
        }
        else {
            return tuple(meta, 'paired', [fq1, fq2])
        }
    }
    input_data = Channel.fromSamplesheet("samplesheet", header: true, sep: ',').map(groupReads)
    sample_name = input_data.map{meta, mode, reads -> meta.id}
    chosen_reads = input_data.map{meta, mode, reads -> [meta, reads]}
    mode = input_data.map{meta, mode, reads -> mode}
    // TODO add tool from nf-modules
    // ------- fetch data --------
    if ( params.fetch_data ) {
        // Sorting this is required to guarantee the order for
        // pair end reads
        FETCHTOOL(sample_name)
        chosen_reads = FETCHTOOL.out.reads
    }
    
    // ------- QC -----------------
    if ( params.reference_genome ) {
        ref_genome         = file(params.reference_genome)
        ref_genome_index   = file("${ref_genome.parent}/*.fa.*")
    } else {
        DOWNLOAD_REFERENCE_GENOME()
        ref_genome = DOWNLOAD_REFERENCE_GENOME.out.ref_genome
        ref_genome_index   = file("${ref_genome.parent}/*.fa.*")
    }
    
    QC(
        chosen_reads,
        ref_genome,
        ref_genome_index
    ) 
}
