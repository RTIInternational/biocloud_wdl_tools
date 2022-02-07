import "biocloud_wdl_tools/make_metal_command_file/make_metal_command_file.wdl" as METAL_COMMAND

workflow test_make_metal_command_file{

    String metal_command_file = "metal.cmd"

    # METAL input file parameters
    String sum_stats_files
    String ?separators
    String ?marker_col_names
    String ?ref_allele_col_names
    String ?alt_allele_col_names
    String ?effect_col_names
    String ?freq_col_names

    # METAL input file sample size weighted meta parameters
    String ?pvalue_col_names
    String ?weight_col_names

    # METAL input file inverse variance weighted meta parameters
    String ?std_err_col_names

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

    call METAL_COMMAND.make_metal_commmand_file as make_metal_commmand_file {
        input:
            metal_command_file = metal_command_file,
            sum_stats_files = sum_stats_files,
            separators = separators,
            marker_col_names = marker_col_names,
            ref_allele_col_names = ref_allele_col_names,
            alt_allele_col_names = alt_allele_col_names,
            effect_col_names = effect_col_names,
            freq_col_names = freq_col_names,
            pvalue_col_names = pvalue_col_names,
            weight_col_names = weight_col_names,
            std_err_col_names = std_err_col_names,
            int_effect_col_names = int_effect_col_names,
            int_std_err_col_names = int_std_err_col_names,
            int_cov_col_names = int_cov_col_names,
            metal_out_prefix = metal_out_prefix,
            scheme = scheme,
            analyze = analyze,
            genomic_control = genomic_control,
            column_counting = column_counting,
            average_freq = average_freq,
            min_max_freq = min_max_freq
    }

    output{
        File command_file = make_metal_commmand_file.command_file
    }
}

