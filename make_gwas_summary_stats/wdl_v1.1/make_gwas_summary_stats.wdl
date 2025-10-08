version 1.1

task make_gwas_summary_stats {

    input{
        File file_in_summary_stats
        File file_in_info
        String file_in_summary_stats_format
        String file_in_info_format = "info"
        String file_out_prefix
        Int chunk_size = 50000

        # Optional pop maf files to add pop MAFs from
        File? file_in_pop_mafs

        # Runtime options
        String docker_image = "rtibiocloud/make_gwas_summary_stats:v2.1.2_936755e"
        String ecr_image = "rtibiocloud/make_gwas_summary_stats:v2.1.2_936755e"
        String image_source = "docker"
        String? ecr_repo
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 1
        Int mem_gb = 3
    }

    command <<<
        set -e
        python /opt/make_gwas_summary_stats.py \
            --file_in_summary_stats ~{file_in_summary_stats} \
            --file_in_info ~{file_in_info} \
            --file_in_summary_stats_format ~{file_in_summary_stats_format} \
            --file_in_info_format ~{file_in_info_format} \
            ~{"--file_in_pop_mafs " + file_in_pop_mafs} \
            --file_out_prefix ~{file_out_prefix} \
            --chunk_size ~{chunk_size}
    >>>

    runtime{
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
    }

    output {
        File output_file = "~{file_out_prefix}.tsv.gz"
        File log_file = "~{file_out_prefix}.log"
   }


}
