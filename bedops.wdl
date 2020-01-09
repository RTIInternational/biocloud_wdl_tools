task Bedops_gtf2bed {
    File gtf
    String output_basename = basename(gtf, ".gtf")
    String output_filename = "${output_basename}.bed"
    Boolean sort_bed = true

    # Runtime environment
    String docker = "rticode/bedops:2.4.36"
    Int cpu = 4
    Int mem_gb = 16
    Int max_retries = 3

    meta {
        description: "Bedops_gtf2bed task will convert a gtf file to bed format"
    }

    parameter_meta {
        gtf: "input gtf file"
        sort_bed: "(optional) whether to output sorted bed"
        docker: "(optional) the docker image containing the runtime environment for this task"
        mem_gb: "(optional) the amount of memory (GB) to provision for this task"
        cpu: "(optional) the number of cpus to provision for this task"
    }

    command <<<
        ## Include extra step to put dummy transcript ids if they're not present in GTF
        ## Solution mentioned https://www.biostars.org/p/206342/

        awk '{ if ($0 ~ "transcript_id") print $0; else print $0" transcript_id \"\";"; }' ${gtf} | gtf2bed ${true='' false='--do-not-sort' sort_bed} - > ${output_filename}
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
