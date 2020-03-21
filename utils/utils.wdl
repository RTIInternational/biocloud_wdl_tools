task append {
    Array[String] a
    String? b

    # Runtime environment
    String docker = "ubuntu:18.04"
    Int cpu = 1
    Int mem_gb = 1

    command {
        cat ${write_lines(a)}
        ${'echo ' + b}
    }

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
    }

    output {
        Array[File] out = read_lines(stdout())
    }
}

task collect_files{
    Array[File] input_files
    String output_dir_name

    # Runtime environment
    String docker = "ubuntu:18.04"
    Int cpu = 1
    Int mem_gb = 2
    Int max_retries = 3

    meta {
        description: "Gather multiple files into a single gzipped tarball that can be unzipped and directly input to MultiQC"
    }

    parameter_meta {
        input_files: "Files to zip"
        output_dir_name: "Name of directory that will be created and tarballed"
        docker: "(optional) the docker image containing the runtime environment for this task"
        mem_gb: "(optional) the amount of memory (GB) to provision for this task"
        cpu: "(optional) the number of cpus to provision for this task"
    }

    command <<<
        set -e

        # Create directory and copy files into directory
        mkdir -p ${output_dir_name}

        # Loop through files in input file and copy/decompress them to output dir
        for input_file in ${sep=" " input_files}; do

            if [[ $input_file == *.tar.gz ]]; then
                # Untar directory into output directory
                tar -xvzf "$input_file" -C ${output_dir_name}
            else
                # Just copy flat files to MultiQC dir
                cp "$input_file" ${output_dir_name}
            fi

        done

        # Make a list of files in directory
        find ${output_dir_name}/* -type f > ${output_dir_name}.contents.txt

        # Compress directory so it can be placed inside higher-level directories
        tar -cvzf ${output_dir_name}.tar.gz ${output_dir_name}

    >>>

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File output_dir_file_list = "${output_dir_name}.contents.txt"
        File output_dir = "${output_dir_name}.tar.gz"
    }
}

task slice{
    # Get 0-based slice of an array
    # end_index is exclusive so it works more or less like python
    Array[String] inputs
    Int start_pos
    Int end_pos
    Int slice_size = end_pos - start_pos

    # Make start pos 1-based because of how tail -N + works
    Int actual_start_pos = start_pos + 1

    # Runtime environment
    String docker = "ubuntu:18.04"
    Int cpu = 1
    Int mem_gb = 1

    command {
        tail -n +${actual_start_pos} ${write_lines(inputs)} | head -${slice_size}
    }

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
    }

    output {
        Array[String] outputs = read_lines(stdout())
    }
}

task flatten_string_array {

    Array[Array[String]] array

    # Runtime environment
    String docker = "ubuntu:18.04"
    Int cpu = 1
    Int mem_gb = 1

    command {
    for line in $(echo ${sep=', ' array}) ; \
    do echo $line | tr -d '"[],' ; done
    }

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
    }

    output {
        Array[String]  flat_array = read_lines(stdout())
    }
}

task remove_empty_files{
    Array[File] input_files

    # Runtime environment
    String docker = "ubuntu:18.04"
    Int cpu = 1
    Int mem_gb = 1

    command {
        mkdir non_empty_files
        for file in ${sep=' ' input_files}; do
            if [ -s $file ];then
                cp $file non_empty_files
            fi
        done
    }

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
    }

    output {
        Array[File] non_empty_files = glob("non_empty_files/*")
    }
}

task wc{
    File input_file

    # Runtime environment
    String docker = "ubuntu:18.04"
    Int cpu = 1
    Int mem_gb = 1

    command {
        if [[ ${input_file} =~ \.gz$ ]]
        then
            gunzip -c ${input_file} | wc -l | cut -d" " -f1
        else
            wc -l ${input_file} | cut -d" " -f1
        fi
    }

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
    }

    output {
        Int num_lines = read_int(stdout())
    }
}

task cut{
    File input_file
    String args
    String output_filename

    # Runtime environment
    String docker = "ubuntu:18.04"
    Int cpu = 1
    Int mem_gb = 1

    command {
        cut ${args} ${input_file} > ${output_filename}
    }

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
    }

    output {
        File output_file = "${output_filename}"
    }
}

task get_file_union{
    # Takes a list of files and outputs the union of lines in each file with no duplicates
    Array[File] input_files
    String output_filename

    String docker = "ubuntu:18.04"
    Int cpu = 1
    Int mem_gb = 2
    Int max_retries = 3

    command <<<
        set -e
        for file in ${sep=" " input_files}
        do
            cat $file >> all_files.txt
        done

        # Dedup merged file
        sort all_files.txt | uniq > ${output_filename}
    >>>

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File output_file = "${output_filename}"
    }
}
