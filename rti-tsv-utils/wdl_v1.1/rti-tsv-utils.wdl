version 1.1

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
        String docker_image = "rtibiocloud/rti-tsv-utils:v1_fcb9291"
        String ecr_image = "rtibiocloud/rti-tsv-utils:v1_fcb9291"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
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
        String docker_image = "rtibiocloud/rti-tsv-utils:v1_fcb9291"
        String ecr_image = "rtibiocloud/rti-tsv-utils:v1_fcb9291"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
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


task tsv_append{
    # TSV utility for combining rows from array of files with same columns

    input {

        Array[File] input_files
        String output_prefix
        Int header_row_count = 1

        # Runtime environment
        String docker_image = "ubuntu:22.04@sha256:19478ce7fc2ffbce89df29fea5725a8d12e57de52eb9ea570890dc5852aac1ac"
        String ecr_image = "rtibiocloud/ubuntu:22.04_19478ce7fc2ff"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 1
        Int mem_gb = 2
        Int max_retries = 3

    }

    command <<<
        set -e
        touch ~{output_prefix}.tsv

        # Write header
        if [[ ~{input_files[0]} =~ \.gz$ ]]; then
            gunzip -c ~{input_files[0]} | head -n ~{header_row_count} > ~{output_prefix}.tsv
        else
            head -n ~{header_row_count} ~{input_files[0]} > ~{output_prefix}.tsv
        fi

        # Append data rows
        first_data_row=$((~{header_row_count} + 1))
        for file in ~{sep(" ", input_files)}; do
            if [[ $file =~ \.gz$ ]]; then
                gunzip -c $file | tail -n +$first_data_row >> ~{output_prefix}.tsv
            else
                tail -n +$first_data_row $file >> ~{output_prefix}.tsv
            fi
        done
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File out_tsv = select_first(["~{output_prefix}.tsv"])
    }
}
