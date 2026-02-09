#!/bin/bash

cd ${REPO_DIR}

if [ ! -d "node_modules" ]; then
  npm install
fi

echo "123123"