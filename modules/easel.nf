/*
 * easel
*/

process EASEL_EXTRACT_BY_COORD {
    publishDir "${params.outdir}/cmsearch/", mode: 'copy'

    container 'quay.io/biocontainers/easel:0.48--hec16e2b_1'

    //memory '5 GB'
    //cpus 4

    input:
        path sequences
        path deoverlapped_coords
    output:
        path "${sequences.baseName}_${deoverlapped_coords.baseName}.fasta", emit: models_fasta

    script:
    """
    awk '{print \$1"-"\$3"/q"\$8"-"\$9" "\$8" "\$9" "\$1}' ${deoverlapped_coords} > ${sequences.baseName}.matched_seqs_with_coords

    esl-sfetch --index ${sequences}

    esl-sfetch -Cf ${sequences} ${sequences.baseName}.matched_seqs_with_coords > ${sequences.baseName}_${deoverlapped_coords.baseName}.fasta

    """
}

