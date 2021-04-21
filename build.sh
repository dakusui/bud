#!/usr/bin/env bash

set -eu -o pipefail -o errtrace
shopt -s inherit_errexit nullglob # compat"${BASH_COMPAT=42}"

source "$(dirname "${BASH_SOURCE[0]}")/buildtools/utils.rc"
source "$(dirname "${BASH_SOURCE[0]}")/buildtools/build_info.rc"
source "$(dirname "${BASH_SOURCE[0]}")/buildtools/jq-front.rc"

__execute_stage_driver_filename=
__execute_stage_stage_name=
function __execute_stage() {
  local _stage="${1}"
  shift
  message "EXECUTING:${_stage}..."
  {
    __execute_stage_driver_filename="$(dirname "${BASH_SOURCE[0]}")/buildtools/drivers/${_stage}.rc"
    __execute_stage_stage_name="${_stage}"
    function execute_stage() {
      abort "The driver: '${__execute_stage_driver_filename}' does not define a function 'execute_stage'"
    }
    function stage_name() {
      abort "The driver: '${__execute_stage_driver_filename}' does not define a function 'stage_name'"
    }
    # shellcheck disable=SC1090
    source "${__execute_stage_driver_filename}"
    function stage_name() {
      echo "'${__execute_stage_stage_name}'"
    }
    "execute_stage" "$@" && message "DONE:${_stage}"
  } || {
    message "FAILED:${_stage}"
    return 1
  }
  return 0
}

function main() {
  if [[ $# == 0 ]]; then
    main clean prepare doc test-compile test
    return 0
  fi
  if [[ ${1} == DOC ]]; then
    main clean prepare doc
    return 0
  fi
  if [[ ${1} == TEST ]]; then
    main clean prepare test
    return 0
  fi
  if [[ ${1} == COVERAGE ]]; then
    main clean prepare coverage
    return 0
  fi

  local -a _stages=()
  _stages+=("$@")
  for i in "${_stages[@]}"; do
    local _args
    IFS=':' read -r -a _args <<<"${i}"
    __execute_stage "${_args[@]}" || exit 1
  done
}

main "${@}"
