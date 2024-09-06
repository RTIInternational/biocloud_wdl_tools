version 1.1

task make_bed{

    input{

        File bed_in
        File bim_in
        File fam_in
        String output_basename
        String input_prefix = basename(sub(bed_in, "\\.gz$", ""), ".bed")

        # Default to using plink1.9 compatible input
        String output_chr = "26"

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
        Array[File]? extract_intersect
        String extract_intersect_prefix = if(defined(extract_intersect)) then "--extract-intersect" else ""

        # Filtering by sample cluster
        File? keep_clusters
        Array[String]? keep_cluster_names
        String keep_cluster_names_prefix = if(defined(keep_cluster_names)) then "--keep-cluster-names" else ""
        File? remove_clusters
        Array[String]? remove_cluster_names
        String remove_cluster_names_prefix = if(defined(remove_cluster_names)) then "--remove-cluster-names" else ""

        # Set gene set membership
        Array[String]? gene
        String gene_prefix = if(defined(gene)) then "--gene" else ""
        Boolean gene_all = false

        # Filter by attributes files
        File? attrib
        String? attrib_filter
        File? attrib_indiv
        String? attrib_indiv_filter

        # Filtering options by chr
        String? chr
        String? not_chr
        Boolean allow_extra_chr = false
        Boolean autosome = false
        Boolean autosome_xy = false
        Boolean prune = false
        Array[String]? chrs
        String chrs_prefix = if(defined(chrs)) then "--chr" else ""
        Array[String]? not_chrs
        String not_chrs_prefix = if(defined(not_chrs)) then "--not-chr" else ""

        # Site type filtering
        Boolean snps_only = false
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
        String snps_prefix = if(defined(snps)) then "--snps" else ""
        Array[String]? exclude_snps
        String exclude_snps_prefix = if(defined(exclude_snps)) then "--exclude-snps" else ""

        # Remove duplicates
        Boolean rm_dup = false
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
        Boolean nonfounders = false
        Boolean maf_succ = false

        # HWE filtering
        Float? hwe_pvalue
        String? hwe_mode

        # Sex filters
        Boolean allow_no_sex = false
        Boolean must_have_sex = false
        Boolean filter_females = false
        Boolean filter_males = false
        Boolean filter_controls = false
        Boolean filter_cases = false
        Boolean filter_nosex = false
        Boolean remove_females = false
        Boolean remove_males = false
        Boolean remove_nosex = false

        # Founder status
        Boolean filter_founders = false
        Boolean filter_nonfounders = false

        # Other data management options
        Boolean sort_vars = false
        String? sort_vars_mode

        # Re-coding heterozygous haploids
        Boolean set_hh_missing = false
        Boolean hh_missing_keep_dosage = false
        Boolean split_x = false
        String? build_code
        Boolean merge_x = false
        Boolean split_no_fail = false
        Boolean merge_no_fail = false


        # Updating files
        File? update_ids
        File? update_parents
        File? update_sex
        Int? update_sex_n

        String docker_image = "rtibiocloud/plink:v2.0_888cf13"
        String ecr_image = "rtibiocloud/plink:v2.0_888cf13"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"

        Int cpu = 1
        Int mem_gb = 2
        Int max_retries = 3

    }

    command <<<

        # Get everything in same directory while preserving .gz extensions
        # This is annoying but apparently necessary
        # This is why it's dumb to make a program that requires everything be in the same directory
        # The upside here is bed/bim/fam files will always be coerced to have same basename
        # So you don't have to worry combining files from the same dataset that may have different inputs

        mkdir plink_input

        # Bed file preprocessing
        if [[ ~{bed_in} =~ \.gz$ ]]; then
            # Append gz tag to let plink know its gzipped input
            unpigz -p ~{cpu} -c ~{bed_in} > plink_input/~{input_prefix}.bed
        else
            # Otherwise just create softlink with normal
            ln -s ~{bed_in} plink_input/~{input_prefix}.bed
        fi

        # Bim file preprocessing
        if [[ ~{bim_in} =~ \.gz$ ]]; then
            unpigz -p ~{cpu} -c ~{bim_in} > plink_input/~{input_prefix}.bim
        else
            ln -s ~{bim_in} plink_input/~{input_prefix}.bim
        fi

        # Fam file preprocessing
        if [[ ~{fam_in} =~ \.gz$ ]]; then
            unpigz -p ~{cpu} -c ~{fam_in} > plink_input/~{input_prefix}.fam
        else
            ln -s ~{fam_in} plink_input/~{input_prefix}.fam
        fi

        
        # Now run plink2
        plink2 --bfile plink_input/~{input_prefix} \
            --out ~{output_basename} \
            --make-bed \
            --threads ~{cpu} \
            ~{'--chr ' + chr} \
            ~{'--not-chr ' + not_chr} \
            ~{if allow_extra_chr then '--allow-extra-chr' else ''} \
            ~{if autosome then '--autosome' else ''} \
            ~{if autosome_xy then '--autosome-par' else ''} \
            ~{chrs_prefix} ~{sep(', ', chrs)} \
            ~{not_chrs_prefix} ~{sep(', ', not_chrs)} \
            ~{'--keep ' + keep_samples} \
            ~{'--remove ' + remove_samples} \
            ~{'--keep-fam ' + keep_fam} \
            ~{'--remove-fam ' + remove_fam} \
            ~{'--keep-clusters ' + keep_clusters} \
            ~{'--remove-clusters ' + remove_clusters} \
            ~{keep_cluster_names_prefix} ~{sep(' ', keep_cluster_names)} \
            ~{remove_cluster_names_prefix} ~{sep(' ', remove_cluster_names)} \
            ~{'--extract ' + extract} \
            ~{'--exclude ' + exclude} \
            ~{extract_intersect_prefix} ~{sep(' ', extract_intersect)} \
            ~{if snps_only then '--snps-only' else ''} ~{snps_only_type} \
            ~{'--from ' + from_id} \
            ~{'--to ' + to_id} \
            ~{'--snp ' + snp} \
            ~{'--window ' +  window} \
            ~{'--exclude-snp ' + exclude_snp} \
            ~{snps_prefix} ~{sep(', ', snps)} \
            ~{exclude_snps_prefix} ~{sep(', ', exclude_snps)} \
            ~{'--from-bp ' + from_bp} \
            ~{'--to-bp ' + to_bp} \
            ~{'--from-kb ' + from_kb} \
            ~{'--to-kb ' + to_kb} \
            ~{'--from-mb ' + from_mb} \
            ~{'--to-mb ' + to_mb} \
            ~{if rm_dup then '--rm-dup' else ''} ~{rm_dup_mode} \
            ~{'--thin ' + thin} \
            ~{'--thin-count ' + thin_count} \
            ~{'--thin-indiv ' + thin_indiv} \
            ~{'--thin-indiv-count ' + thin_indiv_count} \
            ~{'--bp-space ' + bp_space} \
            ~{'--filter' + filter} ~{sep(' ', filter_values)} \
            ~{'--min-alleles ' + min_alleles} \
            ~{'--max-alleles ' + max_alleles} \
            ~{'--maf ' + min_maf} ~{maf_mode} \
            ~{'--max-maf ' + max_maf} ~{maf_mode} \
            ~{'--mac ' + min_mac} ~{mac_mode} \
            ~{'--max-mac ' + max_mac} ~{mac_mode} \
            ~{if maf_succ then '--maf-succ' else ''} \
            ~{'--hwe ' + hwe_pvalue} ~{hwe_mode} \
            ~{if allow_no_sex then '--allow-no-sex' else ''} \
            ~{if filter_females then '--keep-females' else ''} \
            ~{if filter_males then '--keep-males' else ''} \
            ~{if filter_nosex then '--keep-nosex' else ''} \
            ~{if remove_females then '--remove-females' else ''} \
            ~{if remove_males then '--remove-males' else ''} \
            ~{if remove_nosex then '--remove-nosex' else ''} \
            ~{if filter_founders then '--keep-founders' else ''} \
            ~{if filter_nonfounders then '--keep-nonfounders' else ''} \
            ~{if nonfounders then '--nonfounders' else ''} \
            ~{if sort_vars then '--sort-vars' else ''} ~{sort_vars_mode} \
            ~{if set_hh_missing then '--set-hh-missing' else ''} ~{if hh_missing_keep_dosage then 'keep-dosage' else ''} \
            ~{'--flip ' + flip} \
            ~{'--geno ' + geno} \
            ~{'--mind ' + mind} \
            ~{if split_x then '--split-par' else ''} ~{build_code} \
            ~{if merge_x then '--merge-par' else ''} \
            ~{'--update-ids ' + update_ids} \
            ~{'--update-parents ' + update_parents} \
            ~{'--update-sex ' + update_sex} ~{'col-num=' + update_sex_n} \
            --output-chr ~{output_chr}
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File bed_out = "~{output_basename}.bed"
        File bim_out = "~{output_basename}.bim"
        File fam_out = "~{output_basename}.fam"
        File plink_log = "~{output_basename}.log"
    }
}

