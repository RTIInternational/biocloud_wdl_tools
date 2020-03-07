task merge_vcfs{
    # Utility for splitting a VCF file into chunks of N variants
    Array[File] input_vcfs
    String output_filename

    # Runtime environment
    String docker = "rtibiocloud/bcftools:v1.9-8875c1e"
    Int cpu = 8
    Int mem_gb = 16
    Int max_retries = 3

    command <<<
        bcftools merge -o ${output_filename} ${sep=" " input_vcfs}
    >>>

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File merged_vcf = "${output_filename"
    }
}