task make_gwas_summary_stats {
    File file_in_summary_stats
    File file_in_info
    File file_in_pop_mafs
    String file_in_summary_stats_format
    String population
    String file_out_prefix

    # Runtime options
    String docker = "rtibiocloud/make_gwas_summary_stats:none_ea93119"
    Int cpu = 1
    Int mem_gb = ceil(size(file_in_summary_stats, "GB") + size(file_in_info, "GB") + size(file_in_pop_mafs, "GB")) * 15
    Int max_retries = 3

    command{
        set -e

        sumstats_file=${file_in_summary_stats}
        info_file=${file_in_info}
        maf_file=${file_in_pop_mafs}

        # Gzip sumstats if not gzipped
        if [[ "${file_in_summary_stats}" != *.gz ]]; then
            echo "Gzipping sumstats..."
            gzip ${file_in_summary_stats}
            sumstats_file=${file_in_summary_stats}.gz
        fi

        # Gzip info if not gzipped
        if [[ "${file_in_info}" != *.gz ]]; then
            echo "Gzipping info..."
            gzip ${file_in_info}
            info_file=${file_in_info}.gz
        fi

        # Gzip pop mafs file if not gzipped
        if [[ "${file_in_pop_mafs}" != *.gz ]]; then
            echo "Gzipping maf pop file..."
            gzip ${file_in_pop_mafs}
            maf_file=${file_in_pop_mafs}.gz
        fi

        python /opt/make_gwas_summary_stats.py \
            --file_in_summary_stats $sumstats_file \
            --file_in_info $info_file \
            --file_in_pop_mafs $maf_file \
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
        File output_file = "${file_out_prefix}.tsv.gz"
        File log_file = "${file_out_prefix}.log"
   }


}