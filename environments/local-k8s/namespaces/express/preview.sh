#!/bin/bash

# Check if namespace exists
if ! kubectl get namespace "${NAMESPACE}" --no-headers --output=name > /dev/null 2>&1; then
  echo "Namespace ${NAMESPACE} does not exist"
  exit 1
fi

# preview diff between current and new deployment and print to stdout
diff=$(envsubst < ${REPO_DIR}/yaml/express.yaml | kubectl -n ${NAMESPACE} diff -f -)

# print diff to stdout or if diff is empty, print "No changes"
if [ -z "$diff" ]; then
  echo "⚠️ No changes to deploy"
else
  echo "$diff"
fi