task make_bed_plink1{

    input{

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
        String extract_prefix = if(defined(extract)) then "--extract" else ""
        String exclude_prefix = if(defined(exclude)) then "--exclude" else ""

        # Filtering by sample cluster
        File? keep_clusters
        Array[String]? keep_cluster_names
        String keep_cluster_names_prefix = if(defined(keep_cluster_names)) then "--keep-cluster-names" else ""
        File? remove_clusters
        Array[String]? remove_cluster_names
        String remove_cluster_names_prefix = if(defined(remove_cluster_names)) then "--remove-cluster-names" else ""


        # Set gene set membership
        Array[String]? gene
        String gene_prefix = if(defined(gene)) then "--gene" else ""
        Boolean gene_all = false

        # Filter by attributes files
        File? attrib
        String? attrib_filter
        File? attrib_indiv
        String? attrib_indiv_filter

        # Filtering options by chr
        String? chr
        String? not_chr
        Boolean allow_extra_chr = false
        Boolean autosome = false
        Boolean autosome_xy = false
        Boolean prune = false
        Array[String]? chrs
        String chrs_prefix = if(defined(chrs)) then "--chr" else ""
        Array[String]? not_chrs
        String not_chrs_prefix = if(defined(not_chrs)) then "--not-chr" else ""

        # Site type filtering
        Boolean snps_only = false
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
        String snps_prefix = if(defined(snps)) then "--snps" else ""
        Array[String]? exclude_snps
        String exclude_snps_prefix = if(defined(exclude_snps)) then "--exclude-snps" else ""

        # Remove duplicates
        Boolean rm_dup = false
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
        Boolean nonfounders = false
        Boolean maf_succ = false

        # HWE filtering
        Float? hwe_pvalue
        String? hwe_mode

        # Sex filters
        Boolean allow_no_sex = false
        Boolean must_have_sex = false
        Boolean filter_females = false
        Boolean filter_males = false
        Boolean filter_controls = false
        Boolean filter_cases = false

        # Founder status
        Boolean filter_founders = false
        Boolean filter_nonfounders = false

        # Other data management options
        Boolean sort_vars = false
        String? sort_vars_mode

        # Re-coding heterozygous haploids
        Boolean set_hh_missing = false
        Boolean split_x = false
        String? build_code
        Boolean merge_x = false
        Boolean split_no_fail = false
        Boolean merge_no_fail = false


        # Updating files
        File? update_ids
        File? update_parents
        File? update_sex
        Int? update_sex_n

        String docker_image = "rtibiocloud/plink:v1.9-77ee25f"
        String ecr_image = "rtibiocloud/plink:v1.9-77ee25f"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 1
        Int mem_gb = 2
        Int max_retries = 3

    }

    command <<<
        # Get everything in same directory while preserving .gz extensions
        # This is annoying but apparently necessary
        # This is why it's dumb to make a program that requires everything be in the same directory
        # The upside here is bed/bim/fam files will always be coerced to have same basename
        # So you don't have to worry combining files from the same dataset that may have different inputs

        mkdir plink_input

        # Bed file preprocessing
        if [[ ~{bed_in} =~ \.gz$ ]]; then
            # Append gz tag to let plink know its gzipped input
            unpigz -p ~{cpu} -c ~{bed_in} > plink_input/~{input_prefix}.bed
        else
            # Otherwise just create softlink with normal
            ln -s ~{bed_in} plink_input/~{input_prefix}.bed
        fi

        # Bim file preprocessing
        if [[ ~{bim_in} =~ \.gz$ ]]; then
            unpigz -p ~{cpu} -c ~{bim_in} > plink_input/~{input_prefix}.bim
        else
            ln -s ~{bim_in} plink_input/~{input_prefix}.bim
        fi

        # Fam file preprocessing
        if [[ ~{fam_in} =~ \.gz$ ]]; then
            unpigz -p ~{cpu} -c ~{fam_in} > plink_input/~{input_prefix}.fam
        else
            ln -s ~{fam_in} plink_input/~{input_prefix}.fam
        fi

        # Now run plink2
        plink --bfile plink_input/~{input_prefix} \
            --out ~{output_basename} \
            --make-bed \
            --threads ~{cpu} \
            ~{'--keep ' + keep_samples} \
            ~{'--remove ' + remove_samples} \
            ~{'--keep-fam ' + keep_fam} \
            ~{'--remove-fam ' + remove_fam} \
            ~{'--keep-clusters ' + keep_clusters} \
            ~{'--remove-clusters ' + remove_clusters} \
            ~{keep_cluster_names_prefix} ~{sep(' ', keep_cluster_names)} \
            ~{remove_cluster_names_prefix} ~{sep(' ', remove_cluster_names)} \
            ~{gene_prefix} ~{sep(' ', gene)} \
            ~{if gene_all then '--gene-all' else ''} \
            ~{'--attrib' + attrib} ~{attrib_filter} \
            ~{'--attrib-indiv' + attrib_indiv} ~{attrib_indiv_filter} \
            ~{'--chr ' + chr} \
            ~{'--not-chr ' + not_chr} \
            ~{chrs_prefix} ~{sep(', ', chrs)} \
            ~{not_chrs_prefix} ~{sep(', ', not_chrs)} \
            ~{if allow_extra_chr then '--allow-extra-chr' else ''}\
            ~{if autosome then '--autosome' else ''} \
            ~{if autosome_xy then '--autosome-xy' else ''} \
            ~{if snps_only then '--snps-only' else ''} ~{snps_only_type} \
            ~{'--from ' + from_id} \
            ~{'--to ' + to_id} \
            ~{'--snp ' + snp} \
            ~{'--window ' +  window} \
            ~{'--exclude-snp ' + exclude_snp} \
            ~{snps_prefix} ~{sep(', ', snps)} \
            ~{exclude_snps_prefix} ~{sep(', ', exclude_snps)} \
            ~{'--from-bp ' + from_bp} \
            ~{'--to-bp ' + to_bp} \
            ~{'--from-kb ' + from_kb} \
            ~{'--to-kb ' + to_kb} \
            ~{'--from-mb ' + from_mb} \
            ~{'--to-mb ' + to_mb} \
            ~{if rm_dup then '--rm-dup' else ''} ~{rm_dup_mode} \
            ~{'--thin ' + thin} \
            ~{'--thin-count ' + thin_count} \
            ~{'--thin-indiv ' + thin_indiv} \
            ~{'--thin-indiv-count ' + thin_indiv_count} \
            ~{'--bp-space ' + bp_space} \
            ~{'--filter' + filter} ~{sep(' ', filter_values)} \
            ~{'--mfilter' + mfilter} \
            ~{'--geno ' + max_missing_geno_rate} \
            ~{'--mind ' + max_missing_ind_rate} \
            ~{if prune then '--prune' else ''} \
            ~{'--min-alleles ' + min_alleles} \
            ~{'--max-alleles ' + max_alleles} \
            ~{'--maf ' + min_maf} ~{maf_mode} \
            ~{'--max-maf ' + max_maf} ~{maf_mode} \
            ~{'--mac ' + min_mac} ~{mac_mode} \
            ~{'--max-mac ' + max_mac} ~{mac_mode} \
            ~{if maf_succ then '--maf-succ' else ''} \
            ~{'--hwe ' + hwe_pvalue} ~{hwe_mode} \
            ~{if allow_no_sex then '--allow-no-sex' else ''} \
            ~{if filter_females then '--filter-females' else ''} \
            ~{if filter_males then '--filter-males' else ''} \
            ~{if filter_cases then '--filter-cases' else ''} \
            ~{if filter_controls then '--filter-controls' else ''} \
            ~{if filter_founders then '--filter-founders' else ''} \
            ~{if filter_nonfounders then '--filter-nonfounders' else ''} \
            ~{if nonfounders then '--nonfounders' else ''} \
            ~{if sort_vars then '--sort-vars' else ''} ~{sort_vars_mode} \
            ~{if set_hh_missing then '--set-hh-missing' else ''} \
            ~{if split_x then '--split-x' else ''} ~{build_code} ~{if split_no_fail then 'no-fail' else ''} \
            ~{if merge_x then '--merge-x' else ''} ~{if merge_no_fail then 'no-fail' else ''} \
            ~{'--update-ids ' + update_ids} \
            ~{'--update-parents ' + update_parents} \
            ~{'--update-sex ' + update_sex} ~{update_sex_n} \
            ~{'--flip ' + flip} \
            ~{'--geno ' + geno} \
            ~{'--mind ' + mind}
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File bed_out = "~{output_basename}.bed"
        File bim_out = "~{output_basename}.bim"
        File fam_out = "~{output_basename}.fam"
        File plink_log = "~{output_basename}.log"
    }
}

