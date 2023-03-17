/*
 * mapseq2biom perl script converter v1.0.0
*/

process MAPSEQ2BIOM {
    publishDir "${params.outdir}/taxonomy-summary/${otu_label}", mode: 'copy', pattern: "$mapseq.baseName.*"
    label 'mapseq2biom'
    container 'perl:5.32-slim'

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
        mapseq2biom.pl \
          --outfile ${mapseq.baseName}.tsv \
          --krona ${mapseq.baseName}.txt \
          --notaxidfile ${mapseq.baseName}.notaxid.tsv \
          --taxid \
          --label $otu_label \
          --query $mapseq \
          --otuTable ${mapseq_db}/${otu_ref}
    """
}