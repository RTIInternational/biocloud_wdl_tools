version 1.1

task merge_vcfs{
    # Utility for splitting a VCF file into chunks of N variants

    input {
        Array[File] input_vcfs
        Array[File]? input_vcf_indices
        String output_filename

        Boolean need_index = if(defined(input_vcf_indices)) then false else true

        # Runtime environment
        String docker_image = "rtibiocloud/bcftools:v1.9-8875c1e"
        String ecr_image = "rtibiocloud/bcftools:v1.9-8875c1e"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 16
        Int mem_gb = 16
        Int max_retries = 3
    }

    command <<<
        # Index files if necessary
        if [[ '~{need_index}' == 'true' ]]; then
            for file in ~{sep(" ", input_vcfs)}; do
                # Send to the background so things get index in parallel
                bcftools index --threads 1 $file &
            done
            # Wait for jobs to complete
            wait
        fi

        # Merge into single VCF
        bcftools merge --threads ~{cpu} -o ~{output_filename} ~{sep(" ", input_vcfs)}
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
    }

    output{
        File merged_vcf = "~{output_filename}"
    }
}