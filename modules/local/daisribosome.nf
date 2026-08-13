process DAISRIBOSOME {
    label 'process_medium'

    container 'cdcgov/dais-ribosome:v2.1.0'
    // The container binding for this step has been moved to the modules if needed

    input:
    path input_fasta
    val dais_module

    output:
    path('*.{seq,ins,del,gen_seq,gen_ins,gen_del}') , emit: dais_outputs
    path('*.seq') , emit: dais_seq_output
    path 'versions.yml' , emit: versions

    shell:
    '''
    base_name=$(basename !{input_fasta})
    dais_out="${base_name%_input*}"
    ribosome --module !{dais_module} !{input_fasta} ${dais_out}.seq ${dais_out}.ins ${dais_out}.del ${dais_out}.gen_seq ${dais_out}.gen_ins ${dais_out}.gen_del

    echo "!{task.process}: daisribosome: cdcgov/dais-ribosome:v2.1.0" > versions.yml
    '''
}
