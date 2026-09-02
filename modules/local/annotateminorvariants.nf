process ANNOTATEMINORVARIANTS {
    label 'process_low'

    container 'cdcgov/mira-oxide:v1.6.'

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
    # Concatenate the per-sample DAIS-ribosome outputs so the annotator can look up
    # codon/amino-acid context for every sample in the aggregated minor variants table.
    # The gene-level indel files (.gen.ins/.gen.del) use a different schema and are excluded.
    find . -maxdepth 1 -name '*.seq' ! -name 'combined_*' -exec cat {} + > combined_dais.seq
    find . -maxdepth 1 -name '*.ins' ! -name '*.gen.ins' ! -name 'combined_*' -exec cat {} + > combined_dais.ins
    find . -maxdepth 1 -name '*.del' ! -name '*.gen.del' ! -name 'combined_*' -exec cat {} + > combined_dais.del

    mira-oxide variants \\
        --query-dais-file combined_dais.seq \\
        --query-insertion-file combined_dais.ins \\
        --query-deletion-file combined_dais.del \\
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
