version development

task gsem_munge {
  input {
    Array[File] sumstats_files
    Array[String] trait_names
    Array[Int] sample_sizes
    File ref_snp_list
    String out_dir = "munge_out"
    Float info_filter = 0.9
    Float maf_filter = 0.01
    Boolean parallel = false
    Int cores = 1
    Boolean no_overwrite = false
    String docker_image = "rtibiocloud/genomic_sem:v0.0.5c_1b51f08"
    String ecr_image = "rtibiocloud/genomic_sem:v0.0.5c_1b51f08"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 1
    Int mem_gb = 8
  }

  parameter_meta {
    sumstats_files: "Input GWAS summary statistics files (comma-separated list in R wrapper)."
    trait_names: "Trait labels corresponding to sumstats_files."
    sample_sizes: "Per-trait sample sizes (N)."
    ref_snp_list: "Reference SNP list (HM3), passed to munge() as hm3."
    out_dir: "Output directory for munged .sumstats.gz files."
    info_filter: "INFO/R2 threshold for filtering summary statistics."
    maf_filter: "Minor allele frequency threshold for filtering summary statistics."
    parallel: "Enable parallel processing in GenomicSEM munge()."
    cores: "Number of cores when parallel processing is enabled."
    no_overwrite: "If true, do not overwrite existing munged outputs."
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

    Rscript /opt/gsem_munge.R \
      --sumstats_files "~{sep(",", sumstats_files)}" \
      --trait_names "~{sep(",", trait_names)}" \
      --sample_sizes "~{sep(",", prefix("", sample_sizes))}" \
      --ref_snp_list "~{ref_snp_list}" \
      --out_dir "~{out_dir}" \
      --info_filter ~{info_filter} \
      --maf_filter ~{maf_filter} \
      ~{if parallel then "--parallel" else ""} \
      --cores ~{cores} \
      ~{if no_overwrite then "--no_overwrite" else ""}
  >>>

  output {
    Array[File] munged_sumstats = glob(out_dir + "/*.sumstats.gz")
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb}G"
  }
}

task gsem_ldsc {
  input {
    Array[File] sumstats_files
    Array[String] trait_names
    Array[Float] sample_prevs
    Array[Float] population_prevs
    Directory ld_dir
    Directory wld_dir
    String output_prefix = "ldsc/gsem_ldsc_output"
    String docker_image = "rtibiocloud/genomic_sem:v0.0.5c_1b51f08"
    String ecr_image = "rtibiocloud/genomic_sem:v0.0.5c_1b51f08"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 1
    Int mem_gb = 8
  }

  parameter_meta {
    sumstats_files: "Input munged summary statistics files for LDSC."
    trait_names: "Trait labels corresponding to sumstats_files."
    sample_prevs: "Sample prevalences per trait."
    population_prevs: "Population prevalences per trait."
    ld_dir: "Directory containing LD score files."
    wld_dir: "Directory containing LD score weights."
    output_prefix: "Output prefix used for LDSC .rds and .log files."
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

    Rscript /opt/gsem_ldsc.R \
      --sumstats_files "~{sep(",", sumstats_files)}" \
      --trait_names "~{sep(",", trait_names)}" \
      --sample_prevs "~{sep(",", prefix("", sample_prevs))}" \
      --population_prevs "~{sep(",", prefix("", population_prevs))}" \
      --ld_dir "~{to_string(ld_dir)}" \
      --wld_dir "~{to_string(wld_dir)}" \
      --output_prefix "~{output_prefix}"
  >>>

  output {
    File ldsc_rds = output_prefix + ".rds"
    File ldsc_log = output_prefix + ".log"
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb}G"
  }
}

