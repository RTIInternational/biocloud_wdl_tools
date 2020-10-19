task genesis {
    File fileInGeno
    File fileInPheno
    String fileOut
    String genoFormat       # Options: gds
    String pheno            # Column name in phenotype file
    Array[String]? covars   # Array of column names of covars
    String family           # Options: gaussian
    String? gxE             # Column name in phenotype file for GxE interaction
    Boolean? gzip

    String covarsPrefix = if defined(covars) then "--covars "  else ""

    # Runtime attributes
    String docker = "rtibiocloud/genesis:v3.11_aeebf78"
    Int cpu = 1
    Int mem_gb = 2
    Int max_retries = 3

    command {
        genesis.R 
            --in-geno ${fileInGeno} \
            --in-geno-format ${genoFormat} \
	        --in-pheno ${fileInPheno} \
	        --pheno ${pheno} \
            ${covarsPrefix} ${sep="," covars} \
            --family ${family} \
            ${ "--gxe " + gxE } \
            --out fileOut \
		    ${true="--gzip" false="" gzip}
    }

    output {
        File assoc_file = fileOut
    }

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

}
