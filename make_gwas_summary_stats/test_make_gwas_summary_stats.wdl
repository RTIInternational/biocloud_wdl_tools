import "biocloud_wdl_tools/make_gwas_summary_stats/make_gwas_summary_stats.wdl" as SUMSTAT

workflow test_make_gwas_summary_stats{
    File rvtests_sumstats_file
    File pop_maf_file
    File info_file
    File info_file_gz

    call SUMSTAT.make_gwas_summary_stats as anno_sumstats_eur{
        input:
            file_in_summary_stats = rvtests_sumstats_file,
            file_in_info = info_file,
            file_in_pop_mafs = pop_maf_file,
            file_in_summary_stats_format = "rvtests",
            population = 'EUR',
            file_out_prefix = "test_chr22_sumstats_eur"
    }

    call SUMSTAT.make_gwas_summary_stats as anno_sumstats_info_gz{
        input:
            file_in_summary_stats = rvtests_sumstats_file,
            file_in_info = info_file_gz,
            file_in_pop_mafs = pop_maf_file,
            file_in_summary_stats_format = "rvtests",
            population = 'EUR',
            file_out_prefix = "test_chr22_sumstats_gz"
    }

    output{
        File eur_annotated_sumstats = anno_sumstats_eur.output_file
        File info_gz_annotated_sumstats = anno_sumstats_info_gz.output_file
    }
}