process NEXTFLOWSAMPLESHEET {
    label 'process_single'
    label 'mira_oxide'

    input:
    path samplesheet
    val fastq_files
    val experiment_type

    output:
    path 'nextflow_samplesheet.csv', emit: nf_samplesheet
    path ('bad_samples.tsv', emit: bad_samples, optional: true)
    path 'versions.yml', emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    // create-nextflow-samplesheet only needs the delay when jobs are submitted
    // through a cluster scheduler. Local-executor runs can skip it.
    def sleep_arg = ['sge', 'slurm'].contains(task.executor) ? '' : '--skip-sleep'

    """
    if [[ "${experiment_type}" == *"Illumina"* ]]; then
        mira-oxide create-nextflow-samplesheet -s "${samplesheet}" -r "${fastq_files}" -e "${experiment_type}" ${sleep_arg}
    elif [[ "${experiment_type}" == *"ONT"* ]]; then
        mira-oxide create-nextflow-samplesheet -s "${samplesheet}" -r "${params.outdir}" -e "${experiment_type}" ${sleep_arg}
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}": nextflowsamplesheet: mira-oxide \$(mira-oxide --version |& sed '1!d; s/mira-oxide //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''

    """
    cat <<-END_VERSIONS > versions.yml
    "${task.process}": nextflowsamplesheet: mira-oxide \$(mira-oxide --version |& sed '1!d; s/mira-oxide //')
    END_VERSIONS
    """
}
