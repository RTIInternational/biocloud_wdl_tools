version development

task gwaslab_read_ldsc {
  input {
    Array[File] filelist
    String out_filename = "ldsc_results.tsv"
    String mode = "h2"

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

    python3 /opt/gwaslab_read_ldsc.py \
      --filelist ~{sep(" ", filelist)} \
      --out "~{out_filename}" \
      --mode "~{mode}"
  >>>

  output {
    File out_tsv = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_load_pickle {
  input {
    File pickle_path
    String out_filename = "from_pickle.tsv.gz"
    String out_fmt = "gwaslab"

    # Runtime parameters
    String docker_image = "rtibiocloud/gwaslab:v4.2.2_a5d9ccd"
    String ecr_image = "rtibiocloud/gwaslab:v4.2.2_a5d9ccd"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 1
    Int mem_gb = 8
  }

  command <<<
    set -euo pipefail

    python3 /opt/gwaslab_load_pickle.py \
      --pickle_path "~{pickle_path}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}"
  >>>

  output {
    File out_file = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_load_gsf {
  input {
    File gsf_path
    String out_filename = "from_gsf.tsv.gz"
    String out_fmt = "gwaslab"
    Array[String]? columns
    String? filters

    # Runtime parameters
    String docker_image = "rtibiocloud/gwaslab:v4.2.2_a5d9ccd"
    String ecr_image = "rtibiocloud/gwaslab:v4.2.2_a5d9ccd"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 1
    Int mem_gb = 8
  }

  command <<<
    set -euo pipefail

    python3 /opt/gwaslab_load_gsf.py \
      --gsf_path "~{gsf_path}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}" \
      ~{if defined(columns) then "--columns " + sep(" ", select_first([columns])) else ""} \
      ~{if defined(filters) then "--filters '" + select_first([filters]) + "'" else ""}
  >>>

  output {
    File out_file = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_read_gtf {
  input {
    File gtf
    String out_filename = "parsed_gtf.tsv"
    String? chrom
    Array[String]? features
    Array[String]? usecols

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

    python3 /opt/gwaslab_read_gtf.py \
      --gtf "~{gtf}" \
      --out "~{out_filename}" \
      ~{if defined(chrom) then "--chrom '" + select_first([chrom]) + "'" else ""} \
      ~{if defined(features) then "--features " + sep(" ", select_first([features])) else ""} \
      ~{if defined(usecols) then "--usecols " + sep(" ", select_first([usecols])) else ""}
  >>>

  output {
    File out_tsv = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_read_bed {
  input {
    File bed
    String out_filename = "parsed_bed.tsv"
    Array[Int]? usecols

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

    python3 /opt/gwaslab_read_bed.py \
      --bed "~{bed}" \
      --out "~{out_filename}" \
      ~{if defined(usecols) then "--usecols " + sep(" ", select_first([usecols])) else ""}
  >>>

  output {
    File out_tsv = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}
