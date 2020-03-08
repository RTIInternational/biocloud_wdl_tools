task filter_bed{
    File bed_in
    File bim_in
    File fam_in
    String output_basename
    String input_prefix = basename(bed_in, ".bed")

    # Filtering options by chr
    String? chr
    String? not_chr
    Boolean? allow_extra_chr
    Boolean? autosome
    Boolean? autosome_par

    # Sample filtering
    File? keep_samples
    File? remove_samples
    File? keep_fam
    File? remove_fam

    # Site filtering by bed
    Array[File]? extract
    String? extract_bed_format
    Array[File]? exclude
    String? exclude_bed_format
    Array[File]? extract_intersect
    String? extract_intersect_bed_format
    Int? bed_border_bp
    Int? bed_border_kb

    # Qual/Filter/Info filtering
    Int? var_min_qual
    String? var_filter
    String? extract_if_info
    String? exclude_if_info
    Array[String]? require_info
    Array[String]? require_no_info

    # Site type filtering
    Boolean? snps_only
    String? snps_only_type
    String? from_id
    String? to_id
    Int? from_bp
    Int? to_bp
    Float? from_kb
    Float? to_kb
    Float? from_mb
    Float? to_mb

    # SNP-level filtering
    String? snp
    Int? window
    String? exclude_snp
    Array[String]? snps
    Array[String]? exclude_snps
    Boolean? force_intersect

    # Remove duplicates
    Boolean? rm_dup
    String? rm_dup_mode # error (default), retain-mismatch, exclude-mismatch, exclude-all, force-first

    # Arbitrary thinning
    Float? thin
    Int? thin_count
    Int? bp_space
    Float? thin_indiv
    Int? thin_indiv_count

    # Phenotype/Covariate based
    String? keep_if
    String? remove_if
    Array[String]? require_pheno
    Array[String]? require_covar
    File? keep_cats
    Array[String]? keep_cat_names
    String? keep_cat_pheno
    File? remove_cats
    Array[String]? remove_cat_names
    String? remove_cat_pheno

    # Genotype filtering
    Float? max_missing_geno_rate
    Float? max_missing_ind_rate

    # Allele and MAF filtering
    Int? min_alleles
    Int? max_alleles
    Float? min_maf
    Float? max_maf
    String? maf_mode
    Int? min_mac
    Int? max_mac
    String? mac_mode
    Boolean? nonfounders
    Boolean? maf_succ

    # HWE filtering
    Float? hwe_pvalue
    String? hwe_mode

    # Imputation quality
    Float? min_mach_r2
    Float? max_mach_r2
    Float? min_minimac3_r2
    Float? max_minimac3_r2
    String mach_r2_prefix = if(defined(min_mach_r2) || defined(max_mach_r2)) then "--mach-r2-filter " else ""
    String minimac3_r2_prefix = if(defined(min_minimac3_r2) || defined(max_minimac3_r2)) then "--minimac3-r2-filter " else ""

    # Sex filters
    Boolean? keep_females
    Boolean? keep_males
    Boolean? keep_nosex
    Boolean? remove_females
    Boolean? remove_males
    Boolean? remove_nosex

    # Founder status
    Boolean? keep_founders
    Boolean? keep_nonfounders

    String docker = "rtibiocloud/plink:v2.0-8875c1e"
    Int cpu = 1
    Int mem_gb = 2
    Int max_retries = 3

    command <<<

        # Create soft-links to input files in wrk dir so you don't actually have to copy them
        ln -s ${bed_in} ${input_prefix}.bed
        ln -s ${bim_in} ${input_prefix}.bim
        ln -s ${fam_in} ${input_prefix}.fam

        plink2 --bfile ${input_prefix} \
            --out ${output_basename} \
            --make-bed \
            ${'--chr ' + chr} \
            ${'--not-chr ' + not_chr} \
            ${true='--allow-extra-chr' false='' allow_extra_chr} \
            ${true='--autosome' false='' autosome} \
            ${true='--autosome-par' false='' autosome_par} \
            ${'--keep ' + keep_samples} \
            ${'--remove ' + remove_samples} \
            ${'--keep-fam ' + keep_fam} \
            ${'--remove-fam ' + remove_fam} \
            ${true='--extract' false="" extract} ${extract_bed_format} ${sep=" " extract} \
            ${true='--exclude' false="" exclude} ${exclude_bed_format} ${sep=" " exclude} \
            ${true='--extract-intersect' false="" extract_intersect} ${extract_intersect_bed_format} ${sep=" " extract_intersect} \
            ${'--bed-border-bp ' + bed_border_bp} \
            ${'--bed-border-kb ' + bed_border_kb} \
            ${'--var-min-qual ' + var_min_qual} \
            ${'--var-filter ' + var_filter} \
            ${'--extract-if-info "' + extract_if_info + '"'} \
            ${'--exclude-if-info "' + exclude_if_info + '"'} \
            ${true='--require-info' false="" require_info} ${sep=" " require_info} \
            ${true='--require-no-info' false="" require_no_info} ${sep=" " require_no_info} \
            ${true='--snps-only' false='' snps_only} ${snps_only_type} \
            ${'--from ' + from_id} \
            ${'--to ' + to_id} \
            ${'--snp ' + snp} \
            ${'--window ' +  window} \
            ${'--exclude-snp ' + exclude_snp} \
            ${true='--snps' false="" snps} ${sep=", " snps} \
            ${true='--exclude-snps' false="" exclude_snps} ${sep=", " exclude_snps} \
            ${'--from-bp ' + from_bp} \
            ${'--to-bp ' + to_bp} \
            ${'--from-kb ' + from_kb} \
            ${'--to-kb ' + to_kb} \
            ${'--from-mb ' + from_mb} \
            ${'--to-mb ' + to_mb} \
            ${true='--force-intersect' false='' force_intersect} \
            ${true='--rm-dup' false="" rm_dup} ${rm_dup_mode} \
            ${'--thin ' + thin} \
            ${'--thin-count ' + thin_count} \
            ${'--thin-indiv ' + thin_indiv} \
            ${'--thin-indiv-count ' + thin_indiv_count} \
            ${'--bp-space ' + bp_space} \
            ${'--keep-if "' + keep_if + '"'} \
            ${'--remove-if "' + remove_if + '"'} \
            ${true='--require-pheno' false='' require_pheno} ${sep=" " require_pheno} \
            ${true='--require-covar' false='' require_covar} ${sep=" " require_covar} \
            ${'--keep-cats ' + keep_cats} \
            ${true='--keep-cat-names' false= '' keep_cat_names} ${sep=" " keep_cat_names} \
            ${'--keep-cat-pheno ' + keep_cat_pheno} \
            ${'--remove-cats ' + remove_cats} \
            ${true='--remove-cat-names' false= '' remove_cat_names} ${sep=" " remove_cat_names} \
            ${'-remove-cat-pheno ' + remove_cat_pheno} \
            ${'--geno ' + max_missing_geno_rate} \
            ${'--mind ' + max_missing_ind_rate} \
            ${'--min-alleles ' + min_alleles} \
            ${'--max-alleles ' + max_alleles} \
            ${'--maf ' + min_maf} ${maf_mode} \
            ${'--max-maf ' + max_maf} ${maf_mode} \
            ${'--mac ' + min_mac} ${mac_mode} \
            ${'--max-mac ' + max_mac} ${mac_mode} \
            ${true='--maf-succ' false="" maf_succ} \
            ${'--hwe ' + hwe_pvalue} ${hwe_mode} \
            ${mach_r2_prefix} ${min_mach_r2} ${max_mach_r2} \
            ${minimac3_r2_prefix} ${min_minimac3_r2} ${max_minimac3_r2} \
            ${true='--keep-females' false="" keep_females} \
            ${true='--keep-males' false="" keep_males} \
            ${true='--keep-nosex' false="" keep_nosex} \
            ${true='--remove-females' false="" remove_females} \
            ${true='--remove-males' false="" remove_males} \
            ${true='--remove-nosex' false="" remove_nosex} \
            ${true='--keep-founders' false="" keep_founders} \
            ${true='--keep-nonfounders' false="" keep_nonfounders} \
            ${true='--nonfounders' false="" nonfounders}
    >>>

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File bed_out = "${output_basename}.bed"
        File bim_out = "${output_basename}.bim"
        File fam_out = "${output_basename}.fam"
        File plink_log = "${output_basename}.log"
    }
}
