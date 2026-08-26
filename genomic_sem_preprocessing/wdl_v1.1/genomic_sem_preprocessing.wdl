version 1.1

task genomic_sem_preprocessing {
  input {
    File sumstats_file
    String col_variant_id
    String col_effect_allele
    String col_non_effect_allele
    String col_effect
    String col_p
    String out_file
    
    # Optional parameters
    String? col_z
    String? col_se
    String? col_n
    String? col_effect_allele_freq
    String? col_info
    String? col_direction
    String sumstats_sep = "\t"
    
    # Runtime parameters
    String docker_image = "genomic-sem-preprocessing:v1"
    String ecr_image = "genomic-sem-preprocessing:v1"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 1
    Int mem_gb = 4
  }

  parameter_meta {
    sumstats_file: "Input summary statistics file (text-based, delimited format)."
    col_variant_id: "Column name containing variant identifiers; rsID will be extracted if present."
    col_effect_allele: "Column name containing the effect allele (A1/ALT)."
    col_non_effect_allele: "Column name containing the non-effect allele (A2/REF)."
    col_effect: "Column name containing the effect size estimate (beta/log odds)."
    col_p: "Column name containing the association p-value."
    out_file: "Output file path; .gz extension will be appended if not present."
    col_z: "Optional column name containing Z-scores."
    col_se: "Optional column name containing standard errors."
    col_n: "Optional column name containing sample sizes."
    col_effect_allele_freq: "Optional column name containing effect allele frequencies (EAF/MAF)."
    col_info: "Optional column name containing imputation quality scores (INFO)."
    col_direction: "Optional column name containing directional effect information."
    sumstats_sep: "Field separator/delimiter in the input file (default: tab)."
    docker_image: "Docker image name/tag used when image_source is docker."
    ecr_image: "ECR image name/tag used when image_source is ecr."
    ecr_repo: "Optional ECR repository URI prefix used with ecr_image."
    image_source: "Container source selector: docker or ecr."
    container_image: "Resolved container image string used at runtime."
    cpu: "Requested CPU cores for the task runtime."
    mem_gb: "Requested memory for the task runtime in GB."
  }

  command <<<
    set -euo pipefail

    python3 /app/genomic_sem_preprocessing.py \
      --sumstats_file "~{sumstats_file}" \
      --col_variant_id "~{col_variant_id}" \
      --col_effect_allele "~{col_effect_allele}" \
      --col_non_effect_allele "~{col_non_effect_allele}" \
      --col_effect "~{col_effect}" \
      --col_p "~{col_p}" \
      --out_file "~{out_file}" \
      --sumstats_sep "~{sumstats_sep}" \
      ~{if defined(col_z) then "--col_z \"~{col_z}\"" else ""} \
      ~{if defined(col_se) then "--col_se \"~{col_se}\"" else ""} \
      ~{if defined(col_n) then "--col_n \"~{col_n}\"" else ""} \
      ~{if defined(col_effect_allele_freq) then "--col_effect_allele_freq \"~{col_effect_allele_freq}\"" else ""} \
      ~{if defined(col_info) then "--col_info \"~{col_info}\"" else ""} \
      ~{if defined(col_direction) then "--col_direction \"~{col_direction}\"" else ""}
  >>>

  output {
    File processed_sumstats = "~{out_file}.gz"
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb}G"
    disks: "local-disk 100 HDD"
  }
}
