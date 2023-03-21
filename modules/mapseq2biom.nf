/*
 * mapseq2biom python script converter v1.0.0
*/

process MAPSEQ2BIOM {

    publishDir(
        path: "${params.outdir}/taxonomy-summary/${otu_label}",
        pattern: "$mapseq.baseName.*",
        mode: 'copy'
    )

    container 'quay.io/biocontainers/python:3.9--1'

    label 'mapseq2biom'

    input:
        path mapseq
        path mapseq_db
        val otu_ref
        val otu_label
    output:
        path "${mapseq.baseName}.tsv", emit: mapseq2biom_tsv
        path "${mapseq.baseName}.txt", emit: mapseq2biom_txt
        path "${mapseq.baseName}.notaxid.tsv", emit: mapseq2biom_notaxid

    script:
    """
    mapseq2biom.py \
        --out-file ${mapseq.baseName}.tsv \
        --krona ${mapseq.baseName}.txt \
        --no-tax-id-file ${mapseq.baseName}.notaxid.tsv \
        --taxid \
        --label $otu_label \
        --query $mapseq \
        --otu-table $otu_ref
    """
}