task merge_beds{

    input {

        Array[File] bed_in
        Array[File] bim_in
        Array[File] fam_in
        String output_basename
        Boolean allow_no_sex = false

        String docker_image = "rtibiocloud/plink:v1.9-77ee25f"
        String ecr_image = "rtibiocloud/plink:v1.9-77ee25f"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 4
        Int mem_gb = 8
        Int max_retries = 3

    }

    command <<<
        # Write bed files to file
        for file in ~{sep(' ', bed_in)}; do
            echo "$file" >> bed_files.txt
        done

        # Write bim files to file
        for file in ~{sep(' ', bim_in)}; do
            echo "$file" >> bim_files.txt
        done

        # Write fam files to file
        for file in ~{sep(' ', fam_in)}; do
            echo "$file" >> fam_files.txt
        done

        # Merge bed/bim/bam links into merge-list file
        paste -d " " bed_files.txt bim_files.txt fam_files.txt > merge_list.txt

        # Merge bed file
        plink --make-bed \
            --threads ~{cpu} \
            --merge-list merge_list.txt \
            ~{if allow_no_sex then '--allow-no-sex' else ''} \
            --out ~{output_basename}
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File bed_out = "~{output_basename}.bed"
        File bim_out = "~{output_basename}.bim"
        File fam_out = "~{output_basename}.fam"
        File plink_log = "~{output_basename}.log"
    }
}

