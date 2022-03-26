import "biocloud_wdl_tools/rti-tsv-utils/rti-tsv-utils.wdl" as SORT

workflow test_sort{

    File in_file
    String cols
    String out_prefix
    String? in_file_sep
    Boolean? ascending

    # Runtime attributes
    Int cpu = 1
    Int mem_gb = 2

    call SORT.tsv_sort as sort {
        input:
            in_file = in_file,
            cols = cols,
            out_prefix = out_prefix,
            in_file_sep = in_file_sep,
            ascending = ascending,
            mem_gb = mem_gb
    }

    output{
        File out_tsv = sort.out_tsv
        File out_log = sort.out_log
    }
}

