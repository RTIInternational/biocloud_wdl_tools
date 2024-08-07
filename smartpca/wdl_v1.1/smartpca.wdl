version 1.1

task smartpca{

    input {

        File genotypename
        File snpname
        File indivname
        String output_basename
        String altnormstyle = "YES"
        Int numoutevec = 10
        Int numoutlieriter = 5
        Array[String] poplist
        Int numthreads = 8

        # Runtime environment
        String docker_image = "rtibiocloud/eigensoft:v6.1.4_2d0f99b"
        String ecr_image = "rtibiocloud/eigensoft:v6.1.4_2d0f99b"
        String? ecr_repo
        String image_source = "docker"
        String container_image = if(image_source == "docker") then docker_image else "~{ecr_repo}/~{ecr_image}"
        Int cpu = 8
        Int mem_gb = 16

    }

    command <<<

        set -e

        # Create parameter file
        echo "genotypename: ~{genotypename}" > par.txt
        echo "snpname: ~{snpname}" >> par.txt
        echo "indivname: ~{indivname}" >> par.txt
        echo "poplistname: ~{write_lines(poplist)}" >> par.txt
        echo "evecoutname: ~{output_basename}.evec" >> par.txt
        echo "evaloutname: ~{output_basename}.eval" >> par.txt
        echo "snpweightoutname: ~{output_basename}.snpweight" >> par.txt
        echo "altnormstyle: ~{altnormstyle}" >> par.txt
        echo "numoutevec: ~{numoutevec}" >> par.txt
        echo "numoutlieriter: ~{numoutlieriter}" >> par.txt
        echo "numthreads: ~{numthreads}" >> par.txt

        cat par.txt

        smartpca -p par.txt > ~{output_basename}.log
    >>>

    runtime {
        docker: container_image
        cpu: cpu
        memory: "~{mem_gb} GB"
    }

    output {
        File evec = "~{output_basename}.evec"
        File eval = "~{output_basename}.eval"
        File snpweight = "~{output_basename}.snpweight"
        File log = "~{output_basename}.log"
    }
}
