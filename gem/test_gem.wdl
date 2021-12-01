import "biocloud_wdl_tools/gem/gem.wdl" as GEM

workflow test_gem{
    call GEM.gem
    output{
        Array[File] outputs = gem.output
    }
}