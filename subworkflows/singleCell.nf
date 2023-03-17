include { MKFASTQ } from '../modules/mkfastq/main'

workflow singleCell {
    mkfastq_ch = MKFASTQ(
        params.samplesheet,
        params.runfolder
    )
}