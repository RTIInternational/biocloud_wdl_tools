version 1.1

task phase_gt_eagle {

  input {

    # Required parameters
    File genetic_map_file
    String chr
    File vcf_in_file
    String output_filename

    # Optional parameters
    String log_filename = "~{output_filename}.log"
    Boolean? impute_variants = false    

    # Runtime environment
    String docker_image = "rtibiocloud/eagle:v2.4.1_046d257"
    String ecr_image = "rtibiocloud/eagle:v2.4.1_046d257"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 2
    Int mem_gb = 4
    Int max_retries = 3
  }

  command <<<
    bio-eagle \
      --vcf ~{vcf_in_file} \
      --chrom ~{chr} \
      --geneticMapFile ~{genetic_map_file} \
      ~{true="" false="--noImpMissing" impute_variants} \
      --outPrefix ~{output_filename}
  >>>

  runtime{
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
        maxRetries: max_retries
  }

  output {
    File output_file = "~{output_filename}"
    File log = "~{log_filename}"
  }

}
