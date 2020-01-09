task Gtf2bed {
    File gtf
    String output_basename = basename(gtf, ".gtf")
    String output_filename = "${output_basename}.bed"

    # Runtime environment
    String docker = "rticode/ucsc_utils:1.04.00"
    Int cpu = 4
    Int mem_gb = 16
    Int max_retries = 3

    meta {
        description: "Gtf2bed task will convert a gtf file to bed format"
    }

    parameter_meta {
        gtf: "input gtf file"
        docker: "(optional) the docker image containing the runtime environment for this task"
        mem_gb: "(optional) the amount of memory (GB) to provision for this task"
        cpu: "(optional) the number of cpus to provision for this task"
    }

    command <<<
        gtfToGenePred ${gtf} ${output_basename}.genepred
        genePredToBed ${output_basename}.genepred ${output_filename}
    >>>

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File bed = output_filename
    }
}
