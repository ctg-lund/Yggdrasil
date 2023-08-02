process BCL_DELIVERY {
    input:
    path(raw)

    output:
    path(raw), emit: raw
    path("*md5"), emit: bcl_md5

    shell:
    """
    # spawn subshell to cd without changing wdir
    # I do this because I want to avoid parsing md5 output
    # this is to preserve bash functionality if this is pasted to a script
    (
    cd ${raw}
    module load parallel/20220722
    parallel -j8 "md5sum {} >> ${raw}/md5.txt" ::: \$(find ${raw}/Data -type f -print)
    )
        
    """ 
    stub:
    """
    touch md5.txt
    """
}