task gsem_s_ldsc {
  input {
    Array[File] sumstats_files
    Array[String] trait_names
    Array[Float] sample_prevs
    Array[Float] population_prevs
    Directory ld_dir
    Directory wld_dir
    Directory frq_dir
    String output_prefix = "s_ldsc/gsem_s_ldsc_output"
    Int n_blocks = 200
    Boolean include_cont = false
    String docker_image = "rtibiocloud/genomic_sem:v0.0.5c_1b51f08"
    String ecr_image = "rtibiocloud/genomic_sem:v0.0.5c_1b51f08"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 1
    Int mem_gb = 8
  }

  parameter_meta {
    sumstats_files: "Input munged summary statistics files for stratified LDSC."
    trait_names: "Trait labels corresponding to sumstats_files."
    sample_prevs: "Sample prevalences per trait."
    population_prevs: "Population prevalences per trait."
    ld_dir: "Directory containing partitioned LD scores."
    wld_dir: "Directory containing LD score weights."
    frq_dir: "Directory containing allele frequency files used by s_ldsc (frq argument)."
    output_prefix: "Output prefix used for S-LDSC .rds and .log files."
    n_blocks: "Number of jackknife blocks for standard error estimation."
    include_cont: "If true, include continuous annotations (exclude_cont = false)."
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

    Rscript /opt/gsem_s_ldsc.R \
      --sumstats_files "~{sep(",", sumstats_files)}" \
      --trait_names "~{sep(",", trait_names)}" \
      --sample_prevs "~{sep(",", prefix("", sample_prevs))}" \
      --population_prevs "~{sep(",", prefix("", population_prevs))}" \
      --ld_dir "~{to_string(ld_dir)}" \
      --wld_dir "~{to_string(wld_dir)}" \
      --frq_dir "~{to_string(frq_dir)}" \
      --output_prefix "~{output_prefix}" \
      --n_blocks ~{n_blocks} \
      ~{if include_cont then "--include_cont" else ""}
  >>>

  output {
    File s_ldsc_rds = output_prefix + ".rds"
    File s_ldsc_log = output_prefix + ".log"
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb}G"
  }
}

task gsem_sumstats {
  input {
    Array[File] sumstats_files
    Array[String] trait_names
    Array[Int] sample_sizes
    Array[Boolean] se_logit
    File ref_snp_list
    String output_prefix = "sumstats/gsem_sumstats_output"
    Array[String]? ols
    Array[String]? linprob
    Array[String]? betas
    Float info_filter = 0.9
    Float maf_filter = 0.01
    Boolean keep_indel = false
    Boolean parallel = false
    Int cores = 1
    String docker_image = "rtibiocloud/genomic_sem:v0.0.5c_1b51f08"
    String ecr_image = "rtibiocloud/genomic_sem:v0.0.5c_1b51f08"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 1
    Int mem_gb = 8
  }

  parameter_meta {
    sumstats_files: "Input GWAS summary statistics files for sumstats()."
    trait_names: "Trait labels corresponding to sumstats_files."
    sample_sizes: "Per-trait sample sizes (N)."
    se_logit: "Per-trait indicator that standard errors are on the logistic scale."
    ref_snp_list: "Reference SNP list (HM3), passed to sumstats() as ref."
    output_prefix: "Output prefix for sumstats .rds result."
    ols: "Optional per-trait OLS indicator for continuous outcomes."
    linprob: "Optional per-trait linear probability model indicator."
    betas: "Optional beta column names for standardized continuous traits."
    info_filter: "INFO/R2 threshold for filtering summary statistics."
    maf_filter: "Minor allele frequency threshold for filtering summary statistics."
    keep_indel: "If true, keep indels in processed summary statistics."
    parallel: "Enable parallel processing in sumstats()."
    cores: "Number of cores when parallel processing is enabled."
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

    Rscript /opt/gsem_sumstats.R \
      --sumstats_files "~{sep(",", sumstats_files)}" \
      --trait_names "~{sep(",", trait_names)}" \
      --sample_sizes "~{sep(",", prefix("", sample_sizes))}" \
      --se_logit "~{sep(",", prefix("", se_logit))}" \
      --ref_snp_list "~{ref_snp_list}" \
      --output_prefix "~{output_prefix}" \
      --info_filter ~{info_filter} \
      --maf_filter ~{maf_filter} \
      ~{if defined(ols) then "--ols \"~{sep(",", select_first([ols]))}\"" else ""} \
      ~{if defined(linprob) then "--linprob \"~{sep(",", select_first([linprob]))}\"" else ""} \
      ~{if defined(betas) then "--betas \"~{sep(",", select_first([betas]))}\"" else ""} \
      ~{if keep_indel then "--keep_indel" else ""} \
      ~{if parallel then "--parallel" else ""} \
      --cores ~{cores}
  >>>

  output {
    File sumstats_rds = output_prefix + ".rds"
    File sumstats_tsv = output_prefix + ".txt"
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb}G"
  }
}

