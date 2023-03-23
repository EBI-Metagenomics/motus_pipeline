# mOTUs pipeline

Raw reads mOTUs and taxonomic classification pipeline

![plot](schema.png)

## What do I need?

This implementation of the pipeline runs with the workflow manager [Nextflow](https://www.nextflow.io/) and needs as second dependency either [Docker](https://docs.docker.com/v17.09/engine/installation/linux/docker-ce/ubuntu/#install-docker-ce) or [Singularity](https://sylabs.io/guides/3.0/user-guide/quick_start.html). 
All databases are automatically downloaded by Nextflow. 

## How to run?

Add your own profile to nextflow.config file including all inputs 

**basic run**
```commandline
nextflow run main.nf \
-profile <choose profile> \
--mode <single/paired> \
--reads <path to folder with fastq files> \
--name <fastq filename>
```

**example: local SE run** \
assume reads location: my_reads/raw/test.fastq.gz
```commandline
nextflow run main.nf \
-profile local \
--mode single \
--reads my_reads/raw \
--name test
```

**example: local PE run** \
assume reads location: my_reads/raw/test_1.fastq.gz, my_reads/raw/test_2.fastq.gz
```commandline
nextflow run main.nf \
-profile local \
--mode paired \
--reads my_reads/raw \
--name test
```