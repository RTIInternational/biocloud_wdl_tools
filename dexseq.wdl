task Dexseq_prepare_annotation {
    File gtf
    String output_basename = basename(gtf, ".gtf")
    String output_filename = "${output_basename}.flattened.gff"

    # Runtime environment
    String docker = "rticode/dexseq:1.30.0_5b776e1"
    Int cpu = 2
    Int mem_gb = 8
    Int max_retries = 3

    meta {
        description: "Dexseq_prepare_annotation converts converts GTF-formatted annotations into non-overlapping gff annotations for downstream use by Dexseq_count"
    }

    parameter_meta {
        gtf: "Input gtf file"
        output_basename: "(optional) basename of gff output file. Defaults to replacing input .gtf filename with .gff"
        docker: "(optional) the docker image containing the runtime environment for this task"
        mem_gb: "(optional) the amount of memory (GB) to provision for this task"
        cpu: "(optional) the number of cpus to provision for this task"
    }

    command <<<
        python /opt/dexseq_prepare_annotation.py ${gtf} ${output_filename}
    >>>

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File flattened_gff = output_filename
    }
}

task Dexseq_count {
    File bam
    File bam_index
    File flattened_gff
    Boolean paired_end
    Boolean stranded
    Boolean bam_sorted_by_pos = true
    Boolean is_bam = true
    Int min_qual = 20
    String output_basename
    String output_filename = "${output_basename}.dexseq_exon_count.txt"

    # Runtime environment
    String docker = "rticode/dexseq:1.30.0_5b776e1"
    Int cpu = 16
    Int mem_gb = 32
    Int max_retries = 3

    meta {
        description: "Dexseq_count counts the number of reads in a bam file mapping to exonic regions"
    }

    parameter_meta {
        bam: "Input bam/sam file to analyze"
        bam_index: "Index for bam/sam file"
        flattened_gff: "Flattened annotation file output by dexseq_prepare_annotation.py"
        paired_end: "Whether input reads are paired-end (true) or single-end (false)"
        stranded: "Whether input reads are stranded (true) or unstranded (false)"
        bam_sorted_by_pos: "Whether input reads are sorted by position (true) or name (false)"
        is_bam: "Whether input reads are bam (true) or sam (false) format"
        min_qual: "Minimum quality threshold for alignments"
        output_basename: "(optional) basename of gff output file. Defaults to replacing input .gtf filename with .gff"
        docker: "(optional) the docker image containing the runtime environment for this task"
        mem_gb: "(optional) the amount of memory (GB) to provision for this task"
        cpu: "(optional) the number of cpus to provision for this task"
    }

    command <<<
        python /opt/dexseq_count.py \
            -p ${true='yes' false='no' paired_end} \
            -s ${true='yes' false='no' stranded} \
            -f ${true='bam' false='sam' is_bam} \
            -r ${true='pos' false='name' bam_sorted_by_pos} \
            ${"-a " + min_qual} \
            ${flattened_gff} \
            ${bam} \
            ${output_filename}
    >>>

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File exon_count_file = output_filename
    }
}
