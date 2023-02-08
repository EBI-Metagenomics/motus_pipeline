/*
 * easel
*/

process EASEL {
    publishDir "${params.output}/cmsearch/", mode: 'copy'

    container 'quay.io/biocontainers/easel:0.48--hec16e2b_1'

    cpus 1

    input:
        path sequences
        path deoverlapped_coords
    output:
        path "${sequences.baseName}_${deoverlapped_coords.baseName}.fasta", emit: models_fasta
        path "sequence-categorisation/*SSU.fasta*", emit: ssu_fasta
        path "sequence-categorisation/*LSU.fasta*", emit: lsu_fasta

    script:
    """
    extract_coords.sh -i ${deoverlapped_coords} -n ${sequences.baseName}

    esl-sfetch --index ${sequences}

    esl-sfetch -Cf ${sequences} ${sequences.baseName}.matched_seqs_with_coords > ${sequences.baseName}_${deoverlapped_coords.baseName}.fasta

    get_subunits.py -i ${sequences.baseName}_${deoverlapped_coords.baseName}.fasta
    """
}

