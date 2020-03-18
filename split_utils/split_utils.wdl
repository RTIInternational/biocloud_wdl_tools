task split_vcf{
    # Utility for splitting a VCF file into chunks of N variants
    File input_vcf
    Int records_per_split
    String output_basename
    Boolean compress_outputs = true

    # Runtime environment
    String docker = "rtibiocloud/pigz:v2.4-8d966cb"
    Int cpu = 8
    Int unzip_cpu = cpu - 1
    Int mem_gb = 8
    Int max_retries = 3

    command <<<
        if [[ ${input_vcf} =~ \.gz$ ]]
        then
            # CASE: File is gzipped and needs to be decompressed on the fly (pigz for multithreaded)
            # Grab the header
            pigz -p ${unzip_cpu} -d -k -c ${input_vcf} | head -n 10000 | grep "^#" > header.txt

            # Split records
            pigz -p ${unzip_cpu} -d -k -c ${input_vcf} | grep -v "^#" | split -l ${records_per_split} - ${output_basename}.split.

        else
            # CASE: File is not gzipped and just do it normally
            # Grab the header
            head -n 10000 ${input_vcf} | grep "^#" > header.txt

            # Split recods
            grep -v "^#" ${input_vcf} | split -l ${records_per_split} - ${output_basename}.split.
        fi

        # Add headers to split records
        for i in ${output_basename}.split.*
        do
            # Add header to each split (with optional output compression)
            if [[ '${compress_outputs}' == 'true' ]]
            then
                cat header.txt $i | pigz -p ${cpu} -c > $i.vcf.gz
            else
                cat header.txt $i > $i.vcf
            fi
        done
    >>>

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        Array[File] split_vcfs = glob("${output_basename}.split.*.vcf*")
    }
}

task split_vcf_info{
    # Utility for splitting a VCF info file into chunks of N variants
    File input_vcf_info
    Int records_per_split
    String output_basename
    Boolean compress_outputs = true

    # Runtime environment
    String docker = "rtibiocloud/pigz:v2.4-8d966cb"
    Int cpu = 8
    Int unzip_cpu = cpu - 1
    Int mem_gb = 8
    Int max_retries = 3

    command <<<
        if [[ ${input_vcf_info} =~ \.gz$ ]]
        then
            # CASE: File is gzipped and needs to be decompressed on the fly (pigz for multithreaded)
            # Grab the header
            pigz -p ${unzip_cpu} -d -k -c ${input_vcf_info} | head -n 1 > header.txt

            # Split records
            pigz -p ${unzip_cpu} -d -k -c ${input_vcf_info} | tail -n +2 | split -l ${records_per_split} - ${output_basename}.split.

        else
            # CASE: File is not gzipped and just do it normally
            # Grab the header
            head -n 1 ${input_vcf_info} > header.txt

            # Split recods
            tail -n +2 ${input_vcf_info} | split -l ${records_per_split} - ${output_basename}.split.
        fi

        # Add headers to split records
        for i in ${output_basename}.split.*
        do
            # Add header to each split (with optional output compression)
            if [[ '${compress_outputs}' == 'true' ]]
            then
                cat header.txt $i | pigz -p ${cpu} -c > $i.info.gz
            else
                cat header.txt $i > $i.info
            fi
        done
    >>>

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        Array[File] split_vcf_infos = glob("${output_basename}.split.*.info*")
    }
}
