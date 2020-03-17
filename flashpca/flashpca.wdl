task flashpca{
    File bed_in
    File bim_in
    File fam_in
    String input_prefix = basename(sub(bed_in, "\\.gz$", ""), ".bed")

    Int? ndim
    String? standx    # Standardization for genotypes (binom2 | binom)
    String? standy   # Standardization for phenotypes (sd | binom2)
    Int? div         # Whether to divide eigenvalues by p, n-1, or none (p|n1|none)
    Int? tol         # Tolerance for PCA iterations

    Boolean? batch
    Int? blocksize
    Int? seed
    File? pheno
    Int? precision

    Boolean? project
    File? inload
    File? inmaf
    File? inmeansd

    Boolean? verbose
    Boolean? notime
    Boolean? check

    # Runtime environment
    String docker = "rtibiocloud/flashpca:v2.0-9b4c1b9"
    Int cpu = 1
    Int mem_gb = 1
    Int mem_mb = mem_gb * 1000

    command {
        mkdir plink_input

        # Bed file preprocessing
        if [[ ${bed_in} =~ \.gz$ ]]; then
            # Append gz tag to let plink know its gzipped input
            gunzip -c ${bed_in} > plink_input/${input_prefix}.bed
        else
            # Otherwise just create softlink with normal
            ln -s ${bed_in} plink_input/${input_prefix}.bed
        fi

        # Bim file preprocessing
        if [[ ${bim_in} =~ \.gz$ ]]; then
            gunzip -c ${bim_in} > plink_input/${input_prefix}.bim
        else
            ln -s ${bim_in} plink_input/${input_prefix}.bim
        fi

        # Fam file preprocessing
        if [[ ${fam_in} =~ \.gz$ ]]; then
            gunzip -c ${fam_in} > plink_input/${input_prefix}.fam
        else
            ln -s ${fam_in} plink_input/${input_prefix}.fam
        fi

        # Run flashPCA
        flashpca --bfile plink_input/${input_prefix} \
            --memory ${mem_mb} \
            --numthreads ${cpu} \
            ${'--blocksize ' + blocksize} \
            ${'--seed ' + seed} \
            ${true='--batch' false="" batch} \
            ${'--pheno ' + pheno} \
            ${'--ndim ' + ndim} \
            ${'--standx ' + standx} \
            ${'--standy ' + standy} \
            ${'--div ' + div} \
            ${'--tol ' + tol} \
            ${true='--project' false="" project} \
            ${'--inload ' + inload} \
            ${'--inmaf ' + inmaf} \
            ${'--inmeansd ' + inmeansd} \
            ${'--inload ' + inload} \
            ${'--precision ' + precision} \
            ${true='--verbose' false="" verbose} \
            ${true='--notime' false="" notime} \
            ${true='--check' false="" check}
    }

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
    }

    output {
        File eigenvectors = "eigenvectors.txt"
        File pcs = "pcs.txt"
        File eigenvalues = "eigenvalues.txt"
        File pve = "pve.txt"
    }
}