task gsem_commonfactor {
  input {
    File ldsc_rds
    String estimation_method = "DWLS"
    String output_prefix = "commonfactor/gsem_commonfactor_output"
    String docker_image = "rtibiocloud/genomic_sem:v0.0.5c_1b51f08"
    String ecr_image = "rtibiocloud/genomic_sem:v0.0.5c_1b51f08"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 1
    Int mem_gb = 8
  }

  parameter_meta {
    ldsc_rds: "RDS containing LDSC covariance structure output."
    estimation_method: "Estimation method for GenomicSEM commonfactor() (for example, DWLS)."
    output_prefix: "Output prefix for common factor model .rds result."
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

    Rscript /opt/gsem_commonfactor.R \
      --ldsc_rds "~{ldsc_rds}" \
      --estimation_method "~{estimation_method}" \
      --output_prefix "~{output_prefix}"
  >>>

  output {
    File commonfactor_rds = output_prefix + ".rds"
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb}G"
  }
}

task gsem_commonfactorgwas {
  input {
    File ldsc_rds
    File sumstats
    String estimation_method = "DWLS"
    String output_prefix = "commonfactorgwas/gsem_commonfactorgwas_output"
    Float? toler
    Float? snpse
    String gc = "standard"
    Boolean mpi = false
    Boolean smooth_check = false
    Boolean twas = false
    Boolean parallel = false
    Int cores = 1
    String docker_image = "rtibiocloud/genomic_sem:v0.0.5c_1b51f08"
    String ecr_image = "rtibiocloud/genomic_sem:v0.0.5c_1b51f08"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 1
    Int mem_gb = 8
  }

  parameter_meta {
    ldsc_rds: "RDS containing LDSC covariance structure output."
    sumstats: "Summary statistics file (RDS or table format) consumed by userGWAS()."
    estimation_method: "Estimation method for common-factor GWAS (for example, DWLS)."
    output_prefix: "Output prefix for common-factor GWAS .rds result."
    toler: "Optional matrix inversion tolerance passed to userGWAS()."
    snpse: "Optional SNP standard error override passed to userGWAS()."
    gc: "Genomic control mode: standard, conserv, or none."
    mpi: "Enable MPI/multi-node mode in userGWAS()."
    smooth_check: "Enable smoothing diagnostics in userGWAS()."
    twas: "Enable TWAS mode in userGWAS()."
    parallel: "Enable parallel processing in userGWAS()."
    cores: "Number of cores when parallel processing is enabled."
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

    Rscript /opt/gsem_commonfactorgwas.R \
      --ldsc_rds "~{ldsc_rds}" \
      --sumstats "~{sumstats}" \
      --estimation_method "~{estimation_method}" \
      --output_prefix "~{output_prefix}" \
      --gc "~{gc}" \
      ~{if defined(toler) then "--toler ~{select_first([toler])}" else ""} \
      ~{if defined(snpse) then "--snpse ~{select_first([snpse])}" else ""} \
      ~{if mpi then "--mpi" else ""} \
      ~{if smooth_check then "--smooth_check" else ""} \
      ~{if twas then "--twas" else ""} \
      ~{if parallel then "--parallel" else ""} \
      --cores ~{cores}
  >>>

  output {
    File commonfactorgwas_rds = output_prefix + ".rds"
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb}G"
  }
}

