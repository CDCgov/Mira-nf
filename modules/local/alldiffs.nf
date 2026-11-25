process ALLDIFFS {
    label 'process_medium'
    label 'mira_oxide'

    input:
    path query_dais
    path ref_dais
    path query_ins
    path query_del
    path ref_ins
    path ref_del
    path variants_of_interest
    path minor_variants
    val  runid

    output:
    path "mira_${runid}_all_diffs.csv", emit: all_diffs
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    mira-oxide variants \\
        --query-dais-file ${query_dais} \\
        --ref-dais-file ${ref_dais} \\
        --output-xsv mira_${runid}_all_diffs.csv \\
        --query-insertion-file ${query_ins} \\
        --query-deletion-file ${query_del} \\
        --ref-insertion-file ${ref_ins} \\
        --ref-deletion-file ${ref_del} \\
        --variants-of-interest ${variants_of_interest} \\
        --minor-variants ${minor_variants} \\
        --all-diffs

    cat <<-END_VERSIONS > versions.yml
    "${task.process}": variantsofint: mira-oxide \$(mira-oxide --version |& sed '1!d ; s/mira-oxide //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''

    """
    cat <<-END_VERSIONS > versions.yml
    "${task.process}": variantsofint: mira-oxide \$(mira-oxide --version |& sed '1!d ; s/mira-oxide //')
    END_VERSIONS
    """
}
