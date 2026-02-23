#!/bin/bash

source ./.env

echo "deploying obsidian..."

export PUID=$(id -u)
export PGID=$(id -g)
export NAMESPACE=obsidian

# Create namespace
if ! kubectl get namespace "${NAMESPACE}" --no-headers --output=name > /dev/null 2>&1; then
  kubectl create ns ${NAMESPACE}
fi

if [[ -z "${OBSIDIAN_HOST}" ]]; then
  read -p "Enter the obsidian host: " OBSIDIAN_HOST
  export OBSIDIAN_HOST=${OBSIDIAN_HOST}
  echo "OBSIDIAN_HOST=${OBSIDIAN_HOST}" >> .env
fi

# replace the variables in the obsidian.install.yaml
envsubst < obsidian/obsidian.install.yaml | kubectl -n ${NAMESPACE} apply -f -

echo "obsidian deployed successfully"