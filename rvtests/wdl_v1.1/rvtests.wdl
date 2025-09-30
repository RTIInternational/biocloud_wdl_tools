version 1.1

task rvtests {

    input {
        File inVCF
        File phenoFile
        String output_basename
        File? covarFile
        Boolean inverseNormal = false
        Boolean useResidualAsPhenotype = false
        Boolean outputRaw = false
        Boolean sex = false
        Boolean qtl = false
        Boolean multipleAllele = false
        Boolean xHemi = false
        String? xLabel
        String? xParRegion
        String? dosage
        String? phenoName
        Int? mpheno

        Array[String]? covarsMaybe
        Array[String]? singleTestsMaybe
        Array[String]? burdenTestsMaybe
        Array[String]? vtTestsMaybe
        Array[String]? kernelTestsMaybe
        Array[String]? metaTestsMaybe

        String covarsPrefix = if defined(covarsMaybe) then "--covar-name "  else ""
        String singlePrefix = if defined(singleTestsMaybe) then "--single " else ""
        String burdenPrefix = if defined(burdenTestsMaybe) then "--burden " else ""
        String vtPrefix = if defined(vtTestsMaybe) then "--vt " else ""
        String kernelPrefix =if defined(kernelTestsMaybe) then "--kernel " else ""
        String metaPrefix = if defined(metaTestsMaybe) then "--meta " else ""

        File? peopleIncludeFile
        Float? freqUpper
        Float? freqLower
        File? rangeFile
        File? siteFile
        String? site
        Int? siteMACMin
        Int ?siteDepthMin
        Int ?siteDepthMax
        String? annoType
        String? impute
        Boolean imputePheno = false
        File? geneFile
        Array[String]? genes
        String genesPrefix = if defined(genes) then "--genes " else ""
        File? setFile
        Array[String]? set
        String setPrefix = if defined(set) then "--set " else ""

        File? kinship
        File? xHemiKinship
        File? kinshipEigen
        File? xHemiKinshipEigen
        Boolean hideCovar = false
        Boolean outputID = false

        # Runtime attributes
        String docker_image = "rtibiocloud/rvtests:v2.1.0-8d966cb"
        String ecr_image = "rtibiocloud/rvtests:v2.1.0-8d966cb"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 1
        Int mem_gb = 2
    }

    command <<<
        set -e
        
        rvtest --inVcf ~{inVCF} \
	        --out ~{output_basename} \
	        --pheno ~{phenoFile} \
		    ~{"--pheno-name " + phenoName} \
		    ~{"--mpheno " + mpheno} \
		    ~{"--covar " + covarFile } \
		    ~{"--xLabel " + xLabel } \
		    ~{"--xParRegion " + xParRegion } \
		    ~{"--dosage " + dosage } \
            ~{if outputRaw then '--outputRaw' else ''}
            ~{if sex then '--sex' else ''}
            ~{if qtl then '--qtl' else ''}
            ~{if multipleAllele then '--multipleAllele' else ''}
            ~{if inverseNormal then '--inverseNormal' else ''}
            ~{if useResidualAsPhenotype then '--useResidualAsPhenotype' else ''} \
            ~{if xHemi then '--xHemi' else ''} \
            ~{covarsPrefix} ~{sep(",", select_first([covarsMaybe, []]))} \
            ~{singlePrefix} ~{sep(",", select_first([singleTestsMaybe, []]))} \
            ~{burdenPrefix} ~{sep(",", select_first([burdenTestsMaybe, []]))} \
            ~{vtPrefix} ~{sep(",", select_first([vtTestsMaybe, []]))} \
            ~{kernelPrefix} ~{sep(",", select_first([kernelTestsMaybe, []]))} \
            ~{metaPrefix} ~{sep(",", select_first([metaTestsMaybe, []]))} \
            ~{ "--peopleIncludeFile " + peopleIncludeFile } \
            ~{ "--freqUpper " + freqUpper} \
            ~{ "--freqLower " + freqLower} \
            ~{ "--rangeFile " + rangeFile } \
            ~{ "--siteFile " +  siteFile } \
            ~{ "--siteMACMin " +  siteMACMin } \
            ~{ "--siteDepthMin " +  siteDepthMin } \
            ~{ "--siteDepthMax " +  siteDepthMax } \
            ~{ "--annoType " +  annoType } \
            ~{ "--impute " +  impute } \
            ~{if imputePheno then '--imputePheno' else ''} \
            ~{ "--geneFile " +  geneFile } \
            ~{genesPrefix} ~{sep(",", genes)} \
            ~{ "--setFile " +  setFile } \
            ~{setPrefix} ~{sep(",", set)} \
            ~{ "--kinship " +  kinship } \
            ~{ "--xHemiKinship " +  xHemiKinship } \
            ~{ "--kinshipEigen " +  kinshipEigen } \
            ~{ "--xHemiKinshipEigen " +  xHemiKinshipEigen } \
            ~{if hideCovar then '--hide-covar' else ''} \
            ~{if outputID then '--outputID' else ''} \
            ~{"--numThread " + cpu }
    >>>

    output {
        Array[File] assoc_outputs = glob( "~{output_basename}*.assoc*.gz" )
        File log_file = "~{output_basename}.log"
    }

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
    }

}

