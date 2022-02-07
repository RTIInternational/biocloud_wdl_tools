import "biocloud_wdl_tools/metal-i/metal-i.wdl" as METAL

workflow test_metal_i{

    File metal_command_file
    Array[File] sum_stats_files
    String output_file

    call METAL.metal_i as metal_i {
        input:
            metal_command_file = metal_command_file,
            sum_stats_files = sum_stats_files,
            output_file = output_file
    }

    output{
        File metal_results = metal_i.metal_results
    }
}

