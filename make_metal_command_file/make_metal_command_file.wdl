task make_metal_commmand_file {

    String metal_command_file = "metal.cmd"

    # METAL input file parameters
    String sum_stats_files
    String separators = "WHITESPACE"
    String marker_col_names = "VARIANT_ID"
    String ref_allele_col_names = "REF"
    String alt_allele_col_names = "ALT"
    String effect_col_names = "ALT_EFFECT"
    String freq_col_names = "ALT_AF"

    # METAL input file sample size weighted meta parameters
    String pvalue_col_names = "P"
    String weight_col_names = "N"

    # METAL input file inverse variance weighted meta parameters
    String std_err_col_names = "SE"

    # METAL input file interaction parameters
    String ?int_effect_col_names
    String ?int_std_err_col_names
    String ?int_cov_col_names

    # METAL analysis parameters
    String metal_out_prefix
    String scheme
    String analyze
    String ?genomic_control

    # Other METAL parameters
    String ?column_counting
    String ?average_freq
    String ?min_max_freq

    # Runtime options
    String docker = "rtibiocloud/make_metal_command_file:v1_02063af"
    Int cpu = 1
    Int mem_gb = 1
    Int max_retries = 3

    command{
        /opt/make_metal_command_file.pl \
            --metal_command_file ${metal_command_file} \
            --sum_stats_files ${sum_stats_files} \
            --separators ${separators} \
            --marker_col_names ${marker_col_names} \
            --ref_allele_col_names ${ref_allele_col_names} \
            --alt_allele_col_names ${alt_allele_col_names} \
            --effect_col_names ${effect_col_names} \
            --freq_col_names ${freq_col_names} \
            --pvalue_col_names ${pvalue_col_names} \
            --weight_col_names ${weight_col_names} \
            --std_err_col_names ${std_err_col_names} \
            ${"--int_effect_col_names " + int_effect_col_names} \
            ${"--int_std_err_col_names " + int_std_err_col_names} \
            ${"--int_cov_col_names " + int_cov_col_names} \
            --metal_out_prefix ${metal_out_prefix} \
            --out_suffix tsv \
            --scheme ${scheme} \
            ${"--genomic_control " + genomic_control} \
            ${"--analyze " + analyze} \
            ${"--column_counting " + column_counting} \
            ${"--average_freq " + average_freq} \
            ${"--min_max_freq " + min_max_freq}
    }

    runtime{
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output {
        File command_file = "${metal_command_file}"
   }


}