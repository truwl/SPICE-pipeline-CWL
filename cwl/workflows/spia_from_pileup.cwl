cwlVersion: v1.1
class: Workflow

doc: |-
  Runs SPIA to calculate the genotype distance between normal and tumor samples
  starting from the pilueps of the SNPs.

requirements:
  SchemaDefRequirement:
    types:
      - $import: "../types/spia_output_map.yaml"
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  MultipleInputFeatureRequirement: {}

inputs:
  snps_pileup_normal:
    doc: The file containing the pileup of the SNPs of the normal sample.
    type: File
  snps_pileup_tumor:
    doc: The file containing the pileup of the SNPs of the tumor sample.
    type: File
  snps_list_file:
    doc: |-
      The file with the SNPs that are used by SPIA to compute the genotype
      distance.
    type: File
  sample_name:
    doc: The name of the sample that is passed in input.
    type: string?
  plot_filename:
    doc: |-
      The name of the file that will contain the SPIA plot. The report will be
      generated only when this parameter is provided.
    type: string?
  log_to_file:
    doc: |-
      If true, the output generated by each tool will be redirected to a file.
      Otherwise the output will be printed on the output.
    type: boolean
    default: true

outputs:
  output:
    doc: The output directory generated by SPIA.
    type: Directory?
    outputSource: spia/output
  output_map:
    doc: |-
      A data structure that will allow easy access to the various outputs
      produced by SPIA.
    type: out_map:spia_output_map?
    outputSource: spia/output_map
  log_files:
    doc: |-
      The log file, if enabled, that captures the output produced by each tool.
    type: File[]?
    outputSource:
      - pileup_to_genotype_normal/log_file
      - pileup_to_genotype_tumor/log_file
      - spia/log_file

steps:
  pileup_to_genotype_normal:
    doc: |-
      Extracts the genotypes of the SNPs used by SPIA from the pileup of the
      normal sample.
    run: ../tools/pileup_to_genotype.cwl
    in:
      snps_pileup: snps_pileup_normal
      snps_list_file: snps_list_file
      sample_name: sample_name
      output_filename:
        default: "genotype_normal.vcf"
      log_filename:
        default: "pileup_to_genotype_spia_normal.log"
      log_to_file: log_to_file
    out:
      - output
      - log_file
  pileup_to_genotype_tumor:
    doc: |-
      Extracts the genotypes of the SNPs used by SPIA from the pileup of the
      tumor sample.
    run: ../tools/pileup_to_genotype.cwl
    in:
      snps_pileup: snps_pileup_tumor
      snps_list_file: snps_list_file
      sample_name: sample_name
      output_filename:
        default: "genotype_tumor.vcf"
      log_filename:
        default: "pileup_to_genotype_spia_tumor.log"
      log_to_file: log_to_file
    out:
      - output
      - log_file
  spia:
    doc: Computes the genotype distance between normal and tumor samples.
    run: ../tools/spia.cwl
    in:
      genotype_vcf_files:
        source:
          - pileup_to_genotype_normal/output
          - pileup_to_genotype_tumor/output
        linkMerge: merge_flattened
      plot_filename: plot_filename
      log_to_file: log_to_file
    out:
      - output
      - output_map
      - log_file

$namespaces:
  out_map: "../types/spia_output_map.yaml#"