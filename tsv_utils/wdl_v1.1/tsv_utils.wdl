version 1.1

task tsv_append{
    # TSV utility for concatenating multiple TSVs into one TSV while taking header into account

    input {

        File tsv_inputs_tarball
        String output_filename
        Boolean header = true
        Boolean track_source = false
        String? source_header
        String? delimiter
        String tsv_dir = basename(tsv_inputs_tarball, ".tar.gz")


        # Runtime environment
        String docker_image = "rtibiocloud/tsv-utils:v2.2.0_5141a72"
        String ecr_image = "rtibiocloud/tsv-utils:v2.2.0_5141a72"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 2
        Int mem_gb = 4

    }

    command <<<
        set -e

        # Unzip/decompress files to working directory
        tar -xvzf ~{tsv_inputs_tarball} -C ./

        # Unzip any/all gzipped files
        find ~{tsv_dir}/ -name '*.gz' | while read file
        do
            echo "Unzipping $file"
            gunzip $file
        done

        # Concat all files together
        tsv-append \
            ~{"--source-header " + source_header} \
            ~{if header then "--header" else ""} \
            ~{if track_source then "--track-source" else ""} \
            ~{"--delimiter '" + delimiter + "'"} \
            ~{tsv_dir}/* > ~{output_filename}
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
    }

    output{
        File tsv_output = output_filename
    }
}

task tsv_filter{
    # TSV utility for filtering on multiple columns

    input {

        File tsv_input
        String output_filename
        Boolean header = true
        Boolean invert = false
        String? delimiter
        Boolean or_filter = false  # Evaluate tests as an OR rather than an AND clause.

        # Filtering criteria (see tsv-filter options for more details
        # There are too many options here to parameterize so just pass as a string
        String filter_string

        # Runtime environment
        String docker_image = "rtibiocloud/tsv-utils:v2.2.0_5141a72"
        String ecr_image = "rtibiocloud/tsv-utils:v2.2.0_5141a72"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 2
        Int mem_gb = 4

    }

    command <<<
        set -e

        input_file=~{tsv_input}

        # Unzip tsv input file if necessary
        if [[ ~{tsv_input} =~ \.gz$ ]]; then
            echo "~{tsv_input} is gzipped. Unzipping..."
            gunzip -c ~{tsv_input} > input.txt
            input_file=input.txt
        fi

        tsv-filter \
            ~{if header then "--header" else ""} \
            ~{if or_filter then "--or" else ""} \
            ~{if invert then "--invert" else ""} \
            ~{"--delimiter '" + delimiter + "'"} \
            ~{filter_string} \
            $input_file > ~{output_filename}
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
    }

    output{
        File tsv_output = output_filename
    }
}

task tsv_select{
    # TSV utility for selecting/re-ordering columns (similar to cut but allows re-ordering)

    input {

        File tsv_input
        String output_filename
        Array[String] fields
        Boolean header = true
        String? delimiter
        String rest = "none"  # Location for remaining fields (none|first|last)

        # Runtime environment
        String docker_image = "rtibiocloud/tsv-utils:v2.2.0_5141a72"
        String ecr_image = "rtibiocloud/tsv-utils:v2.2.0_5141a72"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 2
        Int mem_gb = 4

    }

    command <<<
        set -e

        input_file=~{tsv_input}

        # Unzip tsv input file if necessary
        if [[ ~{tsv_input} =~ \.gz$ ]]; then
            echo "~{tsv_input} is gzipped. Unzipping..."
            gunzip -c ~{tsv_input} > input.txt
            input_file=input.txt
        fi
        tsv-select \
            ~{if header then "--header" else ""} \
            ~{"--delimiter '" + delimiter + "'"} \
            --fields ~{sep(",", fields)} \
            --rest ~{rest} \
            $input_file > ~{output_filename}
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
    }

    output{
        File tsv_output = output_filename
    }
}

task tsv_join{
    # TSV utility for subsetting tsv file based on ids in another file

    input {

        File tsv_input
        File tsv_filter_file
        String? key_fields
        String? data_fields
        String? append_fields
        Boolean header = true
        String? delimiter
        String prefix = "none"
        Boolean write_unmatched = false
        String? write_unmatched_str
        Boolean exclude = false
        Boolean allow_duplicate_keys = false
        String output_filename

        # Runtime environment
        String docker_image = "rtibiocloud/tsv-utils:v2.2.0_5141a72"
        String ecr_image = "rtibiocloud/tsv-utils:v2.2.0_5141a72"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 2
        Int mem_gb = ceil(size(tsv_filter_file, "GiB") * 2) + 2

    }

    command <<<
        set -e
        
        input_file=~{tsv_input}
        filter_file=~{tsv_filter_file}

        # Unzip tsv input file if necessary
        if [[ ~{tsv_input} =~ \.gz$ ]]; then
            echo "~{tsv_input} is gzipped. Unzipping..."
            gunzip -c ~{tsv_input} > input.txt
            input_file=input.txt
        fi

        # Unzip filter file if necessary
        if [[ ~{tsv_filter_file} =~ \.gz$ ]]; then
            echo "~{tsv_filter_file} is gzipped. Unzipping..."
            gunzip -c ~{tsv_filter_file} > filter_input.txt
            filter_file=filter_input.txt
        fi


        tsv-join \
            --filter-file $filter_file \
            ~{"--key-fields " + key_fields} \
            ~{"--data-fields " + data_fields} \
            ~{"--append-fields " + append_fields} \
            ~{if header then "--header" else ""} \
            ~{"--prefix " + prefix} \
            ~{"--delimiter '" + delimiter + "'"} \
            ~{if write_unmatched then "--write-all " + write_unmatched_str else ""} \
            ~{if exclude then "--exclude" else ""} \
            ~{if allow_duplicate_keys then "--allow-duplicate-keys" else ""} \
            $input_file > ~{output_filename}
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
    }

    output{
        File tsv_output = output_filename
    }
}

