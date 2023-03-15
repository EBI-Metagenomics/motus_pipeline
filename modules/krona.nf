/*
 * Krona 2.7.1
*/

process KRONA {
    publishDir "${params.outdir}/taxonomy-summary/${otu_label}", mode: 'copy', pattern: "*krona.html"

    container 'quay.io/microbiome-informatics/krona:2.7.1'
    label 'krona'

    input:
        val otu_label
        path otu_counts
    output:
        path "*krona.html", emit: krona_html

    script:
    """
    ktImportText -o krona.html $otu_counts
    """
}

