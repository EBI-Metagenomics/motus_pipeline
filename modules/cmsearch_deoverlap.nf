/*
 * cmsearch deoverlap Perl script
*/

process CMSEARCH_DEOVERLAP {
    publishDir "${params.outdir}/cmsearch/", mode: 'copy'

    container 'debian:stable-slim'

    memory '200 MB'
    cpus 2

    input:
        path clan_information
        path cmsearch_matches
    output:
        path "${cmsearch_matches}.deoverlapped", emit: cmsearch_deoverlap

    script:
    """
    cmsearch-deoverlap.pl --clanin ${clan_information} ${cmsearch_matches}
    """
}

