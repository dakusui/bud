#!/usr/bin/env bash

set -eu -o pipefail -o errtrace
shopt -s inherit_errexit nullglob compat"${BASH_COMPAT=42}"

source "buildtools/utils.rc"
source "buildtools/build_info.rc"
source "buildtools/drivers.rc"

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
  if [[ ${1} == OSX ]]; then
    main doc package test_package
    return 0
  fi
  if [[ ${1} == PACKAGE ]]; then
    main doc test package test_package
    return 0
  fi
  if [[ ${1} == DEPLOY ]]; then
    main doc test package test_package deploy
    return 0
  elif [[ ${1} == RELEASE ]]; then
    main check_release doc test package_release test_release release post_release
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
