version 1.1

task run_gxe {

    input {

        File file_bgen
        File file_bgi
        File file_sample
        File file_pheno
        String ancestry
        String pheno
        String omega3
        String file_out_prefix
        Int nchunks = 100

        # Runtime environment
        String docker_image = "rtibiocloud/pulmonary_longitudinal_gxe:v1_9c94ff2"
        String ecr_image = "rtibiocloud/pulmonary_longitudinal_gxe:v1_9c94ff2"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 2
        Int mem_gb = 8

    }

    command <<<
        set -e pipefail
        Rscript /opt/run_gxe.R \
            --working_dir "/data" \
            --file-bgen "~{file_bgen}" \
            --file-bgi "~{file_bgi}" \
            --file-sample "~{file_sample}" \
            --file-pheno "~{file_pheno}" \
            --ancestry "~{ancestry}" \
            --pheno "~{pheno}" \
            --omega3 "~{omega3}" \
            --file-out-prefix "~{file_out_prefix}" \
            --ncores ~{cpu} > \
            --nchunks ~{nchunks}
            "~{file_out_prefix}.log" 2>&1
    >>>

    runtime{
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
    }

    output {
        File gxe_results = "~{file_out_prefix}.tsv"
        File log = "~{file_out_prefix}.log"
    }
}
