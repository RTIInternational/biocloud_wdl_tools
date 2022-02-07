task metal_i {

  File metal_command_file
  Array[File] sum_stats_files
  String output_file

  String docker = "rtibiocloud/metal-i:v2010.02.08_3b82b22"
  Int cpu = 1
  Int mem_gb = 2
  Int max_retries = 3

  command <<<

    # execute metal file
    /opt/metal ${metal_command_file}

  >>>

  output {
    File metal_results = "${output_file}"
  }
  
  runtime {
    docker: docker
    cpu: cpu
    memory: "${mem_gb} GB"
    maxRetries: max_retries
  }

  parameter_meta  {
    metal_command_file: "File containing commands for METAL to run"
    sum_stats_files: "Sum stats files to use for meta-analysis"
    output_file: "Name of output file"
  }

  meta {
    description: "Perform 2df meta-analysis on the input files"
    author: "Nathan Gaddis"
    email: "ngaddis@rti.org"
  }
}
