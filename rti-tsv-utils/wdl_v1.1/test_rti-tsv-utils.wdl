version 1.1

import "rti-tsv-utils.wdl" as TSV_UTILS

workflow test_append{

    Array[File] input_files
    String output_prefix
    Int header_row_count = 1

    # Runtime attributes
    Int cpu = 1
    Int mem_gb = 2

    call TSV_UTILS.tsv_append as append {
        input:
            input_files = input_files,
            output_prefix = output_prefix,
            header_row_count = header_row_count
    }

    output{
        File out_tsv = append.out_tsv
    }
}


