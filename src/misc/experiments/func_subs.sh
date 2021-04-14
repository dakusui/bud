#!/usr/bin/env bash

set -eu -o pipefail -o errtrace
shopt -s inherit_errexit nullglob compat"${BASH_COMPAT=42}"

function func_test() {
    echo "func_name: ${func_name}: ${1}!"
    func_name="!!!${func_name}!!!"
    return 1
}

function abort() {
  echo "ABORTED!!!"
  exit 1
}
trap abort ERR

# func_name="func_test"
# func_name="notFound"
func_name="cat"
var=""

# var="$("${func_name}" "hello")"
# echo "$("${func_name}" "hello")"
# cat < <("${func_name}" "hello")
# ${func_name}" "hello"
# func_test "hello" &

sleep 1
echo "func_name: ${func_name}"

echo "!!! THIS SHOULDN'T REACH !!!: $var"