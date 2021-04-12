#!/usr/bin/env bash

set -eu -o pipefail -o errtrace
shopt -s inherit_errexit nullglob compat"${BASH_COMPAT=42}"

source "$(dirname "${BASH_SOURCE[0]}")/buildtools/utils.rc"
source "$(dirname "${BASH_SOURCE[0]}")/buildtools/build_info.rc"
source "$(dirname "${BASH_SOURCE[0]}")/buildtools/drivers.rc"
source "$(dirname "${BASH_SOURCE[0]}")/buildtools/jq-front.rc"

function execute_stage() {
  local _stage="${1}"
  shift
  message "EXECUTING:${_stage}..."
  {
    "execute_${_stage}" "$@" && message "DONE:${_stage}"
  } || {
    message "FAILED:${_stage}"
    return 1
  }
  return 0
}

function main() {
  if [[ $# == 0 ]]; then
    main doc test
    return 0
  fi
  if [[ ${1} == DOC ]]; then
    main clean prepare doc
    return 0
  fi

  local -a _stages=()
  _stages+=("$@")
  for i in "${_stages[@]}"; do
    local _args
    IFS=':' read -r -a _args <<<"${i}"
    execute_stage "${_args[@]}" || exit 1
  done
}

main "${@}"
