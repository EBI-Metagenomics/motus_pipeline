/*
 * mOTUs 3.0.3
 * tool that estimates relative taxonomic abundance of known
 * and currently unknown microbial community members
 * using metagenomic shotgun sequencing data.
*/

process MOTUS {
    publishDir "${params.output}/mOTUs/", mode: 'copy'

    container 'quay.io/biocontainers/motus:3.0.3--pyhdfd78af_0'
    containerOptions '--bind db_mOTU:/db_mOTU'

    cpus 2

    input:
        path reads
        path motus_db
    output:
        path "${reads.baseName}.motus", emit: motus_result
        path "*.tsv", emit: motus_result_cleaned

    script:
    """
    motus profile -c -q \
          -db /db_mOTU \
          -s $reads \
          -t ${task.cpus} \
          -o ${reads.baseName}.motus

    bash clean_motus_output.sh ${reads.baseName}.motus

    """
}