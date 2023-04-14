// Manual input for running

samplesheet = params.samplesheet
runfolder = params.runfolder

include { MKFASTQ } from '../modules/mkfastq/main'

workflow SINGLE_CELL {
    mkfastq_ch = MKFASTQ(
        samplesheet,
        runfolder
    )
}