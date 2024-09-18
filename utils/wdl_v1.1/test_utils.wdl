version 1.1

import "utils.wdl" as UTILS

workflow test_utils {

    input {
        File input_file
        String output_filename
    }

    call UTILS.rename_file {
        input:
            input_file = input_file,
            output_filename = output_filename
    }

    output {
        File output_file = rename_file.output_file
    }

}
