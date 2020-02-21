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