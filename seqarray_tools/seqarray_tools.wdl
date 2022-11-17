task convert_seq_gds_to_vcf {
    File in_seq_gds
    String out_vcf
    File? seq_gds_variant_annot
    File? variant_ids
    String? variant_annot_xref_col
    String? variant_annot_gds_id_col
    File? seq_gds_sample_annot
    File? sample_ids
    String? sample_annot_xref_col
    String? sample_annot_gds_id_col
    Boolean compress = true

    # Runtime environment
    String docker = "rtibiocloud/seqarray_tools:v1.38_4456ec4"
    Int mem_gb = 16
    Int cpu = 4
    Int max_retries = 3

    String out_vcf_final = if(compress) then "${out_vcf}.gz" else out_vcf

    command{
        /opt/convert_seq_gds_to_vcf.R \
            --file-seq-gds ${in_seq_gds} \
            --file-vcf ${out_vcf} \
            ${'--file-gds-variant-annot ' + seq_gds_variant_annot} \
            ${'--file-variant-ids ' + variant_ids} \
            ${'--variant-annot-xref-col ' + variant_annot_xref_col} \
            ${'--variant-annot-gds-id-col ' + variant_annot_gds_id_col} \
            ${'--file-gds-sample-annot ' + seq_gds_sample_annot} \
            ${'--file-sample-ids ' + sample_ids} \
            ${'--sample-annot-xref-col ' + sample_annot_xref_col} \
            ${'--sample-annot-gds-id-col ' + sample_annot_gds_id_col}
    
        if [[ '${compress}' == 'true' ]];
        then
            gzip ${out_vcf}
        fi
    }

    runtime{
        docker: docker
        cpu: cpu
        memory: "${mem_gb} GB"
        maxRetries: max_retries
    }

    output {
        File output_vcf = "${out_vcf_final}"
    }
}
