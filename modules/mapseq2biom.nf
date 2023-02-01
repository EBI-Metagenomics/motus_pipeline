/*
 * mapseq2biom perl script converter v1.0.0
*/

process MAPSEQ2BIOM {
    publishDir "${params.output}/taxonomy-summary/", mode: 'copy', pattern: "$mapseq.baseName.*"

    container 'quay.io/microbiome-informatics/mapseq2biom:1.0.0'

    cpus 1

    input:
        path mapseq
        path otu_ref
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
          --otuTable $otu_ref
    """
}