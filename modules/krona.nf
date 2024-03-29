/*
 * Krona 2.7.1
*/

process KRONA {

    label 'krona'

    publishDir(
        "${params.outdir}/taxonomy/${otu_label}",
        mode: 'copy',
        pattern: "*krona.html"
    )

    container 'quay.io/biocontainers/krona:2.7.1--pl5321hdfd78af_7'

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
