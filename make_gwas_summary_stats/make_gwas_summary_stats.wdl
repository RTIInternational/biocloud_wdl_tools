task make_gwas_summary_stats {
    File file_in_summary_stats
    File file_in_info
    File file_in_pop_mafs
    String file_in_summary_stats_format
    String population
    String file_out_prefix

    # Runtime options
    String docker = "rticode/"
    Int cpu = 2
    Int mem_gb = 8
    Int max_retries = 3

    command{
        set -e

        python /opt/make_gwas_summary_stats.py \
            --file_in_summary_stats ${file_in_summary_stats} \
            --file_in_info ${file_in_info} \
            --file_in_pop_mafs ${file_in_pop_mafs} \
            --file_in_summary_stats_format ${file_in_summary_stats_format} \
            --population ${population} \
            --file_out_prefix ${file_out_prefix}
    }

    runtime{
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output {
        File output_file = "${file_out_prefix}.tsv"
        File log_file = "${file_out_prefix}.log"
   }


}