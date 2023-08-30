task assign_ancestry_mahalanobis {

    File file_pcs
    Int pc_count = 10
    String dataset
    String dataset_legend_label
    Array[String] ref_pops
    Array[String] ref_pops_legend_labels
    Int use_pcs_count = 10
    String midpoint_formula = "median"

    # Runtime environment
    String docker = "rtibiocloud/assign_ancestry_mahalanobis:v1_7e53dc6"
    String ecr = ""
    String container_source = "docker"
    String container_image = if(container_source == "docker") then docker else ecr
    Int cpu = 1
    Int mem_gb = 2
    Int max_retries = 3

    command{
        Rscript /opt/assign_ancestry_mahalanobis.R \
            --file-pcs "${file_pcs}" \
            --pc-count ${pc_count} \
            --dataset "${dataset}" \
            --dataset-legend-label "${dataset_legend_label}" \
            --ref-pops "${sep=',' ref_pops}" \
            --ref-pops-legend-labels "${sep=',' ref_pops_legend_labels}" \
            --out-dir "" \
            --use-pcs-count ${use_pcs_count} \
            --midpoint-formula "${midpoint_formula}"
    }

    runtime{
        docker: container_image
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output {
        Array[File] pre_processing_pc_plots  = glob("*_pc1_pc2_pc3.png")
        File ref_dropped_samples  = "ref_dropped_samples.tsv"
        File ref_raw_ancestry_assignments = "ref_raw_ancestry_assignments.tsv"
        File ref_raw_ancestry_assignments_summary = "ref_raw_ancestry_assignments_summary.tsv"
        Array[File] dataset_ancestry_assignments = glob("${dataset}*ancestry_assignments.tsv")
        File dataset_ancestry_assignments_summary = "${dataset}_ancestry_assignments_summary.tsv"
        Array[File] dataset_ancestry_assignments_plots = glob("${dataset}*ancestry_assignments.png")
        Array[File] dataset_ancestry_outliers_plots = glob("${dataset}*outliers.png")
        Array[File] dataset_2_stddev_keep_lists = glob("${dataset}*2_stddev_keep.tsv")
        Array[File] dataset_3_stddev_keep_lists = glob("${dataset}*3_stddev_keep.tsv")
        Array[File] dataset_4_stddev_keep_lists = glob("${dataset}*4_stddev_keep.tsv")
    }
}
