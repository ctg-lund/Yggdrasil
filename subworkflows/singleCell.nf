// Manual input for running

samplesheet = params.samplesheet
runfolder = params.runfolder

include { MKFASTQ } from '../modules/mkfastq/main'
include { INTEROP } from '../modules/interop/main'
include { FASTQC } from '../modules/fastqc/main'
include { MULTIQC } from '../modules/multiqc/main'
include { PUBLISH_PROJECT } from '../modules/publish_project/main'


workflow singleCell {
    interop_ch = INTEROP(
        runfolder
    )
    mkfastq_ch = MKFASTQ(
        samplesheet,
        runfolder
    )

    fastqc_ch = FASTQC(
        mkfastq_ch
    )

    multiqc_ch = MULTIQC(
        fastqc_ch,
        project_name_ch
    )
    
    

}