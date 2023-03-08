/*
 * Krona 2.7.1
*/

process KRONA {
    publishDir "${params.outdir}/taxonomy-summary/${otu_label}", mode: 'copy', pattern: "*krona.html"

    container 'quay.io/microbiome-informatics/krona:2.7.1'

    memory '200 MB'
    cpus 2

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

