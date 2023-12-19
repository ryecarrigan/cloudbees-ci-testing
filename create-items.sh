#!/usr/bin/env bash
output_dir="${CBCI_OUTPUT_FOLDER:-items}"

# Test whether authentication works
./auth.sh
if [[ $? != 0 ]]; then exit; fi

# Create items from each file in the output dir
for item in ${output_dir}/*.yaml; do
  echo -n "Creating items in $item: "
  curl -sS -X POST \
    -u "${JENKINS_USER_ID}:${JENKINS_API_TOKEN}" \
    -H "Content-Type:text/yaml" \
    -w "%{http_code}\n" \
    --data-binary @$item \
    "${JENKINS_URL}/casc-items/create-items"
done

echo "Done"
