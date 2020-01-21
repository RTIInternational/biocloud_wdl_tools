import "rnaseq-pipeline/tools/dexseq.wdl" as DEXSEQ

workflow test_dexseq{
    File bam
    File bam_index
    File gtf
    Boolean paired_end
    Boolean stranded
    Boolean bam_sorted_by_pos = true
    Boolean is_bam = true
    Int min_qual = 20
    Int? cpu
    Int? mem_gb
    String output_basename = "Derp"

    call DEXSEQ.Dexseq_prepare_annotation as flatten_gtf{
        input:
            gtf = gtf
     }

    call DEXSEQ.Dexseq_count{
        input:
            bam = bam,
            bam_index = bam_index,
            flattened_gff = flatten_gtf.flattened_gff,
            paired_end = paired_end,
            stranded = stranded,
            output_basename = output_basename,
            bam_sorted_by_pos = bam_sorted_by_pos,
            is_bam = is_bam,
            min_qual = min_qual,
            cpu = cpu,
            mem_gb = mem_gb
     }

    output{
        File exon_count_file = Dexseq_count.exon_count_file
    }
}