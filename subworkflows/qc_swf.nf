/*
 * Quality control, host-decontamination and overlap reads
 */

include { FASTP as FASTP_SINGLE } from '../modules/nf-core/fastp/main'
include { FASTP as FASTP_PAIRED } from '../modules/nf-core/fastp/main'
include { SEQPREP } from '../modules/seqprep'
include { SEQPREP_REPORT } from '../modules/seqprep'
include { QC_REPORT } from '../modules/create_qc_report'
include { DECONTAMINATION } from '../modules/local/decontamination'
include { DECONTAMINATION_REPORT } from '../modules/loca/decontamination'
include { SAMTOOLS_BAM2FQ } from '../modules/nf-core/samtools/bam2fq/main'
include { SEQTK as FASTQ_TO_FASTA} from '../modules/seqtk'
include { QC_STATS } from '../modules/qc_summary'

workflow QC {

    take:
        input
        ref_genome
        ref_genome_index
    main:
        ch_versions           = Channel.empty()
        
        input.branch {
            single: it[1].collect().size() == 1
            paired: it[1].collect().size() == 2
            }.set {
                ch_input_for_fastp
        }
    
        // We don't provide the adapter sequences, which is the second parameter for fastp
    
        FASTP_SINGLE ( ch_input_for_fastp.single, [], false, false )
    
        // Last parameter here turns on merging of PE data
        FASTP_PAIRED ( ch_input_for_fastp.paired, [], false, params.merge_pairs )
    
        if ( params.merge_pairs ) {
            ch_fastp_paired = FASTP_PAIRED.out.reads_merged
        } else {
            ch_fastp_paired = FASTP_PAIRED.out.reads
        }

        ch_processed_reads = ch_fastp_paired.mix(
            FASTP_SINGLE.out.reads
        )
        ch_versions = ch_versions.mix(FASTP_SINGLE.out.versions.first())
        ch_versions = ch_versions.mix(FASTP_PAIRED.out.versions.first())

        DECONTAMINATION(ch_processed_reads.map { meta, reads -> 
                [ meta, reads, ref_genome, ref_genome_index ]
            }, 
            false
        )
        ch_versions = ch_versions.mix( DECONTAMINATION.out.versions )
        
        SAMTOOLS_BAM2FQ( DECONTAMINATION.out.bam.map { meta, ref_fasta, bam, bai -> [ meta, bam ] }, true )
        ch_versions = ch_versions.mix(SAMTOOLS_BAM2FQ.out.versions.first())
        
}
