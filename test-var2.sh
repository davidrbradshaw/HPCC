#!/bin/bash

inputFile=${OHPC_INPUT_LOCAL_VAR:-/opt/ohpc/pub/doc/recipes/centos7/input-var2.local}

if [ ! -e ${inputFile} ];then
  echo "Error: Unable to access local input file -> ${inputFile}"
  exit 1
else
  . ${inputFile} || { echo "Error sourcing ${inputFile}"; exit 1; }
fi

echo "testing:"
echo "$var"
