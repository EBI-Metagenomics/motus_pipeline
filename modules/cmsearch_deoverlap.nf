/*
 * cmsearch deoverlap Perl script
*/

process CMSEARCH_DEOVERLAP {

    label 'cmsearch_deoverlap'

    container 'quay.io/biocontainers/perl:5.22.2.1'

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
