process FINDCHEMISTRY {
    tag "${sample}"
    label 'process_single'

    container 'cdcgov/mira-oxide:1.5.7'

    input:
    tuple val(sample), path(fastq)
    val read_counts
    val irma_config
    val custom_irma_config

    output:
    path "${sample}_chemistry.csv", emit: sample_chem_csv
    path 'versions.yml', emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // If ad irma module is selected, set experiment to FLU-AD, otherwise use the experiment parameter
    def args = task.ext.args ?: ''
    def experiment = irma_config == 'ad' ? 'FLU-AD' : params.e

    """
    mira-oxide find-chemistry --sample "${sample}" --fastq "${fastq}" --experiment "${experiment}" --wd-path "${projectDir}" --read-count "${read_counts}" --irma-config "${irma_config}" --irma-config-path "${custom_irma_config}"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}": findchemistry: mira-oxide \$(mira-oxide --version |& sed '1!d ; s/mira-oxide //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''

    """

    cat <<-END_VERSIONS > versions.yml
    "${task.process}": findchemistry: mira-oxide \$(mira-oxide --version |& sed '1!d ; s/mira-oxide //')
    END_VERSIONS
    """
}