task merge_two_beds{

    input {

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
        Boolean allow_no_sex = false
        String output_basename

        String docker_image = "rtibiocloud/plink:v1.9-77ee25f"
        String ecr_image = "rtibiocloud/plink:v1.9-77ee25f"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 4
        Int mem_gb = 8
        Int max_retries = 3

    }

    command <<<

        mkdir plink_input

        # Create softlinks for bed A
        ln -s ~{bed_in_a} plink_input/~{input_prefix_a}.bed
        ln -s ~{bim_in_a} plink_input/~{input_prefix_a}.bim
        ln -s ~{fam_in_a} plink_input/~{input_prefix_a}.fam

        # Create softlinks for bed B
        ln -s ~{bed_in_b} plink_input/~{input_prefix_b}.bed
        ln -s ~{bim_in_b} plink_input/~{input_prefix_b}.bim
        ln -s ~{fam_in_b} plink_input/~{input_prefix_b}.fam


        # Merge bed file
        plink --make-bed \
            --bfile plink_input/~{input_prefix_a} \
            --bmerge plink_input/~{input_prefix_b} \
            ~{'--merge-mode ' + merge_mode} \
            ~{if allow_no_sex then '--allow-no-sex' else ''} \
            --out ~{output_basename} \
            --threads ~{cpu}

        # Touch to create null missnp file for successful merge
        touch ~{output_basename}.missnp

        # If ignore errors touch files to create null outputs so task doesn't error out
        if [[ '~{ignore_errors}' == 'true' ]];
        then
            touch ~{output_basename}.bed
            touch ~{output_basename}.bim
            touch ~{output_basename}.fam
        fi
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File bed_out = "~{output_basename}.bed"
        File bim_out = "~{output_basename}.bim"
        File fam_out = "~{output_basename}.fam"
        File plink_log = "~{output_basename}.log"
        File missnp_out = "~{output_basename}.missnp"
    }
}

task remove_fam_phenotype{

    input{

        File fam_in
        String output_basename

        # Runtime environment
        String docker_image = "ubuntu:22.04@sha256:19478ce7fc2ffbce89df29fea5725a8d12e57de52eb9ea570890dc5852aac1ac"
        String ecr_image = "rtibiocloud/ubuntu:22.04_19478ce7fc2ff"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 1
        Int mem_gb = 1

    }

    command <<<
        set -e
        # Gunzip if necessary
        input=~{fam_in}
        if [[ ~{fam_in} =~ \.gz$ ]]; then
            gunzip -c ~{fam_in} > fam.txt
            input=fam.txt
        fi

        perl -pe 's/\S+$/0/;' "$input" > ~{output_basename}.fam
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
    }

    output {
        File fam_out = "~{output_basename}.fam"
    }
}

task remove_fam_pedigree{

    input{

        File fam_in
        String output_basename

        # Runtime environment
        String docker_image = "ubuntu:22.04@sha256:19478ce7fc2ffbce89df29fea5725a8d12e57de52eb9ea570890dc5852aac1ac"
        String ecr_image = "rtibiocloud/ubuntu:22.04_19478ce7fc2ff"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 1
        Int mem_gb = 1

    }

    command <<<
        set -e
        # Zero out the mother/father id and remove family with line count
        awk '{$1=NR; $3=0; $4=0; print}' ~{fam_in} > ~{output_basename}.fam

        # Create mapping file for restoring family id later
        awk '{print NR,$2,$1,$2}' ~{fam_in} > ~{output_basename}.idmap.fam
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
    }

    output {
        File fam_out = "~{output_basename}.fam"
        File id_map_out = "~{output_basename}.idmap.fam"
    }
}

task prune_ld_markers{

    input {

        File bed_in
        File bim_in
        File fam_in
        String output_basename
        String input_prefix = basename(sub(bed_in, "\\.gz$", ""), ".bed")

        # Auto-force compatibility between plink1.9 and plink2.0 chr codes
        String output_chr = "26"

        # Variant filtering
        File? exclude

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
        Boolean bad_ld = false

        # Runtime environment
        String docker_image = "rtibiocloud/plink:v2.0_888cf13"
        String ecr_image = "rtibiocloud/plink:v2.0_888cf13"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 4
        Int mem_gb = 8

    }

    command <<<
        mkdir plink_input

       # Bed file preprocessing
        if [[ ~{bed_in} =~ \.gz$ ]]; then
            # Append gz tag to let plink know its gzipped input
            unpigz -p ~{cpu} -c ~{bed_in} > plink_input/~{input_prefix}.bed
        else
            # Otherwise just create softlink with normal
            ln -s ~{bed_in} plink_input/~{input_prefix}.bed
        fi

        # Bim file preprocessing
        if [[ ~{bim_in} =~ \.gz$ ]]; then
            unpigz -p ~{cpu} -c ~{bim_in} > plink_input/~{input_prefix}.bim
        else
            ln -s ~{bim_in} plink_input/~{input_prefix}.bim
        fi

        # Fam file preprocessing
        if [[ ~{fam_in} =~ \.gz$ ]]; then
            unpigz -p ~{cpu} -c ~{fam_in} > plink_input/~{input_prefix}.fam
        else
            ln -s ~{fam_in} plink_input/~{input_prefix}.fam
        fi

        # Prune ld
        plink2 --bfile plink_input/~{input_prefix} \
            --~{ld_type} ~{window_size}~{window_size_unit} ~{step_size} ~{r2_threshold} ~{vif_threshold} \
            ~{'--maf ' + maf} \
            ~{'--chr ' + chr} \
            ~{'--exclude ' + exclude} \
            ~{'--exclude range ' + exclude_regions} \
            --out ~{output_basename} \
            --threads ~{cpu} \
            ~{if bad_ld then '--bad-ld' else ''} \
            --output-chr ~{output_chr}
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
    }

    output {
        File include_markers = "~{output_basename}.prune.in"
        File exclude_markers = "~{output_basename}.prune.out"
    }
}

