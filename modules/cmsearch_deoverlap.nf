/*
 * cmsearch deoverlap Perl script
*/

process CMSEARCH_DEOVERLAP {
    publishDir "${params.output}/cmsearch/", mode: 'copy'

    container 'quay.io/microbiome-informatics/cmsearch_deoverlap:1.0.0'

    cpus 1

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

