task cov_ldsc {
    String plink_format_prefix
    File cov_file
    String out_prefix

    # Runtime environment
    String docker = "rtibiocloud/convert_variant_ids:v1_9a23978"
    Int cpu = 4
    Int mem_gb = 8
    Int max_retries = 3

    command{
        python /opt/ldsc.py \
            --bfile ${plink_format_prefix} \
            --l2 \
            --ld-wind-cm 20 \
            --cov ${cov_file} \
            --out ${out_prefix}
    }

    runtime{
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output {
        File out1 = "${out_prefix}.M"
        File out2 = "${out_prefix}.M_5_50"
        File out3 = "${out_prefix}.ldscore.gz"
        File log = "${out_prefix}.log"
    }
}