task sex_check{

    input {

        File bed_in
        File bim_in
        File fam_in
        Float female_max_f = 0.2
        Float male_min_f = 0.8
        String output_basename
        String input_prefix = basename(sub(bed_in, "\\.gz$", ""), ".bed")

        File? update_sex

        # Runtime environment
        String docker_image = "rtibiocloud/plink:v1.9-77ee25f"
        String ecr_image = "rtibiocloud/plink:v1.9-77ee25f"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 4
        Int mem_gb = 8

    }

    command <<<
        mkdir plink_input

       # Bed file preprocessing
        if [[ ~{bed_in} =~ \.gz$ ]]; then
            # Append gz tag to let plink know its gzipped input
            unpigz -p ~{cpu} -c ~{bed_in} > plink_input/~{input_prefix}.bed
        else
            # Otherwise just create softlink with normal
            ln -s ~{bed_in} plink_input/~{input_prefix}.bed
        fi

        # Bim file preprocessing
        if [[ ~{bim_in} =~ \.gz$ ]]; then
            unpigz -p ~{cpu} -c ~{bim_in} > plink_input/~{input_prefix}.bim
        else
            ln -s ~{bim_in} plink_input/~{input_prefix}.bim
        fi

        # Fam file preprocessing
        if [[ ~{fam_in} =~ \.gz$ ]]; then
            unpigz -p ~{cpu} -c ~{fam_in} > plink_input/~{input_prefix}.fam
        else
            ln -s ~{fam_in} plink_input/~{input_prefix}.fam
        fi

        # Run sex check
        plink --bfile plink_input/~{input_prefix} \
            ~{'--update-sex ' + update_sex} \
            --check-sex ~{female_max_f} ~{male_min_f} \
            --out ~{output_basename} \
            --threads ~{cpu}

        # Rename output file
        perl -lane 'print join("\t",@F);' ~{output_basename}.sexcheck > ~{output_basename}.sexcheck.all.tsv

        # Extract subjects failing sex check
        head -n 1 ~{output_basename}.sexcheck.all.tsv > ~{output_basename}.sexcheck.problems.tsv
        grep PROBLEM ~{output_basename}.sexcheck.all.tsv >> ~{output_basename}.sexcheck.problems.tsv

        # Create remove list
        tail -n +2 ~{output_basename}.sexcheck.problems.tsv |
        perl -lane 'print join(" ", $F[0], $F[1]);' > ~{output_basename}.sexcheck.remove
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
    }

    output {
        File plink_sex_check_output = "~{output_basename}.sexcheck.all.tsv"
        File sex_check_problems = "~{output_basename}.sexcheck.problems.tsv"
        File samples_to_remove = "~{output_basename}.sexcheck.remove"
    }
}

task contains_chr{

    input {

        File bim_in
        String chr

        # Runtime environment
        String docker_image = "ubuntu:22.04@sha256:19478ce7fc2ffbce89df29fea5725a8d12e57de52eb9ea570890dc5852aac1ac"
        String ecr_image = "rtibiocloud/ubuntu:22.04_19478ce7fc2ff"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 1
        Int mem_gb = 1

    }

    command <<<
        if [[ ~{bim_in} =~ \.gz$ ]]; then
            gunzip -c ~{bim_in} | cut -f1 | sort | uniq | grep '^~{chr}$' > results.txt
        else
            cut -f1 ~{bim_in} | sort | uniq | grep '^~{chr}$' > results.txt
        fi

        if [ -s results.txt ]; then
            echo "true"
        else
            echo "false"
        fi
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
    }

    output {
        Boolean contains = read_boolean(stdout())
    }
}

task get_excess_homo_samples{

    input {

        File bed_in
        File bim_in
        File fam_in
        String output_basename
        String input_prefix = basename(sub(bed_in, "\\.gz$", ""), ".bed")
        Float min_he
        Float max_he

        String docker_image = "rtibiocloud/plink:v1.9-77ee25f"
        String ecr_image = "rtibiocloud/plink:v1.9-77ee25f"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 1
        Int mem_gb = 2
        Int max_retries = 3

    }

    command <<<
        set -e
        mkdir plink_input

       # Bed file preprocessing
        if [[ ~{bed_in} =~ \.gz$ ]]; then
            # Append gz tag to let plink know its gzipped input
            unpigz -p ~{cpu} -c ~{bed_in} > plink_input/~{input_prefix}.bed
        else
            # Otherwise just create softlink with normal
            ln -s ~{bed_in} plink_input/~{input_prefix}.bed
        fi

        # Bim file preprocessing
        if [[ ~{bim_in} =~ \.gz$ ]]; then
            unpigz -p ~{cpu} -c ~{bim_in} > plink_input/~{input_prefix}.bim
        else
            ln -s ~{bim_in} plink_input/~{input_prefix}.bim
        fi

        # Fam file preprocessing
        if [[ ~{fam_in} =~ \.gz$ ]]; then
            unpigz -p ~{cpu} -c ~{fam_in} > plink_input/~{input_prefix}.fam
        else
            ln -s ~{fam_in} plink_input/~{input_prefix}.fam
        fi

        # Get expected heterozygosity for each sample
        plink --bfile plink_input/~{input_prefix} \
            --het \
            --threads ~{cpu} \
            --out ~{output_basename}

        # Get list of outlier samples that need to be removed
        perl -lane 'if ($F[5] < ~{min_he} || $F[5] > ~{max_he}) { print $F[0]." ".$F[1]; }' ~{output_basename}.het > ~{output_basename}.remove
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File homo_report = "~{output_basename}.het"
        File excess_homos = "~{output_basename}.remove"
    }
}

