/*
 * Quality control, host-decontamination and overlap reads
 */

include { FASTP as FASTP_FILTERING } from '../modules/fastp'
include { FASTP as FASTP_OVERLAP } from '../modules/fastp'
include { FASTP_REPORT } from '../modules/create_report_fastp'
include { DECONTAMINATION } from '../modules/decontamination'
include { SEQTK as FASTQ_TO_FASTA} from '../modules/seqtk'
include { QC_STATS } from '../modules/qc_summary'

workflow QC {

    take:
        name
        reads
        mode
        length_filter
        polya_trim_param
        qualified_quality_phred
        unqualified_percent_limit
    main:
        reads_list = reads.collect()

        FASTP_FILTERING(
            name,
            reads_list,
            mode,
            channel.value(""),
            length_filter,
            polya_trim_param,
            qualified_quality_phred,
            unqualified_percent_limit
        )
        
        overlapped_report = FASTP_FILTERING.out.json

        DECONTAMINATION(
            FASTP_FILTERING.out.output_reads,
            mode,
            name
        )

        if ( params.mode == "paired" ) {
            FASTP_OVERLAP(
                name,
                DECONTAMINATION.out.decontaminated_reads,
                mode,
                channel.value("merged.fastq.gz"),
                channel.value(""),
                channel.value(""),
                channel.value(""),
                channel.value("")
            )
            overlapped_reads = FASTP_OVERLAP.out.overlapped_reads
            overlapped_report = overlapped_report.concat(FASTP_OVERLAP.out.json)
        } else {
            overlapped_reads = DECONTAMINATION.out.decontaminated_reads
        }

        FASTP_REPORT(overlapped_report.collect(), mode)

        FASTQ_TO_FASTA(name, overlapped_reads)

        QC_STATS(FASTQ_TO_FASTA.out.sequence)

    emit:
        merged_reads = overlapped_reads
        sequence = FASTQ_TO_FASTA.out.sequence
        fastp_report = FASTP_REPORT.out.qc_report
        qc_stats = QC_STATS.out.qc_statistics
}

