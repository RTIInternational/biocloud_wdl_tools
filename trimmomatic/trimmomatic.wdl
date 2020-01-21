task Trimmomatic_SE{
    File fastq
    File adapters
    Int seed_mismatches
    Int pal_clip_thresh
    Int simple_clip_thresh
    Int min_adapter_len
    Boolean keep_pair

    #Optional args
    Int? leading
    Int? trailing
    Int? sliding_window_qual = 0
    Int? sliding_window_len = 0
    Int? min_len
    Int? avg_qual
    Boolean? is_phred33 = true

    # Output file
    String output_basename
    String trimmed_output_filename = "${output_basename}.trimmed.fastq.gz"

    # Runtime environment
    String docker = "rticode/trimmomatic:0.39"
    Int cpu = 8
    Int mem_gb = 12
    Int max_retries = 3

    meta {
        description: "Trimmomatic_SE task will trim and filter a single-end FastQ using various quality filters"
    }

    parameter_meta {
        fastq: "input fastq file"
        adapters: "Fasta file of adapter sequences to look for on trimming"
        seed_mismatches: "Number of seed mismatches allowed when trimming adapters"
        pal_clip_thresh: "Overlap threshold when doing palindrome adapter clipping"
        simple_clip_thresh: "Overlap threshold when doing simple adapter clipping"
        min_adapter_len: "Minimum length of adapter match to remove"
        keep_pair: "Whether to keep pairs after trimming"
        is_phred33: "(optional) Flag for whether reads use 33 base vs 64 base PHRED scores"
        leading: "(optional) Number of 5' bases to clip"
        trailing: "(optional) Number of 3' bases to clip"
        sliding_window_len: "(optional) Size of sliding window for sliding window trimming"
        sliding_window_qual: "(optional) Average quality score threshold to remove bases after sliding window"
        min_len: "(optional) Remove reads with < this length"
        avg_qual: "(optional) Remove reads with < average quality"
        docker: "(optional) the docker image containing the runtime environment for this task"
        mem_gb: "(optional) the amount of memory (GB) to provision for this task"
        cpu: "(optional) the number of cpus to provision for this task"
    }

    command{
        java -jar /opt/trimmomatic \
            SE \
            ${true='-phred33' false='-phred64' is_phred33} \
            -threads ${cpu} \
            ${fastq} ${trimmed_output_filename} \
            ILLUMINACLIP:${adapters}:${seed_mismatches}:${pal_clip_thresh}:${simple_clip_thresh}:${min_adapter_len}:${true='true' false='false' keep_pair} \
            ${'LEADING:' + leading} \
            ${'TRAILING:' + trailing} \
            SLIDINGWINDOW:${sliding_window_len}:${sliding_window_qual} \
            ${'MINLEN:' + min_len} \
            ${'AVGQUAL:' + avg_qual} \
            > ${output_basename}.trimmomatic.log 2>&1
    }

    runtime{
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File trimmed_fastq = "${trimmed_output_filename}"
        File trim_log = "${output_basename}.trimmomatic.log"
    }
}

