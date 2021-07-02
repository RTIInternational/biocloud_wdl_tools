task cov_ldsc {
    String bfile
    Boolean? l2
    Float? ld_wind_cm
    File cov_eigenvec
    String out_prefix
    Float mem

    # Runtime attributes
    String docker = "rtibiocloud/cov_ldsc:v1_78e7ecc"
    Int cpu = 8
    Int mem_gb = ${mem} 
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
        File logFile = "${out_prefix}.log
    }

}

