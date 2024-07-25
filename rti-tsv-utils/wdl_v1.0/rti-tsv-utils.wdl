version 1.0

task tsv_join{
    # TSV utility for subsetting tsv file based on ids in another file

    input {

        File left_file
        String left_on
        String? left_sep
        String? left_cols
        String? left_suffix
        Array[File] right_files
        String right_ons
        String? right_seps
        String? right_cols
        String? right_suffixes
        String? hows
        String out_prefix
        Boolean? sort
        Int? chunk_size

        # Runtime environment
        String docker = "rtibiocloud/rti-tsv-utils:v1_fcb9291"
        String? ecr_path
        String ecr = "~{ecr_path}/rtibiocloud/rti-tsv-utils:v1_fcb9291"
        String container_source = "docker"
        String container_image = if(container_source == "docker") then docker else ecr
        Int cpu = 1
        Int mem_gb = 2
        Int max_retries = 3

    }

    command <<<

        python /opt/rti-tsv-utils-join.py \
            --in-file-left ~{left_file} \
            ~{"--in-file-left-sep " + left_sep} \
            ~{"--in-file-left-cols " + left_cols} \
            --left-on ~{left_on} \
            ~{"--left-suffix " + left_suffix} \
            --in-file-right ~{sep=" " right_files} \
            ~{"--in-file-right-sep " + right_seps} \
            ~{"--in-file-right-cols " + right_cols} \
            --right-on ~{right_ons} \
            ~{"--right-suffix " + right_suffixes} \
            ~{"--how " + hows} \
            --out-file-prefix ~{out_prefix} \
            ~{true="--sort" false="--no-sort" sort} \
            ~{"--chunk-size " + chunk_size}

    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File out_tsv = "~{out_prefix}.tsv.gz"
        File out_log = "~{out_prefix}.log"
    }
}

task tsv_sort{
    # TSV utility for sorting tsv file based on specified columns

    input {

        File in_file
        String cols
        String out_prefix
        String in_file_sep = "tab"
        Boolean ascending = true

        # Runtime environment
        String docker = "rtibiocloud/rti-tsv-utils:v1_fcb9291"
        String? ecr_path
        String ecr = "~{ecr_path}/rtibiocloud/rti-tsv-utils:v1_fcb9291"
        String container_source = "docker"
        String container_image = if(container_source == "docker") then docker else ecr
        Int cpu = 1
        Int mem_gb = 2
        Int max_retries = 3

    }

    command <<<

        python /opt/rti-tsv-utils-sort.py \
            --in-file ~{in_file} \
            ~{"--cols " + cols} \
            --out-prefix ~{out_prefix} \
            ~{"--in-file-sep " + in_file_sep} \
            ~{true="--ascending" false="--descending" ascending} \
            --out-file-compression gzip

    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File out_tsv = "~{out_prefix}.tsv.gz"
        File out_log = "~{out_prefix}.log"
    }
}
