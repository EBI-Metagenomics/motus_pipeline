/*
 * mOTUs 3.0.3
 * tool that estimates relative taxonomic abundance of known
 * and currently unknown microbial community members
 * using metagenomic shotgun sequencing data.
*/

process MOTUS {
    publishDir "${params.outdir}/mOTUs/", mode: 'copy'

    container 'quay.io/biocontainers/motus:3.0.3--pyhdfd78af_0'
    containerOptions '--bind db_mOTU:/db_mOTU'

    memory '1 GB'
    cpus 4

    input:
    path reads
    path motus_db

    output:
    path "${reads.baseName}.motus", emit: motus_result
    path "*.tsv", emit: motus_result_cleaned

    script:
    """
    gunzip $reads
    motus profile -c -q \
          -db /db_mOTU \
          -s ${reads.baseName} \
          -t ${task.cpus} \
          -o ${reads.baseName}.motus
    echo 'clean files'
    echo -e '#mOTU\tconsensus_taxonomy\tcount' > ${reads.baseName}.tsv
    grep -v "0\$" ${reads.baseName}.motus | egrep '^meta_mOTU|^ref_mOTU'  | sort -t\$'\t' -k3,3n >> ${reads.baseName}.tsv
    tail -n1 ${reads.baseName}.motus | sed s'/-1/Unmapped/g' >> ${reads.baseName}.tsv
    export y=\$(cat ${reads.baseName}.tsv | wc -l)
    echo 'number of lines is' \$y
    if [ \$y -eq 2 ]; then
      echo 'rename file to empty'
      mv ${reads.baseName}.tsv 'empty.motus.tsv'
    fi
    """
}