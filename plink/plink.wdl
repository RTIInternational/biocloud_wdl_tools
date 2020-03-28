task make_bed_plink2{
    File bed_in
    File bim_in
    File fam_in
    String output_basename
    String input_prefix = basename(sub(bed_in, "\\.gz$", ""), ".bed")

    # Strand flipping
    File? flip

    # Filtering options by chr
    String? chr
    String? not_chr
    Boolean? allow_extra_chr
    Boolean? autosome
    Boolean? autosome_par
    Array[String]? chrs
    Array[String]? not_chrs

    String chrs_prefix = if(defined(chrs)) then "--chr" else ""
    String not_chrs_prefix = if(defined(not_chrs)) then "--not-chr" else ""

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
    Float? geno
    Float? mind

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

    # Other data management options
    Boolean? sort_vars
    String? sort_vars_mode

    # Re-coding heterozygous haploids
    Boolean? set_hh_missing
    Boolean? hh_missing_keep_dosage

    Boolean? split_x
    Boolean? merge_x
    String? build_code
    Boolean? split_no_fail
    Boolean? merge_no_fail



    String docker = "rtibiocloud/plink:v2.0-4d3bad3"
    Int cpu = 1
    Int mem_gb = 2
    Int max_retries = 3

    command <<<

        # Get everything in same directory while preserving .gz extensions
        # This is annoying but apparently necessary
        # This is why it's dumb to make a program that requires everything be in the same directory
        # The upside here is bed/bim/fam files will always be coerced to have same basename
        # So you don't have to worry combining files from the same dataset that may have different inputs

        mkdir plink_input

        # Bed file preprocessing
        if [[ ${bed_in} =~ \.gz$ ]]; then
            # Append gz tag to let plink know its gzipped input
            unpigz -p ${cpu} -c ${bed_in} > plink_input/${input_prefix}.bed
        else
            # Otherwise just create softlink with normal
            ln -s ${bed_in} plink_input/${input_prefix}.bed
        fi

        # Bim file preprocessing
        if [[ ${bim_in} =~ \.gz$ ]]; then
            unpigz -p ${cpu} -c ${bim_in} > plink_input/${input_prefix}.bim
        else
            ln -s ${bim_in} plink_input/${input_prefix}.bim
        fi

        # Fam file preprocessing
        if [[ ${fam_in} =~ \.gz$ ]]; then
            unpigz -p ${cpu} -c ${fam_in} > plink_input/${input_prefix}.fam
        else
            ln -s ${fam_in} plink_input/${input_prefix}.fam
        fi

        # Now run plink2
        plink2 --bfile plink_input/${input_prefix} \
            --out ${output_basename} \
            --make-bed \
            --threads ${cpu} \
            ${'--chr ' + chr} \
            ${'--not-chr ' + not_chr} \
            ${true='--allow-extra-chr' false='' allow_extra_chr} \
            ${true='--autosome' false='' autosome} \
            ${true='--autosome-par' false='' autosome_par} \
            ${chrs_prefix} ${sep=", " chrs} \
            ${not_chrs_prefix} ${sep=", " not_chrs} \
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
            ${true='--nonfounders' false="" nonfounders} \
            ${true='--sort-vars' false="" sort_vars} ${sort_vars_mode} \
            ${true='--set-hh-missing' false="" set_hh_missing} ${true='keep-dosage' false="" hh_missing_keep_dosage}
            ${'--flip ' + flip} \
            ${'--geno ' + geno} \
            ${'--mind ' + mind} \
            ${true='--split-par' false="" split_x} ${build_code} ${true='no-fail' false="" split_no_fail} \
            ${true='--merge-par' false="" merge_x} ${true='no-fail' false="" merge_no_fail}
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

task make_bed{
    File bed_in
    File bim_in
    File fam_in
    String output_basename
    String input_prefix = basename(sub(bed_in, "\\.gz$", ""), ".bed")

    # Strand flipping
    File? flip

    # Missingness filters
    Float? geno
    Float? mind

    # Sample filtering
    File? keep_samples
    File? remove_samples
    File? keep_fam
    File? remove_fam

    # Site filtering by bed
    File? extract
    File? exclude
    Boolean? extract_range
    Boolean? exclude_range
    String? extract_range_opt = if(defined(extract_range) && extract_range) then "range" else ""
    String? exclude_range_opt = if(defined(exclude_range) && exclude_range) then "range" else ""
    String extract_prefix = if(defined(extract)) then "--extract" else ""
    String exclude_prefix = if(defined(exclude)) then "--exclude" else ""

    # Filtering by sample cluster
    File? keep_clusters
    Array[String]? keep_cluster_names
    File? remove_clusters
    Array[String]? remove_cluster_names

    # Set gene set membership
    Array[String]? gene
    Boolean? gene_all

    # Filter by attributes files
    File? attrib
    String? attrib_filter
    File? attrib_indiv
    String? attrib_indiv_filter

    # Filtering options by chr
    String? chr
    String? not_chr
    Boolean? allow_extra_chr
    Boolean? autosome
    Boolean? autosome_xy
    Boolean? prune
    Array[String]? extra_chrs
    Array[String]? chrs
    Array[String]? not_chrs

    String chrs_prefix = if(defined(chrs)) then "--chr" else ""
    String not_chrs_prefix = if(defined(not_chrs)) then "--not-chr" else ""

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
    File? filter
    Array[String]? filter_values
    Int? mfilter

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

    # Sex filters
    Boolean? allow_no_sex
    Boolean? must_have_sex
    Boolean? filter_females
    Boolean? filter_males
    Boolean? filter_controls
    Boolean? filter_cases

    # Founder status
    Boolean? filter_founders
    Boolean? filter_nonfounders

    # Other data management options
    Boolean? sort_vars
    String? sort_vars_mode

    # Re-coding heterozygous haploids
    Boolean? set_hh_missing
    Boolean? split_x
    String? build_code
    Boolean? merge_x
    Boolean? split_no_fail
    Boolean? merge_no_fail


    # Updating files
    File? update_ids
    File? update_parents
    File? update_sex
    Int? update_sex_n

    String docker = "rtibiocloud/plink:v1.9-77ee25f"
    Int cpu = 1
    Int mem_gb = 2
    Int max_retries = 3

    command <<<
        # Get everything in same directory while preserving .gz extensions
        # This is annoying but apparently necessary
        # This is why it's dumb to make a program that requires everything be in the same directory
        # The upside here is bed/bim/fam files will always be coerced to have same basename
        # So you don't have to worry combining files from the same dataset that may have different inputs

        mkdir plink_input

        # Bed file preprocessing
        if [[ ${bed_in} =~ \.gz$ ]]; then
            # Append gz tag to let plink know its gzipped input
            unpigz -p ${cpu} -c ${bed_in} > plink_input/${input_prefix}.bed
        else
            # Otherwise just create softlink with normal
            ln -s ${bed_in} plink_input/${input_prefix}.bed
        fi

        # Bim file preprocessing
        if [[ ${bim_in} =~ \.gz$ ]]; then
            unpigz -p ${cpu} -c ${bim_in} > plink_input/${input_prefix}.bim
        else
            ln -s ${bim_in} plink_input/${input_prefix}.bim
        fi

        # Fam file preprocessing
        if [[ ${fam_in} =~ \.gz$ ]]; then
            unpigz -p ${cpu} -c ${fam_in} > plink_input/${input_prefix}.fam
        else
            ln -s ${fam_in} plink_input/${input_prefix}.fam
        fi

        # Now run plink2
        plink --bfile plink_input/${input_prefix} \
            --out ${output_basename} \
            --make-bed \
            --threads ${cpu} \
            ${'--keep ' + keep_samples} \
            ${'--remove ' + remove_samples} \
            ${'--keep-fam ' + keep_fam} \
            ${'--remove-fam ' + remove_fam} \
            ${extract_prefix} ${extract_range_opt} ${extract} \
            ${exclude_prefix} ${exclude_range_opt} ${exclude} \
            ${'--keep-clusters ' + keep_clusters} \
            ${'--remove-clusters ' + remove_clusters} \
            ${true='--keep-cluster-names' false="" keep_cluster_names} ${sep=" " keep_cluster_names} \
            ${true='--remove-cluster-names' false="" remove_cluster_names} ${sep=" " remove_cluster_names} \
            ${true='--gene' false="" gene} ${sep=" " gene} \
            ${true='--gene-all' false="" gene_all} \
            ${true='--attrib' false="" attrib} ${attrib} ${attrib_filter} \
            ${true='--attrib-indiv' false="" attrib_indiv} ${attrib_indiv} ${attrib_indiv_filter} \
            ${'--chr ' + chr} \
            ${'--not-chr ' + not_chr} \
            ${chrs_prefix} ${sep=", " chrs} \
            ${not_chrs_prefix} ${sep=", " not_chrs} \
            ${true='--allow-extra-chr' false='' allow_extra_chr} ${extra_chrs}\
            ${true='--autosome' false='' autosome} \
            ${true='--autosome-xy' false='' autosome_xy} \
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
            ${true='--rm-dup' false="" rm_dup} ${rm_dup_mode} \
            ${'--thin ' + thin} \
            ${'--thin-count ' + thin_count} \
            ${'--thin-indiv ' + thin_indiv} \
            ${'--thin-indiv-count ' + thin_indiv_count} \
            ${'--bp-space ' + bp_space} \
            ${true='--filter' false="" filter} ${filter} ${sep=" " filter_values} \
            ${true='--mfilter' false="" mfilter} ${mfilter} \
            ${'--geno ' + max_missing_geno_rate} \
            ${'--mind ' + max_missing_ind_rate} \
            ${true='--prune' false='' prune} \
            ${'--min-alleles ' + min_alleles} \
            ${'--max-alleles ' + max_alleles} \
            ${'--maf ' + min_maf} ${maf_mode} \
            ${'--max-maf ' + max_maf} ${maf_mode} \
            ${'--mac ' + min_mac} ${mac_mode} \
            ${'--max-mac ' + max_mac} ${mac_mode} \
            ${true='--maf-succ' false="" maf_succ} \
            ${'--hwe ' + hwe_pvalue} ${hwe_mode} \
            ${true='--filter-females' false="" filter_females} \
            ${true='--filter-males' false="" filter_males} \
            ${true='--filter-cases' false="" filter_cases} \
            ${true='--filter-controls' false="" filter_controls} \
            ${true='--filter-founders' false="" filter_founders} \
            ${true='--filter-nonfounders' false="" filter_nonfounders} \
            ${true='--nonfounders' false="" nonfounders} \
            ${true='--sort-vars' false="" sort_vars} ${sort_vars_mode} \
            ${true='--set-hh-missing' false="" set_hh_missing} \
            ${true='--split-x' false="" split_x} ${build_code} ${true='no-fail' false="" split_no_fail} \
            ${true='--merge-x' false="" merge_x} ${true='no-fail' false="" merge_no_fail} \
            ${'--update-ids ' + update_ids} \
            ${'--update-parents ' + update_parents} \
            ${'--update-sex ' + update_sex} ${update_sex_n} \
            ${'--flip ' + flip} \
            ${'--geno ' + geno} \
            ${'--mind ' + mind}
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

task merge_beds{
    Array[File] bed_in
    Array[File] bim_in
    Array[File] fam_in
    String output_basename

    String docker = "rtibiocloud/plink:v1.9-9e70778"
    Int cpu = 4
    Int mem_gb = 8
    Int max_retries = 3

    command <<<
        # Write bed files to file
        for file in ${sep=" " bed_in}; do
            echo "$file" >> bed_files.txt
        done

        # Write bim files to file
        for file in ${sep=" " bim_in}; do
            echo "$file" >> bim_files.txt
        done

        # Write fam files to file
        for file in ${sep=" " fam_in}; do
            echo "$file" >> fam_files.txt
        done

        # Merge bed/bim/bam links into merge-list file
        paste -d " " bed_files.txt bim_files.txt fam_files.txt > merge_list.txt

        # Merge bed file
        plink --make-bed \
            --threads ${cpu} \
            --merge-list merge_list.txt \
            --out ${output_basename}
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

task merge_two_beds{
    File bed_in_a
    File bed_in_b
    File bim_in_a
    File bim_in_b
    File fam_in_a
    File fam_in_b
    String input_prefix_a = basename(sub(bed_in_a, "\\.gz$", ""), ".bed")
    String input_prefix_b = basename(sub(bed_in_b, "\\.gz$", ""), ".bed")
    Int? merge_mode
    Boolean ignore_errors = false
    String output_basename

    String docker = "rtibiocloud/plink:v1.9-9e70778"
    Int cpu = 4
    Int mem_gb = 8
    Int max_retries = 3

    command <<<

        mkdir plink_input

        # Create softlinks for bed A
        ln -s ${bed_in_a} plink_input/${input_prefix_a}.bed
        ln -s ${bim_in_a} plink_input/${input_prefix_a}.bim
        ln -s ${fam_in_a} plink_input/${input_prefix_a}.fam

        # Create softlinks for bed B
        ln -s ${bed_in_b} plink_input/${input_prefix_b}.bed
        ln -s ${bim_in_b} plink_input/${input_prefix_b}.bim
        ln -s ${fam_in_b} plink_input/${input_prefix_b}.fam


        # Merge bed file
        plink --make-bed \
            --bfile plink_input/${input_prefix_a} \
            --bmerge plink_input/${input_prefix_b} \
            ${'--merge-mode ' + merge_mode} \
            --out ${output_basename} \
            --threads ${cpu}

        # Touch to create null missnp file for successful merge
        touch ${output_basename}.missnp

        # If ignore errors touch files to create null outputs so task doesn't error out
        if [[ '${ignore_errors}' == 'true' ]];
        then
            touch ${output_basename}.bed
            touch ${output_basename}.bim
            touch ${output_basename}.fam
        fi
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
        File missnp_out = "${output_basename}.missnp"
    }
}

task remove_fam_phenotype{
    File fam_in
    String output_basename

    # Runtime environment
    String docker = "ubuntu:18.04"
    Int cpu = 1
    Int mem_gb = 1

    command {
        set -e
        # Gunzip if necessary
        input=${fam_in}
        if [[ ${fam_in} =~ \.gz$ ]]; then
            gunzip -c ${fam_in} > fam.txt
            input=fam.txt
        fi

        perl -pe 's/\S+$/0/;' "$input" > ${output_basename}.fam
    }

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
    }

    output {
        File fam_out = "${output_basename}.fam"
    }
}

task remove_fam_pedigree{
    File fam_in
    String output_basename

    # Runtime environment
    String docker = "ubuntu:18.04"
    Int cpu = 1
    Int mem_gb = 1

    command <<<
        set -e
        # Zero out the mother/father id and remove family with line count
        awk '{$1=NR; $3=0; $4=0; print}' ${fam_in} > ${output_basename}.fam

        # Create mapping file for restoring family id later
        awk '{print NR,$2,$1,$2}' ${fam_in} > ${output_basename}.idmap.fam
    >>>

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
    }

    output {
        File fam_out = "${output_basename}.fam"
        File id_map_out = "${output_basename}.idmap.fam"
    }
}

