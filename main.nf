#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PIPELINE } from './workflow/pipeline.nf'

workflow {
    PIPELINE ()
}
