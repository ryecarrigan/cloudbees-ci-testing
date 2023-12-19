#!/usr/bin/env bash
delay=${CBCI_TRIGGER_INTERVAL:-60}
folder_count="${CBCI_FOLDER_COUNT:-50}"
jobs_per_folder="${CBCI_JOBS_PER_FOLDER:-100}"
total_time=${CBCI_TEST_TIME_IN_SECONDS:-14400}

# Test whether authentication works
./auth.sh
if [[ $? != 0 ]]; then exit; fi

while (( SECONDS < total_time )); do
  job_name=$(printf "folder%03d/job/pipeline%03d\n" $((1 + RANDOM % $folder_count)) $((1 + RANDOM % $jobs_per_folder)))
  echo -n "Scheduling job: ${job_name} "
  rsp=$(curl -sS -X POST -w "%{http_code}" -o /dev/null -u ${JENKINS_USER_ID}:${JENKINS_API_TOKEN} ${JENKINS_URL}/job/${job_name}/build)
  if [[ $rsp == 201 ]]; then
    echo "OK  ($rsp) [$SECONDS/$total_time]"
  else
    echo "N/A ($rsp)"
  fi

  sleep $delay

done
