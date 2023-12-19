#!/usr/bin/env sh

# Ensure the variables are set
if [[ -z "${JENKINS_USER_ID}" || -z "${JENKINS_API_TOKEN}" || -z "${JENKINS_URL}" ]]; then
  echo "Please ensure that JENKINS_USER_ID, JENKINS_API_TOKEN, and JENKINS_URL are set!"
  exit 1
fi

# Test whether authentication works
authenticated=$(curl -sS -X GET \
    -u "${JENKINS_USER_ID}:${JENKINS_API_TOKEN}" \
    "${JENKINS_URL}/whoAmI/api/json?tree=authenticated")
if [[ "$authenticated" = '{"_class":"hudson.security.WhoAmI","authenticated":true}' ]]; then
  echo "Authentication OK"
else
  echo "Error! Unable to authenticate:\n${authenticated}"
  exit 1
fi
