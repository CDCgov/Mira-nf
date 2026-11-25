process POSITIONSOFINT {
    label 'process_low'
    label 'mira_oxide'

    input:
    path query_dais
    path ref_dais
    path query_ins
    path query_del
    path ref_ins
    path ref_del
    path variants_of_interest
    val  runid
    path minor_variants      // may be [] / empty

    output:
    path "*_positions_of_interest.csv", emit: position_of_int
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def minor_variants_arg = minor_variants ? "--minor-variants ${minor_variants}" : ''

    """
    mira-oxide variants \\
        --positions-of-interest \\
        --query-dais-file ${query_dais} \\
        --ref-dais-file ${ref_dais} \\
        --output-xsv mira_${runid}_positions_of_interest.csv \\
        --query-insertion-file ${query_ins} \\
        --query-deletion-file ${query_del} \\
        --ref-insertion-file ${ref_ins} \\
        --ref-deletion-file ${ref_del} \\
        --variants-of-interest ${variants_of_interest} \\
        ${minor_variants_arg} \\
        --all-positions

    cat <<-END_VERSIONS > versions.yml
    "${task.process}": positionsofint: mira-oxide \$(mira-oxide --version |& sed '1!d ; s/mira-oxide //')
    END_VERSIONS
    """
    // stub block unchanged
}