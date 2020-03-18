task convert_to_impute2_ids {
    File in_file
    File legend_file
    Int contains_header = 1
    Int id_col
    Int chr_col
    Int pos_col
    Int a1_col
    Int a2_col
    String chr
    String output_filename

    # Runtime environment
    String docker = "rtibiocloud/convert_to_1000g_ids:none_315130"
    Int cpu = 1
    Int mem_gb = 2
    Int max_retries = 3

    command{
        set -e

        /opt/convert_to_1000g_ids.pl \
            --file_in ${in_file} \
            --file_out ${output_filename} \
            --legend ${legend_file} \
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