task get_samples_missing_chr{

    input {

        File bed_in
        File bim_in
        File fam_in
        String chr
        Float missing_threshold = 1.00
        String output_basename
        String input_prefix = basename(sub(bed_in, "\\.gz$", ""), ".bed")

        String docker_image = "rtibiocloud/plink:v1.9-77ee25f"
        String ecr_image = "rtibiocloud/plink:v1.9-77ee25f"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 1
        Int mem_gb = 2
        Int max_retries = 3

    }

    command <<<
        set -e
        mkdir plink_input

        # Bed file preprocessing
        if [[ ~{bed_in} =~ \.gz$ ]]; then
            # Append gz tag to let plink know its gzipped input
            gunzip -c ~{bed_in} > plink_input/~{input_prefix}.bed
        else
            # Otherwise just create softlink with normal
            ln -s ~{bed_in} plink_input/~{input_prefix}.bed
        fi

        # Bim file preprocessing
        if [[ ~{bim_in} =~ \.gz$ ]]; then
            gunzip -c ~{bim_in} > plink_input/~{input_prefix}.bim
        else
            ln -s ~{bim_in} plink_input/~{input_prefix}.bim
        fi

        # Fam file preprocessing
        if [[ ~{fam_in} =~ \.gz$ ]]; then
            gunzip -c ~{fam_in} > plink_input/~{input_prefix}.fam
        else
            ln -s ~{fam_in} plink_input/~{input_prefix}.fam
        fi


        # Get list of chromosomes

        # Get missing call rates for samples on chr of interest
        plink --bfile plink_input/~{input_prefix} \
            --missing \
            --chr ~{chr} \
            --threads ~{cpu} \
            --out ~{output_basename}

        # Parse out any indiduals with 100% missing call rates on a given SNP
        tail -n +2 ~{output_basename}.imiss | awk '{ OFS="\t" } { if($6>=~{missing_threshold}){ print $1,$2 } }' > ~{output_basename}.samples_missing.chr~{chr}.txt

    >>>
    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File missing_samples = "~{output_basename}.samples_missing.chr~{chr}.txt"
        File sample_missing_report = "~{output_basename}.imiss"
        File site_missing_report = "~{output_basename}.lmiss"
    }
}

task get_bim_chrs{
    # Returns a list chrs in a bim file in the order they appear

    input {

        File bim_in

        # Runtime environment
        String docker_image = "ubuntu:22.04@sha256:19478ce7fc2ffbce89df29fea5725a8d12e57de52eb9ea570890dc5852aac1ac"
        String ecr_image = "rtibiocloud/ubuntu:22.04_19478ce7fc2ff"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 1
        Int mem_gb = 1

    }

    command <<<
        # Can't just use cut/sort/uniq bc we need chrs in order and strings like MT would efff that up by forcing alphabetical sorting
        # Solution here is just to scan the file with awk and print every time it sees a new chr
        if [[ ~{bim_in} =~ \.gz$ ]]; then
            gunzip -c ~{bim_in} | awk '{if(!($1 in arr)){print $1};arr[$1]++}'
        else
           cat ~{bim_in} | awk '{if(!($1 in arr)){print $1};arr[$1]++}'
        fi
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
    }

    output {
        Array[String] chrs = read_lines(stdout())
    }
}

task hardy{

    input {

        File bed_in
        File bim_in
        File fam_in
        String output_basename
        String input_prefix = basename(sub(bed_in, "\\.gz$", ""), ".bed")

        # Auto-force compatibility between plink1.9 and plink2.0 chr codes
        String output_chr = "26"

        Float hwe_pvalue = 0.0
        String? hwe_mode
        Boolean filter_females = false
        Boolean nonfounders = false
        Array[String]? chrs
        String chrs_prefix = if(defined(chrs)) then "--chr" else ""

        File? keep_samples
        File? remove_samples

        String docker_image = "rtibiocloud/plink:v2.0_888cf13"
        String ecr_image = "rtibiocloud/plink:v2.0_888cf13"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 1
        Int mem_gb = 2
        Int max_retries = 3

    }

    command <<<
        set -e
        mkdir plink_input

        # Bed file preprocessing
        if [[ ~{bed_in} =~ \.gz$ ]]; then
            # Append gz tag to let plink know its gzipped input
            unpigz -p ~{cpu} -c ~{bed_in} > plink_input/~{input_prefix}.bed
        else
            # Otherwise just create softlink with normal
            ln -s ~{bed_in} plink_input/~{input_prefix}.bed
        fi

        # Bim file preprocessing
        if [[ ~{bim_in} =~ \.gz$ ]]; then
            unpigz -p ~{cpu} -c ~{bim_in} > plink_input/~{input_prefix}.bim
        else
            ln -s ~{bim_in} plink_input/~{input_prefix}.bim
        fi

        # Fam file preprocessing
        if [[ ~{fam_in} =~ \.gz$ ]]; then
            unpigz -p ~{cpu} -c ~{fam_in} > plink_input/~{input_prefix}.fam
        else
            ln -s ~{fam_in} plink_input/~{input_prefix}.fam
        fi

        # Get expected heterozygosity for each sample
        plink2 --bfile plink_input/~{input_prefix} \
            --hardy \
            --threads ~{cpu} \
            --out ~{output_basename} \
            ~{if filter_females then '--keep-females' else ''} \
            ~{if nonfounders then '--nonfounders' else ''} \
            ~{chrs_prefix} ~{sep(', ', chrs)} \
            ~{'--keep ' + keep_samples} \
            ~{'--remove ' + remove_samples} \
            --output-chr ~{output_chr}


        # Filter chrX file if present
        if [ -f ~{output_basename}.hardy.x ];then
            perl -lane 'if(($. > 1) && ($F[13] < ~{hwe_pvalue})){print $F[1];};' ~{output_basename}.hardy.x > ~{output_basename}.remove
        fi

        # Filter auto hardy file if present
        if [ -f ~{output_basename}.hardy ];then
            perl -lane 'if(($. > 1) && ($F[9] < ~{hwe_pvalue})){print $F[1];};' ~{output_basename}.hardy >> ~{output_basename}.remove
        fi

        # Touch chrX and norm .hardy files so we can expect them both. One will probably be empty if you're subsetting by chr
        touch ~{output_basename}.hardy.x
        touch ~{output_basename}.hardy
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File remove = "~{output_basename}.remove"
        File hwe_report = "~{output_basename}.hardy"
        File hwe_chrX_report = "~{output_basename}.hardy.x"
    }
}

