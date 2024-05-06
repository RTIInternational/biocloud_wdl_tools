import "biocloud_wdl_tools/assign_ancestry_mahalanobis/assign_ancestry_mahalanobis.wdl" as ANCESTRY

workflow test_assign_ancestry_mahalanobis{

    File file_pcs
    Int pc_count = 10
    String dataset
    String dataset_legend_label
    Array[String] ref_pops
    Array[String] ref_pops_legend_labels
    Int use_pcs_count = 10
    String midpoint_formula = "median"
    Int std_dev_cutoff = 3

    call ANCESTRY.assign_ancestry_mahalanobis{
        input:
            file_pcs = file_pcs,
            pc_count = pc_count,
            dataset = dataset,
            dataset_legend_label = dataset_legend_label,
            ref_pops = ref_pops,
            ref_pops_legend_labels = ref_pops_legend_labels,
            use_pcs_count = use_pcs_count,
            midpoint_formula = midpoint_formula,
            std_dev_cutoff = 3
    }

    output{
        Array[File] pre_processing_pc_plots = assign_ancestry_mahalanobis.pre_processing_pc_plots
        File ref_dropped_samples  = assign_ancestry_mahalanobis.ref_dropped_samples
        File ref_raw_ancestry_assignments = assign_ancestry_mahalanobis.ref_raw_ancestry_assignments
        File ref_raw_ancestry_assignments_summary = assign_ancestry_mahalanobis.ref_raw_ancestry_assignments_summary
        File dataset_ancestry_assignments = assign_ancestry_mahalanobis.dataset_ancestry_assignments
        File dataset_ancestry_assignments_summary = assign_ancestry_mahalanobis.dataset_ancestry_assignments_summary
        Array[File] dataset_ancestry_assignments_plots = assign_ancestry_mahalanobis.dataset_ancestry_assignments_plots
        Array[File] dataset_ancestry_outliers_plots = assign_ancestry_mahalanobis.dataset_ancestry_outliers_plots
        Array[File] dataset_ancestry_keep_lists = assign_ancestry_mahalanobis.dataset_ancestry_keep_lists
    }
}