task prune_ld_markers{
    File bed_in
    File bim_in
    File fam_in
    String output_basename
    String input_prefix = basename(sub(bed_in, "\\.gz$", ""), ".bed")

    # Region filtering
    String? chr
    File? exclude_regions

    String ld_type
    Int window_size
    Float? maf
    String? window_size_unit
    Int? step_size
    Float? r2_threshold
    Float? vif_threshold
    Int? x_chr_mode

    # Runtime environment
    String docker = "rtibiocloud/plink:v1.9-9e70778"
    Int cpu = 4
    Int mem_gb = 8

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

        # Run sex check
        plink --bfile plink_input/${input_prefix} \
            --${ld_type} ${window_size}${window_size_unit} ${step_size} ${r2_threshold} ${vif_threshold} \
            ${'--ld-xchr ' + x_chr_mode} \
            ${'--maf ' + maf} \
            ${'--chr ' + chr} \
            ${'--exclude range ' + exclude_regions} \
            --out ${output_basename} \
            --threads ${cpu}
    }

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
    }

    output {
        File include_markers = "${output_basename}.prune.in"
        File exclude_markers = "${output_basename}.prune.out"
    }
}

task sex_check{
    File bed_in
    File bim_in
    File fam_in
    Float female_max_f = 0.2
    Float male_min_f = 0.8
    String output_basename
    String input_prefix = basename(sub(bed_in, "\\.gz$", ""), ".bed")

    File? update_sex

    # Runtime environment
    String docker = "rtibiocloud/plink:v1.9-9e70778"
    Int cpu = 4
    Int mem_gb = 8

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

        # Run sex check
        plink --bfile plink_input/${input_prefix} \
            ${'--update-sex ' + update_sex} \
            --check-sex ${female_max_f} ${male_min_f} \
            --out ${output_basename} \
            --threads ${cpu}

        # Rename output file
        perl -lane 'print join("\t",@F);' ${output_basename}.sexcheck > ${output_basename}.sexcheck.all.tsv

        # Extract subjects failing sex check
        head -n 1 ${output_basename}.sexcheck.all.tsv > ${output_basename}.sexcheck.problems.tsv
        grep PROBLEM ${output_basename}.sexcheck.all.tsv >> ${output_basename}.sexcheck.problems.tsv

        # Create remove list
        tail -n +2 ${output_basename}.sexcheck.problems.tsv |
        perl -lane 'print join(" ", $F[0], $F[1]);' > ${output_basename}.sexcheck.remove
    }

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
    }

    output {
        File plink_sex_check_output = "${output_basename}.sexcheck.all.tsv"
        File sex_check_problems = "${output_basename}.sexcheck.problems.tsv"
        File samples_to_remove = "${output_basename}.sexcheck.remove"
    }
}

