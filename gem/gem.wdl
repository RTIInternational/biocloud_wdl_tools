task gem {

    # Input/Output File Options:
    File phenoFile
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
    String out
    String? outputStyle

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


    # Set file options
    String phenoFileParameter = if defined(phenoFile) then ${ "--pheno-file " + phenoFile } else ""
    String genotypeFileParameter = ""
    Boolean setGenotypeFile = true
    if (defined(bgen)) {
        genotypeFileParameter = "--bgen " + bgen
        if (defined(sample)) {
            genotypeFileParameter = genotypeFileParameter + " --sample " + sample
        }
        setGenotypeFile = false
    }
    if (setGenotypeFile && defined(pfile)) {
        genotypeFileParameter = "--pfile " + pfile
        setGenotypeFile = false
    }
    if (setGenotypeFile && defined(pgen)) {
        genotypeFileParameter = "--pgen " + pgen
        if (defined(pvar)) {
            genotypeFileParameter = genotypeFileParameter + " --pvar " + pvar
        }
        if (defined(psam)) {
            genotypeFileParameter = genotypeFileParameter + " --psam " + psam
        }
        setGenotypeFile = false
    }
    if (setGenotypeFile && defined(bfile)) {
        genotypeFileParameter = "--bfile " + bfile
        setGenotypeFile = false
    }
    if (setGenotypeFile && defined(bed)) {
        genotypeFileParameter = "--bed " + bed
        if (defined(bim)) {
            genotypeFileParameter = "--bim " + bim
        }
        if (defined(fam)) {
            genotypeFileParameter = genotypeFileParameter + " --fam " + fam
        }
        setGenotypeFile = false
    }
    String outParameter = if defined(out) then ${ "--out " + out } else ""
    String outputStyleParameter = if defined(outputStyle) then ${ "--output-style " + outputStyle } else ""
    String outLog = if defined(out) then ${ out + ".log" } else ""

    # Set pheno file options
    String sampleidNameParameter = if defined(sampleidName) then ${ "--sampleid-name " + sampleidName } else ""
    String phenoNameParameter = if defined(phenoName) then ${ "--pheno-name " + phenoName } else ""
    String exposureNamesParameter = if defined(exposureNames) then ${ "--exposure-names " + exposureNames } else ""
    String intCovarNamesParameter = if defined(intCovarNames) then ${ "--int-covar-names " + intCovarNames } else ""
    String covarNamesParameter = if defined(covarNames) then ${ "--covar-names " + covarNames } else ""
    String robustParameter = if defined(robust) then ${ "--robust " + robust } else ""
    String tolParameter = if defined(tol) then ${ "--tol " + tol } else ""
    String delimParameter = if defined(delim) then ${ "--delim " + delim } else ""
    String missingValueParameter = if defined(missingValue) then ${ "--missing-value " + missingValue } else ""
    String centerParameter = if defined(center) then ${ "--center " + center } else ""
    String scaleParameter = if defined(scale) then ${ "--scale " + scale } else ""
    String categoricalNames = if defined(categoricalNames) then ${ "--categorical-names " + categoricalNames } else ""
    String catThresholdParameter = if defined(catThreshold) then ${ "--cat-threshold " + catThreshold } else ""

    # Set filter options
    String mafParameter = if defined(maf) then ${ "--maf " + maf } else ""
    String missGenoCutoffParameter = if defined(missGenoCutoff) then ${ "--miss-geno-cutoff " + missGenoCutoff } else ""
    String includeSnpFileParameter = if defined(includeSnpFile) then ${ "--include-snp-file " + includeSnpFile } else ""

    # Set performance options
    String threadsParameter = if defined(threads) then ${ "--threads " + threads } else ""
    String streamSnpsParameter = if defined(streamSnps) then ${ "--stream-snps " + streamSnps } else ""


    # Runtime attributes
    String docker = "rtibiocloud/gem:v1.4.2_05922f6"
    Int cpu = 1
    Int mem_gb = 2
    Int max_retries = 3


    command {
        gem phenoFileParameter \ 
            genotypeFileParameter \
            outParameter \
            sampleidNameParameter \
            phenoNameParameter \
            outputStyleParameter \
            exposureNamesParameter \
            intCovarNamesParameter \
            covarNamesParameter \
            robustParameter \
            tolParameter \
            delimParameter \
            missingValueParameter \
            centerParameter \
            scaleParameter \
            categoricalNames \
            catThresholdParameter \
            mafParameter \
            missGenoCutoffParameter \
            includeSnpFileParameter \
            threadsParameter \
            streamSnpsParameter > \
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
