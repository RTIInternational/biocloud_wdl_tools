task Regtools_junctions_extract{
    File bam
    File bam_index
    Int min_anchor_len = 8
    Int min_intron_len = 70
    Int max_intron_len = 500000
    String? region
    Int strand_specificity
    String output_basename
    String output_filename = "${output_basename}.junctions.bed"

    # Runtime environment
    String docker = "rticode/regtools:0.5.1"
    Int cpu = 16
    Int mem_gb = 32
    Int max_retries = 3

    meta {
        description: "Regtools_junctions_extract task identifies exon-exon junctions from alignments"
    }

    parameter_meta {
        bam: "Input bam/sam file to analyze"
        bam_index: "Index for bam/sam file"
        min_anchor_len: "(optional) Minimum anchor length. Junctions which satisfy a minimum anchor length on both sides are reported"
        min_intron_len: "(optional) Minimum intron length"
        max_intron_len: "(optional) Maximum intron length"
        region: "(optional) region to identify junctions"
        strand_specificity: "(optional) Strand specificity of RNA library preparation (0 = unstranded, 1 = first-strand/RF, 2, = second-strand/FR)."
        output_basename: "Basename of output bed file"
        docker: "(optional) the docker image containing the runtime environment for this task"
        mem_gb: "(optional) the amount of memory (GB) to provision for this task"
        cpu: "(optional) the number of cpus to provision for this task"
    }

    command <<<

        regtools junctions extract \
            ${'-a ' + min_anchor_len} \
            ${'-m ' + min_intron_len} \
            ${'-M ' + max_intron_len} \
            ${'-o ' + output_filename} \
            ${'-r ' + region} \
            ${'-s ' + strand_specificity} \
            ${'-a ' + min_anchor_len} \
            ${bam}

    >>>

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File junctions_bed = output_filename
    }
}

task Regtools_junctions_annotate{
    File junctions_bed
    File gtf
    File genome_fa
    Boolean include_single_exons = false
    String output_basename
    String output_filename = "${output_basename}.annotated_junctions.bed"

    # Runtime environment
    String docker = "rticode/regtools:0.5.1"
    Int cpu = 16
    Int mem_gb = 32
    Int max_retries = 3

    meta {
        description: "Regtools_junctions_extract task identifies exon-exon junctions from alignments"
    }

    parameter_meta {
        junctions_bed: "Output bed file from Regtools_junctions_extract"
        gtf: "Genome annotation file"
        genome_fa: "Genome FASTA file. Must match GTF"
        include_single_exons: "(optional) include single exon genes in output"
        output_basename: "Basename of annotated output file"
        docker: "(optional) the docker image containing the runtime environment for this task"
        mem_gb: "(optional) the amount of memory (GB) to provision for this task"
        cpu: "(optional) the number of cpus to provision for this task"
    }

    command <<<

        regtools junctions annotate \
            ${true='-S' false='' include_single_exons} \
            ${'-o ' + output_filename} \
            ${junctions_bed} \
            ${genome_fa} \
            ${gtf}
    >>>

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File annotated_junctions_bed = output_filename
    }
}