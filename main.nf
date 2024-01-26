#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PIPELINE } from './workflow/motus_pipeline.nf'

workflow {
    PIPELINE ()
}