task contains_chr{
    File bim_in
    String chr

    # Runtime environment
    String docker = "ubuntu:18.04"
    Int cpu = 1
    Int mem_gb = 1

    command {
        if [[ ${bim_in} =~ \.gz$ ]]; then
            gunzip -c ${bim_in} | cut -f1 | sort | uniq | grep '^${chr}$' > results.txt
        else
            cut -f1 ${bim_in} | sort | uniq | grep '^${chr}$' > results.txt
        fi

        if [ -s results.txt ]; then
            echo "true"
        else
            echo "false"
        fi
    }

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
    }

    output {
        Boolean contains = read_boolean(stdout())
    }
}

task get_excess_homo_samples{
    File bed_in
    File bim_in
    File fam_in
    String output_basename
    String input_prefix = basename(sub(bed_in, "\\.gz$", ""), ".bed")
    Float min_he
    Float max_he

    String docker = "rtibiocloud/plink:v1.9-9e70778"
    Int cpu = 1
    Int mem_gb = 2
    Int max_retries = 3

    command <<<
        set -e
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

        # Get expected heterozygosity for each sample
        plink --bfile plink_input/${input_prefix} \
            --het \
            --threads ${cpu} \
            --out ${output_basename}

        # Get list of outlier samples that need to be removed
        perl -lane 'if ($F[5] < ${min_he} || $F[5] > ${min_he}) { print $F[0]." ".$F[1]; }' ${output_basename}.het > ${output_basename}.remove
    >>>

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File homo_report = "${output_basename}.het"
        File excess_homos = "${output_basename}.remove"
    }
}

