# Taxonomic profiling pipeline

Raw reads mOTUs and taxonomic classification pipeline.

## Pipeline summary

The containerised pipeline for profiling shotgun metagenomic data is derived from the [MGnify](https://www.ebi.ac.uk/metagenomics/) pipeline raw-reads analyses, a well-established resource used for analyzing microbiome data.

Key components:
- Quality control and decontamination
- rRNA and ncRNA detection using [Rfam database](https://rfam.org/)
- Taxonomic classification of SSU and LSU regions based on [SILVA database](https://www.arb-silva.de/projects/ssu-ref-nr/)
- Abundance analysis of [mOTUs](https://github.com/motu-tool/mOTUs) (Metagenomic Operational Taxonomic Units)


<p align="center">
    <img src="docs/images/pipeline_schema.png" alt="Taxonomic profiling pipeline overview" width="90%">
</p>

The pipeline is implemented in [Nextflow](https://www.nextflow.io/) and needs as second dependency either [Docker](https://docs.docker.com/v17.09/engine/installation/linux/docker-ce/ubuntu/#install-docker-ce) or [Singularity](https://sylabs.io/guides/3.0/user-guide/quick_start.html).
All databases are automatically downloaded by Nextflow.

## Quick Start

1. Install [Nextflow](https://www.nextflow.io/)

2. Install any of [Docker](https://docs.docker.com/v17.09/engine/installation/linux/docker-ce/ubuntu/#install-docker-ce) or  [Singularity](https://sylabs.io/guides/3.0/user-guide/quick_start.html).

3. Download the pipeline and test it on a minimal dataset.

### Run examples

Add your own profile to nextflow.config file including all inputs

#### Basic run

```bash
nextflow run EBI-Metagenomics/motus_pipeline \
-profile <choose profile> \
--mode <single/paired> \
--single_end  / --paired_end_forward --paired_end_reverse <path with fastq file/s>\
--sample_name <accession/name>
```

#### Using the fetch tool to download the reads

```bash
nextflow run EBI-Metagenomics/motus_pipeline \
-profile local \
--mode single \
--sample_name test
--runs_accession ERR4387386
```

#### Local Single End run

```bash
nextflow run EBI-Metagenomics/motus_pipeline \
-profile local \
--mode single \
--single_end my_reads/raw/test.fastq.gz \
--sample_name test
```

#### Local Paired Ends run
```bash
nextflow run EBI-Metagenomics/motus_pipeline \
-profile local \
--mode paired \
--paired_end_forward my_reads/raw/test_1.fastq.gz \
--paired_end_reverse my_reads/raw/test_2.fastq.gz \
--sample_name test
```

## Development

Install development tools (including pre-commit hooks to run Black code formatting).

```bash
pip install -r requirements-dev.txt
pre-commit install
```

### Code style

Use Black, this tool is configured if you install the pre-commit tools as above.

To manually run them: black .

## Testing

The pipeline unit test are executed using [nf-test](https://github.com/askimed/nf-test).

To run the nextflow unit tests the databases have to downloaded manually, we are working to improve this.

```bash
nf-test test tests/*
```
