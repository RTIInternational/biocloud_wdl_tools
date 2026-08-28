version development

task gwaslab_download_ref {
  input {
    String name
    String? out_dir

    # Runtime parameters
    String docker_image = "rtibiocloud/gwaslab:v4.2.2_a5d9ccd"
    String ecr_image = "rtibiocloud/gwaslab:v4.2.2_a5d9ccd"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 1
    Int mem_gb = 4
  }

  command <<<
    set -euo pipefail

    python3 /opt/gwaslab_download_ref.py \
      --name "~{name}" \
      ~{if defined(out_dir) then "--out_dir '" + select_first([out_dir]) + "'" else ""}
  >>>

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_check_format {
  input {
    String fmt
    String out_json = "format_mapping.json"

    # Runtime parameters
    String docker_image = "rtibiocloud/gwaslab:v4.2.2_a5d9ccd"
    String ecr_image = "rtibiocloud/gwaslab:v4.2.2_a5d9ccd"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 1
    Int mem_gb = 2
  }

  command <<<
    set -euo pipefail

    python3 /opt/gwaslab_check_format.py \
      --fmt "~{fmt}" \
      --out_json "~{out_json}"
  >>>

  output {
    File format_json = out_json
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_download_sumstats {
  input {
    String gcst_id
    String out_dir = "./"
    String? filename
    Boolean harmonised = true
    Boolean overwrite = false

    # Runtime parameters
    String docker_image = "rtibiocloud/gwaslab:v4.2.2_a5d9ccd"
    String ecr_image = "rtibiocloud/gwaslab:v4.2.2_a5d9ccd"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 1
    Int mem_gb = 4
  }

  command <<<
    set -euo pipefail

    python3 /opt/gwaslab_download_sumstats.py \
      --gcst_id "~{gcst_id}" \
      --out_dir "~{out_dir}" \
      ~{if defined(filename) then "--filename '" + select_first([filename]) + "'" else ""} \
      ~{if harmonised then "--harmonised" else "--raw"} \
      ~{if overwrite then "--overwrite" else ""}
  >>>

  output {
    Array[File] downloaded_sumstats = glob("~{out_dir}/*")
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_get_power {
  input {
    String mode = "q"
    Int? n
    Float? beta
    Float eaf = 0.2
    Float vary = 1.0
    Int? ncase
    Int? ncontrol
    Float? genotype_or
    Float? genotype_rr
    Float prevalence = 0.01
    Float sig_level = 5e-8

    # Runtime parameters
    String docker_image = "rtibiocloud/gwaslab:v4.2.2_a5d9ccd"
    String ecr_image = "rtibiocloud/gwaslab:v4.2.2_a5d9ccd"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 1
    Int mem_gb = 2
  }

  command <<<
    set -euo pipefail

    python3 /opt/gwaslab_get_power.py \
      --mode "~{mode}" \
      --eaf ~{eaf} \
      --sig_level ~{sig_level} \
      ~{if defined(n) then "--n " + select_first([n]) else ""} \
      ~{if defined(beta) then "--beta " + select_first([beta]) else ""} \
      ~{if (mode == "q") then "--vary " + vary else ""} \
      ~{if defined(ncase) then "--ncase " + select_first([ncase]) else ""} \
      ~{if defined(ncontrol) then "--ncontrol " + select_first([ncontrol]) else ""} \
      ~{if defined(genotype_or) then "--genotype_or " + select_first([genotype_or]) else ""} \
      ~{if defined(genotype_rr) then "--genotype_rr " + select_first([genotype_rr]) else ""} \
      ~{if (mode == "b") then "--prevalence " + prevalence else ""}
  >>>

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}
