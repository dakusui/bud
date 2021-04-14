set -eu -o pipefail -o errtrace
shopt -s inherit_errexit nullglob compat"${BASH_COMPAT=42}"

trap abort ERR

function abort() {
  echo "ABORT: $?"
  exit 1
}

function func1() {
  return 1
}

function func2() {
  echo "$(func1)"
  # echo "THIS SHOULDN'T BE PRINTED(2): $?"
}


func2

echo "THIS SHOULDN'T BE PRINTED(0): $?"