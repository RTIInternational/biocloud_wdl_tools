task cov_ldsc {
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
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

}
