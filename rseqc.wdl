task RseQC_bam_stat {
    File bam
    File bam_index
    Int map_qual = 30
    String output_basename

    # Runtime environment
    String docker = "rticode/rseqc:3.0.0"
    Int cpu = 2
    Int mem_gb = ceil(size(bam, "GiB") * 2)
    Int max_retries = 3

    command <<<
        bam_stat.py -i ${bam} \
            -q ${map_qual} \
            > ${output_basename}.bam_stat.log 2>&1
   >>>

   runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
   }

   output{
        File rseqc_log = "${output_basename}.bam_stat.log"
   }
}

task RseQC_infer_experiment {
    File bam
    File bam_index
    File ref_bed
    Int sample_size = 200000
    Int map_qual = 30
    String output_basename

    # Runtime environment
    String docker = "rticode/rseqc:3.0.0"
    Int cpu = 2
    Int mem_gb = ceil((size(bam, "GiB") * 2) + (size(ref_bed, "GiB")*2))
    Int max_retries = 3

    command <<<
        infer_experiment.py -i ${bam} \
            -q ${map_qual} \
            -r ${ref_bed} \
            -s ${sample_size} \
            > ${output_basename}.infer_experiment.txt
   >>>

   runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
   }

   output{
        File rseqc_log = "${output_basename}.infer_experiment.txt"
   }
}

task RseQC_inner_distance{
    File bam
    File bam_index
    File ref_bed
    Int sample_size = 1000000
    Int map_qual = 30
    Int lower_bound = -250
    Int upper_bound = 250
    Int step_size = 5
    String output_basename

    # Runtime environment
    String docker = "rticode/rseqc:3.0.0"
    Int cpu = 2
    Int mem_gb = ceil((size(bam, "GiB") * 2) + (size(ref_bed, "GiB")*2))
    Int max_retries = 3

    command <<<
        inner_distance.py -i ${bam} \
            -q ${map_qual} \
            -r ${ref_bed} \
            -k ${sample_size} \
            -o ${output_basename} \
            -s ${step_size} \
            -l ${lower_bound} \
            -u ${upper_bound} \
            > ${output_basename}.inner_distance.log 2>&1
   >>>

   runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
   }

   output{
        File rseqc_log = "${output_basename}.inner_distance.log"
        File inner_distance_plot = "${output_basename}.inner_distance_plot.pdf"
        File inner_distance_r = "${output_basename}.inner_distance_plot.r"
        File inner_distance_freq = "${output_basename}.inner_distance_freq.txt"
   }
}

task RseQC_junction_saturation {
    File bam
    File bam_index
    File ref_bed
    Int sample_size = 200000
    Int map_qual = 30
    String output_basename
    Int pct_lower_bound = 5
    Int pct_upper_bound = 100
    Int pct_step = 5
    Int min_intron_size = 50
    Int min_splice_read = 1


    # Runtime environment
    String docker = "rticode/rseqc:3.0.0"
    Int cpu = 2
    Int mem_gb = ceil((size(bam, "GiB") * 2) + (size(ref_bed, "GiB")*2))
    Int max_retries = 3

    command <<<
        junction_saturation.py -i ${bam} \
            -q ${map_qual} \
            -r ${ref_bed} \
            -s ${sample_size}  \
            -l ${pct_lower_bound} \
            -u ${pct_upper_bound} \
            -s ${pct_step} \
            -m ${min_intron_size} \
            -v ${min_splice_read} \
            -o ${output_basename} \
            > ${output_basename}.junction_saturation.log 2>&1
   >>>

   runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
   }

   output{
        File rseqc_log = "${output_basename}.junction_saturation.log"
        File junction_saturation_plot = "${output_basename}.junctionSaturation_plot.pdf"
        File junction_saturation_r = "${output_basename}.junctionSaturation_plot.r"
   }
}

