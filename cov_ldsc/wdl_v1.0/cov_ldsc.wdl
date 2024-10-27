version 1.0

task cov_ldsc {

    input {

        File bed_in
        File bim_in
        File fam_in
        
        File cov_eigenvec
        String output_basename

        String input_prefix = basename(sub(bed_in, "\\.gz$", ""), ".bed")

        # Runtime attributes
        String docker_image = "rtibiocloud/cov_ldsc:v1_78e7ecc"
        String ecr_image = "rtibiocloud/cov_ldsc:v1_78e7ecc"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu
        Int mem_gb
        Int max_retries = 3

    }

    command {
        
        # Get everything in the same directory
        mkdir plink_input

        # Bed file preprocessing
        ln -s ~{bed_in} plink_input/~{input_prefix}.bed

        # Bim file preprocessing
        ln -s ~{bim_in} plink_input/~{input_prefix}.bim

        # Fam file preprocessing
        ln -s ~{fam_in} plink_input/~{input_prefix}.fam

        # Run cov-LDSC python script
        set -e
        python /opt/ldsc.py \
            --bfile plink_input/~{input_prefix} \
            --l2 \
            --ld-wind-cm 20 \
            --yes-really \
            --cov ~{cov_eigenvec} \
            --out ~{output_basename} 
    }

    output {
        File m_file = "~{output_basename}.l2.M"
        File m_5_50_file = "~{output_basename}.l2.M_5_50"
        File ldscore_out = "~{output_basename}.l2.ldscore.gz"
        File log = "~{output_basename}.log"
    }

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
        maxRetries: max_retries
    }

}

