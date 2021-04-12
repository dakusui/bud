#!/usr/local/bin/bash
set -eu -o pipefail -E
shopt -s inherit_errexit

function func1() {
  # local arg="${1}"
  echo "(func1)This line shouldn't be reached:arg='${1}': '${?}'" >&2
}

function func2() {
  echo "value from func2"
  exit 1
}

var="$(func1 "$(func2)")" # The Line
echo "main:This line shouldn't be reached:var='${var}':'${?}'" >&2