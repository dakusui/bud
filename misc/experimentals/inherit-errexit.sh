set -eu -o pipefail -o errtrace
shopt -s inherit_errexit nullglob compat"${BASH_COMPAT=42}"

function  f() {
    return 1
}

function g() {
  local _ret
  _ret="$(f)"
  echo ${_ret}
}

function h() {
  local _ret
  echo "$(g)"
  # echo ${_ret}
}

trap "echo BYE" ERR
# echo "f"
# f
# echo "g"
# g
# echo "h"
# h
h
#cat -n <(f)