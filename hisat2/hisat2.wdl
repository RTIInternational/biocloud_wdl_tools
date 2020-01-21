task Hisat2_PE {
  File hisat2_ref
  File fastq_R1
  File fastq_R2
  Array[File]? unpaired_fastqs
  String ref_name
  String output_basename
  String sample_name

  # runtime values
  String docker = "quay.io/humancellatlas/secondary-analysis-hisat2:v0.2.2-2-2.1.0"
  Int mem_gb = 64
  Int cpu = 32
  Int max_retries = 5
  Int hisat_cpu = ceil(cpu/2)
  Int samtools_cpu = ceil(cpu/2)

  meta {
    description: "HISAT2 alignment task will align paired-end fastq reads to reference genome."
  }

  parameter_meta {
    hisat2_ref: "HISAT2 reference"
    fastq_R1: "gz forward fastq file"
    fastq_R2: "gz reverse fastq file"
    unpaired_fastqs: "(optional) unpaired gz fastq files"
    ref_name: "the basename of the index for the reference genome"
    output_basename: "basename used for output files"
    sample_name: "sample name of input"
    docker: "(optional) the docker image containing the runtime environment for this task"
    mem_gb: "(optional) the amount of memory (GiB) to provision for this task"
    cpu: "(optional) the number of cpus to provision for this task"
    disk: "(optional) the amount of disk space (GiB) to provision for this task"
    preemptible: "(optional) if non-zero, request a pre-emptible instance and allow for this number of preemptions before running the task on a non preemptible machine"
  }

  command {
    # Note that files MUST be gzipped or the module will not function properly
    # This will be addressed in the future either by a change in how Hisat2 functions or a more
    # robust test for compression type.

    set -e

    # fix names if necessary.
    if [ "${fastq_R1}" != *.fastq.gz ]; then
        FQ1=${fastq_R1}.fastq.gz
        mv ${fastq_R1} ${fastq_R1}.fastq.gz
    else
        FQ1=${fastq_R1}
    fi
    if [ "${fastq_R2}" != *.fastq.gz ]; then
        FQ2=${fastq_R2}.fastq.gz
        mv ${fastq_R2} ${fastq_R2}.fastq.gz
    else
        FQ2=${fastq_R2}
    fi

    tar --no-same-owner -xvf "${hisat2_ref}"

    # run HISAT2 to genome reference with dedault parameters
    # --seed to fix pseudo-random number and in order to produce deterministics results
    # --secondary reports secondary alignments for multimapping reads. -k 10
    # searches for up to 10 primary alignments for each read
    hisat2 -t \
      -x ${ref_name}/${ref_name} \
      -1 $FQ1 \
      -2 $FQ2 \
      ${true="-U " false='' defined(unpaired_fastqs)}${sep="," unpaired_fastqs} \
      --rg-id=${sample_name} --rg SM:${sample_name} --rg LB:${sample_name} \
      --rg PL:ILLUMINA --rg PU:${sample_name} \
      --new-summary --summary-file ${output_basename}.hisat2.log \
      --met-file ${output_basename}.hisat2.met.txt --met 5 \
      --seed 12345 \
      -k 10 \
      --secondary \
      -p ${hisat_cpu} | samtools sort -@ ${samtools_cpu} - > ${output_basename}.bam
    samtools index ${output_basename}.bam
  }

  runtime {
    docker: docker
    memory: "${mem_gb} GiB"
    cpu: cpu
    maxRetries: max_retries
  }

  output {
    File log_file = "${output_basename}.hisat2.log"
    File met_file = "${output_basename}.hisat2.met.txt"
    File output_bam = "${output_basename}.bam"
    File bam_index = "${output_basename}.bam.bai"
  }
}

task Hisat2_SE {
  File hisat2_ref
  Array[File]+ fastqs
  String ref_name
  String output_basename
  String sample_name

  # runtime values
  String docker = "quay.io/humancellatlas/secondary-analysis-hisat2:v0.2.2-2-2.1.0"
  Int mem_gb = 64
  Int cpu = 32
  Int max_retries = 3
  Int hisat_cpu = ceil(cpu/2)
  Int samtools_cpu = ceil(cpu/2)

  meta {
    description: "This HISAT2 alignment task will align single-end fastq reads to reference genome."
  }

  parameter_meta {
    hisat2_ref: "HISAT2 reference"
    fastqs: "one or more input fastqs from single ended data"
    ref_name: "the basename of the index for the reference genome"
    output_basename: "basename used for output files"
    sample_name: "sample name of input"
    docker: "(optional) the docker image containing the runtime environment for this task"
    mem_gb: "(optional) the amount of memory (MiB) to provision for this task"
    cpu: "(optional) the number of cpus to provision for this task"
    disk: "(optional) the amount of disk space (GiB) to provision for this task"
    preemptible: "(optional) if non-zero, request a pre-emptible instance and allow for this number of preemptions before running the task on a non preemptible machine"
  }

  command {
    set -e
    tar --no-same-owner -xvf "${hisat2_ref}"

    # The parameters for this task are copied from the HISAT2PairedEnd task.
    hisat2 -t \
      -x ${ref_name}/${ref_name} \
      -U ${sep=',' fastqs} \
      --rg-id=${sample_name} --rg SM:${sample_name} --rg LB:${sample_name} \
      --rg PL:ILLUMINA --rg PU:${sample_name} \
      --new-summary --summary-file "${output_basename}.hisat2.log" \
      --met-file ${output_basename}.hisat2.met.txt --met 5 \
      --seed 12345 \
      -k 10 \
      --secondary \
      -p ${hisat_cpu} | samtools sort -@ ${samtools_cpu} - > ${output_basename}.bam
    samtools index ${output_basename}.bam
  }

  runtime {
    docker: docker
    memory: "${mem_gb} GiB"
    cpu: cpu
    maxRetries: max_retries

  }

  output {
    File log_file ="${output_basename}.hisat2.log"
    File met_file ="${output_basename}.hisat2.met.txt"
    File output_bam = "${output_basename}.bam"
    File bam_index = "${output_basename}.bam.bai"
  }
}
