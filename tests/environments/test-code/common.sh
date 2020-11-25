#!/bin/bash
set -e # exit on any failure
set -o pipefail # any step in pipe caused failure
set -u # undefined variables cause exit


# ensure the working dir is the repo root
SCRIPT_DIR=$(realpath $(dirname "$0"))
REPO_ROOT=$SCRIPT_DIR/../../..
cd $REPO_ROOT
GCR_PATH=gcr.io/sanche-testing-project/logging:latest

build_container() {
  docker build -t $GCR_PATH --file $SCRIPT_DIR/Dockerfile $REPO_ROOT
  docker push $GCR_PATH
}

logs() {
  local OFFSET="${1:-10}"
  echo "resource filter: \"$(filter-string)\""
  echo "printing from last $OFFSET mins..."
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ"  --date "-$OFFSET min")
  gcloud logging read "$(filter-string) AND timestamp > \"$TIMESTAMP\""
}


ACTION=$1
if [[ "$(type -t $ACTION)" == "function" ]]; then
  shift
  echo $ACTION $@
  $ACTION $@
else
  echo $ACTION not valid command
  exit 1
fi