task gsem_usergwas {
  input {
    File ldsc_rds
    File sumstats
    File model_lavaan
    String estimation_method = "DWLS"
    String output_prefix = "usergwas/gsem_usergwas_output"
    Boolean not_printwarn = false
    Array[String]? sub
    Float? toler
    Float? snpse
    String gc = "standard"
    Boolean mpi = false
    Boolean smooth_check = false
    Boolean twas = false
    Boolean std_lv = false
    Boolean not_fix_measurement = false
    Boolean q_snp = false
    Boolean parallel = false
    Int cores = 1
    String docker_image = "rtibiocloud/genomic_sem:v0.0.5c_1b51f08"
    String ecr_image = "rtibiocloud/genomic_sem:v0.0.5c_1b51f08"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 1
    Int mem_gb = 8
  }

  parameter_meta {
    ldsc_rds: "RDS containing LDSC covariance structure output."
    sumstats: "Summary statistics file (RDS or table format) consumed by userGWAS()."
    model_lavaan: "Lavaan model file defining the user GWAS model."
    estimation_method: "Estimation method for userGWAS (for example, DWLS)."
    output_prefix: "Output prefix for user-model GWAS .rds result."
    not_printwarn: "If true, suppress per-SNP lavaan warnings/errors in output."
    sub: "Optional subset of model components to return; values must match model lines."
    toler: "Optional matrix inversion tolerance passed to userGWAS()."
    snpse: "Optional SNP standard error override passed to userGWAS()."
    gc: "Genomic control mode: standard, conserv, or none."
    mpi: "Enable MPI/multi-node mode in userGWAS()."
    smooth_check: "Enable smoothing diagnostics in userGWAS()."
    twas: "Enable TWAS mode in userGWAS()."
    std_lv: "If true, set latent variables to unit variance."
    not_fix_measurement: "If true, do not fix measurement model across SNPs."
    q_snp: "If true, compute Q_SNP statistics."
    parallel: "Enable parallel processing in userGWAS()."
    cores: "Number of cores when parallel processing is enabled."
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

    Rscript /opt/gsem_usergwas.R \
      --ldsc_rds "~{ldsc_rds}" \
      --sumstats "~{sumstats}" \
      --model_lavaan "~{model_lavaan}" \
      --estimation_method "~{estimation_method}" \
      --output_prefix "~{output_prefix}" \
      --gc "~{gc}" \
      ~{if not_printwarn then "--not_printwarn" else ""} \
      ~{if defined(sub) then "--sub \"~{sep(",", select_first([sub]))}\"" else ""} \
      ~{if defined(toler) then "--toler ~{select_first([toler])}" else ""} \
      ~{if defined(snpse) then "--snpse ~{select_first([snpse])}" else ""} \
      ~{if mpi then "--mpi" else ""} \
      ~{if smooth_check then "--smooth_check" else ""} \
      ~{if twas then "--twas" else ""} \
      ~{if std_lv then "--std_lv" else ""} \
      ~{if not_fix_measurement then "--not_fix_measurement" else ""} \
      ~{if q_snp then "--q_snp" else ""} \
      ~{if parallel then "--parallel" else ""} \
      --cores ~{cores}
  >>>

  output {
    File usergwas_rds = output_prefix + ".rds"
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb}G"
  }
}

task gsem_usermodel {
  input {
    File ldsc_rds
    File model_lavaan
    String estimation_method
    String output_prefix = "usermodel/gsem_usermodel_output"
    Boolean cficalc = false
    Boolean std_lv = false
    Boolean imp_cov = false
    Boolean fix_resid = false
    Float? toler
    Boolean q_factor = false
    String docker_image = "rtibiocloud/genomic_sem:v0.0.5c_1b51f08"
    String ecr_image = "rtibiocloud/genomic_sem:v0.0.5c_1b51f08"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 1
    Int mem_gb = 8
  }

  parameter_meta {
    ldsc_rds: "RDS containing LDSC covariance structure output."
    model_lavaan: "Lavaan model file for usermodel()."
    estimation_method: "Estimation method for usermodel (for example, DWLS)."
    output_prefix: "Output prefix for usermodel .rds result."
    cficalc: "If true, compute CFI for the user model."
    std_lv: "If true, use unit-variance identification for latent variables."
    imp_cov: "If true, include implied and residual covariance matrices in output."
    fix_resid: "If true, constrain residual variances above zero to aid convergence."
    toler: "Optional tolerance used for matrix inversion in standard errors."
    q_factor: "If true, compute heterogeneity statistic for factor correlations."
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

    Rscript /opt/gsem_usermodel.R \
      --ldsc_rds "~{ldsc_rds}" \
      --model_lavaan "~{model_lavaan}" \
      --estimation_method "~{estimation_method}" \
      --output_prefix "~{output_prefix}" \
      ~{if cficalc then "--cficalc" else ""} \
      ~{if std_lv then "--std_lv" else ""} \
      ~{if imp_cov then "--imp_cov" else ""} \
      ~{if fix_resid then "--fix_resid" else ""} \
      ~{if defined(toler) then "--toler ~{select_first([toler])}" else ""} \
      ~{if q_factor then "--q_factor" else ""}
  >>>

  output {
    File usermodel_rds = output_prefix + ".rds"
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb}G"
  }
}

