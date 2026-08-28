version development

# ==============================================================================
# CORE TASKS
# ==============================================================================

task gwaslab_sumstats_basic_check {
  input {
    File sumstats
    String out_filename = "basic_checked.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"
    String? snpid
    String? rsid
    String? chrom
    String? pos
    String? ea
    String? nea
    String? eaf
    String? beta
    String? se
    String? p
    String? mlog10p
    String? n
    String build = "99"
    Boolean remove = false
    Boolean remove_dup = false
    Boolean normalize = true
    Int threads = 1

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

    python3 /opt/gwaslab_sumstats_basic_check.py \
      --sumstats "~{sumstats}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}" \
      --fmt "~{fmt}" \
      --build "~{build}" \
      ~{if defined(snpid) then "--snpid '" + select_first([snpid]) + "'" else ""} \
      ~{if defined(rsid) then "--rsid '" + select_first([rsid]) + "'" else ""} \
      ~{if defined(chrom) then "--chrom '" + select_first([chrom]) + "'" else ""} \
      ~{if defined(pos) then "--pos '" + select_first([pos]) + "'" else ""} \
      ~{if defined(ea) then "--ea '" + select_first([ea]) + "'" else ""} \
      ~{if defined(nea) then "--nea '" + select_first([nea]) + "'" else ""} \
      ~{if defined(eaf) then "--eaf '" + select_first([eaf]) + "'" else ""} \
      ~{if defined(beta) then "--beta '" + select_first([beta]) + "'" else ""} \
      ~{if defined(se) then "--se '" + select_first([se]) + "'" else ""} \
      ~{if defined(p) then "--p '" + select_first([p]) + "'" else ""} \
      ~{if defined(mlog10p) then "--mlog10p '" + select_first([mlog10p]) + "'" else ""} \
      ~{if defined(n) then "--n '" + select_first([n]) + "'" else ""} \
      ~{if remove then "--remove" else ""} \
      ~{if remove_dup then "--remove_dup" else ""} \
      ~{if normalize then "--normalize" else ""} \
      --threads ~{threads}
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_harmonize {
  input {
    File sumstats
    String out_filename = "harmonized.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"
    String? snpid
    String? rsid
    String? chrom
    String? pos
    String? ea
    String? nea
    String? eaf
    String? beta
    String? se
    String? p
    String? mlog10p
    String? n
    String build = "99"
    File? ref_seq
    File? ref_infer
    File? ref_rsid_tsv
    File? ref_rsid_vcf
    String? ref_alt_freq
    Float maf_threshold = 0.4
    Int threads = 1
    Boolean sweep_mode = false

    # Runtime parameters
    String docker_image = "rtibiocloud/gwaslab:v4.2.2_a5d9ccd"
    String ecr_image = "rtibiocloud/gwaslab:v4.2.2_a5d9ccd"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 2
    Int mem_gb = 16
  }

  command <<<
    set -euo pipefail

    python3 /opt/gwaslab_sumstats_harmonize.py \
      --sumstats "~{sumstats}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}" \
      --fmt "~{fmt}" \
      --build "~{build}" \
      ~{if defined(snpid) then "--snpid '" + select_first([snpid]) + "'" else ""} \
      ~{if defined(rsid) then "--rsid '" + select_first([rsid]) + "'" else ""} \
      ~{if defined(chrom) then "--chrom '" + select_first([chrom]) + "'" else ""} \
      ~{if defined(pos) then "--pos '" + select_first([pos]) + "'" else ""} \
      ~{if defined(ea) then "--ea '" + select_first([ea]) + "'" else ""} \
      ~{if defined(nea) then "--nea '" + select_first([nea]) + "'" else ""} \
      ~{if defined(eaf) then "--eaf '" + select_first([eaf]) + "'" else ""} \
      ~{if defined(beta) then "--beta '" + select_first([beta]) + "'" else ""} \
      ~{if defined(se) then "--se '" + select_first([se]) + "'" else ""} \
      ~{if defined(p) then "--p '" + select_first([p]) + "'" else ""} \
      ~{if defined(mlog10p) then "--mlog10p '" + select_first([mlog10p]) + "'" else ""} \
      ~{if defined(n) then "--n '" + select_first([n]) + "'" else ""} \
      ~{if defined(ref_seq) then "--ref_seq '" + select_first([ref_seq]) + "'" else ""} \
      ~{if defined(ref_infer) then "--ref_infer '" + select_first([ref_infer]) + "'" else ""} \
      ~{if defined(ref_rsid_tsv) then "--ref_rsid_tsv '" + select_first([ref_rsid_tsv]) + "'" else ""} \
      ~{if defined(ref_rsid_vcf) then "--ref_rsid_vcf '" + select_first([ref_rsid_vcf]) + "'" else ""} \
      ~{if defined(ref_alt_freq) then "--ref_alt_freq '" + select_first([ref_alt_freq]) + "'" else ""} \
      --maf_threshold ~{maf_threshold} \
      --threads ~{threads} \
      ~{if sweep_mode then "--sweep_mode" else ""}
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_liftover {
  input {
    File sumstats
    String to_build
    String? from_build
    File? chain_path
    String out_filename = "lifted.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"
    Boolean remove = true

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

    python3 /opt/gwaslab_sumstats_liftover.py \
      --sumstats "~{sumstats}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}" \
      --fmt "~{fmt}" \
      --to_build "~{to_build}" \
      ~{if defined(from_build) then "--from_build '" + select_first([from_build]) + "'" else ""} \
      ~{if defined(chain_path) then "--chain_path '" + select_first([chain_path]) + "'" else ""} \
      ~{if remove then "--remove" else ""}
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_summary {
  input {
    File sumstats
    String out_filename = "qc_summary.json"
    String fmt = "auto"

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

    python3 /opt/gwaslab_sumstats_summary.py \
      --sumstats "~{sumstats}" \
      --fmt "~{fmt}" \
      --out "~{out_filename}"
  >>>

  output {
    File summary_json = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_lookup_status {
  input {
    File sumstats
    String out_filename = "status_breakdown.tsv"
    String status_col = "STATUS"
    String fmt = "auto"

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

    python3 /opt/gwaslab_sumstats_lookup_status.py \
      --sumstats "~{sumstats}" \
      --fmt "~{fmt}" \
      --status_col "~{status_col}" \
      --out "~{out_filename}"
  >>>

  output {
    File status_tsv = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_infer_build {
  input {
    File sumstats
    String out_filename = "inferred_build.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"

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

    python3 /opt/gwaslab_sumstats_infer_build.py \
      --sumstats "~{sumstats}" \
      --fmt "~{fmt}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}"
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_set_build {
  input {
    File sumstats
    String target_build
    String out_filename = "set_build.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"

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

    python3 /opt/gwaslab_sumstats_set_build.py \
      --sumstats "~{sumstats}" \
      --fmt "~{fmt}" \
      --target_build "~{target_build}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}"
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_sort_coordinate {
  input {
    File sumstats
    String out_filename = "sorted_coords.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"

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

    python3 /opt/gwaslab_sumstats_sort_coordinate.py \
      --sumstats "~{sumstats}" \
      --fmt "~{fmt}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}"
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_sort_column {
  input {
    File sumstats
    String out_filename = "sorted_columns.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"

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

    python3 /opt/gwaslab_sumstats_sort_column.py \
      --sumstats "~{sumstats}" \
      --fmt "~{fmt}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}"
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_fill_data {
  input {
    File sumstats
    String out_filename = "filled.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"
    Array[String] to_fill = ["Z", "MLOG10P", "CHISQ"]
    Boolean overwrite = false
    Boolean extreme = false

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

    python3 /opt/gwaslab_sumstats_fill_data.py \
      --sumstats "~{sumstats}" \
      --fmt "~{fmt}" \
      --to_fill ~{sep(" ", to_fill)} \
      ~{if overwrite then "--overwrite" else ""} \
      ~{if extreme then "--extreme" else ""} \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}"
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_check_ref {
  input {
    File sumstats
    File ref_seq
    String out_filename = "checked_ref.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"
    Boolean remove = false

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

    python3 /opt/gwaslab_sumstats_check_ref.py \
      --sumstats "~{sumstats}" \
      --fmt "~{fmt}" \
      --ref_seq "~{ref_seq}" \
      ~{if remove then "--remove" else ""} \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}"
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_infer_strand {
  input {
    File sumstats
    File ref_infer
    String out_filename = "inferred_strand.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"
    String ref_alt_freq = "AF"
    Float maf_threshold = 0.4
    Boolean flip_stats = false

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

    python3 /opt/gwaslab_sumstats_infer_strand.py \
      --sumstats "~{sumstats}" \
      --fmt "~{fmt}" \
      --ref_infer "~{ref_infer}" \
      --ref_alt_freq "~{ref_alt_freq}" \
      --maf_threshold ~{maf_threshold} \
      ~{if flip_stats then "--flip_stats" else ""} \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}"
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_flip_allele_stats {
  input {
    File sumstats
    String out_filename = "flipped_stats.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"

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

    python3 /opt/gwaslab_sumstats_flip_allele_stats.py \
      --sumstats "~{sumstats}" \
      --fmt "~{fmt}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}"
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_assign_rsid {
  input {
    File sumstats
    File? ref_rsid_tsv
    File? ref_rsid_vcf
    String out_filename = "assigned_rsid.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"
    String overwrite = "empty"
    Int threads = 1

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

    python3 /opt/gwaslab_sumstats_assign_rsid.py \
      --sumstats "~{sumstats}" \
      --fmt "~{fmt}" \
      ~{if defined(ref_rsid_tsv) then "--ref_rsid_tsv '" + select_first([ref_rsid_tsv]) + "'" else ""} \
      ~{if defined(ref_rsid_vcf) then "--ref_rsid_vcf '" + select_first([ref_rsid_vcf]) + "'" else ""} \
      --overwrite "~{overwrite}" \
      --threads ~{threads} \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}"
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_rsid_to_chrpos {
  input {
    File sumstats
    File? ref_vcf
    File? ref_hdf5
    String out_filename = "assigned_coords.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"
    Int threads = 4

    # Runtime parameters
    String docker_image = "rtibiocloud/gwaslab:v4.2.2_a5d9ccd"
    String ecr_image = "rtibiocloud/gwaslab:v4.2.2_a5d9ccd"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 4
    Int mem_gb = 16
  }

  command <<<
    set -euo pipefail

    python3 /opt/gwaslab_sumstats_rsid_to_chrpos.py \
      --sumstats "~{sumstats}" \
      --fmt "~{fmt}" \
      ~{if defined(ref_vcf) then "--ref_vcf '" + select_first([ref_vcf]) + "'" else ""} \
      ~{if defined(ref_hdf5) then "--ref_hdf5 '" + select_first([ref_hdf5]) + "'" else ""} \
      --threads ~{threads} \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}"
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_check_af {
  input {
    File sumstats
    File ref_infer
    String out_filename = "checked_af.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"
    String ref_alt_freq = "AF"
    Float maf_threshold = 0.4
    String column_name = "DAF"
    Int threads = 1

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

    python3 /opt/gwaslab_sumstats_check_af.py \
      --sumstats "~{sumstats}" \
      --fmt "~{fmt}" \
      --ref_infer "~{ref_infer}" \
      --ref_alt_freq "~{ref_alt_freq}" \
      --maf_threshold ~{maf_threshold} \
      --column_name "~{column_name}" \
      --threads ~{threads} \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}"
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_infer_af {
  input {
    File sumstats
    File ref_infer
    String out_filename = "inferred_af.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"
    String ref_alt_freq = "AF"
    Boolean from_maf = false
    Int threads = 1

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

    python3 /opt/gwaslab_sumstats_infer_af.py \
      --sumstats "~{sumstats}" \
      --fmt "~{fmt}" \
      --ref_infer "~{ref_infer}" \
      --ref_alt_freq "~{ref_alt_freq}" \
      ~{if from_maf then "--from_maf" else ""} \
      --threads ~{threads} \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}"
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_to_format {
  input {
    File sumstats
    String to_fmt
    String out_filename = "converted_sumstats"
    String tab_fmt = "tsv"
    String fmt = "auto"
    Boolean gzip = true
    Boolean bgzip = false
    Boolean tabix = false
    Boolean md5sum = false
    Boolean ssfmeta = false

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

    python3 /opt/gwaslab_sumstats_to_format.py \
      --sumstats "~{sumstats}" \
      --fmt "~{fmt}" \
      --to_fmt "~{to_fmt}" \
      --tab_fmt "~{tab_fmt}" \
      --out "~{out_filename}" \
      ~{if gzip then "--gzip" else ""} \
      ~{if bgzip then "--bgzip" else ""} \
      ~{if tabix then "--tabix" else ""} \
      ~{if md5sum then "--md5sum" else ""} \
      ~{if ssfmeta then "--ssfmeta" else ""}
  >>>

  output {
    Array[File] converted_files = glob("~{out_filename}*")
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_report {
  input {
    File sumstats
    String out_filename = "qc_report.html"
    String report_title = "GWAS Quality Control Report"
    String fmt = "auto"

    # Runtime parameters
    String docker_image = "rtibiocloud/gwaslab:v4.2.2_a5d9ccd"
    String ecr_image = "rtibiocloud/gwaslab:v4.2.2_a5d9ccd"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 2
    Int mem_gb = 8
  }

  command <<<
    set -euo pipefail

    python3 /opt/gwaslab_sumstats_report.py \
      --sumstats "~{sumstats}" \
      --fmt "~{fmt}" \
      --out "~{out_filename}" \
      --report_title "~{report_title}"
  >>>

  output {
    File report_html = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

# ==============================================================================
# FIX TASKS
# ==============================================================================

task gwaslab_sumstats_fix_id {
  input {
    File sumstats
    String out_filename = "fixed_id.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"
    Boolean fixprefix = false
    Boolean fixchrpos = false
    Boolean fixid = false
    Boolean fixsep = false
    Boolean overwrite = false

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

    python3 /opt/gwaslab_sumstats_fix_id.py \
      --sumstats "~{sumstats}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}" \
      --fmt "~{fmt}" \
      ~{if fixprefix then "--fixprefix" else ""} \
      ~{if fixchrpos then "--fixchrpos" else ""} \
      ~{if fixid then "--fixid" else ""} \
      ~{if fixsep then "--fixsep" else ""} \
      ~{if overwrite then "--overwrite" else ""}
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_fix_chr {
  input {
    File sumstats
    String out_filename = "fixed_chr.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"
    String add_prefix = ""
    Boolean remove = false

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

    python3 /opt/gwaslab_sumstats_fix_chr.py \
      --sumstats "~{sumstats}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}" \
      --fmt "~{fmt}" \
      --add_prefix "~{add_prefix}" \
      ~{if remove then "--remove" else ""}
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_fix_pos {
  input {
    File sumstats
    String out_filename = "fixed_pos.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"
    Boolean remove = false
    Int lower_limit = 0
    Int limit = 250000000

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

    python3 /opt/gwaslab_sumstats_fix_pos.py \
      --sumstats "~{sumstats}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}" \
      --fmt "~{fmt}" \
      ~{if remove then "--remove" else ""} \
      --lower_limit ~{lower_limit} \
      --limit ~{limit}
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_fix_allele {
  input {
    File sumstats
    String out_filename = "fixed_allele.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"
    Boolean remove = false

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

    python3 /opt/gwaslab_sumstats_fix_allele.py \
      --sumstats "~{sumstats}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}" \
      --fmt "~{fmt}" \
      ~{if remove then "--remove" else ""}
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_remove_dup {
  input {
    File sumstats
    String out_filename = "deduped.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"
    String mode = "ds"
    String keep = "first"
    String? keep_col
    Boolean remove_na = false

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

    python3 /opt/gwaslab_sumstats_remove_dup.py \
      --sumstats "~{sumstats}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}" \
      --fmt "~{fmt}" \
      --mode "~{mode}" \
      --keep "~{keep}" \
      ~{if defined(keep_col) then "--keep_col '" + select_first([keep_col]) + "'" else ""} \
      ~{if remove_na then "--remove_na" else ""}
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_check_sanity {
  input {
    File sumstats
    String out_filename = "sanity_checked.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"
    Float float_tolerance = 1e-7

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

    python3 /opt/gwaslab_sumstats_check_sanity.py \
      --sumstats "~{sumstats}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}" \
      --fmt "~{fmt}" \
      --float_tolerance ~{float_tolerance}
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_check_data_consistency {
  input {
    File sumstats
    String out_filename = "consistency_checked.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"
    Float rtol = 1e-5
    Float atol = 1e-8

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

    python3 /opt/gwaslab_sumstats_check_data_consistency.py \
      --sumstats "~{sumstats}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}" \
      --fmt "~{fmt}" \
      --rtol ~{rtol} \
      --atol ~{atol}
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_normalize_allele {
  input {
    File sumstats
    String out_filename = "normalized_alleles.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"
    Int threads = 1

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

    python3 /opt/gwaslab_sumstats_normalize_allele.py \
      --sumstats "~{sumstats}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}" \
      --fmt "~{fmt}" \
      --threads ~{threads}
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_flip_snpid {
  input {
    File sumstats
    String action = "flip"
    String out_filename = "modified_snpid.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"

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

    python3 /opt/gwaslab_sumstats_flip_snpid.py \
      --sumstats "~{sumstats}" \
      --action "~{action}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}" \
      --fmt "~{fmt}"
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

# ==============================================================================
# FILTER TASKS
# ==============================================================================

task gwaslab_sumstats_filter_value {
  input {
    File sumstats
    String expr
    String out_filename = "filtered.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"
    Boolean remove = false

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

    python3 /opt/gwaslab_sumstats_filter_value.py \
      --sumstats "~{sumstats}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}" \
      --fmt "~{fmt}" \
      --expr '~{expr}' \
      ~{if remove then "--remove" else ""}
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_filter_in_out {
  input {
    File sumstats
    String action = "in"
    String lt_json = "{}"
    String gt_json = "{}"
    String eq_json = "{}"
    String out_filename = "filtered_in_out.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"

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

    python3 /opt/gwaslab_sumstats_filter_in_out.py \
      --sumstats "~{sumstats}" \
      --action "~{action}" \
      --lt_json '~{lt_json}' \
      --gt_json '~{gt_json}' \
      --eq_json '~{eq_json}' \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}" \
      --fmt "~{fmt}"
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_filter_region {
  input {
    File sumstats
    String? region
    File? bed_in
    File? bed_out
    Boolean exclude_hla = false
    String hla_mode = "xmhc"
    String out_filename = "filtered_region.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"

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

    python3 /opt/gwaslab_sumstats_filter_region.py \
      --sumstats "~{sumstats}" \
      ~{if defined(region) then "--region '" + select_first([region]) + "'" else ""} \
      ~{if defined(bed_in) then "--bed_in '" + select_first([bed_in]) + "'" else ""} \
      ~{if defined(bed_out) then "--bed_out '" + select_first([bed_out]) + "'" else ""} \
      ~{if exclude_hla then "--exclude_hla" else ""} \
      --hla_mode "~{hla_mode}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}" \
      --fmt "~{fmt}"
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_filter_variant_types {
  input {
    File sumstats
    String filter_type
    String mode = "in"
    String out_filename = "filtered_type.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"

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

    python3 /opt/gwaslab_sumstats_filter_variant_types.py \
      --sumstats "~{sumstats}" \
      --filter_type "~{filter_type}" \
      --mode "~{mode}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}" \
      --fmt "~{fmt}"
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_search {
  input {
    File sumstats
    String action = "search"
    Array[String]? snplist
    Int windowsizekb = 500
    Int n_variants = 100
    File? vcf_path
    Float ld_threshold = 0.8
    String out_filename = "search_results.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"

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

    python3 /opt/gwaslab_sumstats_search.py \
      --sumstats "~{sumstats}" \
      --action "~{action}" \
      ~{if defined(snplist) then "--snplist " + sep(" ", select_first([snplist])) else ""} \
      --windowsizekb ~{windowsizekb} \
      --n_variants ~{n_variants} \
      ~{if defined(vcf_path) then "--vcf_path '" + select_first([vcf_path]) + "'" else ""} \
      --ld_threshold ~{ld_threshold} \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}" \
      --fmt "~{fmt}"
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

# ==============================================================================
# DOWNSTREAM TASKS
# ==============================================================================

task gwaslab_sumstats_get_lead {
  input {
    File sumstats
    String out_filename = "lead_variants.tsv"
    String fmt = "auto"
    Int windowsizekb = 500
    Float sig_level = 5e-8
    Boolean anno = false
    Boolean wc_correction = false

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

    python3 /opt/gwaslab_sumstats_get_lead.py \
      --sumstats "~{sumstats}" \
      --fmt "~{fmt}" \
      --out "~{out_filename}" \
      --windowsizekb ~{windowsizekb} \
      --sig_level ~{sig_level} \
      ~{if anno then "--anno" else ""} \
      ~{if wc_correction then "--wc_correction" else ""}
  >>>

  output {
    File lead_tsv = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_get_top {
  input {
    File sumstats
    String action = "top"
    String by = "DENSITY"
    File? known
    Array[String]? efo
    Boolean only_novel = false
    Int windowsizekb = 500
    String out_filename = "top_variants.tsv"
    String fmt = "auto"

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

    python3 /opt/gwaslab_sumstats_get_top.py \
      --sumstats "~{sumstats}" \
      --action "~{action}" \
      --by "~{by}" \
      ~{if defined(known) then "--known '" + select_first([known]) + "'" else ""} \
      ~{if defined(efo) then "--efo " + sep(" ", select_first([efo])) else ""} \
      ~{if only_novel then "--only_novel" else ""} \
      --windowsizekb ~{windowsizekb} \
      --fmt "~{fmt}" \
      --out "~{out_filename}"
  >>>

  output {
    File results_tsv = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_anno_gene {
  input {
    File sumstats
    String out_filename = "gene_annotated.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"

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

    python3 /opt/gwaslab_sumstats_anno_gene.py \
      --sumstats "~{sumstats}" \
      --fmt "~{fmt}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}"
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_get_per_snp_r2 {
  input {
    File sumstats
    String action = "r2"
    String mode = "q"
    String vary = "1.0"
    Float? prevalence
    String out_filename = "snp_r2.tsv.gz"
    String out_fmt = "gwaslab"
    String fmt = "auto"

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

    python3 /opt/gwaslab_sumstats_get_per_snp_r2.py \
      --sumstats "~{sumstats}" \
      --action "~{action}" \
      --mode "~{mode}" \
      --vary "~{vary}" \
      ~{if defined(prevalence) then "--prevalence " + select_first([prevalence]) else ""} \
      --fmt "~{fmt}" \
      --out "~{out_filename}" \
      --out_fmt "~{out_fmt}"
  >>>

  output {
    File out_sumstats = glob("~{out_filename}*")[0]
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_get_gc {
  input {
    File sumstats
    String mode = "P"
    Boolean include_chrXYMT = false
    String fmt = "auto"

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

    python3 /opt/gwaslab_sumstats_get_gc.py \
      --sumstats "~{sumstats}" \
      --mode "~{mode}" \
      ~{if include_chrXYMT then "--include_chrXYMT" else ""} \
      --fmt "~{fmt}"
  >>>

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_infer_ancestry {
  input {
    File sumstats
    String? ancestry_af
    String fmt = "auto"

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

    python3 /opt/gwaslab_sumstats_infer_ancestry.py \
      --sumstats "~{sumstats}" \
      ~{if defined(ancestry_af) then "--ancestry_af '" + select_first([ancestry_af]) + "'" else ""} \
      --fmt "~{fmt}"
  >>>

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_abf_finemapping {
  input {
    File sumstats
    String out_prefix = "abf_finemapping"
    String? region
    String? snpid_target
    String fmt = "auto"

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

    python3 /opt/gwaslab_sumstats_abf_finemapping.py \
      --sumstats "~{sumstats}" \
      --out_prefix "~{out_prefix}" \
      ~{if defined(region) then "--region '" + select_first([region]) + "'" else ""} \
      ~{if defined(snpid_target) then "--snpid_target '" + select_first([snpid_target]) + "'" else ""} \
      --fmt "~{fmt}"
  >>>

  output {
    File? abf_results_tsv = "~{out_prefix}.abf_results.tsv"
    File? credible_sets_tsv = "~{out_prefix}.credible_sets.tsv"
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_clump {
  input {
    File sumstats
    String out_prefix = "clumped_output"
    File? bfile
    File? pfile
    File? vcf
    Float clump_p1 = 5e-8
    Float clump_p2 = 1e-5
    Float clump_r2 = 0.1
    Int clump_kb = 250
    Int threads = 4

    # Runtime parameters
    String docker_image = "rtibiocloud/gwaslab:v4.2.2_a5d9ccd"
    String ecr_image = "rtibiocloud/gwaslab:v4.2.2_a5d9ccd"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 4
    Int mem_gb = 16
  }

  command <<<
    set -euo pipefail

    python3 /opt/gwaslab_sumstats_clump.py \
      --sumstats "~{sumstats}" \
      --out "~{out_prefix}" \
      ~{if defined(bfile) then "--bfile '" + select_first([bfile]) + "'" else ""} \
      ~{if defined(pfile) then "--pfile '" + select_first([pfile]) + "'" else ""} \
      ~{if defined(vcf) then "--vcf '" + select_first([vcf]) + "'" else ""} \
      --clump_p1 ~{clump_p1} \
      --clump_p2 ~{clump_p2} \
      --clump_r2 ~{clump_r2} \
      --clump_kb ~{clump_kb} \
      --threads ~{threads}
  >>>

  output {
    File? clumped_tsv = "~{out_prefix}.clumped.tsv"
    File? clumps_tsv = "~{out_prefix}.clumps.tsv"
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_sumstats_ldsc {
  input {
    File sumstats
    String ref_ld_chr
    String w_ld_chr
    String out_filename = "ldsc_results.tsv"
    String action = "h2"
    Array[File]? other_sumstats
    Float? samp_prev
    Float? pop_prev
    String fmt = "auto"

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

    python3 /opt/gwaslab_sumstats_ldsc.py \
      --sumstats "~{sumstats}" \
      --action "~{action}" \
      --ref_ld_chr "~{ref_ld_chr}" \
      --w_ld_chr "~{w_ld_chr}" \
      ~{if defined(other_sumstats) then "--other_sumstats " + sep(" ", select_first([other_sumstats])) else ""} \
      ~{if defined(samp_prev) then "--samp_prev " + select_first([samp_prev]) else ""} \
      ~{if defined(pop_prev) then "--pop_prev " + select_first([pop_prev]) else ""} \
      --fmt "~{fmt}" \
      --out "~{out_filename}"
  >>>

  output {
    File ldsc_tsv = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

