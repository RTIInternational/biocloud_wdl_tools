version development

task gwaslab_plot_mqq {
  input {
    File sumstats
    String out_filename = "manhattan_qq.png"
    String mode = "mqq"
    String fmt = "auto"
    String build = "19"
    Float sig_level = 5e-8
    Float suggestive_sig_level = 5e-6
    Boolean suggestive_sig_line = false
    Float skip = 0.0
    Float cut = 0.0
    Boolean anno = false
    Int anno_max_rows = 40
    Array[String]? highlight
    Array[String] colors = ["#597FBD", "#74BAD3"]
    String? region
    File? vcf_path
    File? ld_path
    Boolean ld_block = false
    String? title
    String? mtitle
    String? qtitle
    String? fig_kwargs_json

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

    python3 /opt/gwaslab_plot_mqq.py \
      --sumstats "~{sumstats}" \
      --out "~{out_filename}" \
      --mode "~{mode}" \
      --fmt "~{fmt}" \
      --build "~{build}" \
      --sig_level ~{sig_level} \
      --suggestive_sig_level ~{suggestive_sig_level} \
      ~{if suggestive_sig_line then "--suggestive_sig_line" else ""} \
      --skip ~{skip} \
      --cut ~{cut} \
      ~{if anno then "--anno" else ""} \
      --anno_max_rows ~{anno_max_rows} \
      --colors ~{sep(" ", colors)} \
      ~{if defined(highlight) then "--highlight " + sep(" ", select_first([highlight])) else ""} \
      ~{if defined(region) then "--region '" + select_first([region]) + "'" else ""} \
      ~{if defined(vcf_path) then "--vcf_path '" + select_first([vcf_path]) + "'" else ""} \
      ~{if defined(ld_path) then "--ld_path '" + select_first([ld_path]) + "'" else ""} \
      ~{if ld_block then "--ld_block" else ""} \
      ~{if defined(title) then "--title '" + select_first([title]) + "'" else ""} \
      ~{if defined(mtitle) then "--mtitle '" + select_first([mtitle]) + "'" else ""} \
      ~{if defined(qtitle) then "--qtitle '" + select_first([qtitle]) + "'" else ""} \
      ~{if defined(fig_kwargs_json) then "--fig_kwargs_json '" + select_first([fig_kwargs_json]) + "'" else ""}
  >>>

  output {
    File plot_file = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_plot_compare_effect {
  input {
    File path1
    File path2
    String out_filename = "compare_effect.png"
    String mode = "scatter"
    String build = "19"
    Float sig_level = 5e-8
    Boolean anno = false
    Int anno_max_rows = 40
    String r_or_r2 = "r2"
    Boolean r_se = false
    Float null_beta = 0.0
    String legend_pos = "upper left"
    Boolean save_merged = false

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

    python3 /opt/gwaslab_plot_compare_effect.py \
      --path1 "~{path1}" \
      --path2 "~{path2}" \
      --out "~{out_filename}" \
      --mode "~{mode}" \
      --build "~{build}" \
      --sig_level ~{sig_level} \
      ~{if anno then "--anno" else ""} \
      --anno_max_rows ~{anno_max_rows} \
      --r_or_r2 "~{r_or_r2}" \
      ~{if r_se then "--r_se" else ""} \
      --null_beta ~{null_beta} \
      --legend_pos "~{legend_pos}" \
      ~{if save_merged then "--save_merged" else ""}
  >>>

  output {
    File plot_file = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_plot_miami2 {
  input {
    File path1
    File path2
    String out_filename = "miami_plot.png"
    Array[String]? titles
    String id1 = "Study 1"
    String id2 = "Study 2"
    String build = "19"
    Float sig_level = 5e-8
    Float suggestive_sig_level = 5e-6
    Boolean suggestive_sig_line = false
    Float skip = 0.0
    Float cut = 0.0
    Boolean anno = false
    Int anno_max_rows = 40
    Array[String]? highlight
    Array[String] colors = ["#597FBD", "#74BAD3"]

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

    python3 /opt/gwaslab_plot_miami2.py \
      --path1 "~{path1}" \
      --path2 "~{path2}" \
      --out "~{out_filename}" \
      --id1 "~{id1}" \
      --id2 "~{id2}" \
      --build "~{build}" \
      --sig_level ~{sig_level} \
      --suggestive_sig_level ~{suggestive_sig_level} \
      ~{if suggestive_sig_line then "--suggestive_sig_line" else ""} \
      --skip ~{skip} \
      --cut ~{cut} \
      ~{if anno then "--anno" else ""} \
      --anno_max_rows ~{anno_max_rows} \
      --colors ~{sep(" ", colors)} \
      ~{if defined(titles) then "--titles " + sep(" ", select_first([titles])) else ""} \
      ~{if defined(highlight) then "--highlight " + sep(" ", select_first([highlight])) else ""}
  >>>

  output {
    File plot_file = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_plot_forest {
  input {
    File data
    String out_filename = "forest_plot.png"
    String beta_col = "BETA"
    String se_col = "SE"
    String sep = "\t"
    String? study_col
    String? group_col
    String font_family = "Arial"
    Int fontsize = 12
    Array[String] colors = ["#597FBD", "#74BAD3"]

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

    python3 /opt/gwaslab_plot_forest.py \
      --data "~{data}" \
      --out "~{out_filename}" \
      --beta_col "~{beta_col}" \
      --se_col "~{se_col}" \
      --sep "~{sep}" \
      --font_family "~{font_family}" \
      --fontsize ~{fontsize} \
      --colors ~{sep(" ", colors)} \
      ~{if defined(study_col) then "--study_col '" + select_first([study_col]) + "'" else ""} \
      ~{if defined(group_col) then "--group_col '" + select_first([group_col]) + "'" else ""}
  >>>

  output {
    File plot_file = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_plot_ld_block {
  input {
    String region
    String out_filename = "ld_block.png"
    File? vcf_path
    File? ld_path
    File? sumstats
    String mode = "standalone"
    Boolean anno_cell = false
    String anno_cell_fmt = "{:.2f}"
    String cmap = "YlOrRd"
    Float vmin = 0.0
    Float vmax = 1.0
    Boolean ld_block_grid = false
    String? title

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

    python3 /opt/gwaslab_plot_ld_block.py \
      --region "~{region}" \
      --out "~{out_filename}" \
      --mode "~{mode}" \
      ~{if anno_cell then "--anno_cell" else ""} \
      --anno_cell_fmt "~{anno_cell_fmt}" \
      --cmap "~{cmap}" \
      --vmin ~{vmin} \
      --vmax ~{vmax} \
      ~{if ld_block_grid then "--ld_block_grid" else ""} \
      ~{if defined(vcf_path) then "--vcf_path '" + select_first([vcf_path]) + "'" else ""} \
      ~{if defined(ld_path) then "--ld_path '" + select_first([ld_path]) + "'" else ""} \
      ~{if defined(sumstats) then "--sumstats '" + select_first([sumstats]) + "'" else ""} \
      ~{if defined(title) then "--title '" + select_first([title]) + "'" else ""}
  >>>

  output {
    File plot_file = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_plot_lead_overlap {
  input {
    Array[File] sumstats_files
    String out_filename = "lead_overlap.png"
    Array[String]? titles
    String mode = "auto"
    String build = "19"
    Float sig_level = 5e-8
    Int windowsizekb = 500
    Int windowsizekb_for_overlap = 1000
    Boolean show_genes = true
    Boolean show_counts = true
    String sort_by = "count"

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

    python3 /opt/gwaslab_plot_lead_overlap.py \
      --sumstats_files ~{sep(" ", sumstats_files)} \
      --out "~{out_filename}" \
      --mode "~{mode}" \
      --build "~{build}" \
      --sig_level ~{sig_level} \
      --windowsizekb ~{windowsizekb} \
      --windowsizekb_for_overlap ~{windowsizekb_for_overlap} \
      ~{if show_genes then "--show_genes" else ""} \
      ~{if show_counts then "--show_counts" else ""} \
      --sort_by "~{sort_by}" \
      ~{if defined(titles) then "--titles " + sep(" ", select_first([titles])) else ""}
  >>>

  output {
    File plot_file = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_plot_power {
  input {
    String out_filename = "power_curves.png"
    String mode = "q"
    Boolean extended = false
    Array[Int] ns = [10000, 20000, 50000]
    Array[Int]? ncases
    Array[Int]? ncontrols
    Array[Float]? prevalences
    Array[Float] sig_levels = [5e-8]

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

    python3 /opt/gwaslab_plot_power.py \
      --out "~{out_filename}" \
      --mode "~{mode}" \
      ~{if extended then "--extended" else ""} \
      --ns ~{sep(" ", ns)} \
      --sig_levels ~{sep(" ", sig_levels)} \
      ~{if defined(ncases) then "--ncases " + sep(" ", select_first([ncases])) else ""} \
      ~{if defined(ncontrols) then "--ncontrols " + sep(" ", select_first([ncontrols])) else ""} \
      ~{if defined(prevalences) then "--prevalences " + sep(" ", select_first([prevalences])) else ""}
  >>>

  output {
    File plot_file = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_plot_rg {
  input {
    File ldscrg
    String out_filename = "rg_heatmap.png"
    String p = "p"
    String rg = "rg"
    String p1 = "p1"
    String p2 = "p2"
    String cmap = "RdBu_r"
    String fdr_method = "bh"
    Boolean square = false

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

    python3 /opt/gwaslab_plot_rg.py \
      --ldscrg "~{ldscrg}" \
      --out "~{out_filename}" \
      --p "~{p}" \
      --rg "~{rg}" \
      --p1 "~{p1}" \
      --p2 "~{p2}" \
      --cmap "~{cmap}" \
      --fdr_method "~{fdr_method}" \
      ~{if square then "--square" else ""}
  >>>

  output {
    File plot_file = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_plot_sankey {
  input {
    File sumstats
    Array[String] columns
    String out_filename = "sankey_plot.png"
    String sep = "\t"
    String? title
    String color_by = "first"
    String node_color_mode = "stacked"
    Float node_width = 0.025
    Float gap_frac = 0.02
    Float link_alpha = 0.55

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

    python3 /opt/gwaslab_plot_sankey.py \
      --sumstats "~{sumstats}" \
      --columns ~{sep(" ", columns)} \
      --out "~{out_filename}" \
      --sep "~{sep}" \
      --color_by "~{color_by}" \
      --node_color_mode "~{node_color_mode}" \
      --node_width ~{node_width} \
      --gap_frac ~{gap_frac} \
      --link_alpha ~{link_alpha} \
      ~{if defined(title) then "--title '" + select_first([title]) + "'" else ""}
  >>>

  output {
    File plot_file = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_plot_scatter {
  input {
    File sumstats
    String x
    String y
    String out_filename = "scatter_plot.png"
    String sep = "\t"
    String? title

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

    python3 /opt/gwaslab_plot_scatter.py \
      --sumstats "~{sumstats}" \
      --x "~{x}" \
      --y "~{y}" \
      --out "~{out_filename}" \
      --sep "~{sep}" \
      ~{if defined(title) then "--title '" + select_first([title]) + "'" else ""}
  >>>

  output {
    File plot_file = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_plot_stacked_mqq {
  input {
    Array[File] sumstats_files
    String out_filename = "stacked_mqq.png"
    Array[String]? titles
    String mode = "m"
    String? region
    File? vcf_path
    String build = "19"
    Float sig_level = 5e-8
    Float skip = 0.0
    Float cut = 0.0
    Array[String] colors = ["#597FBD", "#74BAD3"]

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

    python3 /opt/gwaslab_plot_stacked_mqq.py \
      --sumstats_files ~{sep(" ", sumstats_files)} \
      --out "~{out_filename}" \
      --mode "~{mode}" \
      --build "~{build}" \
      --sig_level ~{sig_level} \
      --skip ~{skip} \
      --cut ~{cut} \
      --colors ~{sep(" ", colors)} \
      ~{if defined(titles) then "--titles " + sep(" ", select_first([titles])) else ""} \
      ~{if defined(region) then "--region '" + select_first([region]) + "'" else ""} \
      ~{if defined(vcf_path) then "--vcf_path '" + select_first([vcf_path]) + "'" else ""}
  >>>

  output {
    File plot_file = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_plot_trumpet {
  input {
    File sumstats
    String out_filename = "trumpet_plot.png"
    String fmt = "auto"
    String mode = "q"
    String build = "19"
    Float sig_level = 5e-8
    Boolean anno = false
    Array[String]? highlight
    Int? n
    Int? ncase
    Int? ncontrol
    Float? prevalence
    String? title

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

    python3 /opt/gwaslab_plot_trumpet.py \
      --sumstats "~{sumstats}" \
      --out "~{out_filename}" \
      --fmt "~{fmt}" \
      --mode "~{mode}" \
      --build "~{build}" \
      --sig_level ~{sig_level} \
      ~{if anno then "--anno" else ""} \
      ~{if defined(highlight) then "--highlight " + sep(" ", select_first([highlight])) else ""} \
      ~{if defined(n) then "--n " + select_first([n]) else ""} \
      ~{if defined(ncase) then "--ncase " + select_first([ncase]) else ""} \
      ~{if defined(ncontrol) then "--ncontrol " + select_first([ncontrol]) else ""} \
      ~{if defined(prevalence) then "--prevalence " + select_first([prevalence]) else ""} \
      ~{if defined(title) then "--title '" + select_first([title]) + "'" else ""}
  >>>

  output {
    File plot_file = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_plot_phenogram {
  input {
    File sumstats
    String out_filename = "phenogram_plot.png"
    String fmt = "auto"
    String build = "19"
    Float sig_level = 5e-8
    Int windowsizekb = 500
    Int anno_max_rows = 200
    Boolean include_sex_chr = false

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

    python3 /opt/gwaslab_plot_phenogram.py \
      --sumstats "~{sumstats}" \
      --out "~{out_filename}" \
      --fmt "~{fmt}" \
      --build "~{build}" \
      --sig_level ~{sig_level} \
      --windowsizekb ~{windowsizekb} \
      --anno_max_rows ~{anno_max_rows} \
      ~{if include_sex_chr then "--include_sex_chr" else ""}
  >>>

  output {
    File plot_file = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_plot_daf {
  input {
    File sumstats
    String out_filename = "daf_plot.png"
    String fmt = "auto"
    String eaf = "EAF"
    String raf = "RAF"
    String daf = "DAF"
    Boolean r2 = false

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

    python3 /opt/gwaslab_plot_daf.py \
      --sumstats "~{sumstats}" \
      --out "~{out_filename}" \
      --fmt "~{fmt}" \
      --eaf "~{eaf}" \
      --raf "~{raf}" \
      --daf "~{daf}" \
      ~{if r2 then "--r2" else ""}
  >>>

  output {
    File plot_file = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_plot_gwheatmap {
  input {
    File sumstats
    String out_filename = "gwheatmap.png"
    String fmt = "auto"
    String group = "CIS/TRANS"
    Int cis_windowsizekb = 100
    Boolean add_b = false
    Array[String] colors = ["#597FBD", "#74BAD3"]

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

    python3 /opt/gwaslab_plot_gwheatmap.py \
      --sumstats "~{sumstats}" \
      --out "~{out_filename}" \
      --fmt "~{fmt}" \
      --group "~{group}" \
      --cis_windowsizekb ~{cis_windowsizekb} \
      ~{if add_b then "--add_b" else ""} \
      --colors ~{sep(" ", colors)}
  >>>

  output {
    File plot_file = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_plot_effect {
  input {
    File sumstats
    String x
    String y
    String out_filename = "effect_plot.png"
    String fmt = "auto"
    String se = "SE"
    String eaf = "EAF"
    Boolean eaf_panel = false
    Boolean snpvar_panel = false
    String? title

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

    python3 /opt/gwaslab_plot_effect.py \
      --sumstats "~{sumstats}" \
      --x "~{x}" \
      --y "~{y}" \
      --out "~{out_filename}" \
      --fmt "~{fmt}" \
      --se "~{se}" \
      --eaf "~{eaf}" \
      ~{if eaf_panel then "--eaf_panel" else ""} \
      ~{if snpvar_panel then "--snpvar_panel" else ""} \
      ~{if defined(title) then "--title '" + select_first([title]) + "'" else ""}
  >>>

  output {
    File plot_file = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_plot_pipcs {
  input {
    File sumstats
    String out_filename = "pipcs_plot.png"
    String fmt = "auto"
    String? region
    String? locus
    String pip = "PIP"
    String cs = "CREDIBLE_SET_INDEX"
    Boolean onlycs = false
    String? title

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

    python3 /opt/gwaslab_plot_pipcs.py \
      --sumstats "~{sumstats}" \
      --out "~{out_filename}" \
      --fmt "~{fmt}" \
      --pip "~{pip}" \
      --cs "~{cs}" \
      ~{if onlycs then "--onlycs" else ""} \
      ~{if defined(region) then "--region '" + select_first([region]) + "'" else ""} \
      ~{if defined(locus) then "--locus '" + select_first([locus]) + "'" else ""} \
      ~{if defined(title) then "--title '" + select_first([title]) + "'" else ""}
  >>>

  output {
    File plot_file = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}

task gwaslab_plot_associations {
  input {
    File sumstats
    String out_filename = "associations_heatmap.png"
    String fmt = "auto"
    String values = "Beta"
    String sort = "P_GCV2"
    String cmap = "RdBu"
    String? title

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

    python3 /opt/gwaslab_plot_associations.py \
      --sumstats "~{sumstats}" \
      --out "~{out_filename}" \
      --fmt "~{fmt}" \
      --values "~{values}" \
      --sort "~{sort}" \
      --cmap "~{cmap}" \
      ~{if defined(title) then "--title '" + select_first([title]) + "'" else ""}
  >>>

  output {
    File plot_file = out_filename
  }

  runtime {
    docker: container_image
    cpu: cpu
    memory: "~{mem_gb} GB"
  }
}