task recode_to_ped{

    input {

        File bed_in
        File bim_in
        File fam_in
        String output_basename
        String input_prefix = basename(sub(bed_in, "\\.gz$", ""), ".bed")

        String docker_image = "rtibiocloud/plink:v1.9-77ee25f"
        String ecr_image = "rtibiocloud/plink:v1.9-77ee25f"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 1
        Int mem_gb = 2
        Int max_retries = 3

    }

    command <<<
        set -e
        mkdir plink_input

       # Bed file preprocessing
        if [[ ~{bed_in} =~ \.gz$ ]]; then
            # Append gz tag to let plink know its gzipped input
            unpigz -p ~{cpu} -c ~{bed_in} > plink_input/~{input_prefix}.bed
        else
            # Otherwise just create softlink with normal
            ln -s ~{bed_in} plink_input/~{input_prefix}.bed
        fi

        # Bim file preprocessing
        if [[ ~{bim_in} =~ \.gz$ ]]; then
            unpigz -p ~{cpu} -c ~{bim_in} > plink_input/~{input_prefix}.bim
        else
            ln -s ~{bim_in} plink_input/~{input_prefix}.bim
        fi

        # Fam file preprocessing
        if [[ ~{fam_in} =~ \.gz$ ]]; then
            unpigz -p ~{cpu} -c ~{fam_in} > plink_input/~{input_prefix}.fam
        else
            ln -s ~{fam_in} plink_input/~{input_prefix}.fam
        fi

        # Get expected heterozygosity for each sample
        plink --bfile plink_input/~{input_prefix} \
            --recode \
            --out ~{output_basename}
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File ped_out = "~{output_basename}.ped"
        File map_out = "~{output_basename}.map"
        File log_file = "~{output_basename}.log"
    }
}

task convert_bgen_to_vcf {

    input {

        File bgen_in
        File sample_in
        String ref_alt_mode
        String vcf_dosage
        String output_basename
        String input_prefix = basename(sub(bgen_in, "\\.gz$", ""), ".bgen")
        File? keep
        File? remove
        File? extract
        File? exclude
        Boolean rm_dup = false
        String? rm_dup_mode

        String docker_image = "rtibiocloud/plink:v2.0_888cf13"
        String ecr_image = "rtibiocloud/plink:v2.0_888cf13"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu
        Int mem_gb
        Int max_retries = 3

    }

    command <<<
        set -e
        mkdir plink_input

       # Bgen file preprocessing
        if [[ ~{bgen_in} =~ \.gz$ ]]; then
            # Unzip
            unpigz -p ~{cpu} -c ~{bgen_in} > plink_input/~{input_prefix}.bgen
        else
            # Otherwise just create softlink with normal
            ln -s ~{bgen_in} plink_input/~{input_prefix}.bgen
        fi

        # Sample file preprocessing
        if [[ ~{sample_in} =~ \.gz$ ]]; then
            unpigz -p ~{cpu} -c ~{sample_in} > plink_input/~{input_prefix}.sample
        else
            ln -s ~{sample_in} plink_input/~{input_prefix}.sample
        fi

        # Convert
        plink2 \
            --bgen plink_input/~{input_prefix}.bgen ~{ref_alt_mode} \
            --sample plink_input/~{input_prefix}.sample \
            ~{'--keep ' + keep} \
            ~{'--remove ' + remove} \
            ~{'--extract ' + extract} \
            ~{'--exclude ' + exclude} \
            ~{if rm_dup then '--rm-dup ' else ''} ~{rm_dup_mode} \
            --export vcf bgz vcf-dosage=~{vcf_dosage} \
            --out ~{output_basename}
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File vcf_out = "~{output_basename}.vcf.gz"
        File log_file = "~{output_basename}.log"
    }
}

task make_founders{

    input {

        File fam_in
        String output_basename
        String input_prefix = basename(sub(fam_in, "\\.gz$", ""), ".fam")
        Boolean require_2_missing = true
        Boolean first = false

        String docker_image = "rtibiocloud/plink:v1.9-77ee25f"
        String ecr_image = "rtibiocloud/plink:v1.9-77ee25f"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 1
        Int mem_gb = 1
        Int max_retries = 3

    }

    command <<<
        set -e
        mkdir plink_input

        # Fam file preprocessing
        if [[ ~{fam_in} =~ \.gz$ ]]; then
            unpigz -p ~{cpu} -c ~{fam_in} > plink_input/~{input_prefix}.fam
        else
            ln -s ~{fam_in} plink_input/~{input_prefix}.fam
        fi

        # Get expected heterozygosity for each sample
        plink --fam plink_input/~{input_prefix}.fam \
            --make-just-fam \
            --make-founders ~{if require_2_missing then 'require-2-missing' else ''} ~{if first then 'first' else ''} \
            --out ~{output_basename}
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File fam_out = "~{output_basename}.fam"
    }
}

task convert_vcf_to_bed{

    input {

        File vcf_in
        String output_basename

        String docker_image = "rtibiocloud/plink:v2.0_888cf13"
        String ecr_image = "rtibiocloud/plink:v2.0_888cf13"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 1
        Int mem_gb = 2
        Int max_retries = 3
        Int threads = cpu

    }

    command <<<

        # Convert vcf to bed
        plink2 \
            --vcf ~{vcf_in} \
            --make-bed \
            --out ~{output_basename} \
            --threads ~{threads}
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File bed_out = "~{output_basename}.bed"
        File bim_out = "~{output_basename}.bim"
        File fam_out = "~{output_basename}.fam"
        File log_file = "~{output_basename}.log"
    }
}

