import "biocloud_wdl_tools/fastqc/fastqc.wdl" as FASTQC

workflow test_fastqc{
    File fastq
    call FASTQC.FastQC{
        input:
            fastq = fastq
     }

    output{
        File html_report = FastQC.html_report
        File test_report = FastQC.text_report
    }
}