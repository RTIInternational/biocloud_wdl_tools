task convert_to_1000g_ids {
    File sumstats_file
    File legend_file_1000g
    Int contains_header = 1
    Int id_col
    Int chr_col
    Int pos_col
    Int a1_col
    Int a2_col
    Int chr
    String output_filename = basename(sumstats_file, ".txt") + ".phase3ID.txt"

    # Runtime options
    String docker = "rticode/convert_to_1000g_ids:fe710d550c9ff0d100d0b7c37db580362488e8fc"
    Int cpu = 2
    Int mem_gb = 8
    Int max_retries = 3

    command{
        set -e

        /opt/code_docker_lib/convert_to_1000g_ids.pl \
            --file_in ${sumstats_file} \
            --file_out ${output_filename} \
            --legend ${legend_file_1000g} \
            --file_in_header ${contains_header} \
            --file_in_id_col ${id_col} \
            --file_in_chr_col ${chr_col} \
            --file_in_pos_col ${pos_col} \
            --file_in_a1_col ${a1_col} \
            --file_in_a2_col ${a2_col} \
            --chr ${chr}
    }

    runtime{
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output {
        File output_file = "${output_filename}"
    }


}