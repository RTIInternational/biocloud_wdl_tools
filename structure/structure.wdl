task structure{
    File mainparams
    File input_file
    File? extraparams
    File? stratparams
    String output_basename

    Int k
    Int numloci
    Int numinds
    Int seed = 1523031945

    # Runtime environment
    String docker = "rtibiocloud/structure:v2.3.4-f2d7e82"
    Int cpu = 8
    Int mem_gb = 16

    command {
        structure -K ${k} \
            -m ${mainparams} \
            ${'-e ' + extraparams} \
            ${'-s ' + stratparams} \
            ${'-L ' + numloci} \
            ${'-N ' + numinds} \
            ${'-D ' + seed} \
            -i ${input_file} \
            -o ${output_basename}
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
