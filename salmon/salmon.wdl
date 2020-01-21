task Salmon_quant {
    File salmon_index_tar_file
    String index_name
    File? fastq_R1
    File? fastq_R2
    Array[File]? unpaired_fastqs
    File transcript_gtf
    String output_dir = "output"

    Boolean gcBias = true
    Boolean seqBias = true
    Boolean dumpEq = true
    Boolean validateMappings = true
    String libType = "A"
    Int numBootstraps = 100
    Int biasSpeedSamp = 5
    Boolean reduceGCMemory = true

    # Runtime settings
    String docker = "combinelab/salmon:1.1.0"
    Int cpu = 16
    Int mem_gb = 32 + ceil(size(salmon_index_tar_file, "GiB")) + ceil(size(fastq_R1, "GiB")*2)
    Int max_retries = 3

    meta {
        description: "Salmon_Quant task will perform quasi-alignment of Fastq reads to transcriptom using a salmon index"
    }

    parameter_meta {
        fastq_R1: "(optional) Forward input fastq file. Do not define for single-end reads"
        fastq_R2: "(optional) Reverse input fastq file. Do not define for single-end reads"
        salmon_index_tar_file: "Salmon transcriptome index tar ball"
        index_name: "Name of salmon index once tarball is unzipped"
        unpaired_fastqs: "(optional) Fastq files for unpaired reads"
        gcBias: "(optional) See salmon manual"
        seqBias: "(optional) See salmon manual"
        dumpEq: "(optional) See salmon manual"
        validateMappings: "(optional) See salmon manual"
        libType: "(optional) See salmon manual. Default is to auto-detect"
        numBootstraps: "(optional) See salmon manual"
        biasSpeedSamp: "(optional) See salmon manual"
        reduceGCMemory: "(optional) Reduce memory usage for GC-bias estimation"
        docker: "(optional) the docker image containing the runtime environment for this task"
        mem_gb: "(optional) the amount of memory (GB) to provision for this task"
        cpu: "(optional) the number of cpus to provision for this task"
    }

    command <<<
        set -e
        tar -xvzf ${salmon_index_tar_file}
        salmon quant \
            --threads ${cpu} \
            ${true='--gcBias' false='' gcBias} \
            ${true='--seqBias' false='' seqBias} \
            ${true='--dumpEq' false='' dumpEq} \
            ${true='--reduceGCMemory' false='' reduceGCMemory} \
            ${true='--validateMappings' false='' validateMappings} \
            --libType ${libType} \
            --numBootstraps ${numBootstraps} \
            --biasSpeedSamp ${biasSpeedSamp} \
            --index ${index_name} \
            --output ${output_dir} \
            ${"-1 " + fastq_R1} \
            ${"-2 " + fastq_R2} \
            ${true="-r " false='' defined(unpaired_fastqs)}${sep=" -r " unpaired_fastqs} \
            -g ${transcript_gtf}

        # Make a tarball copy of dir for later modules that require the entire in-place directory
        tar czvf ${output_dir}.tar.gz ${output_dir}
    >>>

    runtime {
        docker: docker
        memory: "${mem_gb} GiB"
        cpu: cpu
        maxRetries: max_retries
    }

    output {
        Array[File] aux_info_files = glob("${output_dir}/aux_info/*")
        File cmd_info_json = "${output_dir}/cmd_info.json"
        File meta_info_json = "${output_dir}/aux_info/meta_info.json"
        File lib_format_counts_json = "${output_dir}/lib_format_counts.json"
        File flenDist_txt = "${output_dir}/libParams/flenDist.txt"
        File salmon_quant_log = "${output_dir}/logs/salmon_quant.log"
        File quant_sf = "${output_dir}/quant.sf"
        File quant_genes_sf = "${output_dir}/quant.genes.sf"
        File quant_dir = "${output_dir}.tar.gz"
  }
}

task Salmon_Merge{
    Array[File] quant_files
    Array[String] sample_names
    String column = "TPM"
    Boolean genes = true
    String output_basename = "quant_merge.sf"

    # Runtime settings
    String docker = "combinelab/salmon:1.1.0"
    Int cpu = 8
    Int mem_gb = 16
    Int max_retries = 3

    meta {
        description: "Salmon_Merge task will merge multiple quantified outputs into single matrix"
    }

    parameter_meta {
        quant_files: "List of quant files (gene or transcript based) to merge"
        sample_names: "List of sample names to associate with each file"
        column: "(optional) The name of the column that will be merged together into the output files [len, elen, tpm, numreads]"
        genes: "(optional) Use gene quantification instead of transcript. Default = true"
        output_basename: "(optional) Output file basename"
        docker: "(optional) the docker image containing the runtime environment for this task"
        mem_gb: "(optional) the amount of memory (GB) to provision for this task"
        cpu: "(optional) the number of cpus to provision for this task"
    }

    command <<<
        salmon quantmerge \
            --quants ${sep=" " quant_files} \
            --names ${sep=" " sample_names} \
            --column ${column} \
            ${true='--genes' false='' genes} \
            --output ${output_basename}.tsv
    >>>

    runtime {
        docker: docker
        memory: "${mem_gb} GiB"
        cpu: cpu
        maxRetries: max_retries
    }

    output {
        File merged_quant_file = "${output_basename}.tsv"
  }

}