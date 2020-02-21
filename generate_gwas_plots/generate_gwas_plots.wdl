task generate_gwas_plots{
    File summary_stats
    String id_colname
    String chr_colname
    String pos_colname
    String pvalue_colname
    String output_basename

    Boolean? show_lambda = true
    Boolean? header = true
    Boolean? is_csv

    # Runtime options
    String docker = "rtibiocloud/generate_gwas_plots:6ce5e03"
    Int cpu = 1
    Int mem_gb = ceil(size(summary_stats, "GB")) + 1
    Int max_retries = 3

    command{
        set -e

        # Convert X chromosome to 23
        echo "Converting instances of X to 23..."
        sed 's/X/23/g' ${summary_stats} > fixed_sumstats.txt

        /opt/generate_gwas_plots.R \
            --in fixed_sumstats.txt \
            --out ${output_basename} \
            --col_id ${id_colname} \
            --col_chromosome ${chr_colname} \
            --col_position ${pos_colname} \
            --col_p ${pvalue_colname} \
            --generate_qq_plot \
            --generate_manhattan_plot \
            ${true='--qq_lambda' false='' show_lambda} \
            ${true='--in_csv' false='' is_csv}
    }

    runtime{
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output {
        File manhattan_plot = "${output_basename}.manhattan.png"
        File qq_plot = "${output_basename}.qq.png"
   }

}