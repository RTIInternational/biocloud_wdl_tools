task gzip{
    File input_file
    String? user_filename
    String default_filename = basename(input_file) + ".gz"
    String output_filename = select_first([user_filename, default_filename])

    String docker = "rtibiocloud/pigz:v2.4_b243f9"
    String ecr = "404545384114.dkr.ecr.us-east-1.amazonaws.com/rtibiocloud/pigz:v2.4_b243f9"
    String container_source = "docker"
    String container_image = if(container_source == "docker") then docker else ecr
    Int cpu = 1
    Int mem_gb = 1
    Int max_retries = 3

    command <<<
        pigz -ck -p${cpu} ${input_file} > ${output_filename}
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File output_file = "${output_filename}"
    }
}

task gunzip{
    File input_file
    String? user_filename
    String default_filename = basename(input_file, ".gz")
    String output_filename = select_first([user_filename, default_filename])

    String docker = "rtibiocloud/pigz:v2.4_b243f9"
    String ecr = "404545384114.dkr.ecr.us-east-1.amazonaws.com/rtibiocloud/pigz:v2.4_b243f9"
    String container_source = "docker"
    String container_image = if(container_source == "docker") then docker else ecr
    Int cpu = 1
    Int mem_gb = 1
    Int max_retries = 3

    command <<<
        unpigz -ck -p${cpu} ${input_file} > ${output_filename}
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File output_file = "${output_filename}"
    }
}
