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