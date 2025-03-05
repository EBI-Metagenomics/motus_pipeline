#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { MOTUS_PIPELINE } from './workflow/motus_pipeline.nf'

workflow {
    MOTUS_PIPELINE ()
}
