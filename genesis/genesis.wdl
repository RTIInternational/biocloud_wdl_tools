task genesis {
    File file_in_geno
    File file_in_pheno
    File? file_in_variant_list
    String file_out
    String geno_format      # Options: gds
    String pheno            # Column name in phenotype file
    Array[String]? covars   # Array of column names of covars
    String family           # Options: gaussian
    String? gxe             # Column name in phenotype file for gxe interaction
    String chr              # Chr being analyzed
    Boolean? gzip

    String covarsPrefix = if defined(covars) then "--covars " else ""
    String variantListPrefix = if defined(file_in_variant_list) then "--file-variant-list " else ""

    # Runtime attributes
    String docker = "rtibiocloud/genesis:v3.15_2d537e1"
    String ecr = "404545384114.dkr.ecr.us-east-1.amazonaws.com/rtibiocloud/genesis:v3.15_2d537e1"
    String container_source = "docker"
    String container_image = if(container_source == "docker") then docker else ecr
    Int cpu = 1
    Int mem_gb = 2
    Int max_retries = 3

    command {
        /opt/genesis.R \
            --file-geno ${file_in_geno} \
            --geno-format ${geno_format} \
            --file-pheno ${file_in_pheno} \
            --pheno ${pheno} \
            ${covarsPrefix} ${sep="," covars} \
            --family ${family} \
            ${ "--gxe " + gxe } \
            --chr ${chr} \
            ${variantListPrefix} ${file_in_variant_list} \
            --out ${file_out} \
            ${true="--gzip" false="" gzip}
    }

    output {
        File sumstats_out = file_out
    }

    runtime {
        docker: container_image
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

}
