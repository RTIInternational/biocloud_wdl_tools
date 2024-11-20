version 1.1

task run_gxe {

    input {

        String work_dir
        File file_rds
        File file_bgi
        File file_sample
        File file_pheno
        String chr
        String ancestry
        String pheno
        String omega3
        Int chunk_size = 2000
        String file_out_prefix

        # Runtime environment
        String docker_image = "rtibiocloud/pulmonary_longitudinal_gxe:v1_ecf0919"
        String ecr_image = "rtibiocloud/pulmonary_longitudinal_gxe:v1_ecf0919"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 1
        Int mem_gb = 2

    }

    command <<<
        Rscript /opt/run_gxe.R \
            --work-dir "~{work_dir}" \
            --file-rds "~{file_rds}" \
            --file-bgi "~{file_bgi}" \
            --file-sample "~{file_sample}" \
            --file-pheno "~{file_pheno}" \
            --chr "~{chr}" \
            --ancestry "~{ancestry}" \
            --pheno "~{pheno}" \
            --omega3 "~{omega3}" \
            --chunk-size ~{chunk_size} \
            --file-out-prefix "~{file_out_prefix}"
    >>>

    runtime{
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
    }

    output {
        Array[File] gxe_results_by_chunk = glob("~{file_out_prefix}_chunk_*.tsv")
    }
}
