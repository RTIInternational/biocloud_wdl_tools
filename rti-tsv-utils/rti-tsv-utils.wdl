task tsv_join{
    # TSV utility for subsetting tsv file based on ids in another file
    File left_file
    String left_on
    String? left_sep
    String? left_cols
    String? left_suffix
    Array[File] right_files
    String right_ons
    String? right_seps
    String? right_cols
    String? right_suffixes
    String? hows
    String out_prefix
    Boolean? sort
    Int? chunk_size

    # Runtime environment
    String docker = "rtibiocloud/rti-tsv-utils:v1_f55805a"
    Int cpu = 1
    Int mem_gb = 2
    Int max_retries = 3

    command <<<

        python /opt/rti-tsv-utils-join.py \
            --in-file-left ${left_file} \
            ${"--in-file-left-sep " + left_sep} \
            ${"--in-file-left-cols " + left_cols} \
            --left-on ${left_on} \
            ${"--left-suffix " + left_suffix} \
            --in-file-right ${sep=" " right_files} \
            ${"--in-file-right-sep " + right_seps} \
            ${"--in-file-right-cols " + right_cols} \
            --right_on ${right_ons} \
            ${"--right-suffix " + right_suffixes} \
            ${"--how " + hows} \
            --out-file-prefix ${out_prefix} \
            ${true="--sort" false="--no-sort" sort} \
            ${"--chunk-size " + chunk_size}

    >>>

    runtime {
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output{
        File out_tsv = "${out_prefix} + .tsv.gz"
        File out_log = "${out_prefix} + .log"
    }
}

