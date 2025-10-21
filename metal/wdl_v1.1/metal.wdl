version 1.1

task metal {

  input{
    # METAL input file parameters
    Array[File] sum_stats_files
    Array[String] separators
    Array[String] marker_col_names
    Array[String] chrom_col_names
    Array[String] pos_col_names
    Array[String] ref_allele_col_names
    Array[String] alt_allele_col_names
    Array[String] effect_col_names
    Array[String] freq_col_names

    # METAL input file sample size weighted meta parameters
    Array[String] pvalue_col_names = []
    Array[String] weight_col_names = []

    # METAL input file inverse variance weighted meta parameters
    Array[String] std_err_col_names = []

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
    String ?track_positions

    # Parameters for make_metal_command_file
    String metal_command_file = "metal.cmd"

    # Runtime options
    String docker_image = "rtibiocloud/metal:v2020.05.05_14c2505"
    String ecr_image = "rtibiocloud/metal:v2020.05.05_14c2505"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 1
    Int mem_gb = 2
  }

  command <<<
    set -e
    
    # Make METAL command file
    /opt/make_metal_command_file.pl \
      --metal_command_file ~{metal_command_file} \
      --sum_stats_files ~{sep(",", sum_stats_files)} \
      --separators ~{sep(",", separators)} \
      --marker_col_names ~{sep(",", marker_col_names)} \
      --chrom_col_names ~{sep(",", chrom_col_names)} \
      --pos_col_names ~{sep(",", pos_col_names)} \
      --ref_allele_col_names ~{sep(",", ref_allele_col_names)} \
      --alt_allele_col_names ~{sep(",", alt_allele_col_names)} \
      --effect_col_names ~{sep(",", effect_col_names)} \
      --freq_col_names ~{sep(",", freq_col_names)} \
      ~{if (length(pvalue_col_names) > 0) then ("--pvalue_col_names " + sep(",", pvalue_col_names)) else ""} \
      ~{if (length(weight_col_names) > 0) then ("--weight_col_names " + sep(",", weight_col_names)) else ""} \
      ~{if (length(std_err_col_names) > 0) then ("--std_err_col_names " + sep(",", std_err_col_names)) else ""} \
      --out_prefix ~{metal_out_prefix} \
      --out_suffix ~{metal_out_suffix} \
      --scheme ~{scheme} \
      ~{"--genomic_control " + genomic_control} \
      ~{"--analyze " + analyze} \
      ~{"--column_counting " + column_counting} \
      ~{"--average_freq " + average_freq} \
      ~{"--min_max_freq " + min_max_freq} \
      ~{"--track_positions " + track_positions}

    # Execute METAL command file
    /opt/metal ~{metal_command_file} > ~{metal_out_prefix}.log

    # Run post-METAL processing
    python /opt/postprocess_metal_results.py \
      --metal_prefix ~{metal_out_prefix} \
      --metal_suffix ~{metal_out_suffix}
  >>>

  output {
    File metal_results = "~{metal_out_prefix}.~{metal_out_suffix}"
    File metal_info = "~{metal_out_prefix}.info"
    File metal_log = "~{metal_out_prefix}.log"
  }
  
  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }

  parameter_meta  {
  }

  meta {
    description: "Perform meta-analysis on the input files"
    author: "Nathan Gaddis"
    email: "ngaddis@rti.org"
  }
}
