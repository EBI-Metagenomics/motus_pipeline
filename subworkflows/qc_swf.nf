/*
 * Quality control, host-decontamination and overlap reads
 */

include { FASTP } from '../modules/fastp'
include { SEQPREP } from '../modules/seqprep'
include { SEQPREP_REPORT } from '../modules/seqprep'
include { QC_REPORT } from '../modules/create_qc_report'
include { DECONTAMINATION } from '../modules/decontamination'
include { DECONTAMINATION_REPORT } from '../modules/decontamination'
include { SEQTK as FASTQ_TO_FASTA} from '../modules/seqtk'
include { QC_STATS } from '../modules/qc_summary'

workflow QC {

    take:
        name
        mode
        reads
        mode
        ref_genome
        ref_genome_name
    main:
        // We sort the reads by name.. to ensure
        // pair end reads land in the correct position
        // _1 -> forward first
        // _2 -> reverse second
        reads_list = reads.collect(sort: {
            it.name
        })

        FASTP(
            name,
            reads_list,
            mode,
            channel.value("")
        )

        DECONTAMINATION(
            FASTP.out.output_reads,
            ref_genome,
            ref_genome_name,
            mode,
            name
        )
        DECONTAMINATION_REPORT(
            mode,
            DECONTAMINATION.out.decontaminated_reads
        )

        if ( $mode == "paired" ) {
            SEQPREP(
                name,
                DECONTAMINATION.out.decontaminated_reads
            )
            SEQPREP_REPORT(
                SEQPREP.out.forward_unmapped_reads,
                SEQPREP.out.reverse_unmerged_reads,
                SEQPREP.out.overlapped_reads
            )
            overlapped_reads = SEQPREP.out.overlapped_reads
            overlapped_counts = SEQPREP_REPORT.out.overlapped_report
        } else {
            overlapped_reads = DECONTAMINATION.out.decontaminated_reads
            overlapped_counts = channel.fromPath("NO_FILE")
        }

        QC_REPORT(
            mode,
            FASTP.out.json,
            DECONTAMINATION_REPORT.out.decontamination_report,
            overlapped_counts,
        )

        FASTQ_TO_FASTA(name, overlapped_reads)

        QC_STATS(FASTQ_TO_FASTA.out.sequence)

    emit:
        merged_reads = overlapped_reads
        sequence = FASTQ_TO_FASTA.out.sequence
        qc_report = QC_REPORT.out.qc_report
        qc_stats = QC_STATS.out.qc_statistics
        fastp_json = FASTP.out.json
}
