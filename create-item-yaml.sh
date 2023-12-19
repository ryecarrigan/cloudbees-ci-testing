#!/usr/bin/env bash
################################################################################
# Script to create CasC item YAMLs
# * Create a test Pipeline called "pipeline.groovy"
# * (Optional) Set CBCI_FOLDER_COUNT and/or CBCI_JOBS_PER_FOLDER
#
# After running this script you will have CasC YAML files in the output dir.
################################################################################

folder_count="${CBCI_FOLDER_COUNT:-50}"
jobs_per_folder="${CBCI_JOBS_PER_FOLDER:-100}"
output_dir="${CBCI_OUTPUT_FOLDER:-items}"

if [[ ! -f pipeline.groovy ]]; then
  echo "Please create the test pipeline at pipeline.groovy"
  exit 1
fi

mkdir -p $output_dir
pipeline_contents=$(awk '{ print "          " $0 }' pipeline.groovy)
for f in $(seq -f "%03g" $folder_count); do
  folder_name="folder${f}"
  folder_file="${output_dir}/${folder_name}.yaml"

  cat > ${folder_file} <<EOF
removeStrategy:
  items: NONE
  rbac: SYNC

items:
- kind: folder
  name: ${folder_name}
  items:
EOF

  for j in $(seq -f "%03g" $jobs_per_folder); do
    pipeline_name="pipeline${j}"
  cat >> ${folder_file} <<EOF
  - kind: pipeline
    name: ${pipeline_name}
    definition:
      cpsFlowDefinition:
        sandbox: true
        script: |
${pipeline_contents}
EOF
  done
done