task Trimmomatic_PE{
    File fastq_R1
    File fastq_R2
    File adapters
    Int seed_mismatches
    Int pal_clip_thresh
    Int simple_clip_thresh
    Int min_adapter_len
    Boolean keep_pair

    # Optional args
    Int? leading
    Int? trailing
    Int? sliding_window_qual = 0
    Int? sliding_window_len = 0
    Int? min_len
    Int? avg_qual
    Boolean? is_phred33 = true

    # Output filenames
    String output_basename
    String trimmed_R1_filename = "${output_basename}.trimmed.R1.fastq.gz"
    String trimmed_R2_filename = "${output_basename}.trimmed.R2.fastq.gz"
    String unpaired_R1_filename = "${output_basename}.trimmed.R1.unpaired.fastq.gz"
    String unpaired_R2_filename = "${output_basename}.trimmed.R2.unpaired.fastq.gz"

    # Runtime Environment
    String docker = "rticode/trimmomatic:0.39"
    Int cpu = 8
    Int mem_gb = 12
    Int max_retries = 3

    meta {
        description: "Trimmomatic_PE task will trim and filter a set of paired-end FastQ files using various quality filters"
    }

    parameter_meta {
        fastq_R1: "Forward input fastq file"
        fastq_R2: "Reverse input fastq file"
        adapters: "Fasta file of adapter sequences to look for on trimming"
        seed_mismatches: "Number of seed mismatches allowed when trimming adapters"
        pal_clip_thresh: "Overlap threshold when doing palindrome adapter clipping"
        simple_clip_thresh: "Overlap threshold when doing simple adapter clipping"
        min_adapter_len: "Minimum length of adapter match to remove"
        keep_pair: "Whether to keep pairs after trimming"
        is_phred33: "(optional) Flag for whether reads use 33 base vs 64 base PHRED scores"
        leading: "(optional) Number of 5' bases to clip"
        trailing: "(optional) Number of 3' bases to clip"
        sliding_window_len: "(optional) Size of sliding window for sliding window trimming"
        sliding_window_qual: "(optional) Average quality score threshold to remove bases after sliding window"
        min_len: "(optional) Remove reads with < this length"
        avg_qual: "(optional) Remove reads with < average quality"
        docker: "(optional) the docker image containing the runtime environment for this task"
        mem_gb: "(optional) the amount of memory (GB) to provision for this task"
        cpu: "(optional) the number of cpus to provision for this task"
    }

    command{
        java -jar /opt/trimmomatic \
            PE \
            ${true='-phred33' false='-phred64' is_phred33} \
            -threads ${cpu} \
            ${fastq_R1} ${fastq_R2} \
            ${trimmed_R1_filename} ${unpaired_R1_filename} \
            ${trimmed_R2_filename} ${unpaired_R2_filename} \
            ILLUMINACLIP:${adapters}:${seed_mismatches}:${pal_clip_thresh}:${simple_clip_thresh}:${min_adapter_len}:${true='true' false='false' keep_pair} \
            ${'LEADING:' + leading} \
            ${'TRAILING:' + trailing} \
            SLIDINGWINDOW:${sliding_window_len}:${sliding_window_qual} \
            ${'MINLEN:' + min_len} \
            ${'AVGQUAL:' + avg_qual} \
            > ${output_basename}.trimmomatic.log 2>&1
    }

    runtime{
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File trimmed_fastq_R1 = "${trimmed_R1_filename}"
        File trimmed_fastq_R2 = "${trimmed_R2_filename}"
        File unpaired_fastq_R1 = "${unpaired_R1_filename}"
        File unpaired_fastq_R2 = "${unpaired_R2_filename}"
        File trim_log = "${output_basename}.trimmomatic.log"
    }
}

task Trimmomatic_Headcrop{
    File fastq
    Int crop_len
    Boolean? is_phred33 = true

    # Output file
    String output_basename
    String trimmed_output_filename = "${output_basename}.headcropped.fastq.gz"

    # Runtime environment
    String docker = "rticode/trimmomatic:0.39"
    Int cpu = 8
    Int mem_gb = 12
    Int max_retries = 3

    meta {
        description: "Trimmomatic_Headcrop task will trim the first N bases from reads in a fastq"
    }

    parameter_meta {
        fastq: "input fastq file"
        crop_len: "Number of 5' bases to crop"
        is_phred33: "(optional) Flag for whether reads use 33 base vs 64 base PHRED scores"
        docker: "(optional) the docker image containing the runtime environment for this task"
        mem_gb: "(optional) the amount of memory (GB) to provision for this task"
        cpu: "(optional) the number of cpus to provision for this task"
    }

    command{
        java -jar /opt/trimmomatic \
            SE \
            ${true='-phred33' false='-phred64' is_phred33} \
            -threads ${cpu} \
            ${fastq} ${trimmed_output_filename} \
            HEADCROP:${crop_len} \
            > ${output_basename}.trimmomatic.log 2>&1
    }

    runtime{
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File trimmed_fastq = "${trimmed_output_filename}"
        File trim_log = "${output_basename}.trimmomatic.log"
    }
}

