task gem {

    # Input/Output File Options:
    File phenoFile
    String out
    File? bgen
    File? sample
    File? pfile
    File? pgen
    File? pvar
    File? psam
    File? bfile
    File? bed
    File? bim
    File? fam
    String? outputStyle = minimum
    String? outLog = out + ".log"

    # Phenotype File Options:
    String sampleidName
    String phenoName
    String? exposureNames
    String? intCovarNames
    String? covarNames
    Boolean? robust
    Float? tol
    String? delim
    String? missingValue
    Boolean? center
    Boolean? scale
    String? categoricalNames
    String? catThreshold

    # Filtering Options:
    Float? maf
    Float? missGenoCutoff
    String? includeSnpFile

    # Performance Options:
    Int? threads
    Int? streamSnps

    # Runtime attributes
    String docker = "rtibiocloud/gem:v1.4.2_05922f6"
    Int cpu = 1
    Int mem_gb = 2
    Int max_retries = 3


    command {
        gem --pheno-file + ${phenoFile} \ 
            --out ${out} \
            --sampleid-name " + sampleidName \
            --pheno-name " + phenoName \
            ${"--bgen" + bgen} \
            ${"--sample " + sample} \
            ${"--pfile " + pfile} \
            ${"--pgen " + pgen} \
            ${"--pvar " + pvar} \
            ${"--psam " + psam} \
            ${"--bfile " + bfile} \
            ${"--bed " + bed} \
            ${"--bim " + bim} \
            ${"--fam " + fam} \
            ${"--output-style " + outputStyle} \
            ${"--exposure-names " + exposureNames} \
            ${"--int-covar-names " + intCovarNames} \
            ${"--covar-names " + covarNames} \
            ${"--robust " + robust} \
            ${"--tol " + tol} \
            ${"--delim " + delim} \
            ${"--missing-value " + missingValue} \
            ${"--center " + center} \
            ${"--scale " + scale} \
            ${"--categorical-names " + categoricalNames} \
            ${"--cat-threshold " + catThreshold} \
            ${"--maf " + maf} \
            ${"--miss-geno-cutoff " + missGenoCutoff} \
            ${"--include-snp-file " + includeSnpFile} \
            ${"--threads " + threads} \
            ${"--stream-snps " + streamSnps} > \
            outLog
    }

    output {
        File assoc_outputs = out
        File log_file = outLog
    }

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

}