task get_samples_missing_chr{
    File bed_in
    File bim_in
    File fam_in
    String chr
    String output_basename
    String input_prefix = basename(sub(bed_in, "\\.gz$", ""), ".bed")

    String docker = "rtibiocloud/plink:v1.9-9e70778"
    Int cpu = 1
    Int mem_gb = 2
    Int max_retries = 3

    command <<<
        set -e
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


        # Get list of chromosomes

        # Get missing call rates for samples on chr of interest
        plink --bfile plink_input/${input_prefix} \
            --missing \
            --chr ${chr} \
            --threads ${cpu} \
            --out ${output_basename}

        # Parse out any indiduals with 100% missing call rates on a given SNP
        tail -n +2 ${output_basename}.imiss | awk '{ OFS="\t" } { if($6==1){ print $1,$2 } }' > ${output_basename}.samples_missing.chr${chr}.txt

    >>>

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File samples = "${output_basename}.samples_missing.chr${chr}.txt"
    }
}

task contains_chr{
    File bim_in
    String chr

    # Runtime environment
    String docker = "ubuntu:18.04"
    Int cpu = 1
    Int mem_gb = 1

    command {
        if [[ ${bim_in} =~ \.gz$ ]]; then
            gunzip -c ${bim_in} | cut -f1 | sort | uniq | grep '^${chr}$' > results.txt
        else
            cut -f1 ${bim_in} | sort | uniq | grep '^${chr}$' > results.txt
        fi

        if [ -s results.txt ]; then
            echo "true"
        else
            echo "false"
        fi
    }

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
    }

    output {
        Boolean contains = read_boolean(stdout())
    }
}

