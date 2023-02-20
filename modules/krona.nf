/*
 * Krona 2.7.1
*/

process KRONA {
    publishDir "${params.outdir}/taxonomy-summary/", mode: 'copy', pattern: "*krona.html"

    container 'quay.io/microbiome-informatics/krona:2.7.1'

    memory '200 MB'
    cpus 2

    input:
        path otu_counts
    output:
        file("*krona.html")

    script:
    """
    ktImportText -o krona.html $otu_counts
    """
}