task convert_bed_to_vcf{

    input {

        File bed_in
        File bim_in
        File fam_in
        String output_basename
        String input_prefix = basename(sub(bed_in, "\\.gz$", ""), ".bed")

        # Determine whether or not to bgzip output
        Boolean bgzip_output = true
        String output_filename = if(bgzip_output) then "~{output_basename}.vcf.gz" else "~{output_basename}.vcf"

        # Optionally subset by chr
        String? chr

        String docker_image = "rtibiocloud/plink:v1.9-77ee25f"
        String ecr_image = "rtibiocloud/plink:v1.9-77ee25f"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 1
        Int mem_gb = 2
        Int max_retries = 3

    }

    command <<<
        set -e
        mkdir plink_input

       # Bed file preprocessing
        if [[ ~{bed_in} =~ \.gz$ ]]; then
            # Append gz tag to let plink know its gzipped input
            unpigz -p ~{cpu} -c ~{bed_in} > plink_input/~{input_prefix}.bed
        else
            # Otherwise just create softlink with normal
            ln -s ~{bed_in} plink_input/~{input_prefix}.bed
        fi

        # Bim file preprocessing
        if [[ ~{bim_in} =~ \.gz$ ]]; then
            unpigz -p ~{cpu} -c ~{bim_in} > plink_input/~{input_prefix}.bim
        else
            ln -s ~{bim_in} plink_input/~{input_prefix}.bim
        fi

        # Fam file preprocessing
        if [[ ~{fam_in} =~ \.gz$ ]]; then
            unpigz -p ~{cpu} -c ~{fam_in} > plink_input/~{input_prefix}.fam
        else
            ln -s ~{fam_in} plink_input/~{input_prefix}.fam
        fi

        # Get expected heterozygosity for each sample
        plink --bfile plink_input/~{input_prefix} \
            --recode vcf ~{if bgzip_output then 'bgz' else ''} \
            ~{'--chr ' + chr} \
            --out ~{output_basename}
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File vcf_out = "~{output_filename}"
        File log_file = "~{output_basename}.log"
    }
}

task calculate_ld {

    input {

        # Input file parameters
        String input_format = "bed-bim-fam"
        File? bed
        File? bim
        File? fam
        File? vcf
        File? bgen
        File? sample
        Boolean allow_extra_chr = false

        # Output file parameters
        String output_basename
        String? output_format   # square, square0 triangle inter-chr
        Boolean with_freqs = false
        Boolean yes_really = false

        # Stat
        String? correlation_stat = "r2"

        # LD window parameters
        Int? ld_window
        Int? ld_window_kb
        Float? ld_window_r2

        # Reference SNP parameters
        String? ld_snp
        File? ld_snp_list

        # D prime parameters
        String? dprime  # d, dprime, dprime-signed

        # Filtering options
        File? keep
        File? remove

        String docker_image = "rtibiocloud/plink:v1.9-77ee25f"
        String ecr_image = "rtibiocloud/plink:v1.9-77ee25f"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 1
        Int mem_gb = 2
        Int max_retries = 3

    }

    command <<<
    
        set -e

        parameter_bed=$(echo ~{bed} | perl -ne 'if ("'~{input_format}'" eq "bed-bim-fam") { print "--bed $_"; } else { print ""; }')
        parameter_bim=$(echo ~{bim} | perl -ne 'if ("'~{input_format}'" eq "bed-bim-fam") { print "--bim $_"; } else { print ""; }')
        parameter_fam=$(echo ~{fam} | perl -ne 'if ("'~{input_format}'" eq "bed-bim-fam") { print "--fam $_"; } else { print ""; }')
        parameter_vcf=$(echo ~{vcf} | perl -ne 'if ("'~{input_format}'" eq "vcf") { print "--vcf $_"; } else { print ""; }')
        parameter_bgen=$(echo ~{bgen} | perl -ne 'if ("'~{input_format}'" eq "bgen") { print "--bgen $_"; } else { print ""; }')
        parameter_sample=$(echo ~{sample} | perl -ne 'if ("'~{input_format}'" eq "bgen") { print "--sample $_"; } else { print ""; }')

        plink \
            $parameter_bed \
            $parameter_bim \
            $parameter_fam \
            $parameter_vcf \
            $parameter_bgen \
            $parameter_sample \
            ~{if allow_extra_chr then '--allow-extra-chr' else ''} \
            ~{'--keep ' + keep} \
            ~{'--remove ' + remove} \
            --out ~{output_basename} \
            --~{correlation_stat} \
                ~{output_format} \
                gz \
                ~{dprime} \
                ~{if with_freqs then 'with-freqs' else ''} \
                ~{if yes_really then 'yes-really' else ''} \
            ~{'--ld-window ' + ld_window} \
            ~{'--ld-window-kb ' + ld_window_kb} \
            ~{'--ld-window-r2 ' + ld_window_r2} \
            ~{'--ld-snp-list ' + ld_snp_list}

    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File ld_file = "~{output_basename}.ld.gz"
        File log_file = "~{output_basename}.log"
    }

}

task convert_bgen_v1_2_to_v1_1 {

    input {

        File bgen_in
        File sample_in
        String ref_alt_mode
        String output_basename
        Boolean rm_dup = false
        String? rm_dup_mode
        File? keep
        File? remove

        String docker_image = "rtibiocloud/plink:v2.0_888cf13"
        String ecr_image = "rtibiocloud/plink:v2.0_888cf13"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu
        Int mem_gb
        Int max_retries = 3

    }

    command <<<
        set -e

        # Convert
        plink2 \
            --bgen ~{bgen_in} ~{ref_alt_mode} \
            --sample ~{sample_in} \
            ~{'--keep ' + keep} \
            ~{'--remove ' + remove} \
            ~{if rm_dup then '--rm-dup ' else ''} ~{rm_dup_mode} \
            --export bgen-1.1 \
            --out ~{output_basename}
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File bgen_out = "~{output_basename}.bgen"
        File sample_out = "~{output_basename}.sample"
        File log_file = "~{output_basename}.log"
    }
}