task vcf2kinship  {

    input {
        File? inputVcf
        File? pedfile
        String? dosage
        Boolean xHemi = false
        String? xLabel
        Float? maxMiss
        Float? minMAF
        Float? minSiteQual

        String output_basename
        Boolean useBaldingNicols = false
        Boolean useIBS = false

        # Runtime attributes
        String docker_image = "rtibiocloud/rvtests:v2.1.0-8d966cb"
        String ecr_image = "rtibiocloud/rvtests:v2.1.0-8d966cb"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 4
        Int mem_gb = 8
    }

    command <<<
        set -e
        
        vcf2kinship  ~{"--inVcf " + inputVcf} \
            ~{"--ped " + pedfile} \
            ~{if useBaldingNicols then "--bn " + dosage else ''} \
            ~{if useIBS then "--ibs " + dosage else ''} \
            ~{if xHemi then "--xHemi" else ''} \
            ~{"--dosage " + dosage } \
            ~{"--xLabel " + xLabel } \
            ~{"--maxMiss " + maxMiss } \
            ~{"--minMAF " + minMAF } \
            ~{"--minSiteQual " + minSiteQual } \
            --thread ~{cpu} \
            --out ~{output_basename}

        # Hack because WDL doesn't allow optional output files
        touch ~{output_basename}.kinship
        touch ~{output_basename}.xHemi.kinship
    >>>

    output {
        File kinship_matrix = "~{output_basename}.kinship"
        File xHemi_kinship_matrix = "~{output_basename}.xHemi.kinship"
        File kinship_log = "~{output_basename}.vcf2kinship.log"
    }

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
    }
}

task combineKinship  {

    input {
        Array[File] kinship_matrices
        Array[File] vcf2kinship_logs
        String output_basename

        # Runtime attributes
        String docker_image = "rtibiocloud/rvtests:v2.1.0-8d966cb"
        String ecr_image = "rtibiocloud/rvtests:v2.1.0-8d966cb"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 16
        Int mem_gb = 16
    }

    command <<<
        # Apparently the logs have to be in the same damn directory as the kinship mats

        set -e

        # Copy kinship mats to working directory
        for file in ~{sep(" ", kinship_matrices)}; do
            cp $file .
        done

        # Copy log files to working directory
        for file in ~{sep(" ", vcf2kinship_logs)}; do
            cp $file .
        done

        combineKinship \
            --out ~{output_basename} \
            --thread ~{cpu} \
            ./*.kinship
    >>>

    output {
        File kinship_matrix = "~{output_basename}.kinship"
    }

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
    }
}
