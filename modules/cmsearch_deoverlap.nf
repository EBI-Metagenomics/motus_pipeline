/*
 * cmsearch deoverlap Perl script
*/

process CMSEARCH_DEOVERLAP {
    label 'cmsearch_deoverlap'
    container 'debian:stable-slim'

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

