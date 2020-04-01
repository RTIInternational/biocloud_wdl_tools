task structure{
    File input_file
    File mainparams = "/opt/data/mainparams"
    File extraparams = "/opt/data/extraparams"
    File? stratparams
    String output_basename

    Int k
    Int numloci
    Int? seed
    Int default_seed = 1523031945
    Int actual_seed = select_first([seed, default_seed])

    # Runtime environment
    String docker = "rtibiocloud/structure:v2.3.4-f2d7e82"
    Int cpu = 8
    Int mem_gb = 16

    command <<<
        set -e

        mkdir structure_output

        # Count number of individuals
        num_inds=$(wc -l ${input_file} | perl -lane 'print $F[0]/2;')

        structure -K ${k} \
            -m ${mainparams} \
            ${'-e ' + extraparams} \
            ${'-s ' + stratparams} \
            -L ${numloci} \
            -N $num_inds \
            -D ${default_seed} \
            -i ${input_file} \
            -o structure_output/${output_basename}
    >>>

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
    }

    output {
        File theta_out = "structure_output/${output_basename}_f"
    }
}

task ped2structure{
    # Utility for converting ped file to STRUCTURE-formatted input
    File ped_in

    # List of files containing ids for populations you want to use for structure
    # Original use-case is sample ids for each reference populations inlcuded to STRUCTURE initializes with pop information
    Array[File]? pop_files
    String output_filename

    String pop_file_prefix = if(defined(pop_files)) then "--pop-files" else ""

    # Runtime environment
    String docker = "rtibiocloud/ped2structure:v1.0-7ae2a15"
    Int cpu = 8
    Int mem_gb = 16

    command<<<
        python /opt/ped2structure.py --ped ${ped_in} \
            ${pop_file_prefix} ${sep=" " pop_files} \
            --output ${output_filename} \
            -vvv
    >>>

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
    }

    output {
        File structure_input = "${output_filename}"
    }


}