task get_bim_chrs{
    # Returns a list chrs in a bim file in the order they appear
    File bim_in

    # Runtime environment
    String docker = "ubuntu:18.04"
    Int cpu = 1
    Int mem_gb = 1

    command <<<
        # Can't just use cut/sort/uniq bc we need chrs in order and strings like MT would efff that up by forcing alphabetical sorting
        # Solution here is just to scan the file with awk and print every time it sees a new chr
        if [[ ${bim_in} =~ \.gz$ ]]; then
            gunzip -c ${bim_in} | awk '{if(!($1 in arr)){print $1};arr[$1]++}'
        else
           cat ${bim_in} | awk '{if(!($1 in arr)){print $1};arr[$1]++}'
        fi
    >>>

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
    }

    output {
        Array[String] chrs = read_lines(stdout())
    }
}

task hardy{
    File bed_in
    File bim_in
    File fam_in
    String output_basename
    String input_prefix = basename(sub(bed_in, "\\.gz$", ""), ".bed")

    Float hwe_pvalue = 0.0
    String hwe_mode
    Boolean? filter_females
    Array[String]? chrs
    String chrs_prefix = if(defined(chrs)) then "--chr" else ""


    String docker = "rtibiocloud/plink:v1.9-9e70778"
    Int cpu = 1
    Int mem_gb = 2
    Int max_retries = 3

    command <<<
        set -e
        mkdir plink_input

        # Bed file preprocessing
        if [[ ${bed_in} =~ \.gz$ ]]; then
            # Append gz tag to let plink know its gzipped input
            unpigz -p ${cpu} -c ${bed_in} > plink_input/${input_prefix}.bed
        else
            # Otherwise just create softlink with normal
            ln -s ${bed_in} plink_input/${input_prefix}.bed
        fi

        # Bim file preprocessing
        if [[ ${bim_in} =~ \.gz$ ]]; then
            unpigz -p ${cpu} -c ${bim_in} > plink_input/${input_prefix}.bim
        else
            ln -s ${bim_in} plink_input/${input_prefix}.bim
        fi

        # Fam file preprocessing
        if [[ ${fam_in} =~ \.gz$ ]]; then
            unpigz -p ${cpu} -c ${fam_in} > plink_input/${input_prefix}.fam
        else
            ln -s ${fam_in} plink_input/${input_prefix}.fam
        fi

        # Get expected heterozygosity for each sample
        plink --bfile plink_input/${input_prefix} \
            --hardy \
            --threads ${cpu} \
            --out ${output_basename} \
            ${true='--filter-females' false="" filter_females} \
            ${chrs_prefix} ${sep=", " chrs}


        # Filter file
        perl -lane 'if(($. > 1) && ($F[9] < ${hwe_pvalue})){print $F[1];};' ${output_basename}.hwe > ${output_basename}.remove
    >>>

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File remove = "${output_basename}.remove"
        File hwe_report = "${output_basename}.hwe"
    }
}
