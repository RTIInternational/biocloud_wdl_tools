task metal_i {

  # METAL input file parameters
  Array[File] sum_stats_files
  String separators
  String marker_col_names
  String ref_allele_col_names
  String alt_allele_col_names
  String effect_col_names
  String freq_col_names

  # METAL input file sample size weighted meta parameters
  String pvalue_col_names
  String weight_col_names

  # METAL input file inverse variance weighted meta parameters
  String std_err_col_names

  # METAL input file interaction parameters
  String ?int_effect_col_names
  String ?int_std_err_col_names
  String ?int_cov_col_names

  # METAL analysis parameters
  String metal_out_prefix
  String metal_out_suffix = "tsv"
  String scheme
  String ?analyze
  String ?genomic_control

  # Other METAL parameters
  String ?column_counting
  String ?average_freq
  String ?min_max_freq

  # Parameters for make_metal_command_file
  String metal_command_file = "metal.cmd"

  # Runtime options
  String docker = "rtibiocloud/metal-i:v2010.02.08_da9f7d8"
  Int cpu = 1
  Int mem_gb = 2
  Int max_retries = 3

  command <<<

    # Make METAL command file
    /opt/make_metal_command_file.pl \
      --metal_command_file ${metal_command_file} \
      --sum_stats_files ${sep="," sum_stats_files} \
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
      --out_prefix ${metal_out_prefix} \
      --out_suffix ${metal_out_suffix} \
      --scheme ${scheme} \
      ${"--genomic_control " + genomic_control} \
      ${"--analyze " + analyze} \
      ${"--column_counting " + column_counting} \
      ${"--average_freq " + average_freq} \
      ${"--min_max_freq " + min_max_freq}

    # Execute METAL command file
    /opt/metal ${metal_command_file}

    # Rename METAL output
    mv ${metal_out_prefix}1${metal_out_suffix} ${metal_out_prefix}.${metal_out_suffix}
    mv ${metal_out_prefix}1${metal_out_suffix}.info ${metal_out_prefix}.info
  >>>

  output {
    File metal_results = "${metal_out_prefix}.${metal_out_suffix}"
    File metal_info = "${metal_out_prefix}.info"
  }
  
  runtime {
    docker: docker
    cpu: cpu
    memory: "${mem_gb} GB"
    maxRetries: max_retries
  }

  parameter_meta  {
  }

  meta {
    description: "Perform 2df meta-analysis on the input files"
    author: "Nathan Gaddis"
    email: "ngaddis@rti.org"
  }
}
