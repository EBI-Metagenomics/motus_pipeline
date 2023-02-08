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
        length_filter
        polya_trim_param
        qualified_quality_phred
        unqualified_percent_limit
        reference_genome
        reference_genome_name

    main:
        raw_reads_list = reads.collect()

        FASTP_FILTERING(
            name,
            raw_reads_list,
            "",
            length_filter,
            polya_trim_param,
            qualified_quality_phred,
            unqualified_percent_limit)

        DECONTAMINATION(
            FASTP_FILTERING.out.output_reads,
            reference_genome,
            reference_genome_name)

        FASTP_OVERLAP(
            name,
            DECONTAMINATION.out.decontaminated_reads,
            "merged.fastq.gz", "", "", "", "")

        FASTP_REPORT(FASTP_FILTERING.out.json, FASTP_OVERLAP.out.json)

        FASTQ_TO_FASTA(FASTP_OVERLAP.out.overlapped_reads)

        QC_STATS(FASTQ_TO_FASTA.out.sequence)

    emit:
        merged_reads = FASTP_OVERLAP.out.overlapped_reads
        sequence = FASTQ_TO_FASTA.out.sequence
        // filtering report
        // qc summary
}

