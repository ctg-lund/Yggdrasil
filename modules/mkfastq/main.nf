process MKFASTQ {
    input :
    path(samplesheet) 
    path(rawdata)

    output :
    path demuxdir

    script :
    """
    echo "Hippitiy hoppity your samplesheet is now a fastq"
    """
    stub:
    """
    echo "Hippitiy hoppity your samplesheet is now a fastq"
    mkdir demuxdir
    """

}