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
    // singularity
    containerOptions '--bind db_mOTU:/db_mOTU'
    // docker mac
    //containerOptions '-v ${params.motus_db}:/db_mOTU --platform linux/amd64'

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
          -o ${name}.motus
    echo 'clean files'
    echo -e '#mOTU\tconsensus_taxonomy\tcount' > ${name}.tsv
    echo 'Generate presence TSV'
    grep -v "0\$" ${name}.motus | egrep '^meta_mOTU|^ref_mOTU'  | sort -t\$'\t' -k3,3n >> ${name}.tsv
    tail -n1 ${name}.motus | sed s'/-1/Unmapped/g' >> ${name}.tsv
    echo 'Check empty file'
    export y=\$(cat ${name}.tsv | wc -l)
    echo 'number of lines is' \$y
    if [ \$y -eq 2 ]; then
      echo 'rename file to empty'
      mv ${name}.tsv 'empty.motus.tsv'
    fi
    """
}