process BCL_DELIVERY {
    input:
    path(raw)

    output:
    path("*zip"), emit: bcl_zip
    path("*md5"), emit: bcl_md5

    shell:
    """
    #module load parallel/20220722
    #raw=$1
    #parallel -j8 "md5sum {} >> ${raw}/md5.txt" ::: $(find ${raw}/Data -type f -print)
    #forgot that I also need to do this
    #sed -i s'/\/projects\/.*\/upload\/\w\+/./g' ${raw}/md5.txt
    """ 
    stub:
    """
    touch bcl_delivery.zip
    touch bcl_delivery.md5
    """
}