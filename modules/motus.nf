/*
 * mOTUs 3.0.3
 * tool that estimates relative taxonomic abundance of known
 * and currently unknown microbial community members
 * using metagenomic shotgun sequencing data.
*/

process MOTUS {
    
    publishDir "${params.outdir}/mOTUs/", mode: 'copy'
    
    label 'motus'

    container 'quay.io/biocontainers/motus:3.0.3--pyhdfd78af_0'

    memory '1 GB'
    cpus 4

    input:
    val name
    path reads
    path motus_db

    output:
    path "${name}.motus", emit: motus_result
    path "*.tsv", emit: motus_result_cleaned

    script:
    """
    gunzip ${reads}
    echo 'Run mOTUs'
    motus profile -c -q \
    -db /db_mOTU \
    -s ${reads.baseName} \
    -t ${task.cpus} \
    -o ${reads.baseName}.motus

    echo 'clean files'
    echo -e '#mOTU\tconsensus_taxonomy\tcount' > ${reads.baseName}.tsv
    grep -v "0\$" ${reads.baseName}.motus | grep -E '^meta_mOTU|^ref_mOTU' | sort -t\$'\t' -k3,3n >> ${reads.baseName}.tsv
    tail -n1 ${reads.baseName}.motus | sed s'/-1/Unmapped/g' >> ${reads.baseName}.tsv

    LINES=\$(cat ${reads.baseName}.tsv | wc -l)
    echo 'number of lines is' \$LINES
    if [ \$LINES -eq 2 ]; then
      echo 'rename file to empty'
      mv ${name}.tsv 'empty.motus.tsv'
    fi
    """
}

/*
 * Download MGnify Rfam DB
*/
process GET_MOTUS_DB {
    publishDir "${params.databases}/", mode: 'copy'
    container 'quay.io/biocontainers/motus:3.0.3--pyhdfd78af_0'
    label 'motus_db'

    input:
        val db_name
    output:
        path "*", emit: motus_db

    script:
    """
    motus downloadDB
    """
}
