#!/usr/bin/env bash

SCRIPT_PATH="$(realpath "$0")"
PROJECT_DIR="$(dirname "${SCRIPT_PATH}")"
CMD_DIR="${PROJECT_DIR}/cmd"



(cd "${CMD_DIR}" || exit; go build)
mv "${CMD_DIR}/cmd" "${PROJECT_DIR}/shuttle"

echo ". OK"
exit 0
