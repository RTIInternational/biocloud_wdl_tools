import "biocloud_wdl_tools/structure/structure.wdl" as STRUCT

workflow test_struct_params{

    String derp

    call STRUCT.make_structure_param_files{
        input:
            markernames = 0,
            pop_flag = 1,
            use_pop_info = 1,
            burnin = 100000,
            numreps = 20000000
    }

    output{
        File mainparams = make_structure_param_files.mainparams_out
        File extraparams = make_structure_param_files.extraparams_out
    }
}