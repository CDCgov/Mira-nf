process ANNOTATEMINORVARIANTS {
    label 'process_low'

    container 'cdcgov/mira-oxide:v1.6.0'

    input:
    path dais_outputs
    path minor_variants_csv
    val runid

    output:
    path "*_annotated_minor_variants.csv", emit: annotated_minor_variants
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """

    mira-oxide variants \\
        --query-dais-file DAIS_ribosome.seq \\
        --query-insertion-file DAIS_ribosome.ins \\
        --query-deletion-file DAIS_ribosome.del \\
        --minor-variants ${minor_variants_csv} \\
        --annotate-minor-variants \\
        --output-xsv mira_${runid}_annotated_minor_variants.csv \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}": annotateminorvariants: mira-oxide \$(mira-oxide --version |& sed '1!d ; s/mira-oxide //')
    END_VERSIONS
    """

    stub:
    """
    touch mira_${runid}_annotated_minor_variants.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}": annotateminorvariants: mira-oxide \$(mira-oxide --version |& sed '1!d ; s/mira-oxide //')
    END_VERSIONS
    """
}
