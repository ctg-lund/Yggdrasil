process BCL_DELIVERY {
    input:
    path(raw)

    output:
    path(raw), emit: raw
    path("*md5"), emit: bcl_md5

    shell:
    """
    module load parallel/20220722
    parallel -j8 "md5sum {} >> ${raw}/md5.txt" ::: \$(find ${raw}/Data -type f -print)
    sed -i s'/\/projects\/.*\/upload\/\w\+/./g' ${raw}/md5.txt
    
    """ 
    stub:
    """
    touch bcl_delivery.zip
    touch bcl_delivery.md5
    """
}