task RseQC_mismatch_profile {
    File bam
    File bam_index
    Int read_len
    Int map_qual = 30
    Int sample_size = 1000000
    String output_basename

    # Runtime environment
    String docker = "rticode/rseqc:3.0.0"
    Int cpu = 2
    Int mem_gb = ceil((size(bam, "GiB")*2))
    Int max_retries = 3

    command <<<
        mismatch_profile.py -i ${bam} \
            -q ${map_qual} \
            -l ${read_len} \
            -o ${output_basename} \
            -n ${sample_size} \
            > ${output_basename}.mismatch_profile.log 2>&1
   >>>

   runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
   }

   output{
        File rseqc_log = "${output_basename}.mismatch_profile.log"
        File mismatch_profile_xls = "${output_basename}.mismatch_profile.xls"
   }
}

task RseQC_read_distribution {
    File bam
    File bam_index
    File ref_bed
    String output_basename

    # Runtime environment
    String docker = "rticode/rseqc:3.0.0"
    Int cpu = 4
    Int mem_gb = ceil((size(bam, "GiB")*5) + (size(ref_bed, "GiB")*2)) + 8
    Int max_retries = 3

    command <<<
        read_distribution.py -i ${bam} \
            -r ${ref_bed} \
            > ${output_basename}.read_distribution.log 2>&1
   >>>

   runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
   }

   output{
        File rseqc_log = "${output_basename}.read_distribution.log"
   }
}

task RseQC_read_duplication {
    File bam
    File bam_index
    Int upper_limit = 500
    Int map_qual = 30
    String output_basename

    # Runtime environment
    String docker = "rticode/rseqc:3.0.0"
    Int cpu = 2
    Int mem_gb = ceil((size(bam, "GiB")*2))
    Int max_retries = 3

    command <<<
        read_duplication.py -i ${bam} \
            -o ${output_basename} \
            -u ${upper_limit} \
            -q ${map_qual} \
            > ${output_basename}.read_duplication.log 2>&1
   >>>

   runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
   }

   output{
        File rseqc_log = "${output_basename}.read_duplication.log"
        File pos_dup_rate_xls = "${output_basename}.pos.DupRate.xls"
        File seq_dup_rate_xls = "${output_basename}.seq.DupRate.xls"
   }
}

task RseQC_read_nvc {
    File bam
    File bam_index
    Boolean nx = true
    Int map_qual = 30
    String output_basename

    # Runtime environment
    String docker = "rticode/rseqc:3.0.0"
    Int cpu = 2
    Int mem_gb = ceil((size(bam, "GiB")*2))
    Int max_retries = 3

    command <<<
        read_NVC.py -i ${bam} \
            -o ${output_basename} \
            -q ${map_qual} \
            ${true="-x" false='' nx} \
            > ${output_basename}.read_NVC.log 2>&1
   >>>

   runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
   }

   output{
        File rseqc_log = "${output_basename}.read_NVC.log"
        File nvc_plot = "${output_basename}.NVC_plot.pdf"
        File nvc_xls = "${output_basename}.NVC.xls"
   }
}

task RseQC_tin {
    File bam
    File bam_index
    File ref_bed
    Int min_cov = 10
    Int sample_size = 100
    Boolean subtract_background = false
    String output_basename

    # Runtime environment
    String docker = "rticode/rseqc:3.0.0"
    Int cpu = 2
    Int mem_gb = ceil((size(bam, "GiB")*2) + (size(ref_bed, "GiB")*2)) + 10
    Int max_retries = 3

    command <<<
        tin.py -i ${bam} \
            -r ${ref_bed} \
            -c ${min_cov} \
            -n ${sample_size} \
            ${true="-s" false='' subtract_background} \
            > ${output_basename}.tin.log 2>&1
   >>>

   runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
   }

   output{
        File rseqc_log = "${output_basename}.tin.log"
        File tin_summary = sub(basename(bam), "bam", "") + "summary.txt"
        File tin_xls = sub(basename(bam), "bam", "") + "tin.xls"
   }
}
