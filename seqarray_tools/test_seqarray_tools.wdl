import "seqarray_tools.wdl" as SEQARRAY

workflow test_seqarray_tools{

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
    Boolean? compress = true

    # Runtime attributes
    Int cpu = 1
    Int mem_gb = 4

    call SEQARRAY.convert_seq_gds_to_vcf as convert_seq_gds_to_vcf {
        input:
            in_seq_gds = in_seq_gds,
            out_vcf = out_vcf,
            seq_gds_variant_annot = seq_gds_variant_annot,
            variant_ids = variant_ids,
            variant_annot_xref_col = variant_annot_xref_col,
            variant_annot_gds_id_col = variant_annot_gds_id_col,
            seq_gds_sample_annot = seq_gds_sample_annot,
            sample_ids = sample_ids,
            sample_annot_xref_col = sample_annot_xref_col,
            sample_annot_gds_id_col = sample_annot_gds_id_col,
            cpu = cpu,
            mem_gb = mem_gb
    }

    output{
        File output_vcf = convert_seq_gds_to_vcf.output_vcf
    }
}

