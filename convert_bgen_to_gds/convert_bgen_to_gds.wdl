task convert_bgen_to_gds {
    File in_bgen
    String out_gds
    String storage_option = "LZMA_RA"
    String float_type = "double"
    String geno = "FALSE"
    String dosage = "FALSE"
    String prob = "FALSE"
    String optimize = "FALSE"
    Int parallel = 8

    # Runtime environment
    String docker = "rtibiocloud/convert_bgen_to_gds:v1_ea21a9b"
    Int cpu = ${parallel}
    Int mem_gb = 8
    Int max_retries = 3

    command{
        /opt/convert_bgen_to_gds.R \
            --in-bgen ${in_bgen} \
            --out-gds ${out_gds} \
            --storage-option ${storage_option} \
            --float-type ${float_type} \
            --geno ${geno} \
            --dosage ${dosage} \
            --prob ${prob} \
            --optimize ${optimize} \
            --parallel ${parallel}
    }

    runtime{
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output {
        File output_file = "${out_gds}"
    }
}
