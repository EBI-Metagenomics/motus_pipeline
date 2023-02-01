/*
 * mOTUs 3.0.3
 * tool that estimates relative taxonomic abundance of known
 * and currently unknown microbial community members
 * using metagenomic shotgun sequencing data.
*/

process MOTUS {

    container 'quay.io/biocontainers/motus:3.0.3--pyhdfd78af_0'
    containerOptions '--volume $motus_db:/db'

    cpus 2

    input:
        path reads
    output:
        path 'taxonomy.motus' into motus_result

    script:
    """
    motus -db /db -s $reads -t {task.cpus} -o taxonomy.motus
    """
}