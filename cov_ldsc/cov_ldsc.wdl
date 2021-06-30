task cov_ldsc {
<<<<<<< HEAD
    String bfile
    Boolean? l2
    Int? ld_wind_cm
    File cov_eigenvec
    String out_prefix

    # Runtime attributes
    String docker = "rtibiocloud/cov_ldsc:v1_78e7ecc"
    Int cpu = 16
    Int mem_gb = 64
    Int max_retries = 3

    command {
        set -e
        python /opt/ldsc.py \
            --bfile ${bfile} \
            --l2 \
            --ld_wind_cm ${ld_wind_cm} \
            --cov ${cov_eigenvec} \
            --out ${out_prefix} 
    }

    output {
        File m_File = "${out_prefix}.M"
        File m_5_50_File = "${out_prefix}.M_5_50"
        File ldscore_out = "${out_prefix}.ldscore.gz"
    }

    runtime {
=======
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
>>>>>>> 585c5f793dda84e3ace62e2034921dd43c76f216
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

<<<<<<< HEAD
=======
    output {
        File out1 = "${out_prefix}.M"
        File out2 = "${out_prefix}.M_5_50"
        File out3 = "${out_prefix}.ldscore.gz"
        File log = "${out_prefix}.log"
    }
>>>>>>> 585c5f793dda84e3ace62e2034921dd43c76f216
}
