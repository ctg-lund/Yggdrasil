// Enable DSL2 functionality
nextflow.enable.dsl = 2

// params
params.proj_root = "$HOME/TEST"

workflow {
    // specified at command line
    ch_in = Channel.fromPath(params.raw)
    TEST(ch_in) | TEST2
}

process TEST {
    publishDir "${params.proj_root}/", mode: 'move'

    input:
    path(dir)

    output:
    path('done.txt')

    script:
    """
    echo {1..10}'\n' > done.txt
    """
}

process TEST2 {
    publishDir "${params.proj_root}/", mode: 'move'

    input:
    path("done.txt")

    output:
    path('*.txt')

    script:
    """
   while read line; do
       touch \${line}.txt
    done < done.txt
        
    """
}