task gsem_enrich {
  input {
    File s_ldsc_rds
    File model_lavaan
    File params
    String output_prefix = "enrich/gsem_enrich_output"
    String fix = "regressions"
    Boolean std_lv = false
    Boolean not_rm_flank = false
    Boolean tau = false
    Boolean not_base = false
    Float? toler
    File? fixparam
    String docker_image = "rtibiocloud/genomic_sem:v0.0.5c_1b51f08"
    String ecr_image = "rtibiocloud/genomic_sem:v0.0.5c_1b51f08"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 1
    Int mem_gb = 8
  }

  parameter_meta {
    s_ldsc_rds: "RDS containing stratified LDSC covariance structure output."
    model_lavaan: "Lavaan model file used for enrichment estimation."
    params: "File listing target lavaan parameter expressions to estimate enrichment for."
    output_prefix: "Output prefix for enrich .rds result."
    fix: "Parameter class to fix from baseline fit (regressions, variances, covariances)."
    std_lv: "If true, use unit-variance identification for latent variables."
    not_rm_flank: "If true, keep flanking-window and continuous annotations in output."
    tau: "If true, use tau matrices instead of zero-order matrices."
    not_base: "If true, exclude baseline model estimates from output."
    toler: "Optional matrix inversion tolerance passed to enrich()."
    fixparam: "Optional file listing parameters to fix during annotation-level estimation."
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

    Rscript /opt/gsem_enrich.R \
      --s_ldsc_rds "~{s_ldsc_rds}" \
      --model_lavaan "~{model_lavaan}" \
      --params "~{params}" \
      --output_prefix "~{output_prefix}" \
      --fix "~{fix}" \
      ~{if std_lv then "--std_lv" else ""} \
      ~{if not_rm_flank then "--not_rm_flank" else ""} \
      ~{if tau then "--tau" else ""} \
      ~{if not_base then "--not_base" else ""} \
      ~{if defined(toler) then "--toler ~{select_first([toler])}" else ""} \
      ~{if defined(fixparam) then "--fixparam \"~{select_first([fixparam])}\"" else ""}
  >>>

  output {
    File enrich_rds = output_prefix + ".rds"
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb}G"
  }
}

task gsem_merge_rds {
  input {
    Array[File] rds_files
    String output_prefix = "merged/gsem_merged_output"
    String docker_image = "rtibiocloud/genomic_sem:v0.0.5c_1b51f08"
    String ecr_image = "rtibiocloud/genomic_sem:v0.0.5c_1b51f08"
    String? ecr_repo
    String image_source = "docker"
    String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
    Int cpu = 1
    Int mem_gb = 8
  }

  parameter_meta {
    rds_files: "Input RDS files to merge into a single RDS."
    output_prefix: "Output prefix used for merged .rds and optional .txt files."
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

    Rscript /opt/gsem_merge_rds.R \
      --rds_files "~{sep(",", rds_files)}" \
      --output_prefix "~{output_prefix}"
  >>>

  output {
    File merged_rds = output_prefix + ".rds"
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb}G"
  }
}
