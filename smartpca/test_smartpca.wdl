import "biocloud_gwas_workflows/biocloud_wdl_tools/smartpca/smartpca.wdl" as SMARTPCA

workflow test_smartpca {
    File genotypename
    File snpname
    File indivname
    String output_basename
    Array[String] poplist

    call SMARTPCA.smartpca as smartpca{
        input:
            genotypename = genotypename,
            snpname = snpname,
            indivname = indivname,
            output_basename = output_basename,
            poplist = poplist
    }

    output{
        File evec = smartpca.evec
        File eval = smartpca.eval
        File snpweight = smartpca.snpweight
        File log = smartpca.log
    }
}
